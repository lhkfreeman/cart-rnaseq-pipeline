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

process MULTIQC {
    publishDir "${params.outdir}/multiqc", mode: 'copy'
    // The official MultiQC Docker container
    container 'quay.io/biocontainers/multiqc:1.14--pyhdfd78af_0'
    input:
    // Takes a unified collecion of all FastQC outputs
    path fastqc_results

    output:
    // Captures the final aggregated dashboard
    path "multiqc_report.html"

    script:
    """
    # The dot (.) tells MultiQC to scan the current working directory for any logs
    multiqc .
    """
}

// --- MAIN WORKFLOW ---
workflow {
    read_pairs_ch = channel.fromFilePairs(params.reads, checkIfExists: true)
    
    // Step 1: Run FastQC on each sample independently
    FASTQC(read_pairs_ch)

    // Step 2: Gather all FastQC outputs and pass them into MultiQC
    MULTIQC(FASTQC.out.collect())
}