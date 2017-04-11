#!/bin/bash

cat workdir_pp.*/slurm*.out | grep GCUT | awk '{print $6}' | sort -g 
