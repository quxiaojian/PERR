#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Find;
use Data::Dumper;

my $global_options=&argument();
my $indir=&default("Reads","indir");
my $organ=&default("mt","organelle");
my $outdir=&default(".","outdir");

my $pattern1="_1.fq";
my $pattern2="_2.fq";

my $logfile="$outdir/remove_$organ\_from_fq.log";
system ("rm -rf $logfile") if (-e $logfile);
open(my $log,">>",$logfile);

my (@filenames1,@filenames2);
find(\&target1,$indir);
sub target1{
    if (/$pattern1/){
        push @filenames1,"$File::Find::name";
    }
    return;
}
find(\&target2,$indir);
sub target2{
    if (/$pattern2/){
        push @filenames2,"$File::Find::name";
    }
    return;
}

while (@filenames1 and @filenames2){
	my $forward=shift @filenames1;
	my $reverse=shift @filenames2;

	my $seed_forward=substr($forward,0,rindex($forward,"\/")+1)."seed_reads_$organ.1";
	my $seed_reverse=substr($reverse,0,rindex($reverse,"\/")+1)."seed_reads_$organ.2";

	open (my $seed1,"<",$seed_forward);
	open (my $seed2,"<",$seed_reverse);
	#open (my $duplicated,">","duplicated.fq");

	my ($header1,$sequence1,$plus1,$quality1,$header2,$sequence2,$plus2,$quality2);
	my (%order,%hashA);
	my $i=0;
	while(defined ($header1=<$seed1>) && defined ($sequence1=<$seed1>) && defined ($plus1=<$seed1>) && defined ($quality1=<$seed1>) && defined ($header2=<$seed2>) && defined ($sequence2=<$seed2>) && defined ($plus2=<$seed2>) && defined ($quality2=<$seed2>)){
		chomp ($header1,$sequence1,$plus1,$quality1,$header2,$sequence2,$plus2,$quality2);
		$order{$header1}=$i++;
		$order{$header2}=$i++;
		$hashA{$header1}=$sequence1."\n".$plus1."\n".$quality1."\n";
		$hashA{$header2}=$sequence2."\n".$plus2."\n".$quality2."\n";
}

	open (my $fq1,"<",$forward);
	open (my $fq2,"<",$reverse);

	my ($header3,$sequence3,$plus3,$quality3,$header4,$sequence4,$plus4,$quality4);
	my (%hashB,@array1,@array2);
	my $count=0;
	print $log "Duplicated rows in files $seed_forward//$seed_reverse and $forward//$reverse!\n";
	while(defined ($header3=<$fq1>) && defined ($sequence3=<$fq1>) && defined ($plus3=<$fq1>) && defined ($quality3=<$fq1>) && defined ($header4=<$fq2>) && defined ($sequence4=<$fq2>) && defined ($plus4=<$fq2>) && defined ($quality4=<$fq2>)){
		chomp ($header3,$sequence3,$plus3,$quality3,$header4,$sequence4,$plus4,$quality4);
		$hashB{$header3}=$sequence3."\n".$plus3."\n".$quality3."\n";
		$hashB{$header4}=$sequence4."\n".$plus4."\n".$quality4."\n";
		unless (defined $order{$header3} && defined $order{$header4}){
			push (@array1,$header3);
			push (@array2,$header4);
		}else{
			$order{$header3}=0;
			$order{$header4}=0;
			#print $duplicated "$header3\n$hashA{$header3}";
			#print $duplicated "$header4\n$hashA{$header4}";
			$count++;
		}
	}
	#print $duplicated "\n";
	print $log "$count reads\n";

	my $seed_name=substr($seed_forward,0,rindex($seed_forward,"."));
	my $fq1_name=substr($forward,0,rindex($forward,"."));
	my $fq2_name=substr($reverse,0,rindex($reverse,"."));
	open (my $unique_seed,">","$seed_name\_unique.fq");
	open (my $unique_fq1,">","$fq1_name\_remove_$organ.fq");
	open (my $unique_fq2,">","$fq2_name\_remove_$organ.fq");

	print $log "Unique rows in file $seed_forward and $seed_reverse!\n";
	my $countA=0;
	my %rorder=reverse %order;
	foreach my $key (sort keys %rorder) {
		if ($key>0) {
			print $unique_seed "$rorder{$key}\n$hashA{$rorder{$key}}";
			$countA++;
		}
	}
	print $log "$countA reads\n";

	print $log "Unique rows in file $forward and $reverse!\n";
	my $countB=(scalar @array1)+(scalar @array2);
	foreach my $element1 (@array1){
		print $unique_fq1 "$element1\n$hashB{$element1}";
	}
	foreach my $element2 (@array2){
		print $unique_fq2 "$element2\n$hashB{$element2}";
	}
	print $log "$countB reads\n";

	if ($countA==0 and $countB==0 ){
		print $log "Two files are identical!!!\n";
	}

	my $uniq_seed_name="$seed_name\_unique.fq";
	system ("rm -rf $uniq_seed_name") if ((-s $uniq_seed_name)==0);
}




########################################
##subroutines
########################################
sub argument{
	my @options=("help|h","indir|i:s","organelle|p:s","outdir|o:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'help'});
	if(!exists $options{'indir'}){
		print "***ERROR: No input dir for multiple subdirs containing paired-end reads are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'organelle'}){
		print "***ERROR: No cp or mt are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'outdir'}){
		print "***ERROR: No output dir are assigned!!!\n";
		exec ("pod2usage $0");
	}
	return \%options;
}

sub default{
	my ($default_value,$option)=@_;
	if(exists $global_options->{$option}){
		return $global_options->{$option};
	}
	return $default_value;
}


__DATA__

=head1 NAME

    remove_cp_or_mt_from_fq.pl

=head1 COPYRIGHT

    copyright (C) 2016 Xiao-Jian Qu

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 DESCRIPTION

    Remove mapped chloroplast or mitochondrial reads from raw fq.

=head1 SYNOPSIS

    remove_cp_or_mt_from_fq -i -p -o
    Copyright (C) 2016 Xiao-Jian Qu
    Please contact me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-i -indir]          The input dir for multiple subdirs containing paired-end reads (default: Reads).
    [-p -organelle]      The cp or mt that you want to remove (default: mt).
    [-o -outdir]         The output dir for your log file (default: .).

=cut

