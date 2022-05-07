#!/bin/zsh


forwardPrimer=$1
reversePrimer=$2
markerGene=$3
fsequence=$4
rsequence=$5



#for file in *.ab1 ; do mv $file $(gsed 's/P2_.*premixed/premixed/g' <<< $file); echo renamed $file to $(sed 's/P2_.*premixed/premixed/g' <<< $file); done

for fsequence in *.ab1
do
    if grep $forwardPrimer <<< $fsequence; then
        fbasename=$(cut -d'.' -f1 <<< $fsequence) # eg F6001-13_988F_premixed
        echo $fbasename
        rsequence=$(sed "s/$forwardPrimer/$reversePrimer/g" <<< $fsequence) # eg F6001-13_1912R_premixed.ab1
        echo $rsequence
        rbasename=$(cut -d'.' -f1 <<< $rsequence) # eg F6001-13_1912R_premixed
        echo $rbasename
        idbasename=$(cut -d'_' -f1 <<< $fsequence) # F6001-13
        echo $idbasename
        seqret -sformat abi -osformat fastq $fsequence "$fbasename".fastq && # convert foward read from abi to fastq
        echo -e "\nConverted $fsequence to "$fbasename".fastq\n"
        seqret -sformat abi -osformat fastq $rsequence "$rbasename"_tmp.fastq &&# convert reverse read from abi to fastq but saving as temporary file (needs to be reverse complemented
        seqkit seq -p -r "$rbasename"_tmp.fastq > "$rbasename".fastq && rm "$rbasename"_tmp.fastq  &&# reverse complementing the temporary file and removing the temporary file
        echo -e "\nConverted and reverse complemented $rsequence to "$rbasename".fastq\n"
        seqtk trimfq -q 0.01  "$fbasename".fastq > "$fbasename"_fp.fastq &&# quality trimming forward read
        echo -e "Quality filtering "$fbasename".fastq to "$fbasename"_fp.fastq\n\n"
        seqtk trimfq -q 0.01  "$rbasename".fastq > "$rbasename"_fp.fastq &&# quality trimming reverse read
        echo -e "\n\nQuality filtering "$rbasename".fastq to "$rbasename"_fp.fastq\n\n"
        merger -asequence "$fbasename"_fp.fastq -bsequence "$rbasename"_fp.fastq \
            -outseq "$idbasename"_"$markerGene".fasta -outfile "$idbasename"_"$markerGene".megamerger &&# merging quality checked forward and reverse reads
        echo -e "\nMerged "$fbasename"_fp.fastq and  "$rbasename"_fp.fastq into "$idbasename"_"$markerGene".fasta\n"
    else
        :
    fi
done

for file in *fasta
do
    basename=$(cut -d_ -f1 <<< $file)
    if [ ! -d "$basename" ]; then
        mkdir $basename
        for allfile in "$basename"*; do
            if ! [ -d "$allfile" ]; then
            mv $allfile $basename
            fi
        done
    else
        echo
        echo "moved $file already"
        echo
    fi
done



