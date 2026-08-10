process FASTQC {

    tag "${sample_id}"
    publishDir "results/nf/qc/raw", mode: 'copy'

    input:
    tuple val(sample_id), path(r1), path(r2)

    output:
    tuple val(sample_id),
          path("*_fastqc.html"),
          path("*_fastqc.zip"),
          emit: reports

    script:
    """
    fastqc \
      ${r1} \
      ${r2} \
      --threads ${task.cpus}
    """
}
