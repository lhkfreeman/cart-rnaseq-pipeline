#!/usr/bin/env nextflow

// --- PARAMETERS ---
params.reads = "data/*_{1,2}.fastq.gz"
params.outdir = "results"
params.fasta = "reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
params.gtf   = "reference/Homo_sapiens.GRCh38.110.gtf"

// --- PROCESS DEFINITIONS ---
process FASTQC {
    tag "QC on $sample_id"
    publishDir "${params.outdir}/fastqc", mode: 'copy'
    container 'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0'

    input:
    tuple val(sample_id), path(reads)

    output:
    path "*.{html,zip}"

    script:
    """
    fastqc -q ${reads}
    """
}

// --- MAIN WORKFLOW ---
workflow {
    read_pairs_ch = channel.fromFilePairs(params.reads, checkIfExists: true)
    FASTQC(read_pairs_ch)
}