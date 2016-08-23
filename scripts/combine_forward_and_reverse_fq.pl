#!/usr/bin/perl -w
use strict;

print "Please type your forward paired-end fq reads:";
my $forward=<STDIN>;
chomp $forward;
print "Please type your reverse paired-end fq reads:";
my $reverse=<STDIN>;
chomp $reverse;
print "Please type your combined paired-end fq reads:";
my $combined=<STDIN>;
chomp $combined;

open(my $input1,"<",$forward);
open(my $input2,"<",$reverse);
open(my $output,">",$combined);
my ($header1,$header2,$sequence1,$sequence2,$plus1,$plus2,$quality1,$quality2);

while (defined($header1=<$input1>) && defined($sequence1=<$input1>) && defined($plus1=<$input1>) && defined($quality1=<$input1>) && defined($header2=<$input2>) && defined($sequence2=<$input2>) && defined($plus2=<$input2>) && defined($quality2=<$input2>)) {
	chomp ($header1,$header2,$sequence1,$sequence2,$plus1,$plus2,$quality1,$quality2);
	print $output "$header1\n$sequence1\n$plus1\n$quality1\n$header2\n$sequence2\n$plus2\n$quality2\n";
}
close $input1;
close $input2;
close $output;

