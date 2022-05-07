#!/bin/bash

# SraAccList_ILL.txt should contain per line the SRR prefixed accession numbers to be downloaded
# fasterq-dump installation required


#while read -r line; do fasterq-dump --defline-seq '@$sn[_$rn]/$ri' --split-files $line; done < SraAccList.txt


while read -r line; do fasterq-dump $line; done < ../SraAccList_ILL.txt
