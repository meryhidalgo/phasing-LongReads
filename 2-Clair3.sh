#!/bin/bash

#conda activate phasing

# run clair3 like this afterward
reference="/media/neuro-rna/E2285B0C285ADF5B/experiments/reference_files/human/GRCh38.primary_assembly.genome.fa"
MODEL_NAME="r1041_e82_400bps_sup_v410"
#bam_dir=
THREADS=4

# Carpeta donde guardar outputs
mkdir -p clair3_results

# Loop sobre todos los BAMs que terminen en _minimapY.bam
for bam in bams/*_minimapY.bam; do
    sample=$(basename "$bam" _minimapY.bam)
    
    echo "=== Procesando muestra: $sample ==="
    
    # Carpeta de salida específica para la muestra
    outdir="clair3_results/${sample}"
    mkdir -p "$outdir"
    
    # Ejecutar Clair3
    run_clair3.sh \
        --bam_fn="$bam" \
        --ref_fn="$reference" \
        --threads=$THREADS \
        --platform="ont" \
        --model_path="${CONDA_PREFIX}/bin/models/${MODEL_NAME}" \
        --output="$outdir"
    
    echo "=== Muestra $sample completada ==="
done