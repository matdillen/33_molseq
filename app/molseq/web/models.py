from django.db import models
from django.db.models import JSONField
import requests

class MatchingRun(models.Model):
    genbank_query = models.CharField(max_length=500)
    genbank_results = JSONField()
    gbif_query = models.CharField(max_length=500)
    gbif_results = JSONField()
    created = models.DateField(auto_now_add=True)

    def save(self):

