units = pd.read_table(config["units"], index_col=["sample", "unit"], dtype=str)
units.index = units.index.set_levels([i.astype(str) for i in units.index.levels])  # enforce str in index

def fastq_files(wildcards):
    return [v[0] for k, v in units.loc[wildcards.sample].items()]

fastp_trimming_input=lambda wildcards: fastq_files(wildcards)

include: "../rules/Fastq/Fastp_trimming.smk"

include: "../rules/Alignment/bwa-mem.smk"