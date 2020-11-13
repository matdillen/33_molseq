from django.db import models
from django.db.models import JSONField
import requests
from pygbif import occurrences
from wikidataintegrator import wdi_core
import pandas as pd
import numpy as np
from .ena import ENAtoGBIF


class MatchingRun(models.Model):
    ena_query = models.CharField(max_length=500)
    ena_results = JSONField(null=True, blank=True)
    gbif_query = JSONField()
    gbif_results = JSONField(null=True, blank=True)
    wikidata_results = JSONField(null=True, blank=True)
    created = models.DateField(auto_now_add=True)

    # These two will contain a list like [{enaID1: [gbifID1, gbifID2}, {enaID2: [gbifID3]}]
    # obj.suggested_results = {'MH175419': ['2571204007', '2571204014', '2571204017']}
    # The validated_matches will be a data export for Francisco/nsidr.org
    validated_matches = models.JSONField(null=True, blank=True)
    suggested_matches = models.JSONField(null=True, blank=True)

    def save(self):
        # If we do it this way, need to add some way of handling validation if genbank_query or gbif_query are badly formatted
        if not self.ena_results:  # This is so that modifying db objects does not cause the query to get run  again
            #self.ena_results = self.get_ena_results()
            enaApi = ENAtoGBIF(ena_query=self.ena_query, gbif_query=self.gbif_query)
            self.ena_results = enaApi.get_ena_results()
        if not self.gbif_results:
            enaApi = ENAtoGBIF(ena_query=self.ena_query, gbif_query=self.gbif_query)
            self.gbif_results = enaApi.get_gbif_results()
        if not self.wikidata_results:
            enaApi = ENAtoGBIF(ena_query=self.ena_query, gbif_query=self.gbif_query)
            self.wikidata_results = enaApi.get_wikidata_results(set([t['tax_id'] for k, t in self.ena_results.items()]))
        # I guess we can do some kind of automated matching here, before the super
        super(MatchingRun, self).save()
