#Establish a connection
B_dwb284.sqlite <- dbConnect(RSQLite::SQLite(), "B_dwb284.sqlite")
drv<-dbDriver(drvName="SQLite")
con<-dbConnect(drv, "B_dwb284.sqlite")

#Create tables statements
dbSendQuery(conn=con, 'CREATE TABLE Experiment (
    expid   INTEGER     PRIMARY KEY autoincrement NOT NULL UNIQUE ,
    expname VARCHAR (20)
);'
)

dbSendQuery(conn=con, 'CREATE TABLE Probes (
    probeid   INTEGER          PRIMARY KEY autoincrement,
    probename VARCHAR (20) 
);'
)

dbSendQuery(conn=con, 'CREATE TABLE Data (
    dataid   INTEGER     PRIMARY KEY autoincrement,
    expid    INTEGER     REFERENCES Experiment (expid),
    probeid  INTEGER     REFERENCES Probe (probeid),
    expvalue NUMERIC
);'
)

#Used a for loop to insert an incrementally increasing key combined with the list of experiment names
for(i in 1:ncol(expvalues)) {
insert_statement = paste("INSERT INTO Experiment ( expname)
VALUES (\"",expnames[i],"\")", sep="")
dbSendQuery(con, insert_statement)

#A for loop to combine an incrementally increasing key with each probe name. There are 263 probe names in total, the number of rows in the original file.
for(i in 1:nrow(expvalues)) {
insert_statement = paste("INSERT INTO Probes (probename)
VALUES (\"",rownames(expvalues)[i],"\")", sep="")
dbSendQuery(con, insert_statement)
}

#To add the data to the data table I did a nested for loop to iterate over the row and then the column
for(i in 1:nrow(expvalues)){
  for (j in 1:ncol(expvalues)){
insert_statement = paste("INSERT INTO Data (expid, probeid, expvalue)
VALUES (\"",
j,"\",\"",
i,"\",\"",
expvalues[i,j],"\")", sep="")
dbSendQuery(con, insert_statement)

#To find the average values, I grouped by probe ID. There are 263 results - each probeID has its average across all experiments.
avg_values <- dbGetQuery(con, "SELECT Probes.probename, AVG(expvalue) as Avgxpression from data JOIN Probes ON data.probeid = Probes.probeid GROUP BY Probes.probename")