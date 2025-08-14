Workflow de Phasing de Long Reads y Análisis de Variantes

Este repositorio/documentación describe los pasos para realizar variant calling, phasing y análisis de co-segregación a partir de long reads (ONT), utilizando Clair3 y WhatsHap, y generar tablas de variantes filtradas para análisis posterior en Python.

Estructura de archivos generados

´´´bash
clair3_results/
    sample1/
        merge_output.vcf.gz       # VCF combinado de Clair3
        ...otros archivos...
    sample2/
bams/
    sample1_minimapY.bam
    sample2_minimapY.bam
phased_results/
    sample1_fixed.vcf.gz
    sample1_RG.bam
    sample1_phased.vcf.gz
    sample1_haplotagged.bam
    sample2_...
vcf_tables/
    sample1_region_table.txt    # tabla con variantes filtradas de interés
    sample2_region_table.txt
´´´

1. QC

Se ejecuta mosdepth y bamstats para los bams de interés. 
   
2. Variant Calling con Clair3

Para cada BAM de muestra se ejecuta Clair3:

´´´bash
run_clair3.sh \
    --bam_fn=<ruta_a_bam> \
    --ref_fn=<referencia> \
    --threads=4 \
    --platform="ont" \
    --model_path="${CONDA_PREFIX}/bin/models/<MODEL_NAME>" \
    --output=<directorio_salida>
´´´

Se generan varios archivos, siendo los más relevantes:

merge_output.vcf.gz → VCF combinado con todas las variantes de la muestra.

full_alignment.vcf.gz → alineamiento completo de variantes.

Para phasing se recomienda usar merge_output.vcf.gz.

3. Phasing con WhatsHap

Se crea un script que, para cada muestra:

Reheaderiza el VCF para que el nombre de la muestra coincida con el BAM.
Añade @RG al BAM para compatibilidad con WhatsHap.
Realiza el phasing.
Genera un haplotagged BAM con las fases asignadas.

´´´bash
phased_vcf="phased_results/<sample>_phased.vcf.gz"
haplotagged_bam="phased_results/<sample>_haplotagged.bam"

whatshap phase -o "$phased_vcf" --reference=<ref.fa> "$fixed_vcf" "$fixed_bam" --ignore-read-groups
whatshap haplotag -o "$haplotagged_bam" --reference=<ref.fa> "$phased_vcf" "$fixed_bam" --ignore-read-groups
´´´

4. Extracción de variantes en región de interés

Se filtran los VCFs phasados para obtener solo heterocigotas y homocigotas alternativas en la región de interés:

´´´bash
region="chr5:1000000-2000000"

bcftools view -r "$region" "$phased_vcf" | \
bcftools query -f '%CHROM\t%POS\t[%GT]\t[%PS]\n' | \
awk '$4 != "." && ($3 ~ /\|/ || $3 == "1/1") {gsub(/\//,"|",$3); print}' \
> vcf_tables/<sample>_region_table.txt
´´´

5. Análisis de co-segregación en Python

Se incluye un script para identificar variantes que segregan en cis con una variante de interés.

Parámetros:

´´´python
carpeta_tablas = "vcf_tables/*.txt"  # patrón de archivos
var_interes_pos = 114787             # posición de tu variante de interés
var_interes_chr = "chr1"             # cromosoma de la variante
´´´


Funcionamiento:

- Lee todas las tablas filtradas.
- Localiza la variante de interés.
- Filtra variantes que pertenecen al mismo bloque de fase (PS) y mismo haplotipo.
- Genera un DataFrame combinado con todas las muestras.
- Cuenta cuántas muestras presentan cada variante co-segregante.
