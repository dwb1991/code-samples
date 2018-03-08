def generate_form():
	print "Content-type:text/html\r\n\r\n"
	print "<html>"
	print "<head>"
	print "<title>Gene/Keyword finder</title>"
	print "</head>"
	print "<body>"
	print "<h2> Please type a Gene Name or Keyword. </h2>"
	print "<p> Typing in a keyword will search for related genes. Typing in a specific gene name will yield experimental results. </p>"
	print "<form action=\"bfinal_dwb284.cgi\" method=\"post\">"
	print "Gene: <input type=\"text\" name=\"gene\"><br>" #Gene entry form
	print "Keyword: <input type = \"text\" name=\"keyword\"><br>" #keyword entry form
	print "<input type=\"submit\" value=\"Enter\">"
	print "</form>"
	print "</body>"
	print "</html>"

	return