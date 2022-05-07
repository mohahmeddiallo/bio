#!/bin/bash
#/Users/mohammedahmed/BRAKER/scriptsstartAlign.pl --genome=*fasta --prot=*.fa --prg=gth
#/Users/mohammedahmed/augustus/scripts/gth2gtf.pl align_gth/gth.concat.aln bonafide.gtf
#/Users/mohammedahmed/augustus/scripts/computeFlankingRegion.pl bonafide.gtf
#/Users/mohammedahmed/augustus/scripts/gff2gbSmallDNA.pl bonafide.gtf *.fasta 10000 bonafide.gb
#etraining --species=nematode bonafide.gb &> bonafide.out
#grep -c ‘‘Variable stopCodonExcludedFromCDS set right’’ bonafide.out
#grep -c LOCUS bonafide.gb
#etraining --species=nematode bonafide.gb 2>&1 | grep ‘‘in sequence’’ | perl -pe s/.*n sequence (\S+):.*/$1/ | sort -u > bad.lst
#/Users/mohammedahmed/augustus/scripts/filterGenes.pl bad.lst bonafide.gb > bonafide.f.gb
#grep -c LOCUS bonafide.gb bonafide.f.gb
#mv bonafide.f.gb bonafide.gb
#/Users/mohammedahmed/augustus/scripts/randomSplit.pl bonafide.gb 200
#mv bonafide.gb.test test.gb
#mv bonafide.gb.train train.gb
#etraining --species=nematode train.gb &> etrain.out
#augustus --species=bug test.gb > test.out

# Annotation protocol using amino acid sequences as guide dataset
# input dataset arguments need to be change accordingly (ie --genome, --prot)

#CHECK PROTOCOL 7

/Users/mohammedahmed/BRAKER/scripts/startAlign.pl --genome=Radopholus_similis_PRJNA522283_assembly.fasta --prot=Radopholus_similis_PRJNA427497_assembly.fasta.transdecoder.fa --prg=gth

/Users/mohammedahmed/BRAKER/scripts/align2hints.pl --in=align_gth/gth.concat.aln --out=prot.hints --prg=gth

augustus --species=brugia --strand=both --genemodel=partial --alternatives-from-sampling=true --minexonintronprob=0.08 --minmeanexonintronprob=0.4 --maxtracks=3 --hintsfile=prot.hints --extrinsicCfgFile=~/augustus/config/extrinsic/extrinsic.MP.cfg --AUGUSTUS_CONFIG_PATH=/Users/mohammedahmed/augustus/config *_assembly.fasta > output.gff &&

~/augustus/scripts/getAnnoFasta.pl output.gff

