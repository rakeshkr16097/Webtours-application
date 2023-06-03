#!perl
# $Id: admin.pl,v 1.3 2007-05-08 15:40:15 adish Exp $ [MISCCSID]


#
# The Server Administration pages
#
# This script handles creating the server options for each IP address.
# The settings for each IP address are saved in the MTData directory, 
# as the IP address (with the .'s removed) suffixed with "so" (server option).
# When cookies are generated for new users (at the welcome page), their
# IP address is checked, the filename created, and the options loaded from the
# corresponding file.  The options are stored in a MSO cookie on the client's
# machine.  As the user navigates through the site, the MSO cookie is 
# constantly checked in order to generated the appropriate pages.
#
#

use CGI qw(:standard save);

require "systemPaths";

$query=new CGI;
 
# create the filename

$ip = remote_addr();
$filename = $ip;
$filename =~ s/\.//g;
$filename .=".so";
    
# Is the user requesting a save?

if ($query->param('save')) {
  doSave();
  $saved = 1;
}

# display the admin page

doAdminPage();

# 50 percent of the time, clean up is necessary.

if (rand(100) < 100) {	

	#cleanUp(3);
	
}


#########################################################################


# save the options in the file.

sub doSave() {
    chdir("MTData");
    open (ADMINFILE, ">$filename");
    $query->save(ADMINFILE);
    close ADMINFILE;
}

# load the options from the file.

sub loadAdminInfo {
    chdir("MTData");
    open (ADMINFILE, "<$filename") or return;
    $query = new CGI(ADMINFILE);
    close ADMINFILE;
}


#
# DIsplay the admin pages.
# All the options are stored in the adminOptions associative array - as pairs of
# (option name, option description).
# The entire list is displayed as a table with checkboxes.
#
  
