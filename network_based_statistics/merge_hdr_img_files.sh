#!/bin/bash

# Iterate through numbers from 001 to 232
for i in $(seq -f "%03g" 1 232); do
  # Construct the filename
  filename="Schaefer2018_200Parcels_7Networks_order_Tian_Subcortex_S2_3T_MNI152NLin2009cAsym_2mm.cluster${i}.rex.roi.hdr"
  
  # Check if the file exists
  if [ -f "$filename" ]; then
    # Run the fslchfiletype command on the file
    fslchfiletype NIFTI "$filename"
    echo "Converted $filename to NIFTI format."
  else
    echo "File $filename does not exist."
  fi
done
