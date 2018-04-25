#! /bin/bash
#$ -V
#$ -cwd
#$ -N MELT_split_AFROSINE
#$ -o $JOB_NAME.o.$JOB_ID
#$ -e $JOB_NAME.e.$JOB_ID
#$ -q omni
#$ -pe mpi 36
#$ -P quanah

WORKDIR=/lustre/scratch/lblancob/2016_08-03-Afrosine2-Elephant/melt_elephants/melt_del
BAM_HOME=/lustre/scratch/lblancob/2016_08-03-Afrosine2-Elephant/melt_elephants/melt_bam
REF_HOME=/lustre/scratch/lblancob/2016_08-03-Afrosine2-Elephant/Reference_Genome
MELT_FILES=/lustre/scratch/lblancob/2016_08-03-Afrosine2-Elephant/melt_files
MELT_HOME=/lustre/work/daray/software/MELTv2.0.2
 
SAMPLE="Asha DPZ DS1546 KB OR_ZOO Pavarthy SL0001 Uno Watoto"
for s in ${SAMPLE}
do
java \
-Xmx2g \
-jar $MELT_HOME/MELT.jar Deletion-Genotype \
-w $WORKDIR \
-l $BAM_HOME/${s}"_sorted.bam" \
-b $MELT_FILES/AfroSINE.out.bed \
-h $REF_HOME/Lafr.Chromosomes.v2.fasta;
done

#List of the tsv
ls $WORKDIR/*.tsv > AfroSINE_list.txt

#Deletion Merge

java \
-jar $MELT_HOME/MELT.jar Deletion-Merge \
-l AfroSINE_list.txt \
-b $MELT_FILES/AfroSINE.out.bed  \
-h $REF_HOME/Lafr.Chromosomes.v2.fasta \
-o AfroSINE.merge.vcf
