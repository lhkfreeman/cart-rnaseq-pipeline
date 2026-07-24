process HISAT2_BUILD {
    tag "Index HISAT2"
    // Updated to the V2-compliant container tag
    container 'quay.io/biocontainers/hisat2:2.2.1--hdbdd923_6'

    input:
    path fasta

    output:
    path "hisat2_index"

    script:
    """
    mkdir hisat2_index
    hisat2-build ${fasta} hisat2_index/genome
    """
}

process HISAT2_ALIGN {
    tag "HISAT2 Align $sample_id"
    // Updated to the V2-compliant container tag
    container 'quay.io/biocontainers/hisat2:2.2.1--hdbdd923_6'

    input:
    tuple val(sample_id), path(reads)
    path index_dir

    output:
    tuple val(sample_id), path("*.sam")

    script:
    """
    hisat2 -x ${index_dir}/genome -1 ${reads[0]} -2 ${reads[1]} -S ${sample_id}.sam
    """
}

process SAMTOOLS_SORT {
    tag "BAM Convert $sample_id"
    publishDir "${params.outdir}/aligned_hisat2", mode: 'copy'
    container 'quay.io/biocontainers/samtools:1.17--h00cdaf9_0'

    input:
    tuple val(sample_id), path(sam_file)

    output:
    path "*.bam"

    script:
    """
    samtools sort -o ${sample_id}_sorted.bam ${sam_file}
    """
}