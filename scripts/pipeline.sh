echo "the pipeline is starting..."
echo
echo "Obtaining the data..."

#Download all the files specified in data/filenames
for url in $(cat data/urls) #TODO
do
    bash scripts/download.sh $url data
done

echo
echo "Downloading the contaminants..."
# Download the contaminants fasta file, and uncompress it
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes
gunzip -k res/contaminants.fasta.gz
echo
echo
echo
echo "contaminats have been downloaded and uncompressed successfully"
echo
echo
echo "Running STAR index..."

# Index the contaminants file
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx


echo "Merging the samples into a single file..."
# Merge the samples into a single file
echo
mkdir -p out/merged
for sid in $(ls data/*.fastq.gz | cut -d "-" -f1 | sed "s:data/::" | sort | uniq ) #Todo
do
    bash scripts/merge_fastqs.sh data out/merged $sid
done


echo" Running Cutadapt..."
mkdir -p log/cutadapt
mkdir -p out/cutadapt
for sid in $(ls out/merged/*.fastq.gz | cut -d "-" -f1 | sed 's:out/merged::' | sort | uniq) #TODO
do
	cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed -o out/cutadapt/${sid}.trimmed.fastq.gz out/merged/${sid}.fastq.gz > log/cutadapt/${sid}.log
done

# TODO: run cutadapt for all merged files
# cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed -o <trimmed_file> <input_file> > <log_file>
echo "Cutadapt has done"
#TODO: run STAR for all trimmed files
echo "Running STAR for all trimmed files..."
for fname in out/trimmed/*.fastq.gz
do
    # you will need to obtain the sample ID from the filename
    sid=$(echo $fname | sed 's:out/trimmed/::' | cut -d "." -f1)

    # mkdir -p out/star/$sid
mkdir -p out/star/$sid
STAR --runThreadN 4 --genomeDir res/contaminants_idx --outReadsUnmapped Fastx --readFilesIn $fname --readFilesCommand zcat --outFileNamePrefix out/star/$sid

    # STAR --runThreadN 4 --genomeDir res/contaminants_idx --outReadsUnmapped Fastx --readFilesIn <input_file> --readFilesCommand zcat --outFileNamePrefix <output_directory>
done

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
