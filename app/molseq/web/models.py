from django.db import models
from django.db.models import JSONField
import requests
from pygbif import occurrences
from wikidataintegrator import wdi_core
import pandas as pd
import numpy as np


class MatchingRun(models.Model):
    ena_query = models.CharField(max_length=500)
    ena_results = JSONField(null=True, blank=True)
    gbif_query = JSONField()
    gbif_results = JSONField(null=True, blank=True)
    wikidata_results = JSONField(null=True, blank=True)
    created = models.DateField(auto_now_add=True)

    def save(self):
        # If we do it this way, need to add some way of handling validation if genbank_query or gbif_query are badly formatted
        if not self.ena_results:
            self.ena_results = self.get_ena_results()
        if not self.gbif_results:
            self.gbif_results = self.get_gbif_results()

        ena_df = pd.DataFrame.from_dict(self.ena_results)
        self.wikidata_results = self.get_wikidata_results(ena_df['tax_id'].unique())
        # I guess we can do some kind of automated matching here, before the super
        super(MatchingRun, self).save()

    def get_ena_results(self):
        base_url = "https://www.ebi.ac.uk/ena/portal/api/"
        all_sequence_return_fields = "accession,study_accession,sample_accession,tax_id,scientific_name,base_count,bio_material,cell_line,cell_type,collected_by,collection_date,country,cultivar,culture_collection,dataclass,description,dev_stage,ecotype,environmental_sample,first_public,germline,host,identified_by,isolate,isolation_source,keywords,lab_host,last_updated,location,mating_type,mol_type,organelle,serotype,serovar,sex,submitted_sex,specimen_voucher,strain,sub_species,sub_strain,tax_division,tissue_lib,tissue_type,topology,variety,altitude,haplotype,plasmid,sequence_md5,sequence_version,sequence_version"

        params_d = {
            "result": "sequence",
            "fields": all_sequence_return_fields,
            "format": "json",
            "limit": 0
        }

        search_r = requests.get(f"{base_url}search?query={self.ena_query}", params=params_d)
        print(search_r.status_code)
        print(search_r)
        print('^^^^ status code')
        return search_r.json()

    def get_gbif_results(self):
        return occurrences.search(**self.gbif_query)['results']

    def get_wikidata_results(self, tax_ids):
        query_template = """
                SELECT ?taxon ?taxonLabel ?ncbi_taxonID ?gbifid WHERE {
                  VALUES ?ncbi_taxonID {%s}
                  ?taxon wdt:P685 ?ncbi_taxonID.
                  OPTIONAL {?taxon wdt:P846 ?gbifid .}
                  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
                }
                """
        results = {}
        for tax_ids_subset in np.array_split(tax_ids, 30):
            query = query_template % ('"' + '" "'.join(tax_ids_subset.tolist()) + '"')
            try:
                result_df = wdi_core.WDFunctionsEngine.execute_sparql_query(query=query, as_dataframe=True)
                if results == {}:
                    results = result_df
                else:
                    results.append(result_df)
            except Exception as e:
                print(e)
        return results.replace(np.nan, '').to_dict()
