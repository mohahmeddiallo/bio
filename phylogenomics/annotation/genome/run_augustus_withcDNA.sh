#!/bin/bash


# augustus is performed on each folder containing assembly file that ends in '_assembly.fasta'
# the output is  output.gff file
for folder in *PR*; do
    basefoldername=$(cut -d'_' -f1,2 <<< $folder)
	cd $folder &&
    echo
    echo
    echo echo ____running blat____
    echo
    echo
    blat *assembly.fasta "$basefoldername"_PRJNA374706/*assembly.fasta "$basefoldername"_PRJNA374706/cdna.psl && 
    echo
    echo
    echo ____filtering alignment____
    echo
    echo
    cat "$basefoldername"_PRJNA374706/cdna.psl | ~/augustus/scripts/filterPSL.pl --best --minCover=80 > "$basefoldername"_PRJNA374706/cdna.f.psl && 
    echo ____generating hintfile____
    ~/augustus/scripts/blat2hints.pl --in="$basefoldername"_PRJNA374706/cdna.f.psl --out=hints.E.gff &&
    echo
    echo
    echo ____running augustus gene prediction____
    echo
    echo
	augustus --species=caenorhabditis --strand=both --genemodel=partial --alternatives-from-sampling=true --minexonintronprob=0.08 --minmeanexonintronprob=0.4 --maxtracks=3 --hintsfile=hints.E.gff --extrinsicCfgFile=~/augustus/config/extrinsic/extrinsic.E.cfg --AUGUSTUS_CONFIG_PATH=/Users/mohammedahmed/augustus/config *_assembly.fasta > output.gff &&
    ~/augustus/scripts/getAnnoFasta.pl output.gff
	cd ../

done

# this script runs a perl script (included in the package) which extracts the protein sequences from the output.gff file
#for folder in *PR*; do cd $folder && ~/augustus/scripts/getAnnoFasta.pl output.gff && cd ../; done
