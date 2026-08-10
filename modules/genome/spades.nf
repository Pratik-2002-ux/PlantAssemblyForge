process GENOME_SPADES {

    tag "${sample_id}"

    cpus 4
    memory '6 GB'

    publishDir "results/nf/genome/assembly",
        mode: 'copy',
        overwrite: true

    input:
    tuple val(sample_id), path(r1), path(r2)

    output:
    tuple val(sample_id),
          path("${sample_id}_contigs.fasta"),
          path("${sample_id}_scaffolds.fasta"),
          emit: assembly

    script:
    """
    spades.py \
      --only-assembler \
      --careful \
      -1 ${r1} \
      -2 ${r2} \
      -k 21,33,55 \
      -t ${task.cpus} \
      -m 6 \
      -o spades_out

    cp spades_out/contigs.fasta \
       ${sample_id}_contigs.fasta

    cp spades_out/scaffolds.fasta \
       ${sample_id}_scaffolds.fasta
    """

    stub:
    """
    touch ${sample_id}_contigs.fasta
    touch ${sample_id}_scaffolds.fasta
    """
}
