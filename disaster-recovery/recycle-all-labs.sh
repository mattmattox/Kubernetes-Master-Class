#!/bin/bash

CPWD=`pwd`

for Dir in `echo */`
do
  echo "######################################################"
  echo "Working on $Dir"
  cd $Dir
  echo "Cleaning..."
  ./clean_nodes.sh
  echo "Building..."
  ./build.sh
  echo "Breaking..."
  ./break.sh
  echo "Verifying..."
  ./verify.sh
  cd $CPWD
  echo "######################################################"
done
