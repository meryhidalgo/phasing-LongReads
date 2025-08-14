#!/bin/bash

#conda activate phasing

mkdir -p QC_results 

for BAM in bams/*_minimapY.bam; do
    filename=$(basename "$BAM")
    prefix="${filename%%_minimapY.bam}"
    
    echo "Procesando muestra: $prefix"

    # bamstats
    bamstats "$BAM" > "QC_results/${prefix}_bamstats.txt"

    # mosdepth
    mosdepth "QC_results/${prefix}" "$BAM"
done