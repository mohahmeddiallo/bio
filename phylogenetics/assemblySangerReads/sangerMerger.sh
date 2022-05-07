#!/bin/bash


mkdir ab1
cp *.ab1 ab1

#cd ab1
#find . -name "*.ab1" | xargs rename 's/-/_/'

for fsequence in *.ab1
do
	if grep "988F" <<< $fsequence; then # eg F6001-16_988F_P2_SSU_A3_premixed.ab1
        fbasename=$(cut -d'.' -f1 <<< $fsequence) # eg F6001-13_988F_premixed
		rsequence=$(sed 's/988F/1912R/g' <<< $fsequence) # eg F6001-13_1912R_premixed.ab1
		rbasename=$(cut -d'.' -f1 <<< $rsequence) # eg F6001-13_1912R_premixed
		idbasename=$(cut -d'_' -f1 <<< $fsequence) # F6001-13
		seqret -sformat abi -osformat fastq $fsequence "$fbasename".fastq # convert foward read from abi to fastq
		echo -e "\nConverted $fsequence to "$fbasename".fastq\n" 
		seqret -sformat abi -osformat fastq $rsequence "$rbasename"_tmp.fastq # convert reverse read from abi to fastq but saving as temporary file (needs to be reverse complemented
		seqkit seq -p -r "$rbasename"_tmp.fastq > "$rbasename".fastq && rm "$rbasename"_tmp.fastq  # reverse complementing the temporary file and removing the temporary file
		echo -e "\nConverted and reverse complemented $rsequence to "$rbasename".fastq\n"
		echo -e "Quality filtering "$fbasename".fastq\n\n"
		seqtk trimfq -q 0.01  "$fbasename".fastq > "$fbasename"_fp.fastq # quality trimming forward read
		echo -e "\n\nQuality filtering "$rbasename".fastq\n\n"
		seqtk trimfq -q 0.01  "$rbasename".fastq > "$rbasename"_fp.fastq # quality trimming reverse read
		merger -asequence "$fbasename"_fp.fastq -bsequence "$rbasename"_fp.fastq \
			-outseq "$idbasename"_SSU1.fasta -outfile "$idbasename"_SSU1.megamerger # merging quality checked forward and reverse reads
		echo -e "\nMerged "$rbasename".fastq and  "$rbasename"_fp.fastq into "$idbasename"_SSU1.fasta\n"
	elif grep "1813F" <<< $fsequence; then
		fbasename=$(cut -d'.' -f1 <<< $fsequence)
		rsequence=$(sed 's/1813F/2646R/g' <<< $fsequence)
		rbasename=$(cut -d'.' -f1 <<< $rsequence)
		idbasename=$(cut -d'_' -f1 <<< $fsequence)
		seqret -sformat abi -osformat fastq $fsequence "$fbasename".fastq
		echo -e "\n\nConverted $fsequence to "$fbasename".fastq\n\n" 
		seqret -sformat abi -osformat fastq $rsequence "$rbasename"_tmp.fastq #&& 
		seqkit seq -p -r "$rbasename"_tmp.fastq > "$rbasename".fastq && rm "$rbasename"_tmp.fastq 
		echo -e "\n\nConverted and reverse complemented $rsequence to "$rbasename".fastq\n\n"
		echo -e "Quality filtering "$fbasename".fastq\n\n"
		seqtk trimfq -q 0.01  "$fbasename".fastq > "$fbasename"_fp.fastq
		echo -e "\n\nQuality filtering "$rbasename".fastq\n\n"
		seqtk trimfq -q 0.01  "$rbasename".fastq > "$rbasename"_fp.fastq
		merger -asequence "$fbasename"_fp.fastq -bsequence "$rbasename"_fp.fastq \
			-outseq "$idbasename"_SSU2.fasta -outfile "$idbasename"_SSU2.megamerger
		echo -e "\n\nMerged "$rbasename".fastq and  "$rbasename"_fp.fastq into "$idbasename"_SSU2.fasta\n\n"
	elif grep "D2AF" <<< $fsequence; then
		fbasename=$(cut -d'.' -f1 <<< $fsequence)
		rsequence=$(sed 's/D2AF/D3BR/g' <<< $fsequence)
		rbasename=$(cut -d'.' -f1 <<< $rsequence)
		idbasename=$(cut -d'_' -f1 <<< $fsequence)
		seqret -sformat abi -osformat fastq $fsequence "$fbasename".fastq
		echo -e "\n\nConverted $fsequence to "$fbasename".fastq\n\n" 
		seqret -sformat abi -osformat fastq $rsequence "$rbasename"_tmp.fastq #&& 
		seqkit seq -p -r "$rbasename"_tmp.fastq > "$rbasename".fastq && rm "$rbasename"_tmp.fastq 
		echo -e "\n\nConverted and reverse complemented $rsequence to "$rbasename".fastq\n\n"
		echo -e "Quality filtering "$fbasename".fastq\n\n"
		seqtk trimfq -q 0.01  "$fbasename".fastq > "$fbasename"_fp.fastq
		echo -e "\n\nQuality filtering "$rbasename".fastq\n\n"
		seqtk trimfq -q 0.01  "$rbasename".fastq > "$rbasename"_fp.fastq
		merger -asequence "$fbasename"_fp.fastq -bsequence "$rbasename"_fp.fastq \
			-outseq "$idbasename"_LSU.fasta -outfile "$idbasename"_LSU.megamerger
		echo -e "\n\nMerged "$rbasename".fastq and  "$rbasename"_fp.fastq into "$idbasename"_SSU2.fasta\n\n"
	else
		:
	fi
done

for contig in *SSU1.fasta; 
do
	idbasename=$(cut -d'_' -f1 <<< $contig)
	contig2=$(sed 's/SSU1/SSU2/g' <<< $contig)
	merger -asequence $contig -bsequence $contig2 -outseq "$idbasename".fasta -outfile "$idbasename".megamerger
done
			
			
rm *.fastq *ab1


for file in *fasta
do
    basename=$(cut -d_ -f1 <<< $file)
    if [ ! -d "$basename" ]; then
        mkdir $basename
        mv "$basename"* $basename
    else
        echo
        echo "moved $file already"
        echo
    fi
done
			

		
