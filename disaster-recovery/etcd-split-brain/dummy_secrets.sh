#!/bin/bash
task(){
  dd bs=1024 count=1 </dev/urandom > random-"$1"
  echo "" >> random-"$1"
  echo "GoodData" >> random-"$1"
  kubectl -n default create secret generic secret-"$1" --from-literal=username=GoodData --from-file=password=./random-"$1"
  rm -f random-"$1"
}
N=10
(
for count in {000000..100000}
do
   ((i=i%N)); ((i++==0)) && wait
   task "$count" &
done
)
