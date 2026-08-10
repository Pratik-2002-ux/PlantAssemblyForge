process FASTQC_TRIMMED {

    tag "${sample_id}"

    publishDir "results/nf/qc/trimmed", mode: 'copy'

    input:
    tuple val(sample_id), path(r1), path(r2)

    output:
    tuple val(sample_id),
          path("${sample_id}_trimmed_R1_fastqc.html"),
          path("${sample_id}_trimmed_R1_fastqc.zip"),
          path("${sample_id}_trimmed_R2_fastqc.html"),
          path("${sample_id}_trimmed_R2_fastqc.zip"),
          emit: reports

    script:
    """
    fastqc \
      ${r1} \
      ${r2} \
      --threads ${task.cpus}

    mv ${sample_id}_R1.trimmed_fastqc.html \
       ${sample_id}_trimmed_R1_fastqc.html

    mv ${sample_id}_R1.trimmed_fastqc.zip \
       ${sample_id}_trimmed_R1_fastqc.zip

    mv ${sample_id}_R2.trimmed_fastqc.html \
       ${sample_id}_trimmed_R2_fastqc.html

    mv ${sample_id}_R2.trimmed_fastqc.zip \
       ${sample_id}_trimmed_R2_fastqc.zip
    """

    stub:
    """
    touch ${sample_id}_trimmed_R1_fastqc.html
    touch ${sample_id}_trimmed_R1_fastqc.zip
    touch ${sample_id}_trimmed_R2_fastqc.html
    touch ${sample_id}_trimmed_R2_fastqc.zip
    """
}
