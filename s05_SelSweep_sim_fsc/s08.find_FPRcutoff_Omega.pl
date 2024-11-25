#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use Cwd 'abs_path';
use File::Basename;
use Getopt::Long;

# By Xilong CHEN
# Create date: 2022-08-02
# Contact: chen_xilong@outlook.com

# Adjusted by Yuqi
# 2024-09-04 
my $pop = $ARGV[0] // die "Veuillez fournir une valeur pour 'pop' en argument.\n";
my $folder = "s08.find_FPRcutoff_OmegaPlus";
my $workdir = "../results";
`mkdir -p $workdir/$folder`;


my $cutoff    = 0.05;      # FPR at 95%
my $cutoff_op = 1 - $cutoff;

my @omegas;
for my $re ( 1 .. 500 ) {
    $/ = "\n\/\/";
    open my $inOm, "<", "$workdir/$pop/OmegaPlus_Report.$pop.$re.1k";

    <$inOm>;

    while (<$inOm>) {
        chomp;
        my @block = split /\n/, $_;
        my $nu    = shift @block;
        my @omega_re;
        for my $line (@block) {
            my ( $po, $omega ) = split /\t/, $line;
            push @omega_re, $omega;
        }
        @omega_re = reverse sort { $a <=> $b } @omega_re;
        push @omegas, $omega_re[0];
    }

@omegas = reverse sort { $a <=> $b } @omegas;
pop @omegas for ( 1 .. int( @omegas * $cutoff_op ) - 1 );
my $omegas_cutoff = $omegas[-1];
}

open my $ouc, ">", "$workdir/$folder/$pop.FPRcutoff.Rdata.txt";
print $ouc "omegas_cutoff $pop\n";
print $ouc "$omegas_cutoff\n";
