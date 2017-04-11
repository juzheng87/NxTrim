#get data
r1=EcMG1_ATGTCA_L001_R1_001.fastq.gz
r2=EcMG1_ATGTCA_L001_R2_001.fastq.gz
ref=EcMG.fna
if [ ! -f $ref ]
then
    curl -O https://s3-eu-west-1.amazonaws.com/nxtrim-examples/bacteria/${ref}
fi
if [ ! -f $r1 ]
then
    curl -O https://s3-eu-west-1.amazonaws.com/nxtrim-examples/bacteria/${r1}
fi
if [ ! -f $r2 ]
then
    curl -O https://s3-eu-west-1.amazonaws.com/nxtrim-examples/bacteria/${r2}
fi
bwa index $ref

#test stdout and alignment
out=EcMG.bam
../nxtrim --stdout -1 $r1 -2 $r2 | bwa mem  -p $ref - | samtools view - -b -o $out

out=EcMG.rf.bam
../nxtrim --rf --stdout -1 $r1 -2 $r2 | bwa mem  -p $ref - | samtools view -b -o $out

out=EcMG.mp.bam
../nxtrim --stdout-mp -1 $r1 -2 $r2 | bwa mem  -p $ref - | samtools view -b -o $out

out=EcMG.un.bam
../nxtrim --stdout-un -1 $r1 -2 $r2 | bwa mem  -p $ref - | samtools view -b -o $out


##assemble with velvet
../nxtrim -1 $r1 -2 $r2  -O EcMG
velveth output_dir 61 -short -fastq.gz EcMG.se.fastq.gz -shortPaired2 -fastq.gz EcMG.pe.fastq.gz -shortPaired3 -fastq.gz EcMG.mp.fastq.gz -shortPaired4 -fastq.gz EcMG.unknown.fastq.gz
velvetg output_dir -exp_cov auto -cov_cutoff auto -shortMatePaired4 yes


##do some alignments 
../nxtrim -s .7 -w -1 EcMG1_ATGTCA_L001_R1_001.fastq.gz -2 EcMG1_ATGTCA_L001_R2_001.fastq.gz --stdout-mp | bwa mem EcMG.fna -p - | gzip -1 > mp.sw.bam

 ../nxtrim  -1 EcMG1_ATGTCA_L001_R1_001.fastq.gz -2 EcMG1_ATGTCA_L001_R2_001.fastq.gz --stdout-mp | bwa mem EcMG.fna -p - | gzip -1 > mp.ham.bam

 ../nxtrim -s .7 -w -1 EcMG1_ATGTCA_L001_R1_001.fastq.gz -2 EcMG1_ATGTCA_L001_R2_001.fastq.gz --stdout-un | bwa mem EcMG.fna -p - | gzip -1 > un.sw.bam

 ../nxtrim  -1 EcMG1_ATGTCA_L001_R1_001.fastq.gz -2 EcMG1_ATGTCA_L001_R2_001.fastq.gz --stdout-un | bwa mem EcMG.fna -p - | gzip -1 > un.ham.bam
