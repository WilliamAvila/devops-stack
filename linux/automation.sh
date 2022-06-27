#!/bin/bash

#Generate Unique tag
uuid=$(uuidgen)
tag=${uuid:0:7}
image="webserver:${tag}"
echo $image 

#Build Dockerfile
cd ../dockerize
podman build -t $image .
cd ../linux

# Assign the template script and create New app yaml
filename="script.yaml"
newfile="new-app.yaml"
placeholder="MY_NEW_IMAGE"

sed "s/$placeholder/$image/g" $filename > $newfile

#Diff kubectl
kubectl diff -f $newfile
