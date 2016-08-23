#!/usr/bin/perl -w
###############################################################################
#
#    PERR.pl Paired-End Reads Recruitment
#
#    Given the mapped reads output from bowtie2 as seeds it recruits overlapped reads from original fastq by extending seeds.
#
#    Copyright (C) 2016 Xiao-Jian Qu
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################
use strict;
use Getopt::Long;
use Time::HiRes qw(time);
use Cwd qw(abs_path);
use File::Basename;
use Term::ProgressBar;
use File::Copy;
use Data::Dumper;

my $now1=time;
my $global_options=&argument();
my $kmer=&default("101","kmer");
my $run=&default("10000","run");
my $forward=&default("forward.fq","forward");
my $reverse=&default("reverse.fq","reverse");
my $seed_forward=&default("seed_reads_cp.1","seed1");
my $seed_reverse=&default("seed_reads_cp.2","seed2");

print "PERR.pl Paired-End Reads Recruitment
Copyright (C) 2016 Xiao-Jian Qu
Email: quxiaojian\@mail.kib.ac.cn\n\n";


my $from_dir_pe=dirname(abs_path($forward));
my $from_dir_seed=dirname(abs_path($seed_forward));
my $to_dir="$from_dir_pe/reads_per_run";

system("rm -rf $to_dir") if (-e $to_dir);
mkdir ($to_dir) if (!-e $to_dir);
my $seed_reads="$from_dir_seed/seed_reads.fq";
my $basename_seed=basename($seed_reads);

my $now2=&gettime;
print "$now2 || Begin dealing with $forward and $reverse!\n";
print "$now2 || Begin combing paired-end seed reads!\n";

open(my $input0,"<",$seed_forward) or die $!;
open(my $input1,"<",$seed_reverse) or die $!;
open(my $output1,">",$seed_reads) or die $!;

my ($header0,$header1,$sequence0,$sequence1,$plus0,$plus1,$quality0,$quality1);
my $cnt1;
while (defined($header0=<$input0>) && defined($sequence0=<$input0>) && defined($plus0=<$input0>) && defined($quality0=<$input0>) && defined($header1=<$input1>) && defined($sequence1=<$input1>) && defined($plus1=<$input1>) && defined($quality1=<$input1>)) {
	$header0=~ s/\n|\r//g;
	$sequence0=~ s/\n|\r//g;
	$plus0=~ s/\n|\r//g;
	$quality0=~ s/\n|\r//g;
	$header1=~ s/\n|\r//g;
	$sequence1=~ s/\n|\r//g;
	$plus1=~ s/\n|\r//g;
	$quality1=~ s/\n|\r//g;
	$cnt1++;
	print $output1 "$header0\n$sequence0\n$plus0\n$quality0\n$header1\n$sequence1\n$plus1\n$quality1\n";
}
close $input0;
close $input1;
close $output1;
my $now3=&gettime;
print "$now3 || Finish combing $cnt1 number of paired-end seed reads!\n";


my $now4=&gettime;
print "$now4 || Begin writing memory for paired-end raw reads!\n";
open(my $input2,"<",$forward) or die $!;
open(my $input3,"<",$reverse) or die $!;
my $seqcount=0;
while (<$input2>) {
	$seqcount++ if(/^@/);
}
my $progress=Term::ProgressBar->new({
	count		=>	$seqcount,
	name		=>	'Processing',
	major_char	=>	'=',			# default symbol of major progress bar
	minor_char	=>	'*',			# default symbol of minor progress bar
	ETA			=>	'linear',		# evaluate remain time: undef (default) or linear
	#term_width	=>	100,			# breadth of terminal, full screen (default)
	#remove		=>	0,				# whether the progress bar disappear after the end of this script or not? 0 (default) or 1
	#fh			=>	\*STDOUT,		# \*STDERR || \*STDOUT
});
$progress->lbrack('[');				# left symbol of progress bar
$progress->rbrack(']');				# right symbol of progress bar
$progress->minor(0);				# close minor progress bar
#$progress->max_update_rate(0.5);	# minumum gap time between two updates (s)


my $cnt2=0;
my $update=0;
seek ($input2,0,0);
my (%prefix,%fq);
my ($header2,$sequence2,$plus2,$quality2,$header3,$sequence3,$plus3,$quality3);

while (defined ($header2=<$input2>) && defined ($sequence2=<$input2>) && defined ($plus2=<$input2>) && defined ($quality2=<$input2>) && defined ($header3=<$input3>) && defined ($sequence3=<$input3>) && defined ($plus3=<$input3>) && defined ($quality3=<$input3>)) {
	$header2=~ s/\n|\r//g;
	$sequence2=~ s/\n|\r//g;
	$plus2=~ s/\n|\r//g;
	$quality2=~ s/\n|\r//g;
	$header3=~ s/\n|\r//g;
	$sequence3=~ s/\n|\r//g;
	$plus3=~ s/\n|\r//g;
	$quality3=~ s/\n|\r//g;

	$fq{$header2}=$sequence2."\n".$plus2."\n".$quality2;
	$fq{$header3}=$sequence3."\n".$plus3."\n".$quality3;
	push @{$prefix{substr($sequence2,0,$kmer)}},$header2;
	push @{$prefix{substr($sequence3,0,$kmer)}},$header3;

	$cnt2++;
	$update=$progress->update ($cnt2) if ($cnt2 > $update);
}
$progress->update ($seqcount) if ($seqcount >= $update);
close $input2;
close $input3;
my $now5=&gettime;
print "$now5 || Finish writing memory for $cnt2 number of paired-end raw reads!\n";


