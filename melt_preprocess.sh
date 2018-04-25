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
SAMTOOLS=/lustre/work/daray/software/samtools-1.3/samtools
REPAIR=/lustre/scratch/lblancob/apps/bbmap
MELT=/lustre/scratch/lblancob/apps/MELTv2.1.4

#preprocess files to use before running melt 

#naming samples
SAMPLE="Asha DPZ DS1546 KB OR_ZOO Pavarthy SL0001 Uno Watoto"

##extract each reads from the original bam file 
for s in ${SAMPLE}
do
$SAMTOOLS view -Sb -o $FILE"_R1.bam" $FILE"_R1.sam"
$SAMTOOLS view -Sb -o $FILE"_R2.bam" $FILE"_R2.sam"
done 

##conver the reads files to from bam to fastq
module load intel bedtools

for s in ${SAMPLE}
do
bedtools bamtofastq -i $FILE"_R1.bam" -fq $FILE"_R1.fastq"
bedtools bamtofastq -i $FILE"_R2.bam" -fq $FILE"_R2.fastq"
done 

## repear file, this will allow melt to run correctly
$REPAIR/repair.sh in=$FILE"_R1.fastq" in2=$FILE"R2.fastq" out=$FILE"_elephant_repair.fastq" outs=$FILE"_out_singleton.out"

#############
###align the repaired reads to the reference genome
#############

#load modules used 
module load intel bwa

bwa mem -M -p \
$REF_HOME/Lafr.Chromosomes.v2.fasta \
$FILE"_elephant_repaired.fastq" \
-t 30 \
> elephant_aln_pe.sam

############
###After the reads have been aligned then we convert
###the sam file to a bam file and remove the reads 
###that did not map 
############

$SAMTOOLS view \
-F 4 \
-q 20 \
-b \
-@ 34 \
-o elephant_R3.bam \
elephant_aln_pe.sam

##load the module java
module spider java

java \
-Xmx24g \
-Djava.io.tmpdir=tmp \
-jar $PICARD_HOME/picard.jar SortSam \
SORT_ORDER=coordinate \
I=elephant_R3.bam \
O=elephant_sorted.bam \
MAX_RECORDS_IN_RAM=1000000 \
VALIDATION_STRINGENCY=LENIENT \
CREATE_INDEX=TRUE \
TMP_DIR=tmp;

####
##Run the preprocess command to creat the files needed
##for melt
####

$MELT/MELT.jar Preprocess \
elephant_sorted.bam $REF_HOME/Lafr.Chromosomes.v2.fasta
