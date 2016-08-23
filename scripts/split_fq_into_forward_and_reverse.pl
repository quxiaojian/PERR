#!/usr/bin/perl -w
use strict;
use Data::Dumper;
$|=1;

print "Please type your combined paired-end fq reads:";
my $combined=<STDIN>;
chomp $combined;
print "Please type your forward paired-end fq reads:";
my $forward=<STDIN>;
chomp $forward;
print "Please type your reverse paired-end fq reads:";
my $reverse=<STDIN>;
chomp $reverse;

open(my $input,"<",$combined);
open(my $output1,">",$forward);
open(my $output2,">",$reverse);
my ($header1,$header2,$sequence1,$sequence2,$plus1,$plus2,$quality1,$quality2);

while (defined($header1=<$input>) && defined($sequence1=<$input>) && defined($plus1=<$input>) && defined($quality1=<$input>) && defined($header2=<$input>) && defined($sequence2=<$input>) && defined($plus2=<$input>) && defined($quality2=<$input>)) {
	chomp ($header1,$header2,$sequence1,$sequence2,$plus1,$plus2,$quality1,$quality2);
	print $output1 "$header1\n$sequence1\n$plus1\n$quality1\n";
	print $output2 "$header2\n$sequence2\n$plus2\n$quality2\n";
}
close $input;
close $output1;
close $output2;

