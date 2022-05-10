#!/bin/bash

# This script performs a batch busco run using nematode and metazoan dataset
# on several amino acid sequences located in a given working directory
# The only argument passed is the folder containing the fasta files
# To run the script, first make sure busco5 is installed and activated with 
# "conda activate busco5"


RETURNDIR=$PWD
FOLDERNAME=$1

cd $FOLDERNAME

mkdir nematodaFolder
for filename in *faa
do
basename=$(cut -d'.' -f1 <<< $filename)
busco -i $filename -l /Users/mohammedahmed/busco_downloads/lineages/nematoda_odb10 -c 8 -f -o "$basename"_nematoda -m prot
done
mv *nematoda nematodaFolder

mkdir metazoaFolder
for filename in *faa
do
basename=$(cut -d'.' -f1 <<< $filename)
busco -i $filename -l /Users/mohammedahmed/busco_downloads/lineages/metazoa_odb10 -c 8 -f -o "$basename"_metazoa -m prot
done
mv *metazoa metazoaFolder

cd $RETURNDIR