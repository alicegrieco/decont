# This script should index the genome file specified in the first argument,
# creating the index in a directory specified by the second argument.

# The STAR command is provided for you. You should replace the parts surrounded by "<>" and uncomment it.

# STAR --runThreadN 4 --runMode genomeGenerate --genomeDir <outdir> --genomeFastaFiles <genomefile> --genomeSAindexNbases 9
mkdir -p res/contaminants_idx
genomefile=$1
outdir=$2

if [ "$2" == "res/contaminants_idx" ]
then
	STAR --runThreadN 4 --runMode genomeGenerate --genomeDir $outdir --genomeFastaFiles $genomefile --genomeSAindexNbases 9
else
	echo "Error"
fi

