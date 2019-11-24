echo "The pipeline is starting..."
echo
echo "Obtaining the data..."

#Download all the files specified in data/filenames
wget -nc -i data/urls -P data/
echo
echo
echo "Downloading the contaminants..."
# Download the contaminants fasta file, and uncompress it
if [ -f "res/contaminants.fasta.gz" ]
then
	echo "The contaminants have been already downloaded"
else
	bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes
	echo "Contaminants have been downloaded"
fi
echo
echo
echo
echo "Running STAR index..."
# Index the contaminants file
if [ -d "res/contaminants_idx/" ]
then
	echo "It already exists"
else
	bash scripts/index.sh res/contaminants.fasta res/contaminants_idx
fi
echo
echo
echo "Merging the samples into a single file..."
# Merge the samples into a single file
echo
echo
mkdir -p out/merged
for sid in $(ls data/*.fastq.gz | cut -d "-" -f1 | sed "s:data/::" | sort | uniq ) #Todo
do
	if [ -f "out/merged/${sid}-merged.fastq.gz" ]
	then
		echo "The samples have been already merged before"
	else

		bash scripts/merge_fastqs.sh data out/merged $sid
	fi
done
echo
echo
echo " Running Cutadapt..."
mkdir -p log/cutadapt
mkdir -p out/trimmed
for sid in $(ls out/merged/*.fastq.gz | cut -d "-" -f1 | sed 's:out/merged::' | sort | uniq) #TODO
do
	if [ -f "out/trimmed/${sid}.trimmed.fastq.gz" ]
	then
		echo "the cutadapt out files already exist"
	else
		cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed -o out/trimmed/${sid}.trimmed.fastq.gz out/merged/${sid}-merged.fastq.gz > log/cutadapt/${sid}.log
		echo "Cutadapt has done"
	fi
done
# TODO: run cutadapt for all merged files
# cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed -o <trimmed_file> <input_file> > <log_file>
echo
echo
#TODO: run STAR for all trimmed files
echo
echo
echo "Running STAR for all trimmed files..."
for fname in out/trimmed/*.fastq.gz
do
    # you will need to obtain the sample ID from the filename
	sid=$(echo $fname | sed 's:out/trimmed/::' | cut -d "." -f1)
	if [  -f "out/star/$sid/Log.final.out" ]
	then
		echo "the star has been already run for all trimmed files"
	else
    # mkdir -p out/star/$sid
		mkdir -p out/star/$sid
		STAR --runThreadN 4 --genomeDir res/contaminants_idx --outReadsUnmapped Fastx --readFilesIn ${fname} --readFilesCommand zcat --outFileNamePrefix out/star/${sid}/
	fi
    # STAR --runThreadN 4 --genomeDir res/contaminants_idx --outReadsUnmapped Fastx --readFilesIn <input_file> --readFilesCommand zcat --outFileNamePrefix <output_directory>
done

echo
echo
echo "Creating a log file containing information from CUTADAPT and STAR logs..."
echo
echo
# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci


if [ -f "log/pipeline.log" ]
then
	echo "The log file already exists"
else
	for sid in $(ls data/*.fastq.gz | cut -d "-" -f1 | sed 's:data/::' | sort | uniq )
	do
        	echo "                                                          " >> log/pipeline.log
        	echo ${sid} >> log/pipeline.log
        	echo "CUTADAPT" >> log/pipeline.log
        	echo $(cat log/cutadapt/${sid}.log | grep  "Reads with adapters") >> log/pipeline.log
        	echo $(cat log/cutadapt/${sid}.log | grep  "total basepairs") >> log/pipeline.log
        	echo "                                                          " >> log/pipeline.log
        	echo "STAR" >> log/pipeline.log
        	echo $(cat out/star/${sid}/Log.final.out | grep "Uniquely mapped reads %") >> log/pipeline.log
        	echo $(cat out/star/${sid}/Log.final.out | grep  "% of reads mapped to multiple loci") >> log/pipeline.log
        	echo $(cat out/star/${sid}/Log.final.out | grep  "% of reads mapped to multiple loci") >> log/pipeline.log
		echo
		echo
		echo "Info about ${sid} have been added in the log file"
	done
fi
echo
echo
echo
echo
echo
echo "The pipeline has been finalized"

