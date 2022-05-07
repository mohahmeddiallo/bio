#!/bin/bash


for folder in proteins/metazoaFolder/*metazoa;
do
name=$(cut -d"/" -f 3 <<< $folder)
cd $folder 
score=$(awk '/^\t+C:*/ {print $0}' < run_metazoa_odb10/short_summary.txt | \
gsed -E 's/(C:.+?%)\[.+\],(F:.+?%),(M:.+%).+/\1\t\2\t\3/g')
echo -e $name "\t" $score
cd ../../../
done 2>&1 | tee metazoan_log.txt



for folder in proteins/nematodaFolder/*nematoda;
do
name=$(cut -d"/" -f 3 <<< $folder)
cd $folder
score=$(awk '/^\t+C:*/ {print $0}' < run_nematoda_odb10/short_summary.txt | \
gsed -E 's/(C:.+?%)\[.+\],(F:.+?%),(M:.+%).+/\1\t\2\t\3/g')
echo -e $name "\t" $score
cd ../../../
done 2>&1 | tee nematoda_log.txt
