#!/bin/bash

#conda activate phasing

vcf=10-515_chr5_phased.vcf
output=10-515_chr5_phased_table2.txt 

bcftools query -f '%CHROM\t%POS\t[%GT]\t[%PS]\n' $vcf | awk '$4 != "." && ($3 ~ /\|/ || $3 == "1/1") {gsub(/\//,"|",$3); print}' > $output

mkdir -p vcf_tables

# Región de interés (cambiar a la que necesites, formato chr:start-end)
region="chr5:1000000-2000000"

for phased_vcf in "$phased_dir"/*_phased.vcf.gz; do
    sample=$(basename "$phased_vcf" _phased.vcf.gz)
    output="vcf_tables/${sample}_phased_table.txt"

    echo "=== Procesando $sample ==="

    # Extraer región y aplicar filtro de heterocigotas y homocigotas alternativas
    bcftools view -r "$region" "$phased_vcf" | \
    bcftools query -f '%CHROM\t%POS\t[%GT]\t[%PS]\n' | \
    awk '$4 != "." && ($3 ~ /\|/ || $3 == "1/1") {gsub(/\//,"|",$3); print}' \
    > "$output"

    echo "Tabla generada en vcf_tables"
done