#!/bin/bash


for dir in *PRJEB31201; do cd $dir/3_ASSEM && TransDecoder.LongOrfs -t *.fasta && hmmscan --cpu 10 --domtblout pfam.domtblout ~/Pfam/Pfam-A.hmm *assembly.fasta.transdecoder_dir/longest_orfs.pep && TransDecoder.Predict -t *_assembly.fasta --retain_pfam_hits pfam.domtblout && cd ../../ ; done
