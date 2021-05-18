#!/usr/bin/perl -w
#perl2exe_include "File/Glob.pm";

use File::Copy;
use POSIX qw/strftime/;
#use Date::Calc qw(:all);

print("~~~ Executing :: $0\n");

$net_path = "\"\\\\10.243.177.20\\Workgroups\\Operations\\Back Office\\Cards\"";
system("echo ~~~ %DATE%-%TIME% - START");
system("echo ~~~ Mapping X: on s-msk00-file02");
system("net use X: $net_path sfcvKi87sd /user:raiffeisen\\srv-processing /persistent:no");

## Define start and end timestamps
my $t = time - 24*60*60;
($year,$month,$day) = (	strftime("%Y",localtime($t)), strftime("%m",localtime($t)), strftime("%d",localtime($t)) );
#($year,$month,$day) = Add_Delta_Days($year,$month,$day,-1);

$curr_date = join( "-", $year, sprintf("%.2d",$month), sprintf("%.2d",$day) );
$curr_day = join( "", $year, sprintf("%.2d",$month), sprintf("%.2d",$day) );
$curr_month = join( "", $year, sprintf("%.2d",$month));

#for manual report generation for period (using 3 parameters) YYYY-MM-DD
#$curr_date = "2013-12-24";
#$curr_day = "20131224";
#$curr_month = "201312";

$start_date = join("_", $curr_date, "00:00:00");
#$end_date   = join("_", $curr_date, "18:00:00");
$end_date   = join("_", $curr_date, "23:59:59");

print("~~~ $0 :: preparing to start Monincasso2\n");
print("  START DATE : $start_date\n");
print("  END DATE   : $end_date\n");
print("  Monincasso2 Started\n");


#constant param
$incasso_param_1 = 0;
#run period previous day - current setting
$incasso_param_2 = 20;
#run period 1 minute
#$incasso_param_2 = 2;
#run period 5 minute
#$incasso_param_2 = 3;
#run period 10 minute
#$incasso_param_2 = 4;

# Run MonIncasso2.0

#run in test mode without work with DB
#system("D:\\Lanit\\tools\\Monincasso2\\Bin\\ATMCTRLINCASSO.exe");

#for XML report generation using 2 parameters (DEFAULT)
system( join(" ", "D:\\Lanit\\tools\\Monincasso2\\Bin\\ATMCTRLINCASSO.exe", $incasso_param_1, $incasso_param_2) );

#for manual XML report generation for period (using 3 parameters)
#system(join(" ","D:\\Lanit\\tools\\Monincasso2\\Bin\\ATMCTRLINCASSO.exe", $incasso_param_1, $start_date, $end_date));

system("echo ~~~ %DATE%-%TIME% ");
print("  Monincasso2 Ended\n");

$file_name = "FILE_";
$src = "E:\\Lanit\\monincasso_test";
#$net_dst = "X:\\Monincasso2_test\\AtmCollections";
$net_dst = "X:\\AtmCollections";
$dst = "E:\\Lanit\\Trace\\monincasso_test";
##$src_xlsx = "E:\\Lanit\\Trace\\monincasso_test\\AtmCollections_xlsx";
#$src_xlsx = "X:\\Monincasso2_test\\AtmCollections_xlsx";
$src_xlsx = "X:\\AtmCollections_xlsx";

print("~~~ $0 :: Masking and copy the file\n");
print("~~~ $0 :: src :: $src\n");
print("~~~ $0 :: dst :: $dst\n");
print("~~~ $0 :: net_dst :: $net_dst\n");

opendir (my $hndl, $src ) or die $!;
while( defined($filename=readdir($hndl)) ) {
	next if $filename =~ /^\.\.?$/;  # bypass . and ..
	#if($filename =~ m/^$file_name(\d{3}).xml/g ) { filename = FILE_XXX.XML
	if($filename =~ m/^$file_name(\d{3}).xml/g ) {
	
	  # 1 pan masking
		$inp_filename = join("\\",$src, join(".",$filename,"bak") ); 
		$out_filename = join("\\",$src,$filename);
		
		copy( $out_filename, $inp_filename );
  		
		xml_pan_masking( sprintf("< %s", $inp_filename), sprintf("> %s", $out_filename));
		
		
		# 2 copy xml file
		$src_xml=join("\\",$src,$filename);
		$src_xml_local=join("",$src,"\\",$curr_day,"003000.xml");
		$src_xml_network=join("",$net_dst,"\\",$curr_day,"003000.xml");
		copy( join("\\",$src,$filename), join("\\",$dst,$filename) );
		#copy xml to local drive with YYYYMMDD003000.xml format
		print "~~~ $0 :: copy xml to local drive...\n";
		print "~~~ $0 :: src_xml     :: $src_xml\n";
		print "~~~ $0 :: src_xml_local     :: $src_xml_local\n";
		copy( join("\\",$src,$filename), join("",$src,"\\",$curr_day,"003000.xml") );
		#copy xml to network drive with YYYYMMDD003000.xml format
		print "~~~ $0 :: copy xml to network drive...\n";
		print "~~~ $0 :: src_xml     :: $src_xml\n";
		print "~~~ $0 :: src_xml_network     :: $src_xml_network\n";
		copy( join("\\",$src,$filename), join("",$net_dst,"\\",$curr_day,"003000.xml") );
		
		# 2 xml2txt		
		system("D:");
		system("cd /D D:\\Lanit\\tools\\Monincasso2\\Bin");
		
		$src_xml=join("\\",$src,$filename);
		$dst_incasso = "E:\\Lanit\\Trace\\monincasso_test";
		
		print "~~~ $0 :: Start xml2txt processing...\n";
		print "~~~ $0 :: src_xml     :: $src_xml\n";
		print "~~~ $0 :: dst_incasso :: $dst_incasso\n";
		system( join(" ", "D:\\Lanit\\tools\\Monincasso2\\Bin\\AtmCtrlIncasso2TxtByAtms.exe", $src_xml, $dst_incasso) );

	}
}
closedir($hndl);

