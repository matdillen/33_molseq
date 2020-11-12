from django.db import models
from django.db.models import JSONField
import requests
from pygbif import occurrences
from wikidataintegrator import wdi_core
import pandas as pd
import numpy as np


class ENAtoGBIF:
    """
    input: ena_query, ena_accession (list)
    output: ena2gbif (dict)
    """
    all_sequence_return_fields = "accession,study_accession,sample_accession,tax_id,scientific_name,base_count,bio_material,cell_line,cell_type,collected_by,collection_date,country,cultivar,culture_collection,dataclass,description,dev_stage,ecotype,environmental_sample,first_public,germline,host,identified_by,isolate,isolation_source,keywords,lab_host,last_updated,location,mating_type,mol_type,organelle,serotype,serovar,sex,submitted_sex,specimen_voucher,strain,sub_species,sub_strain,tax_division,tissue_lib,tissue_type,topology,variety,altitude,haplotype,plasmid,sequence_md5,sequence_version,sequence_version"
    base_url = "https://www.ebi.ac.uk/ena/portal/api/"
    ena_accession = None
    ena_query = None

    def __init__(self,ena_accession:list,ena_query:str):
        self.ena_accession = ena_accession  # accession candidates (i.e. from user/ PaperParser)
        self.ena_query = ena_query  # more flexible search "specimen_voucher=\"*BR)*\"", this will be placed directly in the api query string
        if not self.ena_accession == None or self.ena_query == None:
            raise Exception("Only accept either one of these: ena_accession, ena_query. Not both.")

    def get_ena_results(self):
        params_d = {
            "result": "sequence",
            "fields": self.all_sequence_return_fields,
            "format": "json",
            "limit": 0
        }
        
        # construct query strong from list of ena_accession
        if ena_accession:
            for i,a in enumerate(ena_accession):
                if i == 1:
                    ena_accession = f"accession=\"{a}\""
                    continue
                else:
                    ena_accession += f"+OR+accession=\"{a}\""

        search_r = requests.get(f"{self.base_url}search?query={self.ena_query}", params=params_d)
        print(search_r.status_code)
        results = search_r.json()
        # Change this to {'AF123': {'sex': '', 'host': '', 'tax_id': '84861'....}, 'AF456': {'sex': 'm', 'host': '', ...
        return {r['accession']: r for r in results}

    def get_gbif_results(self):
        results = occurrences.search(**self.gbif_query)['results']
        return {r['gbifID']: r for r in results}

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
        for tax_ids_subset in np.array_split(list(tax_ids), 30):
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