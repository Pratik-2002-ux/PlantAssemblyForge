include { GENOME_FASTQC }       from '../modules/genome/fastqc'
include { GENOME_FASTP }        from '../modules/genome/fastp'
include { GENOME_FASTQC_CLEAN } from '../modules/genome/fastqc_clean'
include { GENOME_JELLYFISH }    from '../modules/genome/jellyfish'
include { GENOME_SPADES }       from '../modules/genome/spades'
include { GENOME_QUAST }        from '../modules/genome/quast'
include { GENOME_BUSCO }        from '../modules/genome/busco'

workflow GENOME_WORKFLOW {

    take:
    reads
    reference
    lineage

    main:

    GENOME_FASTQC(reads)

    GENOME_FASTP(reads)

    clean_reads = GENOME_FASTP.out.reads

    GENOME_FASTQC_CLEAN(clean_reads)

    GENOME_JELLYFISH(clean_reads)

    GENOME_SPADES(clean_reads)

    assembly_ch = GENOME_SPADES.out.assembly

    GENOME_QUAST(
        assembly_ch,
        reference
    )

    GENOME_BUSCO(
        assembly_ch,
        lineage
    )

    emit:
    assembly  = assembly_ch
    histogram = GENOME_JELLYFISH.out.histogram
    quast     = GENOME_QUAST.out.report
    busco     = GENOME_BUSCO.out.result
}
