IFS=$'\n';
for file in `cat links.txt`; do
   echo "Downloading $file";
   wget $file
done
