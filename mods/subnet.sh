#!/bin/bash
for i in `seq 221 250`;
do

	n_last=$(expr $i - 1)
	sed -i -e s/$n_last/$i/g main.tf

	terraform apply --auto-approve
	echo "Sleeping a few..."
	sleep 10
	terraform apply --auto-approve

	echo "Sleeping for a minute..."
	sleep 60

done
