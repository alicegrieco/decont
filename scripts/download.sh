# This script should download the file specified in the first argument ($1), place it in the directory specified in the second argument, 
# and *optionally* uncompress the downloaded file with gunzip if the third argument contains the word "yes".
url=$1
data=$2
name=$(basename $url)
if [ "$3" == "yes" ]
then
	wget -P $data $url
	gunzip -k $data/$name
else
	wget -P $data $url
fi


