process RNASPADES {

    tag "${sample_id}"
    publishDir "results/nf/de_novo", mode: 'copy'

    input:
    tuple val(sample_id), path(r1), path(r2)

    output:
    tuple val(sample_id),
          path("${sample_id}_rnaspades/transcripts.fasta"),
          emit: transcripts

    script:
    """
    rnaspades.py \
      -1 ${r1} \
      -2 ${r2} \
      -o ${sample_id}_rnaspades \
      -t ${task.cpus}
    """
}
