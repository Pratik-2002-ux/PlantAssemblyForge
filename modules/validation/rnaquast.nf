process RNAQUAST {

    tag "${sample_id}"

    publishDir "results/nf/validation/rnaquast", mode: 'copy'

    input:
    tuple val(sample_id), path(transcripts)
    path reference
    path annotation

    output:
    path "short_report.txt", emit: report_txt
    path "short_report.tsv", emit: report_tsv
    path "short_report.pdf", emit: report_pdf

    path "transcripts_output", emit: detailed_results

    script:
    """
    python ${projectDir}/tools/rnaquast/rnaQUAST.py \
      -c ${transcripts} \
      -r ${reference} \
      --gtf ${annotation} \
      -o rnaquast_out \
      -t ${task.cpus}

    cp rnaquast_out/short_report.txt .
    cp rnaquast_out/short_report.tsv .
    cp rnaquast_out/short_report.pdf .

    cp -R rnaquast_out/transcripts_output .
    """

    stub:
    """
    touch short_report.txt
    touch short_report.tsv
    touch short_report.pdf

    mkdir -p transcripts_output
    touch transcripts_output/basic_metrics.txt
    """
}
