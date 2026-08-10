process FASTP {

    tag "${sample_id}"

    publishDir "results/nf/trimmed", mode: 'copy'

    input:
    tuple val(sample_id), path(r1), path(r2)

    output:
    tuple val(sample_id),
          path("${sample_id}_R1.trimmed.fastq.gz"),
          path("${sample_id}_R2.trimmed.fastq.gz"),
          emit: reads

    path "${sample_id}_fastp.html", emit: html
    path "${sample_id}_fastp.json", emit: json

    script:
    """
    fastp \
        -i ${r1} \
        -I ${r2} \
        -o ${sample_id}_R1.trimmed.fastq.gz \
        -O ${sample_id}_R2.trimmed.fastq.gz \
        --adapter_sequence AAGCAGTGGTATCAACGCAGAGTGGCCGAGGCGGCC \
        --adapter_sequence_r2 AAGCAGTGGTATCAACGCAGAGTGGCCGAGGCGGCC \
        --qualified_quality_phred 20 \
        --length_required 40 \
        --thread ${task.cpus} \
        --html ${sample_id}_fastp.html \
        --json ${sample_id}_fastp.json
    """
}
