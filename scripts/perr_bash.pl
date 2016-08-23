#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Find;

my $global_options=&argument();
my $indir=&default("Reads","indir");
my $kmer=&default("101","kmer");
my $organ=&default("mt","organelle");
my $fq=&default("T","fq");
my $seed=&default("cp","seed");
my $outdir=&default(".","outdir");

my ($pattern1,$pattern2);
if ($fq eq "F"){
	$pattern1="_1.fq";
	$pattern2="_2.fq";
}elsif($fq eq "T"){
	$pattern1="_1_remove_$organ.fq";
	$pattern2="_2_remove_$organ.fq";
}


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

open (my $output,">","$outdir/perr_bash.sh");
while (@filenames1 and @filenames2) {
	my $forward=shift @filenames1;
	my $name=substr ($forward,0,rindex($forward,"\/"));
	my $reverse=shift @filenames2;

	print $output "PERR.pl -k $kmer ","-f ",$forward," -r ",$reverse," -s1 $name/seed_reads_$seed.1"," -s2 $name/seed_reads_$seed.2\n";
}
close $output;

#PERR.pl -k 101 -f Documents/Assembly/Reads/FC314/FC314_1.fq -r Documents/Assembly/Reads/FC314/FC314_2.fq -s1 Documents/Assembly/Reads/FC314/seed_reads_cp.1 -s2 Documents/Assembly/Reads/FC314/seed_reads_cp.2




########################################
##subroutines
########################################
sub argument{
	my @options=("help|h","indir|i:s","kmer|k:i","organelle|p:s","fq|f:s","seed|s:s","outdir|o:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'help'});
	if(!exists $options{'indir'}){
		print "***ERROR: No input dir for multiple subdirs containing paired-end reads are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'kmer'}){
		print "***ERROR: No kmer value are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'fq'}){
		print "***ERROR: No raw fq file are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'seed'}){
		print "***ERROR: No cp or mt of seed reads are assigned!!!\n";
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

    perr_bash.pl

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

    Generate bash file for performing PERR.

=head1 SYNOPSIS

    perr_bash.pl -i -k -p -f -s -o
    Copyright (C) 2016 Xiao-Jian Qu
    Please contact me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-i -indir]          The input dir for multiple subdirs containing paired-end reads (default: Reads).
    [-k -kmer]           The kmer value (default: 101).
    [-p -organelle]      The cp or mt that you have removed from raw fq file, you can ignore this argument when not assigned (default: mt).
    [-f -fq]             The raw fq file you want to extend, F equal to _1.fq and _2.fq, T equal to _1_remove_mt.fq and _2_remove_mt.fq (default: T).
    [-s -seed]           The cp or mt that you want to extend (default: cp).
    [-o -outdir]         The output dir for your bash file (default: .).

=cut

