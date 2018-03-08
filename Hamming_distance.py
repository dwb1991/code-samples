#code to solve rosalind problem for calculating hamming distance
with open('rosalind_HAMM.txt') as f:
	s = f.readline().strip()
	t = f.readline().strip()
	if len(s) != len(t):
		print "both DNA fragments must be the same length"
	else:
		lengthlist=[] #use empty list
		for i in range(len(s)): #loop over the length of one fragment (should be equal)
			if s[i] is not t[i]: #compare each position to the other string
		 		lengthlist.append(i) #add a random number to the empty list
		print len(lengthlist)# the length of the list is the total number of mismatches

		
