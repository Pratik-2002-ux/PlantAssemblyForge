nextflow.enable.dsl=2

include { FASTQC }              from './modules/qc/fastqc'
include { FASTQC_TRIMMED }      from './modules/qc/fastqc_trimmed'
include { MULTIQC }             from './modules/qc/multiqc'
include { FASTP }               from './modules/qc/fastp'

include { RNASPADES }           from './modules/assembly/rnaspades'
include { READBACK_MAPPING }    from './modules/validation/readback'
include { RNAQUAST }            from './modules/validation/rnaquast'

include { HISAT2 }              from './modules/alignment/hisat2'
include { SAMTOOLS_SORT_INDEX } from './modules/alignment/samtools'
include { STRINGTIE }           from './modules/alignment/stringtie'

include { TRANSDECODER }        from './modules/annotation/transdecoder'
include { DIAMOND_BLASTP }      from './modules/annotation/diamond'

params.samplesheet =
    'config/samplesheet.csv'

params.reference =
    'data/reference/arabidopsis/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa'

params.annotation =
    'data/reference/arabidopsis/Arabidopsis_thaliana.TAIR10.63.gff3'

params.hisat2_index =
    'data/reference/arabidopsis/hisat2_index/TAIR10.*.ht2'

params.diamond_db =
    'data/reference/arabidopsis/proteome/arabidopsis_proteins.dmnd'


workflow {

    reads_ch = Channel
        .fromPath(params.samplesheet)
        .splitCsv(header: true)
        .map { row ->
            tuple(
                row.sample,
                file(row.r1),
                file(row.r2)
            )
        }


    /*
     * RAW READ QC
     */

    FASTQC(reads_ch)


    /*
     * PREPROCESSING
     */

    FASTP(reads_ch)

    trimmed_ch = FASTP.out.reads


    /*
     * POST-TRIMMING QC
     */

    FASTQC_TRIMMED(trimmed_ch)


    /*
     * DE NOVO TRANSCRIPTOME
     */

    RNASPADES(trimmed_ch)


    /*
     * DE NOVO ASSEMBLY VALIDATION
     */

    READBACK_MAPPING(
        trimmed_ch,
        RNASPADES.out.transcripts
    )

    RNAQUAST(
        RNASPADES.out.transcripts,
        file(params.reference),
        file(params.annotation)
    )


    /*
     * CODING REGION + HOMOLOGY ANNOTATION
     */

    TRANSDECODER(
        RNASPADES.out.transcripts
    )

    DIAMOND_BLASTP(
        TRANSDECODER.out.pep,
        file(params.diamond_db)
    )


    /*
     * REFERENCE-GUIDED TRANSCRIPTOME
     */

    HISAT2(
        trimmed_ch,
        files(params.hisat2_index)
    )

    SAMTOOLS_SORT_INDEX(
        HISAT2.out.sam
    )

    STRINGTIE(
        SAMTOOLS_SORT_INDEX.out.bam,
        file(params.annotation)
    )


    /*
     * MULTIQC
     */

    raw_qc_files = FASTQC.out.reports
        .map { sample, html, zip ->
            [html, zip]
        }
        .flatten()

    trimmed_qc_files = FASTQC_TRIMMED.out.reports
        .map { sample, r1_html, r1_zip, r2_html, r2_zip ->
            [r1_html, r1_zip, r2_html, r2_zip]
        }
        .flatten()

    multiqc_input = raw_qc_files
        .mix(trimmed_qc_files)
        .mix(FASTP.out.html)
        .mix(FASTP.out.json)
        .collect()

    MULTIQC(
        multiqc_input
    )
}
