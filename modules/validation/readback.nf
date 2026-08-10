process READBACK_MAPPING {

    tag "${sample_id}"

    publishDir "results/nf/validation/readback", mode: 'copy'

    input:
    tuple val(sample_id), path(r1), path(r2)
    tuple val(assembly_sample), path(transcripts)

    output:
    tuple val(sample_id),
          path("${sample_id}_readback.sorted.bam"),
          emit: bam

    path "${sample_id}_readback.sorted.bam.bai",
         emit: bai

    path "${sample_id}_readback_summary.txt",
         emit: summary

    path "${sample_id}_readback_flagstat.txt",
         emit: flagstat

    script:
    """
    bowtie2-build \
      ${transcripts} \
      ${sample_id}_transcriptome

    bowtie2 \
      -x ${sample_id}_transcriptome \
      -1 ${r1} \
      -2 ${r2} \
      -p ${task.cpus} \
      2> ${sample_id}_readback_summary.txt \
      | samtools view -@ ${task.cpus} -bS - \
      | samtools sort -@ ${task.cpus} \
        -o ${sample_id}_readback.sorted.bam

    samtools index \
      ${sample_id}_readback.sorted.bam

    samtools flagstat \
      ${sample_id}_readback.sorted.bam \
      > ${sample_id}_readback_flagstat.txt
    """

    stub:
    """
    touch ${sample_id}_readback.sorted.bam
    touch ${sample_id}_readback.sorted.bam.bai
    touch ${sample_id}_readback_summary.txt
    touch ${sample_id}_readback_flagstat.txt
    """
}
