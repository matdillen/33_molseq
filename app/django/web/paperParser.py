import re
from pdfminer.high_level import extract_text
import nltk
from nltk.tokenize import RegexpTokenizer


# FIXME: #download nltk resource at app initialization
# nltk.download('popular') # download nltk resource

class paperParser:
    # potential patterns of accessions
    grep_accession = re.compile(r"^[A-Z]+\d+")  #  anything like an acession
    grep_numbers = re.compile(r"^\d{5,}$")  # 5 or more digits, to avoid matching year
    tokenizer = RegexpTokenizer(r'\w+')
    
    def __init__(self,pdf_path:str):
        self.pdf_path = pdf_path

    # SET
    def set_tokenizer_pattern(self,pattern:str):
        self.tokenizer = RegexpTokenizer(rf'{pattern}')

    # METHODS
    def extract_text(self):
        self.text = extract_text(self.pdf_path)

    def tokenize(self):
        """
        tokenize and sentence tokenize
        """
        self.token = self.tokenizer.tokenize(self.text)
        self.token = list(set(self.token))
        self.sent_token = nltk.sent_tokenize(self.text)

    def search_accession_org(self,label_to_look_for:str="ORGANIZATION"):
        """
        Search accession source using part of speech.
        """
        # filter sentences with keyword 'accession'
        accession_sent = []
        sent_text = nltk.sent_tokenize(self.sent_token)
        for s in sent_text:
            if re.search("accession",s):
                print(s)
                accession_sent.append(s)
        # pos tag and entities analysis
        for s in accession_sent:
            tokens = nltk.word_tokenize(s)
            tagged = nltk.pos_tag(tokens)
            entities = nltk.chunk.ne_chunk(tagged)
        # TODO: error handling if entities is None
        self.accession_org = []
        for i,e in enumerate(entities):
            if type(e) is not tuple: # not a simple POS
                if e.label() == label_to_look_for:
                    org_name = ""
                    for token in e:
                        org_name += f" {token[0]}"
                    self.accession_org.append(org_name.strip())

    def grep_accession(self):
        self.accession_candidates = []
        for i in self.token:
            if self.grep_accession.search(i):
                self.accession_candidates.append(i)
        for i in self.token:
            if self.grep_numbers.search(i):
                self.accession_candidates.append(i)
    
    def auto_parse(self):
        self.extract_text()
        self.tokenize()
        self.search_accession_org()
        self.grep_accession()