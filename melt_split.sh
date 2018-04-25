#! /bin/bash
#$ -V
#$ -cwd
#$ -N MELT_split_AFROSINE
#$ -o $JOB_NAME.o.$JOB_ID
#$ -e $JOB_NAME.e.$JOB_ID
#$ -q omni
#$ -pe mpi 36
#$ -P quanah

WORKDIR=/lustre/scratch/lblancob/2016_08-03-Afrosine2-Elephant/melt_elephants/melt_split/Combine_melt
afrosine=/lustre/scratch/lblancob/2016_08-03-Afrosine2-Elephant/melt_files
REF_HOME=/lustre/scratch/lblancob/2016_08-03-Afrosine2-Elephant/Reference_Genome
REFGENOME=Lafr.Chromosomes.v2.fasta
MELT_HOME=/lustre/work/daray/software/MELTv2.0.2
BED_HOME=/lustre/scratch/lblancob/2016_08-03-Afrosine2-Elephant/melt_files
SORTED_BAM=/lustre/scratch/lblancob/2016_08-03-Afrosine2-Elephant/melt_elephants/melt_bam
THREADS=30

cd $WORKDIR

#=== AfroSINE discovery
 
for i in Asha DPZ DS1546 KB OR_ZOO Pavarthy SL0001 Uno Watoto; do \
java \
-Xmx6G \
-jar $MELT_HOME/MELT.jar IndivAnalysis \
-w $WORKDIR \
-l $SORTED_BAM/${i}_sorted.bam \
-c 14 \
-h $REF_HOME/$REFGENOME \
-t $afrosine/AFROSINE_MELT.zip \
-r 150; done
 
java \
-Xmx6G \
-jar $MELT_HOME/MELT.jar GroupAnalysis \
-l $WORKDIR \
-h $REF_HOME/Lafr.Chromosomes.v2.fasta \
-n $BED_HOME/Loxo_hgTables.bed \
-t $afrosine/AFROSINE_MELT.zip \
-w $WORKDIR \
-r 150
 
for i in Asha DPZ DS1546 KB OR_ZOO Pavarthy SL0001 Uno Watoto; do \
java \
-Xmx6G \
-jar $MELT_HOME/MELT.jar Genotype \
-w $WORKDIR \
-l $SORTED_BAM/${i}_sorted.bam \
-h $REF_HOME/$REFGENOME \
-t $afrosine/AFROSINE_MELT.zip \
-p $WORKDIR; done
 
ls $WORKDIR/*.tsv > $WORKDIR/AfroSINE_list.txt
java \
-Xmx6G \
-jar $MELT_HOME/MELT.jar MakeVCF \
-f $WORKDIR/AfroSINE_list.txt \
-h $REF_HOME/Lafr.Chromosomes.v2.fasta \
-t $afrosine/AFROSINE_MELT.zip \
-w $WORKDIR \
-p $WORKDIR 
