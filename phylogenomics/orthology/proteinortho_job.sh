#!/bin/bash -l


#SBATCH -A snic2020-15-99
#SBATCH -p core
#SBATCH -n 18
#SBATCH -t 2-00:15:00
#SBATCH -J proteinortho_TRICHINELLIDA



proteinortho -project=orthology_0.00001 -clean -sim=0.97 -identity=50 proteins/*.faa

