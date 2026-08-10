process GENOME_JELLYFISH {

    tag "${sample_id}"

    cpus 4

    publishDir "results/nf/genome/kmer",
        mode: 'copy',
        overwrite: true

    input:
    tuple val(sample_id), path(r1), path(r2)

    output:
    tuple val(sample_id),
          path("${sample_id}_k21.histo"),
          emit: histogram

    script:
    """
    jellyfish count \
      -m 21 \
      -s 500M \
      -t ${task.cpus} \
      -C \
      -o ${sample_id}_k21.jf \
      <(gzip -dc ${r1}) \
      <(gzip -dc ${r2})

    jellyfish histo \
      -t ${task.cpus} \
      ${sample_id}_k21.jf \
      > ${sample_id}_k21.histo

    rm -f ${sample_id}_k21.jf
    """

    stub:
    """
    touch ${sample_id}_k21.histo
    """
}
