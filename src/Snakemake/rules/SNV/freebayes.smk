# vim: syntax=python tabstop=4 expandtab
# coding: utf-8

__author__ = "Jonas Almlöf, Patrik Smeds"
__copyright__ = "Copyright 2021, Patrik Smeds, Jonas Almlöf"
__email__ = "jonas.almlöf@scilifelab.uu.se, patrik.smeds@scilifelab.uu.se"
__license__ = "GPL3"

"""
 Collection of rules that calls variants using Freebayes.
 Input, output and config
 ------------------------------------------------------------------------------
 Input variable: 
    freebayes_input: optional
        Default:
            "alignment/temp/{sample}.{chr}.bam",

 Output variable:  
    freebayes_output: optional
        Default:
            "freebayes/{sample}.freebayes.fixAF.vcf"
    
 Config dict keys: values
    config["reference"]["ref"]': required
    config["singularity"]["freebayes"]' or config["singularity"]["default"]'  : required 
    config["singularity"]["bcftools"] or config["singularity"]["default"]': required
    config["singularity"]["bcftools"] or config["singularity"]["default"]': required
 Overriding input and output
 ------------------------------------------------------------------------------
 Required wildcards:
    sample
 Override input format
 Ex
  freebayes_input=alignment/{sample}.{chr}.bam
  
 Override output format
 Ex
   "freebayes/{sample}.freebayes.vcf"
"""

_freebayes_input = "alignment/temp/{sample}.{chr}.bam"
try:
    _freebayes_input = freebayes_input
except:
    pass


_freebayes_output = "freebayes/{sample}.freebayes.fixAF.vcf"
try:
    _freebayes_output = freebayes_output
except:
    pass


rule freebayes:
    input:
        samples=_freebayes_input,
        indexes=_freebayes_input + ".bai",
        ref=config["reference"]["ref"],
        regions="mutect2/bedfile.{chr}.bed",
    output:
        "freebayes/{sample}.{chr}.unsort.vcf",
    log:
        "logs/variantCalling/freebayes/{sample}.{chr}.log",
    threads: 1
    params:
        extra=" --min-alternate-fraction 0.01 --allele-balance-priors-off --pooled-discrete --pooled-continuous --report-genotype-likelihood-max --genotype-qualities --strict-vcf --no-partial-observations ",
    singularity:
        config["singularity"].get("freebayes", config["singularity"].get("default", ""))
    wrapper:
        "0.70.0/bio/freebayes"


rule filter_freebayes:
    input:
        "freebayes/{sample}.{chr}.unsort.vcf",
    output:
        temp("freebayes/{sample}.{chr}.unsort.filtered.vcf"),
    params:
        filter="-i 'ALT=\"<*>\" || QUAL > 5'",
    log:
        "logs/variantCalling/freebayes/{sample}.{chr}.filter.log",
    singularity:
        config["singularity"].get("bcftools", config["singularity"].get("default", ""))
    wrapper:
        "file:///projects/wp4/nobackup/workspace/snakemake-wrappers-fork/bio/bcftools/filter"


rule filter_iupac_codes:
    input:
        "freebayes/{sample}.{chr}.unsort.filtered.vcf",
    output:
        temp("freebayes/{sample}.{chr}.unsort.filtered.mod.vcf"),
    log:
        "logs/variantCalling/freebayes/{sample}.{chr}.iupac_replace.log",
    shell:
        "awk -F$'\t' -v OFS='\t' '{{if ($0 !~ /^#/) gsub(/[KMRYSWBVHDXkmryswbvhdx]/, \"N\", $4) }} {{print}}' {input} > {output}) &> {log}"


rule Merge_freebayes_vcf:
    input:
        calls=expand(
            "freebayes/{{sample}}.{chr}.unsort.filtered.mod.vcf",
            chr=utils.extract_chr(config['reference']['ref'] + ".fai"),
        ),
    output:
        temp("freebayes/temp/{sample}.merged.SB.vcf"),
    log:
        "logs/variantCalling/mutect2/merge_vcf/{sample}.log",
    singularity:
        config["singularity"].get("bcftools", config["singularity"].get("default", ""))
    wrapper:
        "0.70.0/bio/bcftools/concat"


rule sortFreebayes:
    input:
        "freebayes/temp/{sample}.merged.SB.vcf",
    output:
        _freebayes_output,
    singularity:
        config["singularity"].get("bcftools", config["singularity"].get("default", ""))
    log:
        "logs/variantCalling/freebayes/{sample}.sort.log",
    shell:
        "(bcftools sort -o {output} -O v {input}) &> {log}"
