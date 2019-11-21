# This script should merge all files from a given sample (the sample id is provided in the third argument)
# into a single file, which should be stored in the output directory specified by the second argument.
# The directory containing the samples is indicated by the first argument.
echo "Merging the files..."
sid=$4
for sid
do
	cat data/${sid}*.fastq.gz > out/merged/${sid}.merged.fastq.gz
done

echo "Merged $sid"

