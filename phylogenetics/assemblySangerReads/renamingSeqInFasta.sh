#!/bin/zsh

# Changes the description lines to match the name of the fasta file



for folder in *
do
	if [ -d $folder ]; then # checking if folder is a directory
        cd $folder && # moving into the folder
        for file in *.fasta # iterating over all .fasta files
        do
            oldname=$(grep '>' $file) # designating the original description line as old name
            newname=">"$(cut -d'.' -f1 <<< $file) # taking the file name without the extension as newname
            gsed -i "/^>/ s/$oldname/$newname/g" $file # substituting oldname with newname IN PLACE with the option '-i'
        done
        cd ../
	fi
done
				
				
				
