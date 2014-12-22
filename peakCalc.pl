#!C:/Perl/bin/perl.exe

#Global variables
my @file_names;
my $mz21s,$mz21e;
my $mz37s,$ms37e;
my $mz55s,$mz55e;
my $mzAnalyte_s,$mzAnalyte_e;
my $path;

sub get_file_names { # argument is path in form 'C:/Program Files/peakCalc'
    my @list = @_;
	opendir(DIR, @list[0]) or die $!;
	#print "@list[0]\n";
		my @f_names;
    	while (my $file = readdir(DIR)) {

       	 # We only want files
        	#next unless (-f "$file");xtaken out to avoid windows issues

        # Use a regular expression to find files ending in .txt
        	next unless ($file =~ m/\.csv$/);#($file =~ m/^\w*\.csv$/);

        	#print "$file\n";
		push (@f_names,  "$path/$file");#changed in the last version
    	}
    closedir(DIR);
    return @f_names;
}

sub load_defaults{
	open FILE, '<' , "defaults.txt" or die $!;
	foreach (<FILE>) {
		chomp();
		@fragments = split ("=");
		#print "@fragments[1]\n";
		#chomp @fragments[1];
		
		if (@fragments [0] eq "DIR"){$path=@fragments[1];}
		if (@fragments [0] eq "mz21s"){$mz21s=@fragments[1];}
		if (@fragments [0] eq "mz21e"){$mz21e=@fragments[1];}
		if (@fragments [0] eq "mz37s"){$mz37s=@fragments[1];}
		if (@fragments [0] eq "mz37e"){$mz37e=@fragments[1];}
		if (@fragments [0] eq "mz55s"){$mz55s=@fragments[1];}
		if (@fragments [0] eq "mz55e"){$mz55e=@fragments[1];}
		if (@fragments [0] eq "mzAnalyte_s"){$mzAnalyte_s=@fragments[1];}
		if (@fragments [0] eq "mzAnalyte_e"){$mzAnalyte_e=@fragments[1];}

	}
}


print "This is a program for PTR-TOF-MS data analysis !!!\n\n";
print "Prior to running the program please check the \nparametars in defaults.txt\n";
print "____________________________________________________________________________\n\n";


load_defaults();
@file_names = get_file_names($path);

#foreach (@file_names) {
#	print "$_\n";
#}

open OUT, ">>REPORT.csv"or die $!;
print OUT ("\nFile name,mz19,mz21,mz37,mz55,analyte,norm. analyte 19, norm. analyte all\n");



#Loop through each file existing in the folder PATH
foreach $fname (@file_names){
	
	open SPECTRA, '<' ,"$fname" or die $!;
	my @spectra = <SPECTRA>; # each line of spetra is assighn in an array
	close SPECTRA;
	
	#print "$fname\n";
	my $MZ21,$MZ37,$MZ55,$MZAnalyte,$MZ19;
	$MZ21=$MZ37=$MZ55=$MZAnalyte=$MZ19=$MZnorm=0;
	
	$m1=$m2=$m3=0;
	$m21corect = $m37corect = $m55corect =$mAnalyteCorect = 0;
	
	#this loops through file to get exact noize in mass window
	foreach $line (@spectra){
		chomp ($line);
		($mass , $cps) = split (/;|,/, $line);
		
		if ($mass >= $mz21s && $m1 == 0){
			$m21first = $cps;
			$m1++;
			next;
		}
		if ($mass >= $mz21s && $mass <= $mz21e){
			$m21last = $cps;
			next;
		}
		
		if ($mass >= $mz37s && $m2 == 0){
			$m37first = $cps;
			$m2++;
			next;
		}
		if ($mass >= $mz37s && $mass <= $mz37e){
			$m37last = $cps;
			next;
		}
		
		if ($mass >= $mz55s && $m3 == 0){
			$m55first = $cps;
			$m3++;
			next;
		}
		if ($mass >= $mz55s && $mass <= $mz55e){
			$m55last = $cps;
			next;
		}
		
		if ($mass >= $mzAnalyte_s && $m4 == 0){
			$mAnalyteFirst = $cps;
			$m4++;
			next;
		}
		if ($mass >= $mzAnalyte_s && $mass <= $mzAnalyte_e){
			$mAnalyteLast = $cps;
			next;
		}
		
	}
	#This is an average noize (in cps) between two point of a mass windows
		$m21corect = ($m21first + $m21last)/2;
		$m37corect = ($m37first + $m37last)/2;
		$m55corect = ($m55first + $m55last)/2;
		$mAnalyteCorect	= ($mAnalyteFirst + $mAnalyteLast)/2;
		
	
	#Loop through each mass in a file
	foreach $line (@spectra){
		chomp ($line);
		#print "$line\n";
		($mass , $cps) = split (/;|,/, $line);
		#print @temp[55];
		#print "$mass\t";
		#print "$cps\n";
		if ($mass eq "X"){next;}
		if ($mass >= $mz21s && $mass <= $mz21e){
			$MZ21 += ($cps - $m21corect);
			#print "$mass\n";
			next;
		}
		if ($mass >= $mz37s && $mass <= $mz37e){
			$MZ37 += ($cps - $m37corect);
			next;

		}
		if ($mass >= $mz55s && $mass <= $mz55e){
			$MZ55 += ($cps - $m55corect);
			next;

		}
		if ($mass >= $mzAnalyte_s && $mass <= $mzAnalyte_e){
			$MZAnalyte += ($cps - $mAnalyteCorect);
			next;

		}
		#print "@temp[0]";		
		
	}
	
	print "filename: $fname\n";
	print "noize 21 = $m21corect, 37 = $m37corect, 55 = $m55corect, analyte = $mAnalyteCorect\n";
	print "mz21: $MZ21\n";
	print "mz37: $MZ37\n";
	print "mz55: $MZ55\n";
	print "mzAnalyte: $MZAnalyte\n\n";
	
	if ($MZ21>0){#discriminate all other filese that dont mach csv spectra
		$MZ19=$MZ21*487;
		$MZnorm = ($MZAnalyte/$MZ19)*1000000;
		$MZnormAll = ($MZAnalyte/($MZ19+$MZ37+$MZ55))*1000000;
	
		print OUT ("$fname,$MZ19,$MZ21,$MZ37,$MZ55,$MZAnalyte,$MZnorm,$MZnormAll\n");
	}
		

}
	
close OUT;

print "Your resulst are storred in REPORT.csv file.\n\n";
print "Press ENTER to exit . . . ";
<STDIN>;

