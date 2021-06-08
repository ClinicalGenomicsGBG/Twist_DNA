

rule GPU_align:
    input:
        fastq1="fastq/DNA/{sample}_R1.fastq.gz",
        fastq2="fastq/DNA/{sample}_R2.fastq.gz",
    output:
        bam="Bam/DNA/{sample}-ready.bam",
    params:
        ref=config["reference"]["ref"],
    log:
        "logs/GPU_align/{sample}.log",
    threads: 40
    # container:
    #    config["singularitys"]["GPU"]
    shell:
        "(pbrun fq2bam "
        "--ref {params.ref} "
        "--in-fq {input.fastq1} {input.fastq2} "
        "--out-bam {output.bam} "
        "--tmp-dir GPU_run "
        ") &> {log}"


rule samtools_index_GPU:
    input:
        "Bam/DNA/{sample}-ready.bam",
    output:
        "Bam/DNA/{sample}-ready.bam.bai",
    log:
        "logs/map/samtools_index/{sample}.log",
    container:
        config["singularity"]["samtools"]
    shell:
        "(samtools index {input} {output}) &> {log}"
