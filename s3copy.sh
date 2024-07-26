#!/bin/bash
set -e

# get source variables
read -p "enter source bucket name: " SourceBucket

read -p "enter source access key id: " SourceKeyid

read -p "enter source secret access key: " Sourceaccesskey

read -p "enter source S3 Url: "  SourceS3Url

mkdir source

# backend: create password file

echo $SourceKeyid:$Sourceaccesskey > source-password-s3fs
chmod 600 source-password-s3fs

# mount bucket to source dir

s3fs $SourceBucket source -o passwd_file=source-password-s3fs -o url=https://$SourceS3Url -o allow_other

echo "mounting source bucket please wait"

sleep 15

#Check to see if source is mounted. if mounted move on

if cat /proc/mounts | grep source > /dev/null; then
    echo "The source has been mounted!"
else
    echo "The mount failed please check your information and try again."
    exit 0
fi


# get Destination variables
read -p "enter destination buket name: " DestBucket

read -p "enter destination access key id: " DestKeyid

read -p "enter destination secret access key: " Destaccesskey

read -p "enter destination S3 Url: "  destS3Url

mkdir destination

# creeate password file

#create password file
echo $DestKeyid:$Destaccesskey > dest-password-s3fs
chmod 600 dest-password-s3fs

# mount bucket to destination dir

s3fs $DestBucket destination -o passwd_file=dest-password-s3fs -o url=https://$destS3Url -o allow_other

echo "mounting destination bucket please wait"

sleep 15
#Check to see if destination is mounted. if mounted move on

if cat /proc/mounts | grep destination > /dev/null; then
    echo "The destination has been mounted!"
else
    echo "The mount failed please check your information and try again."
    exit 0
fi

# perform copy output logs to log dir
echo "File copy Started Standby!"
rsync -avP --progress source/ destination/ --log-file=output.txt
echo "File copy completed!, run "cat output.txt" to view the results."

#unmount source and destination bkuckets.
umount source/
umount destination/
rm -r source/
rm -r destination/  
rm dest-password-s3fs
rm source-password-s3fs
