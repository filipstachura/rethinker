##Automatic generation of commCodes constant in reql.R

readLines('terms')->terms;

#Parse and split
terms<-gsub(',','',terms);
strsplit(terms,split=': ')->terms;
sapply(terms,'[',1)->textual;
as.numeric(sapply(terms,'[',2))->codes;

textual<-tolower(textual);
for(e in 1:length(letters))
 textual<-gsub(sprintf("_%s",letters[e]),LETTERS[e],textual);

#Print commCodes
cat(sprintf("commCodes<-c(%s);",paste(sprintf("%s=%s",textual,codes),collapse=',')))
