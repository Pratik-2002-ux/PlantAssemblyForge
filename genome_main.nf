nextflow.enable.dsl=2

include { GENOME_WORKFLOW } from './workflows/genome'

params.sample_id = 'SRR1946456'

params.r1 =
'data/genome/final_raw/SRR1946456_1.fastq.gz'

params.r2 =
'data/genome/final_raw/SRR1946456_2.fastq.gz'

params.reference =
'data/reference/arabidopsis/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa'

params.busco_lineage =
'busco_downloads/lineages/eudicotyledons_odb12.2'

workflow {

    reads_ch = Channel.of(
        tuple(
            params.sample_id,
            file(params.r1),
            file(params.r2)
        )
    )

    reference_ch = Channel.value(
        file(params.reference)
    )

    lineage_ch = Channel.value(
        file(params.busco_lineage)
    )

    GENOME_WORKFLOW(
        reads_ch,
        reference_ch,
        lineage_ch
    )
}
