#!/bin/bash

# This script creates in a tabular form a summary of busco results
# One parameter is provided, and it is the folder containing the proteins
# on which busco was run

RETURNDIR=$PWD
INPUTFOLDER=$1

cd $INPUTFOLDER

for folder in nematodaFolder/*nematoda;
do
name=$(cut -d"/" -f 3 <<< $folder)
cd $folder
score=$(awk '/^\t+C:*/ {print $0}' < run_nematoda_odb10/short_summary.txt | \
gsed -E 's/(C:.+?%)\[.+\],(F:.+?%),(M:.+%).+/\1\t\2\t\3/g')
echo -e $name "\t" $score
cd ../../
done 2>&1 | tee nematoda_log.txt


for folder in metazoaFolder/*metazoa;
do
name=$(cut -d"/" -f 3 <<< $folder)
cd $folder 
score=$(awk '/^\t+C:*/ {print $0}' < run_metazoa_odb10/short_summary.txt | \
gsed -E 's/(C:.+?%)\[.+\],(F:.+?%),(M:.+%).+/\1\t\2\t\3/g')
echo -e $name "\t" $score
cd ../../
done 2>&1 | tee metazoan_log.txt


cd $RETURNDIR