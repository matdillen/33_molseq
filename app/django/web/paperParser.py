import re
from pdfminer.high_level import extract_text
import nltk
from nltk.tokenize import RegexpTokenizer

class paperParser():
    def __init__(self,pdf_path:str):
        self.pdf_path = pdf_path
        self.tokenizer = RegexpTokenizer(r'\w+')

    # SET
    def set_tokenizer_pattern(self,pattern:str):
        self.tokenizer = RegexpTokenizer(rf'{pattern}')

    # METHODS
    def extract_text(self):
        self.text = extract_text(self.pdf_path)

    def tokenize(self):
        self.token = self.tokenizer.tokenize(self.text)
        self.token = list(set(self.token))

    def sent_tokenize(self):
        self,sent_token = nltk.sent_tokenize(self.text)
    
    

    