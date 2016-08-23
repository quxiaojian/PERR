#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Find;

my $global_options=&argument();
my $indir=&default("Reads","indir");
my $kmer=&default("91,95,101,105,111,115","kmer");
my $organ=&default("cp","organelle");
my $outdir=&default(".","outdir");

my $pattern1="recruited_reads.1.fq";
my $pattern2="recruited_reads.2.fq";
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

open (my $output,">","$outdir/spades_bash.sh");
while (@filenames1 and @filenames2) {
	my $forward=shift @filenames1;
	my $name=substr ($forward,0,rindex($forward,"\/"));
	#my $name2=substr ($forward,rindex($forward,"\/")+1,-5);
	my $reverse=shift @filenames2;

	print $output "spades.py --careful -1 ",$forward," -2 ",$reverse," -k $kmer ","-o $name/Spades_$organ\n";
}
close $output;

#spades.py --careful -1 Documents/Assembly/Reads/FC314/recruited_reads.1.fq -2 Documents/Assembly/Reads/FC314/recruited_reads.2.fq -k 91,95,101,105,111,115 -o Documents/Assembly/Reads/FC314/Spades




########################################
##subroutines
########################################
sub argument{
	my @options=("help|h","indir|i:s","kmer|k:s","organelle|p:s","outdir|o:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'help'});
	if(!exists $options{'indir'}){
		print "***ERROR: No input dir for multiple subdirs containing paired-end reads are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'kmer'}){
		print "***ERROR: No kmer value are assigned!!!\n";
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

    spades_bash.pl

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

    Generate bash file for performing spades.

=head1 SYNOPSIS

    spades_bash.pl -i -k -p -o
    Copyright (C) 2016 Xiao-Jian Qu
    Please contact me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-i -indir]          The input dir for multiple subdirs containing paired-end reads (default: Reads).
    [-k -kmer]           The kmer value (default: 91,95,101,105,111,115).
    [-p -organelle]      The cp or mt that you want to assembly (default: cp).
    [-o -outdir]         The output dir for your bash file (default: .).

=cut

