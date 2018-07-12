<?php

// frontend to the get-audit-count-by-service.pl search tool

if($_GET['submit']==1){
        $daysAgo = $_POST["daysAgo"];
        $limit = $_POST["limit"];

	if(is_numeric($daysAgo) && $daysAgo < 10000 && $daysAgo >= 1){}
	else{print "Error: could not understand days ago value";exit;}

	if(is_numeric($limit) && $limit < 10000 && $limit >= 1){}
	else{print "Error: could not understand limit value";exit;}

	$v = `/usr/local/zabbix/create-audit-count-by-service.pl $daysAgo $limit`;
	print "<PRE>$v</PRE>";
	exit;
}
else{

?>

<H2>Audit Count Search Tool</H2>
This will search the health check page archive for the total number of audits by service over the past x days.  Note that no distinction is made between "Successful" audits and "Failure" audits, and the total count may include both successful and failure audits.<BR><BR>
<form action="https://clfloapv0020.wdw.disney.com/data/archive/auditCountSearch.php?submit=1" method="post">
Please enter number of days ago to search: <INPUT TYPE="text" name="daysAgo"></INPUT><BR>
Please enter a limit for the number of policies to return per environment: <INPUT TYPE="text" name="limit"></INPUT><BR>
<INPUT TYPE="submit" name="Submit">


<?php } ?>