########################################
##extend_seed_reads
########################################
my $now6=&gettime;
print "$now6 || Begin recruiting overlapped reads!\n";
my $seed=$seed_reads;
my $i;
for ($i=1;$i<=$run;$i++) {
	open(my $input4,"<",$seed) or die $!;
	open(my $output2,">>","$from_dir_pe/header") or die $!;
	my ($header4,$sequence4,$plus4,$quality4);

	while (defined ($header4=<$input4>) && defined ($sequence4=<$input4>) && defined ($plus4=<$input4>) && defined ($quality4=<$input4>)) {
		$header4=~ s/\n|\r//g;
		$sequence4=~ s/\n|\r//g;

		extend_seed($sequence4,$kmer,\%prefix,$output2);
		(my $complement=$sequence4)=~ tr/ACGTacgt/TGCAtgca/;
		my $reverse_complement=reverse $complement;
		extend_seed($reverse_complement,$kmer,\%prefix,$output2);

		$plus4=~ s/\n|\r//g;
		$quality4=~ s/\n|\r//g;

	}
	close $input4;
	close $output2;


	open (my $overlapped_read1,"<","$from_dir_pe/header") or die $!;
	open (my $overlapped_read2,">","$from_dir_pe/read$i.fq") or die $!;
	my (%hash1,@array1);
	while (<$overlapped_read1>) {
		$_=~ s/\n|\r//g;

		if (not $hash1{$_}++){
			push @array1,$_;
		}
	}
	foreach my $item1 (@array1) {
		$item1=~ s/\n|\r//g;
		$hash1{$item1}=$fq{$item1};
	}
	foreach (sort keys %hash1) {
		print $overlapped_read2 "$_\n$hash1{$_}\n";
		delete $prefix{$_};
	}
	close $overlapped_read1;
	close $overlapped_read2;
	$seed="$from_dir_pe/read$i.fq";
	unlink("$from_dir_pe/header");

	last if (-s $seed==0);
	my $now5=&gettime;
	print "$now5 || The $i run finished: ",time-$now1," seconds!\n";
}
my $now7=&gettime;
print "$now7 || Finish recruiting overlapped reads!\n";


my $now8=&gettime;
print "$now8 || Begin subsequent processing!\n";
########################################
##move_extended_reads_to_assigned_dir
########################################
opendir(my $directory1,$from_dir_pe) or die $!;
while (my $filename1=readdir $directory1) {
	next if ($filename1 eq "." or $filename1 eq "..");
	if ($filename1=~ m/read.+.fq/g){
		move $from_dir_pe."/".$filename1,$to_dir;
	}
}
copy $seed_reads,$to_dir;
closedir $directory1;


########################################
##combine_all_extended_reads_files
########################################
opendir(my $directory2,$to_dir) or die $!;
my @dir=readdir $directory2;
close $directory2;
open (my $single_reads,">","$from_dir_pe/single_reads.fq") or die $!;
foreach my $filename2 (@dir){
	if ($filename2=~ m/fq$/g or $filename2=~ m/fastq$/g){
		open (my $input5,"<","$to_dir/$filename2") or die $!;
		while(<$input5>){
			print $single_reads $_;
		}
		close $input5;
	}
}
close $single_reads;
#system("rm -rf $to_dir");


########################################
##extract_pe_reads_using_single
########################################
open (my $input6,"<","$from_dir_pe/single_reads.fq") or die $!;
open (my $output3,">","$from_dir_pe/recruited_reads.fq") or die $!;
my (%hash2,%hash3,%hash4);
my ($header5,$sequence5,$plus5,$quality5);
my $cnt3;

while (defined($header5=<$input6>) && defined($sequence5=<$input6>) && defined($plus5=<$input6>) && defined($quality5=<$input6>)){
	$header5=~ s/\n|\r//g;
	$hash2{substr($header5,0,-6)}++;
	#$hash2{substr($header5,0,-1)}++;
	$sequence5=~ s/\n|\r//g;
	$plus5=~ s/\n|\r//g;
	$quality5=~ s/\n|\r//g;
	$hash3{$header5}=$sequence5."\n".$plus5."\n".$quality5;
	$cnt3++;
}
foreach my $item3 (keys %hash2) {
	if ($hash2{$item3}==1){
		my $item4=$item3;
		$item4.=" 1:N:0";
		#$item4.="1";
		my $item5=$item3;
		$item5.=" 2:N:0";
		#$item5.="2";

		$hash4{$item4}=$fq{$item4};
		$hash4{$item5}=$fq{$item5};
	}else{
		my $item6=$item3;
		$item6.=" 1:N:0";
		#$item6.="1";
		my $item7=$item3;
		$item7.=" 2:N:0";
		#$item7.="2";

		$hash4{$item6}=$hash3{$item6};
		$hash4{$item7}=$hash3{$item7};
	}
}
foreach (sort keys %hash4) {
	print $output3 "$_\n$hash4{$_}\n";
}
close $input6;
close $output3;
unlink("$from_dir_pe/single_reads.fq");


