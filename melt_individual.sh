#! /bin/bash
#$ -V
#$ -cwd
#$ -N MELT_split_AFROSINE
#$ -o $JOB_NAME.o.$JOB_ID
#$ -e $JOB_NAME.e.$JOB_ID
#$ -q omni
#$ -pe mpi 36
#$ -P quanah

WORKDIR=/lustre/scratch/lblancob/2016_08-03-Afrosine2-Elephant/melt_elephants/melt_split_AFROSINE
afrosine=/lustre/scratch/lblancob/2016_08-03-Afrosine2-Elephant/melt_files/AFROSINE_Zips
REF_HOME=/lustre/scratch/lblancob/2016_08-03-Afrosine2-Elephant/Reference_Genome
REFGENOME=Lafr.Chromosomes.v2.fasta
MELT_HOME=/lustre/scratch/lblancob/apps/MELTv2.1.4
BED_HOME=/lustre/scratch/lblancob/2016_08-03-Afrosine2-Elephant/melt_files
SORTED_BAM=/lustre/scratch/lblancob/2016_08-03-Afrosine2-Elephant/melt_elephants/melt_preprocess_bam
THREADS=30

cd $WORKDIR
#=== AfroSINE discovery
##1.Load all modules needed for to run this script

module load gnu 
module load bowtie2
module load intel 
module load samtools/1.7.0-intel
 
for i in Asha DPZ DS1546 KB OR_ZOO Pavarthy SL0001 Uno Watoto; do \
java \
-Xmx6G \
-jar $MELT_HOME/MELT.jar IndivAnalysis \
-w $WORKDIR \
-l $SORTED_BAM/${i}_sorted.bam \
-c 14 \
-h $REF_HOME/$REFGENOME \
-t $afrosine/AFROSINE_MELT.zip \
-r 150; 
done
