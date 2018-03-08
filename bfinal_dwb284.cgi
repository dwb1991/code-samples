#!/usr/bin/python 
import cgi
import cgitb
import sqlite3
import os.path
import csv
cgitb.enable()



#Section I creates database (if it does not exist already) that corresponds to the displays, using sqlite3
##############################################################################################
def create_db():

	if os.path.isfile('final_dwb284.db') == False: #if the databse does not exist yet
		conn = sqlite3.connect('final_dwb284.db')
		cursor = conn.cursor()
		cursor.execute("CREATE TABLE GeneTable(Model TEXT, Type TEXT, Short_description TEXT)") #creates GeneTable table
		with open ('GeneTable','r') as input_file_1:
			reader1 = csv.reader(input_file_1,delimiter='\t')
			data1 = [row for row in reader1]
		cursor.executemany("INSERT INTO GeneTable (Model, Type, Short_description) VALUES (?,?,?);", data1) #inserts data into Genetable
		cursor.execute("CREATE TABLE CuffDiff(test_id TEXT, gene TEXT, locus TEXT, sample_1 TEXT, sample_2 TEXT, status TEXT, value_1 INT, value_2 INT, lnfold_change INT, test_stat INT, p_value INT, significant TEXT)") #creates CuffDiff table
		with open ('gene_exp.diff','r') as input_file_2:
			reader2 = csv.reader(input_file_2,delimiter='\t')
			data2 = [row for row in reader2]
		cursor.executemany("INSERT INTO CuffDiff(test_id, gene, locus, sample_1, sample_2, status, value_1, value_2, lnfold_change, test_stat, p_value, significant) VALUES (?,?,?,?,?,?,?,?,?,?,?,?);", data2) #inserts data into CuffDiff table
		conn.commit()
	else:
		pass	

	return

#Section II is the html code for the clickable form for the data entry
################################################################################################
def generate_form():
	
	
	print "<html>"
	print "<head>"
	print "<title>Gene/Keyword finder</title>"
	print "</head>"
	print "<body>"
	print "<h2> Please type a Gene Name or Keyword. </h2>"
	print "<p> Typing in a keyword will search for related genes. Typing in a specific gene name will yield experimental results. </p>"
	print "<form action=\"bfinal_dwb284.cgi\" method=\"get\">"
	print "Gene: <input type=\"text\" name=\"gene\"><br>" #Gene entry form
	print "Keyword: <input type = \"text\" name=\"keyword\"><br>" #keyword entry form
	print "<input type=\"submit\" value=\"Enter\">"
	print "</form>"
	print "</body>"
	print "</html>"
	
	return	

#section III selects the data from the table depending on the keyword entered into the HTML form.
#################################################################################################
def respond1(keyword): #display 1
	try:
		conn = sqlite3.connect('final_dwb284.db') #open database
		cursor = conn.cursor()
		cursor.execute("SELECT * from GeneTable where Model LIKE ? OR Type LIKE ? Or Short_description LIKE ?", (keyword, keyword, keyword,)) #selects all results from GeneTable
		results1 = cursor.fetchall() #fetch all results
		results1_list_a = [[str(item) for item in results] for results in results1]
		results1_list = [val for sublist in results1_list_a for val in sublist]#list had to be flattened to find each data point
		conn.commit()
		print "<html>"
		print "<head>"
		print "<title>Display 1 Results</title>"
		print "</head>"
		print "<body>"
		print "<p>GeneTable Results [Display 1]</p>"
		print "<table>"
		print "<tr>"
		print "<th>Model</th>"
		print "<th>Type</th>"
		print "<th>Description</th>"
		print "</tr>"
		
		for i in range(0,100,3):#displays only the first ~100 results for ease of search
			print "<tr>" 
			print "<td><a href=/~dwb284/cgi-bin/bfinal_dwb284.cgi?gene=%s&keyword=>%s</a></td>" % (results1_list[i], results1_list[i])
			print "<td>%s</td>" % (results1_list[i+1])
			print "<td>%s</td>" % (results1_list[i+2])
			print "</tr>"
		print "</table>"
		print "</body>"
		print "</html>"#prints the results, clickable 
	except ValueError:
		print "Error: unable to find gene"
	except IndexError: #caused by gene not in database, usually
		print "Error: no results found."

	return

def respond2(gene):	#display 2
	try:
		conn = sqlite3.connect('final_dwb284.db')
		cursor = conn.cursor()
 		cursor.execute("SELECT all * from CuffDiff WHERE test_id LIKE ?", (gene,))
 		results2 = cursor.fetchall() #fetch result (only one)
 		results2_list_a = [[str(item) for item in results] for results in results2]
 		results2_list = [val for sublist in results2_list_a for val in sublist]#list had to be flattened in order to target each data point
 		conn.commit()
		
		print "<html>"
		print "<head>"
		print "<title>Display 2 Results</title>"
		print "</head>"
		print "<body>"
		print "<p> CuffDiff Experimental Results [Display 2] </p>"
		print "<table>"
		print "<tr>"
		print "<th>GeneID</th>"
		print "<th>gene</th>"
		print "<th>locus</th>"
		print "<th>sample 1</th>" 
		print "<th>sample 2</th>"
		print "<th>status</th>"
		print "<th>value 1</th>" 
		print "<th>value 2</th>"
		print "<th>ln(fold_change)</th>"
		print "<th>test_stat</th>" 
		print "<th>p_value</th>"
		print "<th>significant?</th>"
		print "</tr>"
		print "<tr>"
		print "<td>%s</td>" % results2_list[0]
		print "<td>%s</td>" % results2_list[1]
		print "<td>%s</td>" % results2_list[2]
		print "<td>%s</td>" % results2_list[3]
		print "<td>%s</td>" % results2_list[4]
		print "<td>%s</td>" % results2_list[5]
		print "<td>%s</td>" % results2_list[6]
		print "<td>%s</td>" % results2_list[7]
		print "<td>%s</td>" % results2_list[8]
		print "<td>%s</td>" % results2_list[9]
		print "<td>%s</td>" % results2_list[10]
		print "<td>%s</td>" % results2_list[11]
		print "</tr>"
		print "</table>"
		print "</body>"
		print "</html>"
	except ValueError:
 		print 'Error: unable to get value.' #error message if no values show up.
 	except IndexError: # likely caused by a gene not being typed correctly
 		print 'Error: No results found.'

 	return

# define main function, which will run when the cgi script is run.
def main():
	create_db()
	args = cgi.FieldStorage()
	keyword = args.getvalue('keyword')
	gene = args.getvalue('gene')
	cgitb.enable()
	if gene:
		respond2(gene)
	elif keyword:
		respond1(keyword)
	else:
		generate_form()

	return

if __name__=="__main__":
    # Required header that tells the browser how to render the HTML.print "Content-type:text/html\r\n\r\n"
    # Call main function.
    main()



