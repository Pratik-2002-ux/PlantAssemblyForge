process SAMTOOLS_SORT_INDEX {

    tag "${sample_id}"

    publishDir "results/nf/reference_guided/samtools", mode: 'copy'

    input:
    tuple val(sample_id), path(sam)

    output:
    tuple val(sample_id),
          path("${sample_id}.sorted.bam"),
          emit: bam

    path "${sample_id}.sorted.bam.bai",
         emit: bai

    path "${sample_id}_flagstat.txt",
         emit: flagstat

    path "${sample_id}_stats.txt",
         emit: stats

    script:
    """
    samtools view -@ ${task.cpus} -bS ${sam} \
      | samtools sort -@ ${task.cpus} \
      -o ${sample_id}.sorted.bam

    samtools index ${sample_id}.sorted.bam

    samtools flagstat ${sample_id}.sorted.bam \
      > ${sample_id}_flagstat.txt

    samtools stats ${sample_id}.sorted.bam \
      > ${sample_id}_stats.txt
    """

    stub:
    """
    touch ${sample_id}.sorted.bam
    touch ${sample_id}.sorted.bam.bai
    touch ${sample_id}_flagstat.txt
    touch ${sample_id}_stats.txt
    """
}
