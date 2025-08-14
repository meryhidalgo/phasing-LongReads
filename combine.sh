#!/bin/bash

#conda activate phasing

bcftools merge -m all -Oz -o joint.vcf.gz sample1.vcf.gz sample2.vcf.gz sample3.vcf.gz
tabix -p vcf joint.vcf.gz