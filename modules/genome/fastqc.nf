process GENOME_FASTQC {

    tag "${sample_id}"

    cpus 2

    publishDir "results/nf/genome/qc/raw",
        mode: 'copy',
        overwrite: true

    input:
    tuple val(sample_id), path(r1), path(r2)

    output:
    tuple val(sample_id),
          path("${sample_id}_R1_fastqc.html"),
          path("${sample_id}_R1_fastqc.zip"),
          path("${sample_id}_R2_fastqc.html"),
          path("${sample_id}_R2_fastqc.zip"),
          emit: qc

    script:
    """
    fastqc ${r1} ${r2} --threads ${task.cpus}

    mv *_1_fastqc.html ${sample_id}_R1_fastqc.html
    mv *_1_fastqc.zip  ${sample_id}_R1_fastqc.zip

    mv *_2_fastqc.html ${sample_id}_R2_fastqc.html
    mv *_2_fastqc.zip  ${sample_id}_R2_fastqc.zip
    """

    stub:
    """
    touch ${sample_id}_R1_fastqc.html
    touch ${sample_id}_R1_fastqc.zip
    touch ${sample_id}_R2_fastqc.html
    touch ${sample_id}_R2_fastqc.zip
    """
}
