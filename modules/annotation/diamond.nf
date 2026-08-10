process DIAMOND_BLASTP {

    tag "${sample_id}"

    publishDir "results/nf/annotation/diamond", mode: 'copy'

    input:
    tuple val(sample_id), path(proteins)
    path diamond_db

    output:
    tuple val(sample_id),
          path("${sample_id}_diamond_hits.tsv"),
          emit: hits

    script:
    """
    diamond blastp \
      -d ${diamond_db} \
      -q ${proteins} \
      -o ${sample_id}_diamond_hits.tsv \
      --outfmt 6 \
      qseqid sseqid pident length mismatch gapopen \
      qstart qend sstart send evalue bitscore \
      --evalue 1e-5 \
      --max-target-seqs 1 \
      --threads ${task.cpus}
    """

    stub:
    """
    touch ${sample_id}_diamond_hits.tsv
    """
}
