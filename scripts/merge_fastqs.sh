# This script should merge all files from a given sample (the sample id is provided in the third argument)
# into a single file, which should be stored in the output directory specified by the second argument.
# The directory containing the samples is indicated by the first argument.
echo "Merging the files..."
input=$1
out=$2
sid=$3
if [ "$1" == "data" ]
then
	cat $1/$3-12.5dpp.1.1s_sRNA.fastq.gz $1/$3-12.5dpp.1.2s_sRNA.fastq.gz  > $2/$3-merged.fastq.gz
	echo "merged $sid"
else
	echo "Error"
fi


