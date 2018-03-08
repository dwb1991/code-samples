#code for Rosalind problem to find GC content
from __future__ import division
def gc_content(seq):
#returns GC percentage of each DNA sequence
	len_total = len(seq)
	c = seq.count("C")
	g = seq.count("G")
	gc_total = g+c
	gc_content = (gc_total/len_total)*100
	return gc_content
#open file and store it as a string
with open('input.txt', 'r') as f: 
    content = f.read()
#separate each sequence with >
allsequences = content.split(">")
#remove first line
sequences = [seq[1:] for seq in allsequences[1:]]
#split newline characters and join as a new string
eachsequence = ["".join(seq.split("\n")[1:]) for seq in sequences]
#return list of sequences
#loop over each sequence, dividing the length of it by the count of G and C
numbers = [gc_content(i) for i in eachsequence]	
print numbers
print max(numbers)
