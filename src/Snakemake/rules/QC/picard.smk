localrules:
    touchBatch,


rule picardHsMetrics:
    input:
        bam="Bam/DNA/{sample}-ready.bam",
        bait_intervals=config["bed"]["intervals"],
        target_intervals=config["bed"]["intervals"],
        reference=config["reference"]["ref"],
    output:
        "qc/{sample}/{sample}.HsMetrics.txt",
    params:
        extra="COVERAGE_CAP=2000",
    log:
        "logs/qc/picard/HsMetrics/{sample}.log",
    container:
        config["singularity"].get("picard", config["singularity"].get("default", ""))
    # shell:
    #    "(java -Xmx4g -jar /opt/conda/share/picard-2.20.1-0/picard.jar CollectHsMetrics BAIT_INTERVALS={input.intervals} TARGET_INTERVALS={input.intervals} INPUT={input.bam} OUTPUT={output}) &> {log}"
    wrapper:
        "0.72.0/bio/picard/collecthsmetrics"


_picardInsertSize_input = "Bam/DNA/{sample}-ready.bam"
try:
    _picardInsertSize_input = picardInsertSize_input
except:
    pass

_picardInsertSize_output_txt = "qc/{sample}/{sample}.insert_size_metrics.txt"
try:
    _picardInsertSize_output_txt = picardInsertSize_output_txt
except:
    pass

_picardInsertSize_output_pdf = "qc/{sample}/{sample}.insert_size_histogram.pdf"
try:
    _picardInsertSize_output_pdf = picardInsertSize_output_pdf
except:
    pass


rule picardInsertSize:
    input:
        bam=_picardInsertSize_input,
    output:
        txt=_picardInsertSize_output_txt,
        pdf=_picardInsertSize_output_pdf,
    log:
        "logs/qc/picard/InsertSize/{sample}.log",
    container:
        config["singularity"].get("picard", config["singularity"].get("default", ""))
    wrapper:
        "0.72.0/bio/picard/collectinsertsizemetrics"


_PicardAlignmentSummaryMetrics_input_bam = "Bam/DNA/{sample}-ready.bam"
try:
    _PicardAlignmentSummaryMetrics_input_bam = PicardAlignmentSummaryMetrics_input_bam
except:
    pass

_PicardAlignmentSummaryMetrics_input_ref = config["reference"]["ref"]
try:
    _PicardAlignmentSummaryMetrics_input_ref = PicardAlignmentSummaryMetrics_input_ref
except:
    pass

_PicardAlignmentSummaryMetrics_output = "qc/{sample}/{sample}.alignment_summary_metrics.txt"
try:
    _PicardAlignmentSummaryMetrics_output = PicardAlignmentSummaryMetrics_output
except:
    pass


rule PicardAlignmentSummaryMetrics:
    input:
        bam=_PicardAlignmentSummaryMetrics_input_bam,
        ref=_PicardAlignmentSummaryMetrics_input_ref,
    output:
        metrics=_PicardAlignmentSummaryMetrics_output,
    log:
        "logs/qc/picard/AlignmentSummaryMetrics/{sample}.log",
    container:
        config["singularity"].get("picard", config["singularity"].get("default", ""))
    wrapper:
        "0.72.0/bio/picard/collectalignmentsummarymetrics"


# rule GcBiasSummaryMetrics:
#     input:
#         bam="Bam/DNA/{sample}-ready.bam",
#         ref=config["reference"]["ref"],
#     output:
#         summary="qc/{sample}/{sample}.gc_bias.summary_metrics.txt",
#         gc="qc/{sample}/{sample}.gc_bias.metrics.txt",
#         pdf="qc/{sample}/{sample}.gc_bias.metrics.pdf",
#     log:
#         "logs/qc/picard/GcBiasSummaryMetrics/{sample}.log",
#     container:
#         config["singularity"].get("picard", config["singularity"].get("default", ""))
#     shell:
#         "(java -Xmx4g -jar /opt/conda/share/picard-2.20.1-0/picard.jar CollectGcBiasMetrics I={input.bam} R={input.ref} O={output.gc} CHART={output.pdf} S={output.summary}) &> {log}"


rule DuplicationMetrics:
    input:
        bam="Bam/DNA/{sample}-ready.bam",
    output:
        metrics="qc/{sample}/{sample}.duplication_metrics.txt",
    log:
        "logs/qc/picard/DuplicationMetrics/{sample}.log",
    container:
        config["singularity"].get("picard", config["singularity"].get("default", ""))
    shell:
        "(picard CollectDuplicateMetrics INPUT={input.bam} M={output.metrics}) &> {log}"
