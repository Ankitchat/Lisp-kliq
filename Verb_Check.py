import urllib.request
import sys
import redis


class Verb:

    def __init__(self):
        self.add_dict = {}

    checklist = ["Present", "Past", "Preterite", "Future"]

    def Verb_get(self, word):
        check = 0
        verb_url = "http://conjugator.reverso.net/conjugation-english-verb-" + \
            word + ".html"
        page = urllib.request.urlopen(verb_url)
        for line in page:
            if check == 1:
                if any(True for x in self.checklist if x in str(line)):
                    if "color:#003EAD" in str(line):
                        toadd = str(line).split("<i>")[1].split("</i")[0]
                        toshow = str(line).split(
                            "color:#003EAD\">")[1].split("</i")[0]
                        toadd = self.removeop(toadd)
                        if "Preterite" in str(line):
                            toadd = "Past"
                        if toadd not in self.add_dict.keys():
                            self.add_dict[toadd] = toshow
            if "responsive-sub" in str(line):
                check = 1

    def removeop(self, sentence):
        mean = ''
        m = 0
        if ">" in sentence or "<" in sentence:
            for c in sentence:
                if c is ">":
                    m = m + 1
                if m == 1:
                    if c is "<":
                        m = 0
                    mean = mean + c
            mean = mean.replace("<", '').replace(">", '')
        else:
            mean = sentence
        return mean

    def Verb_Check(self, word):
        r = redis.StrictRedis(host='localhost', port=6379, db=0)
        if self.Check_It(word) == "verb":
            self.Verb_get(word)
            r.set('CheckAns', 'verb')
        else:
            r.set('CheckAns', self.Check_It(word))

    def Check_It(self, word):
        try:
            verb_url = "http://www.oxfordlearnersdictionaries.com/definition/english/" + \
                word
            page = urllib.request.urlopen(verb_url)
        except:
            return "noun"
        else:
            for line in page:
                if "<span class=\"pos\">" in str(line):
                    English_word = str(line).split(
                        "<span class=\"pos\">")[1].split("</span>")[0]
                    return English_word


ob = Verb()
ob.Verb_Check(sys.argv[1].lower())
