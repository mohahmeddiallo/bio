#!/bin/bash

# cleans sequences using fastp; if the first argument happens to be 'pe', indication
# paired-end sequencing approach was used during sequence, then fastp cleans both reads in parallel
# otherwise, one read is cleaned at a time


if [[ $1 == "pe" ]]
then
	for f in *_1.fastq; do

    		r=$(sed -e "s/_1./_2./" <<< "$f")

    		s=$(cut -d_ -f1 <<< "$f")

    		fastp -w 8 -h ../2_CLEAN/"$s".html -j ../2_CLEAN/"$s".json -i $f -I $r -o ../2_CLEAN/"$s"_fp_1.fastq -O ../2_CLEAN/"$s"_fp_2.fastq

	done

else
	for f in *.fastq; do

    		s=$(cut -d. -f1 <<< "$f")

    		fastp -w 8 -h ../2_CLEAN/"$s".html -j ../2_CLEAN/"$s".json -i $f -o ../2_CLEAN/"$s"_fp.fastq

	done
fi

