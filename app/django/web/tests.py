from django.test import TestCase
from .paperParser import paperParser
from .ena import ENAtoGBIF

# Create your tests here.

# test paperParser
sample_pdf = "static/252-Texto del artículo-603-2-10-20170418.pdf"
p = paperParser(pdf_path=sample_pdf)
accession_ls = p.auto_parse()

# test ena
m = ENAtoGBIF(ena_accession=accession_ls)
m.get_ena_results()



