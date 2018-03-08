#Section I parses through GFF file input
##################################################################################################################################

import pysam
gene_start_list = []
gene_end_list = []
chromosome_number_list=[]
with open('athaliana.gff') as f:
	for line in f:
		gff_entry = line.split('\t')
		if 'gene' in gff_entry[2]: #only picks up lines with "gene" in column 3.
			gene_start = gff_entry[3]
			gene_end = gff_entry[4]
			chromosome_number=str(gff_entry[0])
			gene_name = gff_entry[8]
			gene_start_list.append(gff_entry[3])
			gene_end_list.append(gene_end)	
			chromosome_number_list.append(chromosome_number)
gene_start_list = map(int, gene_start_list) #list of start points of genes from GFF file
gene_end_list = map(int,gene_end_list) #list of end points of genes from GFF file
chromosome_number_list = map(str,chromosome_number_list) #list that can be looped over for range of chromosomes

#Section II makes a tab delimited printout of the gene identity and the counts associated with it using pysam.
##################################################################################################################################

pysam.index("athaliana.bam") #file needs to be indexed
samfile = pysam.AlignmentFile("athaliana.bam", "rb") #opens BAM file reader with pysam
for i in range(len(gene_start_list)): #loop through results to count
    bam_count = samfile.count(chromosome_number_list[i], start=int(gene_start_list[i]),end=int(gene_end_list[i])) #counts for each gene
    print gene_name, "\t", bam_count #prints the gene, a tab, and the read count of the gene.
