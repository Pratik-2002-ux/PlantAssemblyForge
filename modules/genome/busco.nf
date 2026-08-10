process GENOME_BUSCO {

    tag "${sample_id}"

    cpus 2

    container 'ezlabgva/busco:v6.1.0_cv1'

    publishDir "results/nf/genome/busco",
        mode: 'copy',
        overwrite: true

    input:
    tuple val(sample_id), path(contigs), path(scaffolds)
    path lineage

    output:
    path "${sample_id}_busco",
         emit: result

    script:
    """
    busco \
      -i ${scaffolds} \
      -o ${sample_id}_busco \
      -m genome \
      -l ${lineage} \
      -c ${task.cpus} \
      --offline
    """

    stub:
    """
    mkdir -p ${sample_id}_busco
    touch ${sample_id}_busco/short_summary.stub.txt
    """
}