system("echo ~~~ %DATE%-%TIME% ");
print("  File masking,copy and xml2txt processing ended\n");

#copy xml to local drive fixed input file name
#system(join("","copy $src\\$file_name","002.xml", " $src\\$curr_day","003000.xml"));
#copy xml to network drive fixed input file name
#system(join("","copy $src\\$file_name","002.xml", " $net_dst\\$curr_day","003000.xml"));

print("~~~ $0 :: Archiving log file\n");
system( join("", "move /y ", $dst, "\\", "ATMCTRLINCASSO.LOG", "  ", $dst, "\\", "ATMCTRLINCASSO.",$curr_day) );
system( join("", "pkzip25 -add -move ", $dst,"\\", $curr_month, ".zip", " ", $dst,"\\","ATMCTRLINCASSO.",$curr_day) );

print("~~~ $0 :: ~~~ Start_creation_xlsx_file\n");
system("echo ~~~ %DATE%-%TIME% ");
system("cd /D D:\\Lanit\\tools\\Monincasso2\\Bin");
system( join(" ", "D:\\Lanit\\tools\\Monincasso2\\Bin\\AtmCtrlIncasso2XLSXByAtms.exe", $dst_incasso, $src_xlsx) );
system("echo ~~~ End_creation_xlsx_file");
system("echo ~~~ %DATE%-%TIME% ");

print("~~~ $0 :: Archiving created files\n");
system("echo ~~~ %DATE%-%TIME% ");
system( join("","mkdir ", $dst, "\\AtmCollections\\", $curr_day) );
system( join("","move /y ", $dst, "\\*.atm"," ", $dst, "\\AtmCollections\\", $curr_day, "\\") );
system( join("","move /y ", $dst, "\\*.xml"," ", $dst, "\\AtmCollections\\", $curr_day,  "\\") );
system( join("","cd /D ", $dst, "\\AtmCollections\\", $curr_day) );
system( join("","pkzip25 -add -move ", $dst,"\\AtmCollections\\", $curr_day, ".zip ", $dst, "\\AtmCollections\\", $curr_day, "\\*") );
system( join("","rmdir -S -Q ", $dst,"\\AtmCollections\\", $curr_day) );
print("~~~ $0 :: Archiving created files ended\n");
system("echo ~~~ %DATE%-%TIME% ");

# ---------------------------------------------------------------------------------

# xml_pan_masking(inpfile,outfile)
#
sub xml_pan_masking {

  open(INPFILE, $_[0]) or die "Error: could not open [", $_[0],"]\n$!";
  open(OUTFILE, $_[1]) or die "Error: could not open [", $_[0],"]\n$!";
  select(OUTFILE);

  my $line;
  my $pan;
  my $mask="XXXXXXXXXXXXXXXXXXXX";

  while( defined($line=<INPFILE>) ) {
    chomp $line;

    if( $line =~ m/CARD="(\d+)"/ ) {
        $pan = $+;
        my $mask_len = length($pan) - 4 - 6;
        substr($pan,6,$mask_len) = substr($mask,0,$mask_len);
        $line =~ s/$+/$pan/g;
        #print "$`\n";
        #print "$&\n";
        #print "$'\n";
    }

    print"$line\n";

  }

  select(STDOUT);
  close OUTFILE or die $!;
  close INPFILE or die $!;
}

#rualkd2 for delete files with not mask cards


#opendir ( DIR, $src ) || die "Error in opening dir $dirname\n";

chdir $src;

foreach $file (<*.xml.bak>) 
{ 
  unlink($file) || warn "having trouble deleting $file: $!";
}

#closedir DIR;

print("~~~ $0 :: Completed \n");
print("~~~ Done :: $0\n");

system("net use X: /delete /y");
system("echo ~~~ %DATE%-%TIME% - END");
system("echo =========================================================================");