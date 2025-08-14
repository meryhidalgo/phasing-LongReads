#!/bin/bash

#conda activate phasing
#!/bin/bash

reference="/media/neuro-rna/E2285B0C285ADF5B/experiments/reference_files/human/GRCh38.primary_assembly.genome.fa"

mkdir -p phased_results

for vcf in clair3_results/*/merge_output.vcf.gz; do
    sample=$(basename "$(dirname "$vcf")")
    bam="bams/${sample}_minimapY.bam"

    #soluciono problema de nombres sample
    fixed_vcf="phased_results/${sample}_fixed.vcf.gz"
    bcftools reheader -s <(echo $sample) "$vcf" -o "$fixed_vcf"
    tabix -p vcf "$fixed_vcf"

    fixed_bam="phased_results/${sample}_RG.bam"
    samtools addreplacerg -r "@RG\tID:1\tSM:${sample}" -o "$fixed_bam" "$bam"
    samtools index "$fixed_bam"

    #phasing
    phased_vcf="phased_results/${sample}_phased.vcf.gz"
    whatshap phase \
        -o "$phased_vcf" \
        --reference="$reference" \
        "$fixed_vcf" \
        "$fixed_bam" \
        --ignore-read-groups
    tabix -p vcf "$phased_vcf"

    
    haplotagged_bam="phased_results/${sample}_haplotagged.bam"
    whatshap haplotag \
        -o "$haplotagged_bam" \
        --reference="$reference" \
        "$phased_vcf" \
        "$fixed_bam" \
        --ignore-read-groups

    echo "=== Muestra $sample completada ==="
done