sub doAdminPage {
	if ($saved != 1) {
		loadAdminInfo();
	}
 
  %adminOptions = (
	"MSO_JSCalc" =>
		"<SMALL><B>Add additional JavaScript that will calculate the days in advance for the ticket purchase.</B><BR/>It appears on the first Flight reservation page and will calculate the days in advance on the submission of the initial flight information form.</SMALL>",
	"MSO_JSFormSubmit1" =>
		"<SMALL><B>Set LOGIN form's action tag to an error page.</B><BR/>When the user submits the form, a javascript routine will re-set the action tag and alter the hidden field flag. The login.pl (what the action tag is reset to by javascript) script checks to make sure the hidden field flag has been set.</SMALL>",
	"MSO_JSFormSubmit2" =>
		"<SMALL><B>Set RESERVATION form's action tag to an error page.</B><BR/>When the user submits the form, a javascript routine will re-set the action tag and alter the hidden field flag. The reservation.pl (what the action tag is reset to by javascript) script checks to make sure the hidden field flag has been set.</SMALL>",
	"MSO_JSWPages" =>
		"<SMALL><B>Generate HTML code on the client side instead of server side.</B><BR/>In some cases, if there was some calculation done to create the HTML, there could problems discovering what the HTML actually is.Additionally, there is a form on this page...creating a bit of trouble when using web_submit_form.</SMALL>",
	"MSO_JSVerify" => 
		"<SMALL><B>Set cliend-side verfication of user data.</B><BR/>This turns on verification of the user data on the client side in the necessary spots during the reservation and signup processes.",
	"MSO_Comments" =>       
		"<SMALL><B>Add extra HTML form code to the page within HTML comments.</B><BR/>The extra HTML code is ignored by the browsers, but it could pose a problem for parsers.</SMALL>",
	"MSO_SLoad" =>   
		"<SMALL><B>Set probability (in percentages) of the server simulating a load problem.</B><BR/>Instead of the process crashing, an HTML page is generated that notifies the user of the problem. The user can choose to either try again (re-submit the same data over again) or to restart their reservation process.</SMALL>",
	"MSO_SErrors" =>
		"<SMALL><B>Set probability (in percentages) of the server making an illegal function call.</B><BR/>The CGI process then will crash, resulting in an 'Internal Server Error' generated by the Web server. This error provides no options for the user to continue with.</SMALL>",
	"MSO_Redirects" =>
		"<SMALL><B>Set this option to turn on some server side redirects.</B><BR/>Instead of a CGI script returning HTML to display, the CGI script returns a new URL for the browser to goto.</SMALL>",
	"MSO_Redirect" =>
		"<SMALL><B>Set redirects the user to a temporary .html file.</B><BR/>Instead of the CGI output going to the user, it is saved into a temporary .html file. The user is then redirected to that .html file, in order to see the results.</SMALL>",
   );
   
    printAdminHeader();
    if ($saved == 1) {
        print "<h3 align=\"center\">Server Reconfigured.</h3>";
    }

    print $query->startform('POST', "admin.pl"),
    	"<center><table border=\"0\" cellspacing=\"0\" width=\"80%\">\n";

	print "<tr><td colspan=\"2\" bgcolor=\"#5E7884\">&nbsp;";
        	
    foreach $key (sort keys %adminOptions) {
        print "<tr><td valign=\"top\" bgcolor=\"#EFF2F7\">",
        	$query->checkbox(-name=>$key, -label=>""),
        	"<td bgcolor=\"#EFF2F7\">$adminOptions{$key}\n";
        if ($key eq 'MSO_SLoad') {
        	print "<br/><SMALL>Frequency (in percent) for the server load problem: ",
        		$query->textfield(-name=>'MSO_ServerLoadProb', -value=>'50', -size=>2);
        }
        if ($key eq 'MSO_SErrors') {
        	print "<br/><SMALL>Frequency (in percent) for the server process error: ",
        		$query->textfield(-name=>'MSO_ServerErrorsProb', -value=>'50', -size=>2);
        }        
        print "<tr><td colspan=\"2\" hight=\"1\" bgcolor=\"#EFF2F7\" valign=\"top\"><HR/>";	
    }

    print "</table>";
	
	print "<BR/><div bgcolor=\"#EFF2F7\" align=\"center\">",
    		$query->submit(-name=>'save', -value=>"Update"),
    		"</div>";

    print p,"<blockquote><a href=\"welcome.pl\" target=\"body\">",
        "Return to the Web Tours Homepage</a></blockquote>",
    	$query->endform(), 
    	"</blockquote>", 
    	$query->end_html();
}



sub printAdminHeader {

	# merge the values passed in (via the checkboxes) into the cookie values.

    @names = $query->param;	
	%prevCookie = cookie('MSO');
    $options{'SID'} = $prevCookie{'SID'};
	
    foreach $key (@names) {
 	   $options{$key} = $query->param($key) unless ($key eq 'save');
    }

    $theCookie = cookie(-name=>'MSO',
                    -value=>\%options,
                    -path=>"/");

    print $query->header(-cookie=>$theCookie), 
        $query->start_html(-title=>'Web Tours Admin Page',
                         -bgcolor=>'#E0E7F1');
                         
	print "<style>blockquote {font-family: tahoma; font-size : 10pt}";
	print "H1 {font-family: tahoma; font-size : 22pt; color: #993333}";
	print "small {font-family: tahoma; font-size : 8pt}";
	print "H3 {font-family: tahoma; font-size : 10pt; color: black}";
	print "</style>";
    	print "&nbsp;<center><H1><b><font color=\"#003366\">Administration Page</font></b></H1></center>";
}

# delete old files

sub cleanUp {
	$age = shift;
	
	opendir THISDIR, ".";
	@allfiles = grep -T, readdir THISDIR;
	closedir THISDIR;

	foreach $file (@allfiles) {
	    	if (-M $file > $age) {
	    	    push @oldies, $file;
	    	}
	}
	unlink @oldies;
}