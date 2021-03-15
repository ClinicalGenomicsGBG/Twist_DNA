# chrom_list = [
#     'chr1',
#     'chr2',
#     'chr3',
#     'chr4',
#     'chr5',
#     'chr6',
#     'chr7',
#     'chr8',
#     'chr9',
#     'chr10',
#     'chr11',
#     'chr12',
#     'chr13',
#     'chr14',
#     'chr15',
#     'chr16',
#     'chr17',
#     'chr18',
#     'chr19',
#     'chr20',
#     'chr21',
#     'chr22',
#    'chrX',
#    'chrY',
#]


<<<<<<< HEAD
rule Split_bam_Markdup:
    input:
        bam="alignment/{sample}-sort.bam",
        bai="alignment/{sample}-sort.bam.bai",
    output:
        bam=temp("alignment/Markdup_temp/{sample}-sort.{chr}.bam"),
    log:
        "logs/map/MarkDup/split_bam_realign_{sample}-sort.{chr}.log",
    singularity:
        config["singularity"].get("samtools", config["singularity"].get("default", ""))
    shell:
        "(samtools view -b {input.bam} {wildcards.chr} > {output.bam}) &> {log}"
=======
#rule Split_bam_Markdup:
#    input:
#        bam="bam/{sample}-sort.bam",
#        bai="bam/{sample}-sort.bam.bai",
#    output:
#        bam=temp("bam/Markdup_temp/{sample}-sort.{chr}.bam"),
#    log:
#        "logs/map/MarkDup/split_bam_realign_{sample}-sort.{chr}.log",
#    singularity:
#        config["singularity"]["samtools"]
#    shell:
#        "(samtools view -b {input.bam} {wildcards.chr} > {output.bam}) &> {log}"
>>>>>>> bff161b... First commit.


rule MarkDuplicates:
    input:
        bam="alignment/Markdup_temp/{sample}-sort.{chr}.bam",
        bai="alignment/Markdup_temp/{sample}-sort.{chr}.bam.bai",
    output:
        bam=temp("alignment/Markdup_temp/{sample}-dup.{chr}.bam"),
    params:
        metric="qc/{sample}_DuplicationMetrics.{chr}.txt",
    log:
        "logs/map/MarkDup/{sample}-ready.{chr}.log",
    threads: 2
    container:
        config["singularity"].get("picard", config["singularity"].get("default", ""))
    shell:
        "(picard MarkDuplicates INPUT={input.bam} OUTPUT={output.bam} METRICS_FILE={params.metric}) &> {log}"


<<<<<<< HEAD
rule Merge_bam_Markdup:
    input:
        bams=expand("alignment/Markdup_temp/{{sample}}-dup.{chr}.bam", chr=chrom_list),
    output:
        bam="Bam/DNA/{sample}-ready.bam",
    log:
        "logs/map/MarkDup/merge_bam/{sample}.log",
    container:
        config["singularity"].get("samtools", config["singularity"].get("default", ""))
    shell:
        "(samtools merge {output.bam} {input.bams}) &> {log}"
=======
#rule Merge_bam_Markdup:
#    input:
#        bams=expand("bam/Markdup_temp/{{sample}}-dup.{chr}.bam", chr=chrom_list),
#    output:
#        bam="DNA_bam/{sample}-ready.bam",
#    log:
#        "logs/map/MarkDup/merge_bam/{sample}.log",
#    container:
#        config["singularity"]["samtools"]
#    shell:
#        "(samtools merge {output.bam} {input.bams}) &> {log}"
>>>>>>> bff161b... First commit.
