#!/usr/bin/perl
# This will search the health check page archive for the total number of audits by service over the past x days.
# Note that no distinction is made between "Successful" audits and "Failure" audits,
# and the total count may include both successful and failure audits. 
# ARG1 = search for audits in health check page archive with mtime less than this many days
# ARG2 = limit the number of policies to return per environment

$daysAgo = $ARGV[0];
$limit = $ARGV[1];

chomp($daysAgo);
chomp($limit);

# environments
%dev = {};
%qa = {};
%prod = {};
%ext = {};

# gather the files for each environment less than $daysAgo days old
# grep for the audit table and pass to addToHash to tally the counts
foreach $file (`find /var/www/html/data/archive/* -mtime -$daysAgo`){
	chomp($file);
	$i=0;
	foreach $auditTable (`cat "$file"|grep "audit_level"`){
		if($i==0){addToHash($auditTable,\%dev);$i++;}
		elsif($i==1){addToHash($auditTable,\%qa);$i++;}
		elsif($i==2){addToHash($auditTable,\%prod);$i++;}
		elsif($i==3){addToHash($auditTable,\%ext);$i++;}
	}
}

print "Dev ";
print "-" x 100;print "\n";
printHash(\%dev); print "\n";
print "QA ";
print "-" x 100;print "\n";
printHash(\%qa); print "\n";
print "Prod ";
print "-" x 100;print "\n";
printHash(\%prod); print "\n";
print "Ext "; 
print "-" x 100;print "\n";
printHash(\%ext); print "\n";


###########################################
#
# printHash
#
# format the hash and print the key/value pairs
#
# ARG1 - the hash to print
#
###########################################
sub printHash{
	my $tmpHash = $_[0];
	$i=0;
	foreach my $name (sort { $tmpHash->{$b} <=> $tmpHash->{$a} } keys %$tmpHash) {
		if($name =~ /HASH/){next;}
		print "$name has " . $tmpHash->{$name}." audits in the past $daysAgo days\n";
		$i++;
		if($i >= $limit){return;}
	}
}
		
##########################################
#
# addToHash
#
# parse the audit table and add the policy counts to the
# previously found values, if not found, add to the hash
#
# ARG1 - audit table extracted from health check page
# ARG2 - hash to modify
#
##########################################
sub addToHash{
	my $buf = shift;
	my $tmpHash = $_[0];
	@tmpArray = split(/\<\/TR\>/,$buf);
	foreach $tableRow (@tmpArray){
		if($tableRow =~ /\<TR onMouseOver\=\"this\.bgColor\=\'lightgrey\'\" onMouseOut\=\"this.bgColor\=\'white\'\"\>\<TD\>(.*)\<\/TD\>\<TD\>WARNING\<\/TD\>\<TD\>(.*)\<\/TD\>\<TD\>(.*)\<\/TD\>/){
			if( exists $tmpHash->{$1} ) { $tmpHash->{$1} = $tmpHash->{$1} + $3;}
			else{$tmpHash->{$1} = $3;}
		}
	}


}

