#!/bin/bash

# this is run when there are several data sets to be assembled in a batch
# this script assumes the raw 454 reads reside in a folder called 1_READS which in turn resides in
# another folder containing in its name "PR" and ends in "454"
# this script is run inside any folder that contains a list of folders specific to each dataset (species)
# for example:
# Litomosoides_sigmodontis_PRJEB2240_454 => 1_READS
# Ostertagia_ostertagi_PRJNA72577 => 1_READS

for folder in *PR*_454; do cd $folder/1_READS && ../../runassembly.sh && cd ../../; done

