process TRANSDECODER {

    tag "${sample_id}"

    publishDir "results/nf/annotation/transdecoder", mode: 'copy'

    input:
    tuple val(sample_id), path(transcripts)

    output:
    tuple val(sample_id),
          path("${sample_id}.transdecoder.pep"),
          emit: pep

    path "${sample_id}.transdecoder.cds",
         emit: cds

    path "${sample_id}.transdecoder.gff3",
         emit: gff3

    script:
    """
    cp ${transcripts} ${sample_id}.fasta

    \$CONDA_PREFIX/opt/transdecoder/util/TransDecoder.LongOrfs \
        -t ${sample_id}.fasta

    \$CONDA_PREFIX/opt/transdecoder/util/TransDecoder.Predict \
        -t ${sample_id}.fasta

    mv ${sample_id}.fasta.transdecoder.pep \
       ${sample_id}.transdecoder.pep

    mv ${sample_id}.fasta.transdecoder.cds \
       ${sample_id}.transdecoder.cds

    mv ${sample_id}.fasta.transdecoder.gff3 \
       ${sample_id}.transdecoder.gff3
    """

    stub:
    """
    touch ${sample_id}.transdecoder.pep
    touch ${sample_id}.transdecoder.cds
    touch ${sample_id}.transdecoder.gff3
    """
}
