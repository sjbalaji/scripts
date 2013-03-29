rm -rf ~/ds3/ 
mkdir ds3/
cp -r NetBeansProjects/ds1/src/ds1 ds3/
cp -r ~/prog/make.sh ~/prog/Manifest.txt ~/ds3
scp -r ~/ds3 hadoop@10.6.9.51:~/
scp -r ~/ds3/ hadoop@10.6.9.52:~/
