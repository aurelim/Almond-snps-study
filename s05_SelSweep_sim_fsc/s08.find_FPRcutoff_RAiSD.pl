#!/usr/bin/perl
use warnings;
use strict;

my $pop = $ARGV[0] // die "Veuillez fournir une valeur pour 'pop' en argument.\n";
my $folder = "s08.find_FPRcutoff_RAiSD.10";
my $workdir = "../results/simulations_2";
`mkdir -p $workdir/$folder`;

my $cutoff    = 0.05;  # FPR at 95%
my $cutoff_op = 1 - $cutoff;

my @raisd;

for my $re ( 1 .. 50 ) {
    for my $chr ( 1 .. 8 ) {
        
        print "Traitement du fichier : Répétition $re, Chromosome $chr\n";

        # Ouvrir le fichier
        open my $inOm, "<", "$workdir/$pop/RAiSD_Report.$pop.$re.10.$chr" or die "Impossible d'ouvrir le fichier : $!";

        # Lire le fichier ligne par ligne, sans utiliser de séparateur d'enregistrement spécial
        my $first_line = <$inOm>;  # Ignorer la première ligne `// 1`
        # print "Première ligne ignorée : $first_line\n";

        while (my $line = <$inOm>) {
            chomp $line;
            # print "Ligne de données : $line\n";  # Afficher chaque ligne de données pour le débogage

            # Vérifier si la ligne est vide ou mal formattée
            next if $line =~ /^\s*$/;

            # Extraire les colonnes
            my ( $po, $start_w, $end_w, $var, $sfs, $ld, $mu ) = split /\t/, $line;

            # Imprimer les colonnes extraites pour vérifier
            # print "Colonnes extraites : po=$po, start_w=$start_w, end_w=$end_w, var=$var, sfs=$sfs, ld=$ld, mu=$mu\n";

            if (defined $mu) {
                # print "Valeur de mu : $mu\n";
                push @raisd, $mu;
            } else {
                print "mu n'est pas défini pour la ligne : $line\n";  # Débogage
            }
        }
        close $inOm;
    }
}

@raisd = reverse sort { $a <=> $b } @raisd;
pop @raisd for ( 1 .. int( @raisd * $cutoff_op ) - 1 );

my $raisd_cutoff = $raisd[-1] // 'Indéfini';  # Ajouter une valeur par défaut pour éviter l'erreur
print "Valeur seuil RAiSD : $raisd_cutoff\n";

open my $ouc, ">", "$workdir/$folder/$pop.FPRcutoff.Rdata.txt" or die "Impossible d'ouvrir le fichier de sortie : $!";
print $ouc "RAiSD_cutoff $pop\n";
print $ouc "$raisd_cutoff\n";
close $ouc;
