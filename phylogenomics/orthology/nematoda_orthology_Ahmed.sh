#!/bin/bash

# A SCRIPT FOR PHYLOGENETIC ANALYSIS.
# THIS IS RUN AFTER PROTEINORTHO HAS BEEN RUN
# 1. CREATE THE FOLLOWING DIRECTORIES {01_INPUT 02_PRTNRTH 03_INPUT_50 04_MAFFT 05_ALISCORE 06_ALICUT 07_IQTREE 08_PHPPRNR 09_RAXML 10_IQTREE 11_IQTREE 12_ASTRAL}
# 2. PLACE THE PROTEIN FILES USED FOR PROTEINORTHO IN 01_INPUT
# 3. PLACE THE PROTEINORTHO RESULTS IN 02_PRTNRTH
# 4. PLACE THIS SCRIPT INSIDE OF 03_INPUT_50 AND RUN IT


mkdir 01_INPUT 02_PRTNRTH 03_INPUT_50 04_MAFFT 05_ALISCORE 06_ALICUT 07_IQTREE 08_PHPPRNR 09_RAXML 10_IQTREE 11_IQTREE 12_ASTRAL


# Removing orthologs with representation in less 50% or less of the total number of OTUS (=46) from the .tsv file
awk '/^#/ {header=$0; print $0}; $1 > 45' ../02_PRTNRTH/orthology_0.00001.proteinortho.tsv > ../02_PRTNRTH/nematoda_reduced.tsv

# Using protein_grab_proteins.pl script to extract only orthologs from the .tsv file
proteinortho_grab_proteins.pl -t -exact ../02_PRTNRTH/nematoda_reduced.tsv ../01_INPUT/proteins/*.faa


# aligning fasta files
for FILENAME in *.fasta
do
	mafft --auto --maxiterate 1000  $FILENAME > ../04_MAFFT/$FILENAME
done

# making backup of alignments before cleaning
cd ../04_MAFFT
mkdir backup
find ./ -name "*.fasta" -exec cp {} backup/ \;

# cleaning alignments with aliscore and alicut combination
for FILENAME in *.fasta
do
	perl /Users/mohammedahmed/OrthoSelect/perl_scripts/aliscore.pl -i $FILENAME
	perl /Users/mohammedahmed/usearch/ALICUT_V2.31.pl -s
	rm -rf $FILENAME
	mv "ALICUT_"$FILENAME ../06_ALICUT/$FILENAME.out # move output files to 06_ALICUT
done


# moving all text files to a different location and deleting other files

find ./ -name "*.txt" -exec mv {} ../05_ALISCORE/ \;
find ./ -name "*.svg" -exec mv {} ../05_ALISCORE/ \;
find ./ -name "*.xls" -exec mv {} ../05_ALISCORE/ \;

cd ../06_ALICUT
find . -name "*fasta.out" | xargs rename 's/.fasta.out/.fa/g' # change the extensions from '.fasta.out' to '.fa'
find . -name "*.fa" | xargs gsed -i 's/_/|/g'

# copying cleaned alignmets into 07_IQTREE for iqtree run
find ./ -name "*.fa" -exec cp {} ../07_IQTREE \;

cd ../07_IQTREE
# shortening the names of the alignments eg. nematodareduced.tsv.Orthogroup0.fasta to Orthogroup0.fasta
find . -name "*.fa" | xargs rename 's/nematodareduced.tsv.//g'

# maximum likelihood trees with iqtree2
for FILENAME in *.fa
do
iqtree2 -s $FILENAME -st AA -m MFP -msub nuclear -B 1000 -T 5
done


# removing paralogs using phylopypruner
Phylopypruner --dir ./ --min-len 50 --trim-lb 5 --min-support 0.75 --prune MI --mask pdist --min-taxa 45 --outgroup PplCau5

# copying supermatrix and partition data files for RAxML from the phylopruner output
cp phylopypruner_output/supermatrix.fas ../09_RAXML/
cp phylopypruner_output/partition_data.txt ../09_RAXML/
mv phylopypruner_output ../08_PHPPRNR

# generating maximum likelihood tree


cd ../09_RAXML
# change the model from AUTO to LG in the partition file
sed 's/AUTO/LG/g' partition_data.txt > partition_data_nematoda.txt

# generating the guid tree using RAxML
raxmlHPC-PTHREADS-SSE3 -s supermatrix.fas -n nemaFull -m PROTGAMMALG -o PplCau5 -p 12345 -q partition_data_nematoda.txt -T 8 --asc-corr=lewis 2>&1 | tee logfile.txt

# copying the same supermatrix file, edited partition data file and the guide tree from the RAxML output for iqtree ML tree
cp partition_data_nematoda.txt ../10_IQTREE/
cp supermatrix.fas ../10_IQTREE/
cp RAxML_bestTree.nemaFull.tre ../10_IQTREE/

cd ../10_IQTREE/
# generating the main ML tree using iqtree2
iqtree2 -nt 10 -bb 1000 -bnni -safe -st AA -s supermatrix.fas -m C60+F+G -fmax -seed 12345 -ft RAxML_bestTree.nemaFull.tre -o PplCau5 --prefix output -q partition_data_nematoda.txt 2>&1 | tee logfile.txt


# gener
mv phylopypruner_output ../08_PHPPRNR

find ../08_PHPPRNR/phylopypruner_output/output_alignments/ -name "*fa" -exec cp {} ../10_IQTREE \;

cd ../10_IQTREE
for FILENAME in *.fa; do
iqtree2 -s $FILENAME -st AA -m MFP -msub nuclear -B 1000 -T 4
done


for tree in *.treefile
do
    basename=$(cut -d'.' -f1 <<< $tree)
    nw_ed $tree 'i & b<=75' o > "$basename"_BS75.fa.treefile
done


find ./ -name "*_BS75.fa.treefile" | xargs gsed 's/_.\{5,7\}:/:/g' >> nematoda_gene.tre


java -jar -Xmx12000M -D"java.library.path=lib/" ~/Astral/astral.5.7.3.jar -i nematoda_gene.tre -o nematoda_consensus.tre 2> nematoda.log


phylo_rename nematoda_consensus.tre
