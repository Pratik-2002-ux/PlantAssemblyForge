process HISAT2 {

    tag "${sample_id}"
    publishDir "results/nf/reference_guided/hisat2", mode: 'copy'

    input:
    tuple val(sample_id), path(r1), path(r2)
    path index_files

    output:
    tuple val(sample_id),
          path("${sample_id}.sam"),
          emit: sam

    path "${sample_id}_alignment_summary.txt",
         emit: summary

    script:
    """
    hisat2 \
      -p ${task.cpus} \
      -x TAIR10 \
      -1 ${r1} \
      -2 ${r2} \
      -S ${sample_id}.sam \
      --summary-file ${sample_id}_alignment_summary.txt
    """
}
