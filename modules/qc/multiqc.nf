process MULTIQC {

    tag "QC summary"

    publishDir "results/nf/qc/multiqc", mode: 'copy'

    input:
    path qc_files

    output:
    path "multiqc_report.html", emit: report
    path "multiqc_report_data", emit: data

    script:
    """
    multiqc . \
      --force \
      --filename multiqc_report.html
    """

    stub:
    """
    touch multiqc_report.html
    mkdir -p multiqc_report_data
    touch multiqc_report_data/multiqc_general_stats.txt
    """
}
