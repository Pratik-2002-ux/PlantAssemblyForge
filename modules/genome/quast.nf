process GENOME_QUAST {

    tag "${sample_id}"

    cpus 4

    publishDir "results/nf/genome/quast",
        mode: 'copy',
        overwrite: true

    input:
    tuple val(sample_id), path(contigs), path(scaffolds)
    path reference

    output:
    path "${sample_id}_quast",
         emit: report

    script:
    """
    python3 ${projectDir}/tools/quast-current/quast.py \
      ${contigs} \
      ${scaffolds} \
      -r ${reference} \
      -o ${sample_id}_quast \
      -t ${task.cpus} \
      --labels contigs,scaffolds
    """

    stub:
    """
    mkdir -p ${sample_id}_quast
    touch ${sample_id}_quast/report.txt
    touch ${sample_id}_quast/report.tsv
    """
}
