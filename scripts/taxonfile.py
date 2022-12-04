import shelve
import json

with open('taxon/br08610.json') as f:
	tax = json.load(f)

def get_lineage(tree, current = []):
    if "children" in tree:
        for child in tree["children"]:
            if isinstance(child, dict):
                yield from get_lineage(child, current+[tree["name"]])
            elif isinstance(child, list):
                for i in child:
                    yield from get_lineage(i, current+[tree["name"]])
    else:
        code = tree["name"].split()[0]
        yield [code]+current+[tree["name"]]

eukaryota = list(get_lineage(tax['children'][0]))
bacteria = list(get_lineage(tax['children'][1]))
archaea = list(get_lineage(tax['children'][2]))

my_dict = {lineage[0]: "; ".join(lineage[1:]) for lineage in eukaryota+bacteria+archaea}

myShelvedDict = shelve.open("taxon/taxonomic_lineages.db")
myShelvedDict.update(my_dict)
