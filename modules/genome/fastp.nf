process GENOME_FASTP {

    tag "${sample_id}"

    cpus 4

    publishDir "results/nf/genome/trimmed",
        mode: 'copy',
        overwrite: true

    input:
    tuple val(sample_id), path(r1), path(r2)

    output:
    tuple val(sample_id),
          path("${sample_id}_R1.clean.fastq.gz"),
          path("${sample_id}_R2.clean.fastq.gz"),
          emit: reads

    path "${sample_id}_fastp.html",
         emit: html

    path "${sample_id}_fastp.json",
         emit: json

    script:
    """
    fastp \
      -i ${r1} \
      -I ${r2} \
      -o ${sample_id}_R1.clean.fastq.gz \
      -O ${sample_id}_R2.clean.fastq.gz \
      --disable_adapter_trimming \
      --qualified_quality_phred 20 \
      --unqualified_percent_limit 40 \
      --n_base_limit 5 \
      --length_required 70 \
      --thread ${task.cpus} \
      --html ${sample_id}_fastp.html \
      --json ${sample_id}_fastp.json
    """

    stub:
    """
    touch ${sample_id}_R1.clean.fastq.gz
    touch ${sample_id}_R2.clean.fastq.gz
    touch ${sample_id}_fastp.html
    touch ${sample_id}_fastp.json
    """
}
