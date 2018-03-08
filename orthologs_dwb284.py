



import sys
from Bio.Blast import NCBIXML
if len(sys.argv) !=4:
    print ("Error, wrong number of arguments")
#command line arguments 1, 2 and 3 as indicated in midterm question
file1 = sys.argv[1] 
file2 = sys.argv[2]
outfile= sys.argv[3]
"""In command line, input is <this file> <xml document 1> <xml document 2> <target txt file>"""
"""output: putitative orthologs between the two species in target txt file"""
#parse for BLAST on first file, using dictionary
with open (sys.argv[1]) as br1:
    blast_record_1=NCBIXML.parse(br1)
    D1={}
    E_VALUE_THRESH = 1e-20
    for blast_record in blast_record_1:
        for alignment in blast_record.alignments:
            for hsp in alignment.hsps:
                if hsp.expect < E_VALUE_THRESH:#making sure the e value is less than 1e-20
                    D1[hsp.match]=alignment.hit_def #the protein is added as a key to a dict with its matching sequence as a value.

#second xml parse for result, same as above
with open (sys.argv[2]) as br2:
    blast_record_2 = NCBIXML.parse(br2)
    D2={}
    E_VALUE_THRESH = 1e-20#ignores everything larger than 1e-20
    for blast_record in blast_record_2:
        for alignment in blast_record.alignments:
            for hsp in alignment.hsps:
                if hsp.expect < E_VALUE_THRESH: #making sure the e value is less than 1e-20
                    D2[hsp.match]=alignment.hit_def #the protein is added as a key to a dict with its matching sequence as a value.
outfile = open(sys.argv[3],'w')
for k in set(D1.keys()) & set(D2.keys()):#orthologous pairs need to be chosen, using dictionary comparison between values (hsp.match sequences)
    x = (D1[k],"\t",D2[k])
    print >>outfile, x#writes the keys (the names of the proteins) into the file
outfile.close()






