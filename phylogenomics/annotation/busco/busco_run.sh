#!/bin/bash

conda activate busco5

cd proteins

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
