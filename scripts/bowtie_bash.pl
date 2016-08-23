#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Find;

my $global_options=&argument();
my $indir=&default("Reads","indir");
my $organ=&default("cp","organelle");
my $ref=&default("reference","ref");
my $outdir=&default(".","outdir");

my $refdir=substr ($ref,0,rindex($ref,"\/"));

my $pattern1="_1.fq";
my $pattern2="_2.fq";
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

open (my $output,">","$outdir/bowtie_$organ\_bash.sh");
while (@filenames1 and @filenames2) {
	my $forward=shift @filenames1;
	my $name1=substr ($forward,0,rindex($forward,"\/"));
	my $name2=substr ($forward,rindex($forward,"\/")+1,-5);
	my $reverse=shift @filenames2;
	print $output "bowtie2 -p 200 --very-fast-local ","-x $ref ","-1 ",$forward," -2 ",$reverse," --al-conc $name1/seed_reads_$organ"," --no-unal -S $refdir/$name2\_$organ.sam\n";
}
close $output;

#bowtie2 -p 200 --very-fast-local -x bowtie_reference/cp/reference -1 Reads/FC314/FC314_1.fq -2 Reads/FC314/FC314_2.fq --al-conc Reads/FC314/seed_reads --no-unal -S bowtie_reference/cp/FC314.sam


########################################
##subroutines
########################################
sub argument{
	my @options=("help|h","indir|i:s","organelle|p:s",,"ref|r:s","outdir|o:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'help'});
	if(!exists $options{'indir'}){
		print "***ERROR: No input dir for multiple subdirs containing paired-end reads are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'organelle'}){
		print "***ERROR: No cp or mt are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'ref'}){
		print "***ERROR: No reference of indexed cp or mt are assigned!!!\n";
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

    bowtie_bash.pl

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

    Generate bash file for performing bowtie.

=head1 SYNOPSIS

    bowtie_bash.pl -i -p -r -o
    Copyright (C) 2016 Xiao-Jian Qu
    Please contact me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-i -indir]          The input dir for multiple subdirs containing paired-end reads (default: Reads).
    [-p -organelle]      The cp or mt that you want to map your reads to (default: cp).
    [-r -ref]            The reference of indexed cp or mt (default: reference).
    [-o -outdir]         The output dir for your bash file (default: .).

=cut