########################################
##split_one_to_two_for_pe_reads
########################################
open (my $input7,"<","$from_dir_pe/recruited_reads.fq") or die $!;
open (my $output4,">","$from_dir_pe/recruited_reads.1.fq") or die $!;
open (my $output5,">","$from_dir_pe/recruited_reads.2.fq") or die $!;
my $row;

while ($row=<$input7>){
	$row=~ s/\n|\r//g;

	if ($. % 8==1) {
		print $output4 "$row\n";
	}
	if ($. % 8==2) {
		print $output4 "$row\n";
	}
	if ($. % 8==3) {
		print $output4 "$row\n";
	}
	if ($. % 8==4) {
		print $output4 "$row\n";
	}

	if ($. % 8==5) {
		print $output5 "$row\n";
	}
	if ($. % 8==6) {
		print $output5 "$row\n";
	}
	if ($. % 8==7) {
		print $output5 "$row\n";
	}
	if ($. % 8==0) {
		print $output5 "$row\n";
	}
}
close $input7;
close $output4;
close $output5;
unlink("$from_dir_pe/recruited_reads.fq");
my $now9=&gettime;
print "$now9 || Finish subsequent processing!\n";
my $now10=&gettime;
print "$now10 || Final statistics >>>\n";
my $space=" " x 26;
print "$space Runs:",$i-1,"\n";
print "$space Raw reads: $cnt2\n";
print "$space Seed reads: $cnt1\n";
print "$space Recruited reads: ",$cnt3-$cnt1,"\n";
print "$space Seed reads plus recruited reads: $cnt3\n";
my $now11=&gettime;
print "$now11 || Total elapsed time: ",time-$now1," seconds! Thanks for using PERR!\n";




########################################
##subroutines
########################################
sub gettime {
	my ($sec,$min,$hour,$day,$mon,$year,$weekday,$yeardate,$savinglightday)=(localtime(time));
	my %hash=(1=>"Mon",2=>"Tue",3=>"Wed",4=>"Thu",5=>"Fri",6=>"Sat",7=>"Sun");
	$year+=1900;
	$mon=($mon<9)?"0".($mon+1):($mon+1);
	$day=($day<10)?"0$day":$day;
	$hour=($hour<10)?"0$hour":$hour;
	$min=($min<10)?"0$min":$min;
	$sec=($sec<10)?"0$sec":$sec;

	my $now="$year.$mon.$day $hash{$weekday} $hour:$min:$sec";
}

sub argument{
	my @options=("help|h","kmer|k:i","run|i:i","forward|f:s","reverse|r:s","seed1|s1:s","seed2|s2:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'help'});
	if(!exists $options{'forward'}){
		print "***ERROR: No forward reads are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'reverse'}){
		print "***ERROR: No reverse reads are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'seed1'}){
		print "***ERROR: No forward seed reads are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'seed2'}){
		print "***ERROR: No reverse seed reads are assigned!!!\n";
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

sub extend_seed {
	my ($seed,$kmer,$prefix,$overlapped_read)=@_;
	my @sub_seed;
	for (my $i=0;$i<((length $seed)-$kmer+1);$i++){
		push @sub_seed,substr($seed,$i,$kmer);
	}

	foreach my $key (@sub_seed){
		if (exists $prefix->{$key}){
			foreach (@{$prefix->{$key}}){
				print $overlapped_read "$_\n";
			}
			delete $prefix->{$key};
		}
	}
}


__DATA__

=head1 NAME

    PERR.pl Paired-End Reads Recruitment

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

    Given the mapped reads output from bowtie2 as seed reads it recruits overlapped reads from original fastq by extending seeds.

=head1 SYNOPSIS

    PERR.pl -k -i -f -r -s1 -s2
    Copyright (C) 2016 Xiao-Jian Qu
    Please contact me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-k -kmer]           kmer value or specifically overlap value between two reads (default: 101).
    [-i -run]            the extending runs of reads recruitment (default: 10000).
    [-f -forward]        raw forward fastq.
    [-r -reverse]        raw reverse fastq.
    [-s1 -seed1]         mapped forward reads from bowtie2 as seed reads (default: seed_reads_cp.1).
    [-s2 -seed2]         mapped reverse reads from bowtie2 as seed reads (default: seed_reads_cp.2).

=cut

