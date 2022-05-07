#!/bin/bash

for f in *1.fastq; do

	gsed -E 's/^(@).RR.+ (.+) .+/\1\2\/1/' $f > tmp.fastq && mv tmp.fastq $f

done

for f in *2.fastq; do

    gsed -E 's/^(@).RR.+ (.+) .+/\1\2\/2/' $f > tmp.fastq && mv tmp.fastq $f

done
