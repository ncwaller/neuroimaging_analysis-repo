#!/bin/bash

# used to submit jobs to a remote super computing cluster for fMRIprep preprocessing

for subject in $(cat subjectlist.txt); do

	export subject
	echo "Submitting $subject"
	sbatch --job-name=$subject --output=/scratch/...INSERT/job_output/$subject-%j.log fMRIprep.sbat #insert paths and .sbat script

done
