#open bed file
import sys
import re


"""INPUT: bed file, fasta file
    OUTPUT: transcribed RNA fasta, translated protein if flag True"""

f=open(sys.argv[1])
lines = f.read()
realstart=re.findall('[^0-9][^0-9][^0-9]\t\d{6}',lines) #finds start region of chromosome
realstart1=''.join(realstart)
realstart2=realstart1.replace('hrX\t',' ')
realstart3 = map(int,realstart2.split())
realstart4=[x+1 for x in realstart3]
realstart5=map(int,realstart4) #list of start region coordinates
realend = re.findall('\d{6}\tu',lines) #finds end region of chromosome
realend1=''.join(realend)
realend2=realend1.replace('\tu',' ')
realend3=map(int,realend2.split()) #list of end region coordinates
linenumber=lines.count('\n')+1
codingregionlengthlist = [x-y for x,y in zip(realend3,realstart3)] #end minus start, the slice of the coding region
f.close()
g = open(sys.argv[1])
for line in g:
    blockstart=line.split()[11]#exon starts
    blockend=line.split()[10]#exon lengths
    blockstartlist=blockstart.split(",")
    del blockstartlist[-1]#ordered column/list of exon starts
    blockstartlist1 = map(int, blockstartlist) #first coordinate for exon slice
    blockendlist=blockend.split(",")
    del blockendlist[-1]#ordered list of lenghths of exon
    blockendlist1 = map(int,blockendlist)
    exonnumber = len(blockstartlist)
    blockrealend = [int(x)+int(y) for x,y in zip(blockstartlist,blockendlist)]#second coordinate for exon slice
    mask=[]
    exonlist=zip(blockstartlist1,blockrealend)

    D1=dict(zip(blockstartlist1, blockrealend))
    for i in codingregionlengthlist:
        mask.append([False]*i)#creates a list of False of length of coding sequence
#unmask exons
for k in D1.keys():
    #mask(k,D1[k])
    exons = []
    for i in blockrealend:
        exons.append([True]*i)
#replace exons in mask with True. To do this I want to find the exon position. The slice of blockstart1 to blockrealend would give the length of each exon.
    #open input fasta
    #open the file and store the entire file as string in content
with open(sys.argv[2], 'r') as seqline:
    content = seqline.read()
    #separate each fasta file using >
    allsequences = content.split(">")
    #get rid of first line
    sequences = [ seq[1:] for seq in allsequences[1:] ]
    #get rid of newline characters and join using empty string
    eachsequence = [ "".join(seq.split("\n")[1:]) for seq in sequences ]
    eachsequence1= ''.join(eachsequence)
    codingregion1 = eachsequence1[realstart5[0]:realend3[0]]
    codingregion2 = eachsequence1[realstart5[1]:realend3[1]]
    codingregion3 = eachsequence1[realstart5[2]:realend3[2]]
    codingregion4 = eachsequence1[realstart5[3]:realend3[3]]
    codingregion5 = eachsequence1[realstart5[4]:realend3[4]]
    codingregion6 = eachsequence1[realstart5[5]:realend3[5]]
    codingregion7 = eachsequence1[realstart5[6]:realend3[6]]
    codingregion8 = eachsequence1[realstart5[7]:realend3[7]]
    codingregion9 = eachsequence1[realstart5[8]:realend3[8]]
    codingregion10 = eachsequence1[realstart5[9]:realend3[9]]
    codingregion11= eachsequence1[realstart5[10]:realend3[10]]
    codingregion12=  eachsequence1[realstart5[11]:realend3[11]]
    codingregion13 = eachsequence1[realstart5[12]:realend3[12]]
    codingregion14 = eachsequence1[realstart5[13]:realend3[13]]
    codingregion15 = eachsequence1[realstart5[14]:realend3[14]]
    codingregion16 = eachsequence1[realstart5[15]:realend3[15]]
    codingregion17 = eachsequence1[realstart5[16]:realend3[16]]
    codingregion18 = eachsequence1[realstart5[17]:realend3[17]]
    codingregion19 = eachsequence1[realstart5[18]:realend3[18]]
    codingregion20 = eachsequence1[realstart5[19]:realend3[19]]
    
    mrna1=codingregion1[0:73]+codingregion1[5160:5363]+codingregion1[7845:7993]+codingregion1[12411:12548]+codingregion1[14326:14455]+codingregion1[15177:1533]+codingregion1[16713:16897]+codingregion1[22775:27032]
    exons = mrna1.upper()

    # where it is true on mask, this is the exons. This must be written to file
#output to file
with open (sys.argv[3],'w') as f:
    f.write(exons)
#output to file (protein)
def validate_sequence(sequence, RnaFLAG=False):
    '''INPUT: a sequence string
        OUTPUT: confirmation if it is a valid DNA or RNA seq
        '''
    if (RnaFLAG):
        return len(sequence) == (sequence.count('U')+sequence.count('C')+sequence.count('G')+sequence.count('A'))
    else:
        return len(sequence) == (sequence.count('T')+sequence.count('C')+sequence.count('G')+sequence.count('A'))


def get_translation(sequence, revCompFlag=False):
    '''INPUT1: sequence in a string
        INPUT2: whether the sequence needs to reverse complemented
        OUTPUT: string of amino acids using amino acid mapping.
        '''
    
    #dictionary of rna codons mapping to AA
    aminoacids = {
    'ATA':'I', 'ATC':'I', 'ATT':'I', 'ATG':'M',
    'ACA':'T', 'ACC':'T', 'ACG':'T', 'ACT':'T',
    'AAC':'N', 'AAT':'N', 'AAA':'K', 'AAG':'K',
    'AGC':'S', 'AGT':'S', 'AGA':'R', 'AGG':'R',
    'CTA':'L', 'CTC':'L', 'CTG':'L', 'CTT':'L',
    'CCA':'P', 'CCC':'P', 'CCG':'P', 'CCT':'P',
    'CAC':'H', 'CAT':'H', 'CAA':'Q', 'CAG':'Q',
    'CGA':'R', 'CGC':'R', 'CGG':'R', 'CGT':'R',
    'GTA':'V', 'GTC':'V', 'GTG':'V', 'GTT':'V',
    'GCA':'A', 'GCC':'A', 'GCG':'A', 'GCT':'A',
    'GAC':'D', 'GAT':'D', 'GAA':'E', 'GAG':'E',
    'GGA':'G', 'GGC':'G', 'GGG':'G', 'GGT':'G',
    'TCA':'S', 'TCC':'S', 'TCG':'S', 'TCT':'S',
    'TTC':'F', 'TTT':'F', 'TTA':'L', 'TTG':'L',
    'TAC':'Y', 'TAT':'Y', 'TAA':'_', 'TAG':'_',
    'TGC':'C', 'TGT':'C', 'TGA':'_', 'TGG':'W'}
    
    #if the reverse complement flag is TRUE, then get the reverse complement
    if (revCompFlag):
        sequence = get_reverse_complement(sequence)
    
    #we will need the sequence to be in RNA format to translate so let's first validate the sequence
    IsRNA = validate_sequence(sequence, True)
    #if it's not RNA then get the transcript


    if (len(sequence) % 3):
        print ('invalid sequence, your sequence is not in frame.')
        sys.exit(0)

    else:
        numCodons = len(sequence)/3
        
        #now get the protein sequence
        protein = [ aminoacids[sequence[i*3:i*3+3]] for i in range(numCodons) ]
        
        return ("".join(protein))

if sys.argv[4]:
    with open (sys.argv[5],'w') as g:
        g.write(get_translation(exons, revCompFlag=False))

