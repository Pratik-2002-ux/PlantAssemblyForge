process GENOME_FASTQC_CLEAN {

    tag "${sample_id}"

    cpus 2

    publishDir "results/nf/genome/qc/clean",
        mode: 'copy',
        overwrite: true

    input:
    tuple val(sample_id), path(r1), path(r2)

    output:
    tuple val(sample_id),
          path("${sample_id}_R1.clean_fastqc.html"),
          path("${sample_id}_R1.clean_fastqc.zip"),
          path("${sample_id}_R2.clean_fastqc.html"),
          path("${sample_id}_R2.clean_fastqc.zip"),
          emit: qc

    script:
    """
    fastqc ${r1} ${r2} --threads ${task.cpus}

    mv ${sample_id}_R1.clean_fastqc.html ${sample_id}_R1.clean_fastqc.html
    mv ${sample_id}_R1.clean_fastqc.zip  ${sample_id}_R1.clean_fastqc.zip

    mv ${sample_id}_R2.clean_fastqc.html ${sample_id}_R2.clean_fastqc.html
    mv ${sample_id}_R2.clean_fastqc.zip  ${sample_id}_R2.clean_fastqc.zip
    """

    stub:
    """
    touch ${sample_id}_R1.clean_fastqc.html
    touch ${sample_id}_R1.clean_fastqc.zip
    touch ${sample_id}_R2.clean_fastqc.html
    touch ${sample_id}_R2.clean_fastqc.zip
    """
}
