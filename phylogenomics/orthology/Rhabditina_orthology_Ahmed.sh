#!/bin/bash

# A SCRIPT FOR PHYLOGENETIC ANALYSIS.
# THIS IS RUN AFTER PROTEINORTHO HAS BEEN RUN
# 1. CREATE THE FOLLOWING DIRECTORIES {01_INPUT 02_PRTNRTH 03_INPUT_50 04_MAFFT 05_ALISCORE 06_ALICUT 07_IQTREE 08_PHPPRNR 09_RAXML 10_IQTREE 11_IQTREE 12_ASTRAL}
# 2. PLACE THE PROTEIN FILES USED FOR PROTEINORTHO IN 01_INPUT
# 3. PLACE THE PROTEINORTHO RESULTS IN 02_PRTNRTH
# 4. PLACE THIS SCRIPT INSIDE OF 03_INPUT_50 AND RUN IT


mkdir 01_INPUT 02_PRTNRTH 03_INPUT_50 04_MAFFT 05_ALISCORE 06_ALICUT 07_IQTREE 08_PHPPRNR 09_RAXML 10_IQTREE 11_IQTREE 12_ASTRAL


# Removing orthologs with represented in less than 61 taxa from the proteinortho output
awk '/^#/ {header=$0; print $0}; $1 > 60' ../02_PRTNRTH/orthology_0.00001.proteinortho.tsv > ../02_PRTNRTH/rhabditina_reduced.tsv

# Using protein_grab_proteins.pl script to extract only orthologs
proteinortho_grab_proteins.pl -t -exact ../02_PRTNRTH/rhabditina_reduced.tsv ../01_INPUT/proteins/*.faa


# aligning fasta files
for FILENAME in *.fasta
do
    mafft --auto --thread 7 --maxiterate 1000  $FILENAME > ../04_MAFFT/$FILENAME
done

cd ../04_MAFFT
mkdir backup
find ./ -name "*.fasta" -exec cp {} backup/ \;

# cleaning alignments with aliscore and alicut combination
for FILENAME in *.fasta
do
    perl /Users/mohammedahmed/OrthoSelect/perl_scripts/aliscore.pl -i $FILENAME
    perl /Users/mohammedahmed/usearch/ALICUT_V2.31.pl -s
    rm -rf $FILENAME
    mv "ALICUT_"$FILENAME ../06_ALICUT/$FILENAME.out
done


# moving all text files to a different location and deleting other files

find ./ -name "*.txt" -exec mv {} ../05_ALISCORE/ \;
find ./ -name "*.svg" -exec mv {} ../05_ALISCORE/ \;
find ./ -name "*.xls" -exec mv {} ../05_ALISCORE/ \;

cd ../06_ALICUT
find . -name "*fasta.out" | xargs rename 's/.fasta.out/.fa/g'
find . -name "*.fa" | xargs gsed -i 's/_/|/g'

find ./ -name "*.fa" -exec cp {} ../07_IQTREE/ \;

cd ../07_IQTREE
find . -name "*.fa" | xargs rename 's/rhabditinareduced.tsv.//g'



# maximum likelihood trees with iqtree2

for FILENAME in *.fa
do
iqtree2 -s $FILENAME -st AA -m MFP -msub nuclear -B 1000 -T 5
done


# removing paralogs using phylopypruner
Phylopypruner --dir ./ --min-len 50 --trim-lb 5 --min-support 0.75 --prune MI --mask pdist --min-taxa 61 --outgroup PleSam2

cp phylopypruner_output/supermatrix.fas ../09_RAXML/
cp phylopypruner_output/partition_data.txt ../09_RAXML/
mv phylopypruner_output ../08_PHPPRNR

cd ../09_RAXML

sed 's/AUTO/LG/g' partition_data.txt > partition_data_rhabditina.txt


raxmlHPC-PTHREADS-SSE3 -s supermatrix.fas -n rhabditina -m PROTGAMMALG -o PleSam2 -p 12345 -q partition_data_rhabditina.txt -T 8 --asc-corr=lewis 2>&1 | tee logfile.txt

cp partition_data_rhabditina.txt ../10_IQTREE/
cp supermatrix.fas ../10_IQTREE/
cp RAxML_bestTree.rhabditina ../10_IQTREE/

cd ../10_IQTREE/

iqtree2 -nt 10 -bb 1000 -bnni -safe -st AA -s supermatrix.fas -m C60+F+G -fmax -seed 12345 -ft RAxML_bestTree.rhabditina -o PleSam2 --prefix output -q partition_data_rhabditina.txt 2>&1 | tee logfile.txt

find ../08_PHPPRNR/phylopypruner_output/output_alignments/ -name "*fa" -exec cp {} ../12_IQTREE \;

cd ../12_IQTREE
find . -name "*.fa" | xargs gsed -i 's/|/_/g'
for FILENAME in *.fa; do
iqtree -s $FILENAME -st AA -m MFP -msub nuclear -bb 1000 -nt 4
done


for tree in *.treefile
do
    basename=$(cut -d'.' -f1 <<< $tree)
    nw_ed $tree 'i & b<=75' o > "$basename"_BS75.fa.treefile
done
    
find ./ -name "*_BS75.fa.treefile" | xargs gsed 's/[|_].\{5,7\}:/:/g' >> rhabditina_gene.tre

java -jar -Xmx12000M -D"java.library.path=lib/" ~/Astral/astral.5.7.3.jar -i rhabditina_gene.tre -o rhabditina_consensus.tre 2>&1 |tee rhabditina.log


phylo_rename nematoda_consensus.tre
