process STRINGTIE {

    tag "${sample_id}"

    publishDir "results/nf/reference_guided/stringtie", mode: 'copy'

    input:
    tuple val(sample_id), path(bam)
    path annotation

    output:
    tuple val(sample_id),
          path("${sample_id}.gtf"),
          emit: gtf

    path "${sample_id}_gene_abundance.tsv",
         emit: abundance

    script:
    """
    stringtie \
      ${bam} \
      -p ${task.cpus} \
      -G ${annotation} \
      -o ${sample_id}.gtf \
      -A ${sample_id}_gene_abundance.tsv
    """

    stub:
    """
    touch ${sample_id}.gtf
    touch ${sample_id}_gene_abundance.tsv
    """
}
