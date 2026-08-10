from pathlib import Path
import json
import re

import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st


# ============================================================
# PATHS
# ============================================================

ROOT = Path(__file__).resolve().parents[1]

RESULTS_SUMMARY = ROOT / "results_summary"
GENOME_SUMMARY = RESULTS_SUMMARY / "genome"

QUAST_TXT = GENOME_SUMMARY / "quast_report.txt"
BUSCO_TXT = GENOME_SUMMARY / "busco_summary.txt"
KMER_FILE = GENOME_SUMMARY / "k21_histogram.tsv"

FASTP_JSON_CANDIDATES = [
    ROOT / "results/genome/final_trimmed/fastp.json",
    ROOT / "results/genome/final_trimmed/SRR1946456_fastp.json",
]


# ============================================================
# PAGE CONFIG
# ============================================================

st.set_page_config(
    page_title="PlantAssemblyForge",
    page_icon="🌱",
    layout="wide",
)


# ============================================================
# CSS
# ============================================================

st.markdown(
    """
<style>

.block-container {
    padding-top: 2.0rem;
    padding-bottom: 3rem;
}

.main-title {
    font-size: 3.2rem;
    font-weight: 750;
    margin-bottom: 0;
}

.subtitle {
    color: #6b7280;
    font-size: 1rem;
    margin-bottom: 2rem;
}

.section-card {
    border: 1px solid #e5e7eb;
    border-radius: 12px;
    padding: 20px;
    background-color: #ffffff;
    margin-bottom: 15px;
}

.workflow-box {
    border: 1px solid #d1d5db;
    border-radius: 10px;
    padding: 14px 10px;
    text-align: center;
    font-weight: 600;
    background-color: #f8fafc;
    margin-bottom: 8px;
}

.workflow-arrow {
    text-align: center;
    font-size: 1.5rem;
    color: #6b7280;
    margin-top: -3px;
    margin-bottom: 3px;
}

.status-complete {
    background-color: #ecfdf5;
    border: 1px solid #a7f3d0;
    color: #065f46;
    padding: 12px 16px;
    border-radius: 10px;
    font-weight: 600;
}

.interpretation {
    background-color: #eff6ff;
    border-left: 4px solid #3b82f6;
    padding: 14px 18px;
    border-radius: 6px;
    margin-top: 15px;
}

.small-note {
    color: #6b7280;
    font-size: 0.9rem;
}

</style>
""",
    unsafe_allow_html=True,
)


# ============================================================
# HELPER FUNCTIONS
# ============================================================

def page_header():
    st.markdown(
        '<div class="main-title">🌱 PlantAssemblyForge</div>',
        unsafe_allow_html=True,
    )

    st.markdown(
        """
        <div class="subtitle">
        Plant Genome & Transcriptome Assembly • Nextflow DSL2 •
        Quality Control • Assembly • Validation
        </div>
        """,
        unsafe_allow_html=True,
    )


def metric_row(values):
    cols = st.columns(len(values))

    for col, (label, value) in zip(cols, values):
        col.metric(label, value)


def workflow_box(text):
    st.markdown(
        f'<div class="workflow-box">{text}</div>',
        unsafe_allow_html=True,
    )


def workflow_arrow():
    st.markdown(
        '<div class="workflow-arrow">↓</div>',
        unsafe_allow_html=True,
    )


def parse_fastp_json():

    for path in FASTP_JSON_CANDIDATES:

        if path.exists():

            with open(path) as f:
                data = json.load(f)

            before = data.get("summary", {}).get("before_filtering", {})
            after = data.get("summary", {}).get("after_filtering", {})

            filtering = data.get("filtering_result", {})

            return {
                "path": path,
                "before_reads": before.get("total_reads"),
                "after_reads": after.get("total_reads"),
                "before_bases": before.get("total_bases"),
                "after_bases": after.get("total_bases"),
                "before_q30": before.get("q30_rate"),
                "after_q30": after.get("q30_rate"),
                "before_gc": before.get("gc_content"),
                "after_gc": after.get("gc_content"),
                "low_quality": filtering.get("low_quality_reads"),
                "too_many_n": filtering.get("too_many_N_reads"),
                "too_short": filtering.get("too_short_reads"),
            }

    return None


def read_kmer():

    if not KMER_FILE.exists():
        return None

    return pd.read_csv(
        KMER_FILE,
        sep=r"\s+",
        header=None,
        names=["Multiplicity", "Frequency"],
    )


# ============================================================
# CONSTANT RESULTS
# ============================================================

GENOME_RESULTS = {
    "coverage": 15.49,
    "contig_size": 107.21,
    "scaffold_size": 107.24,
    "contig_n50": 7429,
    "scaffold_n50": 8515,
    "largest_scaffold": 56462,
    "gc": 36.21,
    "reference_size": 119.667750,
}

QUAST_RESULTS = {
    "genome_fraction_contigs": 81.706,
    "genome_fraction_scaffolds": 81.892,
    "dup_contigs": 1.003,
    "dup_scaffolds": 1.003,
    "nga50_contigs": 5280,
    "nga50_scaffolds": 5971,
    "misassemblies_contigs": 2522,
    "misassemblies_scaffolds": 2535,
    "mismatch_contigs": 612.47,
    "mismatch_scaffolds": 616.08,
    "indel_contigs": 132.48,
    "indel_scaffolds": 136.22,
}

BUSCO_RESULTS = {
    "complete": 95.4,
    "single": 93.9,
    "duplicated": 1.5,
    "fragmented": 3.4,
    "missing": 1.3,
    "single_count": 1869,
    "duplicated_count": 29,
    "fragmented_count": 67,
    "missing_count": 25,
    "total": 1990,
}

TRANSCRIPTOME_RESULTS = {
    "mapping": 73.85,
    "proteins": 7699,
    "diamond_hits": 7630,
}

annotation_rate = (
    TRANSCRIPTOME_RESULTS["diamond_hits"]
    / TRANSCRIPTOME_RESULTS["proteins"]
    * 100
)


# ============================================================
# SIDEBAR
# ============================================================

st.sidebar.title("PlantAssemblyForge")

page = st.sidebar.radio(
    "Navigation",
    [
        "Overview",
        "Quality Control",
        "Genome Assembly",
        "QUAST",
        "BUSCO",
        "k-mer Analysis",
        "Transcriptome",
        "Workflow",
    ],
)


# ============================================================
# OVERVIEW
# ============================================================

if page == "Overview":

    page_header()

    st.header("Project Overview")

    metric_row(
        [
            ("Cleaned Coverage", "15.49×"),
            ("Assembly Size", "107.24 Mb"),
            ("Genome Fraction", "81.89%"),
            ("BUSCO Complete", "95.4%"),
        ]
    )

    st.markdown("<br>", unsafe_allow_html=True)

    st.markdown(
        '<div class="status-complete">'
        '✓ Pipeline analysis completed &nbsp;&nbsp; • &nbsp;&nbsp; '
        '7/7 genome modules validated'
        '</div>',
        unsafe_allow_html=True,
    )

    st.subheader("Benchmark Dataset")

    dataset = pd.DataFrame(
        {
            "Property": [
                "Organism",
                "SRA Run",
                "Sequencing",
                "Read length",
                "Assembler",
                "Workflow engine",
            ],
            "Value": [
                "Arabidopsis thaliana",
                "SRR1946456",
                "Illumina paired-end WGS",
                "100 bp",
                "SPAdes",
                "Nextflow DSL2",
            ],
        }
    )

    st.dataframe(
        dataset,
        width="stretch",
        hide_index=True,
    )

    st.subheader("Genome Workflow")

    workflow_box("Paired-end FASTQ")
    workflow_arrow()

    workflow_box("FastQC — Raw read quality assessment")
    workflow_arrow()

    workflow_box("fastp — Quality filtering")
    workflow_arrow()

    workflow_box("Post-filter FastQC")
    workflow_arrow()

    c1, c2 = st.columns(2)

    with c1:
        workflow_box("Jellyfish — 21-mer Analysis")

    with c2:
        workflow_box("SPAdes — De Novo Assembly")

    st.markdown("### Assembly Validation")

    c1, c2 = st.columns(2)

    with c1:
        workflow_box("QUAST — Structural Evaluation")

    with c2:
        workflow_box("BUSCO — Gene-space Completeness")


# ============================================================
# QUALITY CONTROL
# ============================================================

elif page == "Quality Control":

    page_header()

    st.header("Sequencing Quality Control")

    fastp = parse_fastp_json()

    if fastp:

        before_reads = fastp["before_reads"]
        after_reads = fastp["after_reads"]

        retention = (
            after_reads / before_reads * 100
            if before_reads
            else None
        )

        before_q30 = (
            fastp["before_q30"] * 100
            if fastp["before_q30"] is not None
            else None
        )

        after_q30 = (
            fastp["after_q30"] * 100
            if fastp["after_q30"] is not None
            else None
        )

        metric_row(
            [
                (
                    "Raw Reads",
                    f"{before_reads:,}" if before_reads else "N/A",
                ),
                (
                    "Clean Reads",
                    f"{after_reads:,}" if after_reads else "N/A",
                ),
                (
                    "Reads Retained",
                    f"{retention:.2f}%"
                    if retention is not None
                    else "N/A",
                ),
                (
                    "Clean Q30",
                    f"{after_q30:.2f}%"
                    if after_q30 is not None
                    else "N/A",
                ),
            ]
        )

        qc_df = pd.DataFrame(
            {
                "Metric": [
                    "Reads",
                    "Bases",
                    "Q30 (%)",
                    "GC (%)",
                ],
                "Raw": [
                    fastp["before_reads"],
                    fastp["before_bases"],
                    before_q30,
                    fastp["before_gc"] * 100
                    if fastp["before_gc"] is not None
                    else None,
                ],
                "Cleaned": [
                    fastp["after_reads"],
                    fastp["after_bases"],
                    after_q30,
                    fastp["after_gc"] * 100
                    if fastp["after_gc"] is not None
                    else None,
                ],
            }
        )

        st.subheader("Raw vs Cleaned Reads")

        st.dataframe(
            qc_df,
            width="stretch",
            hide_index=True,
        )

        plot_qc = pd.DataFrame(
            {
                "Stage": ["Raw", "Cleaned"],
                "Reads": [
                    fastp["before_reads"],
                    fastp["after_reads"],
                ],
            }
        )

        fig = px.bar(
            plot_qc,
            x="Stage",
            y="Reads",
            text_auto=".3s",
            title="Read Retention After Quality Filtering",
        )

        fig.update_layout(
            height=420,
            yaxis_title="Number of reads",
        )

        st.plotly_chart(
            fig,
            width="stretch",
        )

        st.markdown(
            """
            <div class="interpretation">
            <b>Interpretation:</b>
            Quality filtering removes low-quality or problematic reads
            before de novo assembly. High read retention together with
            strong Q30 values indicates that the WGS dataset remained
            suitable for assembly after preprocessing.
            </div>
            """,
            unsafe_allow_html=True,
        )

    else:

        st.warning(
            "fastp JSON report was not found. "
            "The page will populate automatically when "
            "results/genome/final_trimmed/fastp.json is available."
        )

        metric_row(
            [
                ("Cleaned Coverage", "15.49×"),
                ("R1 Q30", "93.75%"),
                ("R2 Q30", "92.13%"),
                ("Read length", "100 bp"),
            ]
        )

        st.info(
            "The cleaned paired-end reads retained high base quality "
            "and were used for downstream k-mer analysis and assembly."
        )


# ============================================================
# GENOME ASSEMBLY
# ============================================================

elif page == "Genome Assembly":

    page_header()

    st.header("De Novo Genome Assembly")

    metric_row(
        [
            ("Scaffold Assembly", "107.24 Mb"),
            ("Scaffold N50", "8,515 bp"),
            ("Largest Scaffold", "56,462 bp"),
            ("GC Content", "36.21%"),
        ]
    )

    assembly_df = pd.DataFrame(
        {
            "Metric": [
                "Reference genome size",
                "Contig assembly size",
                "Scaffold assembly size",
                "Contig N50",
                "Scaffold N50",
                "Largest scaffold",
                "GC content",
            ],
            "Value": [
                "119.67 Mb",
                "107.21 Mb",
                "107.24 Mb",
                "7,429 bp",
                "8,515 bp",
                "56,462 bp",
                "36.21%",
            ],
        }
    )

    st.dataframe(
        assembly_df,
        width="stretch",
        hide_index=True,
    )

    comparison = pd.DataFrame(
        {
            "Sequence": [
                "Reference",
                "Contigs",
                "Scaffolds",
            ],
            "Size (Mb)": [
                GENOME_RESULTS["reference_size"],
                GENOME_RESULTS["contig_size"],
                GENOME_RESULTS["scaffold_size"],
            ],
        }
    )

    fig = px.bar(
        comparison,
        x="Sequence",
        y="Size (Mb)",
        text_auto=".2f",
        title="Reference and Assembly Size Comparison",
    )

    fig.update_layout(height=420)

    st.plotly_chart(
        fig,
        width="stretch",
    )

    st.markdown(
        """
        <div class="interpretation">
        <b>Interpretation:</b>
        The short-read assembly recovered approximately 107 Mb of the
        Arabidopsis genome. Contiguity remains limited, as expected for a
        moderate-depth short-read-only assembly, while downstream BUSCO
        analysis shows strong recovery of conserved gene content.
        </div>
        """,
        unsafe_allow_html=True,
    )


# ============================================================
# QUAST
# ============================================================

elif page == "QUAST":

    page_header()

    st.header("QUAST Assembly Evaluation")

    metric_row(
        [
            ("Genome Fraction", "81.892%"),
            ("Duplication Ratio", "1.003"),
            ("Scaffold NGA50", "5,971 bp"),
        ]
    )

    quast_df = pd.DataFrame(
        {
            "Metric": [
                "Genome fraction (%)",
                "Duplication ratio",
                "NGA50",
                "Misassemblies",
                "Mismatches / 100 kbp",
                "Indels / 100 kbp",
            ],
            "Contigs": [
                81.706,
                1.003,
                5280,
                2522,
                612.47,
                132.48,
            ],
            "Scaffolds": [
                81.892,
                1.003,
                5971,
                2535,
                616.08,
                136.22,
            ],
        }
    )

    st.dataframe(
        quast_df,
        width="stretch",
        hide_index=True,
    )

    contiguity = pd.DataFrame(
        {
            "Assembly": ["Contigs", "Scaffolds"],
            "NGA50": [5280, 5971],
        }
    )

    fig = px.bar(
        contiguity,
        x="Assembly",
        y="NGA50",
        text_auto=True,
        title="Reference-aware Contiguity (NGA50)",
    )

    fig.update_layout(
        height=420,
        yaxis_title="NGA50 (bp)",
    )

    st.plotly_chart(
        fig,
        width="stretch",
    )

    recovery = pd.DataFrame(
        {
            "Assembly": ["Contigs", "Scaffolds"],
            "Genome fraction (%)": [81.706, 81.892],
        }
    )

    fig = px.bar(
        recovery,
        x="Assembly",
        y="Genome fraction (%)",
        text_auto=".3f",
        title="Reference Genome Fraction",
    )

    fig.update_layout(
        height=420,
        yaxis_range=[0, 100],
    )

    st.plotly_chart(
        fig,
        width="stretch",
    )

    st.markdown(
        """
        <div class="interpretation">
        <b>Interpretation:</b>
        Scaffolding modestly improves reference-aware contiguity while
        maintaining an almost identical duplication ratio. The 81.9%
        genome fraction indicates substantial reference recovery but also
        reflects the fragmented nature of a moderate-depth short-read
        assembly.
        </div>
        """,
        unsafe_allow_html=True,
    )


# ============================================================
# BUSCO
# ============================================================

elif page == "BUSCO":

    page_header()

    st.header("BUSCO Gene-space Completeness")

    metric_row(
        [
            ("Complete", "95.4%"),
            ("Single-copy", "93.9%"),
            ("Duplicated", "1.5%"),
            ("Missing", "1.3%"),
        ]
    )

    st.caption(
        "Lineage dataset: eudicotyledons_odb12.2 • n = 1,990"
    )

    busco_df = pd.DataFrame(
        {
            "Category": [
                "Single-copy",
                "Duplicated",
                "Fragmented",
                "Missing",
            ],
            "BUSCOs": [
                1869,
                29,
                67,
                25,
            ],
            "Percentage": [
                93.9,
                1.5,
                3.4,
                1.3,
            ],
        }
    )

    st.dataframe(
        busco_df,
        width="stretch",
        hide_index=True,
    )

    # Stacked BUSCO bar
    fig = go.Figure()

    categories = [
        ("Single-copy", 93.9),
        ("Duplicated", 1.5),
        ("Fragmented", 3.4),
        ("Missing", 1.3),
    ]

    for name, value in categories:

        fig.add_trace(
            go.Bar(
                y=["BUSCO"],
                x=[value],
                name=name,
                orientation="h",
                text=[f"{value}%"],
                textposition="inside",
            )
        )

    fig.update_layout(
        barmode="stack",
        title="BUSCO Completeness Profile",
        xaxis_title="Percentage of BUSCO groups",
        xaxis_range=[0, 100],
        height=330,
        legend_title="Category",
    )

    st.plotly_chart(
        fig,
        width="stretch",
    )

    st.markdown(
        """
        <div class="interpretation">
        <b>Interpretation:</b>
        95.4% complete BUSCO recovery indicates strong conservation of
        expected eudicot gene space. The low missing fraction (1.3%)
        suggests that most conserved protein-coding regions are represented
        despite limited scaffold contiguity.
        </div>
        """,
        unsafe_allow_html=True,
    )


# ============================================================
# K-MER
# ============================================================

elif page == "k-mer Analysis":

    page_header()

    st.header("Jellyfish 21-mer Spectrum")

    hist = read_kmer()

    if hist is None:

        st.warning(
            "k21_histogram.tsv was not found."
        )

    else:

        metric_row(
            [
                ("k-mer Size", "21"),
                (
                    "Multiplicity-1 k-mers",
                    f"{int(hist.iloc[0]['Frequency']):,}",
                ),
                (
                    "Observed Multiplicities",
                    f"{len(hist):,}",
                ),
            ]
        )

        max_mult = st.slider(
            "Maximum multiplicity displayed",
            min_value=20,
            max_value=min(200, int(hist["Multiplicity"].max())),
            value=50,
            step=10,
        )

        log_scale = st.toggle(
            "Log-scale frequency axis",
            value=False,
        )

        plot_df = hist[
            hist["Multiplicity"] <= max_mult
        ].copy()

        fig = px.line(
            plot_df,
            x="Multiplicity",
            y="Frequency",
            title="21-mer Frequency Spectrum",
        )

        fig.update_traces(
            line_width=3
        )

        if log_scale:
            fig.update_yaxes(type="log")

        fig.update_layout(
            height=500,
            xaxis_title="k-mer multiplicity",
            yaxis_title="Frequency",
        )

        st.plotly_chart(
            fig,
            width="stretch",
        )

        st.subheader("Histogram Data")

        st.dataframe(
            hist.head(50),
            width="stretch",
            hide_index=True,
        )

        st.markdown(
            """
            <div class="interpretation">
            <b>Interpretation:</b>
            Very low-frequency k-mers are often enriched for sequencing
            errors, whereas the broader higher-multiplicity distribution
            represents repeatedly observed genomic sequence. The interactive
            zoom and logarithmic scale allow the spectrum to be examined
            without the multiplicity-1 peak dominating the entire plot.
            </div>
            """,
            unsafe_allow_html=True,
        )


# ============================================================
# TRANSCRIPTOME
# ============================================================

elif page == "Transcriptome":

    page_header()

    st.header("Transcriptome Assembly")

    metric_row(
        [
            ("Read-back Mapping", "73.85%"),
            ("Predicted Proteins", "7,699"),
            ("DIAMOND Hits", "7,630"),
            ("Annotation Rate", f"{annotation_rate:.1f}%"),
        ]
    )

    transcript_df = pd.DataFrame(
        {
            "Metric": [
                "Predicted proteins",
                "Proteins with DIAMOND hits",
            ],
            "Count": [
                7699,
                7630,
            ],
        }
    )

    fig = px.bar(
        transcript_df,
        x="Metric",
        y="Count",
        text_auto=True,
        title="Predicted vs Homology-Annotated Proteins",
    )

    fig.update_layout(height=420)

    st.plotly_chart(
        fig,
        width="stretch",
    )

    st.subheader("De Novo Branch")

    workflow_box("RNA-seq paired-end reads")
    workflow_arrow()

    workflow_box("FastQC")
    workflow_arrow()

    workflow_box("fastp")
    workflow_arrow()

    workflow_box("RNA-SPAdes")
    workflow_arrow()

    workflow_box("Bowtie2 Read-back Mapping")
    workflow_arrow()

    workflow_box("rnaQUAST")
    workflow_arrow()

    workflow_box("TransDecoder")
    workflow_arrow()

    workflow_box("DIAMOND")

    st.subheader("Reference-guided Branch")

    workflow_box("RNA-seq")
    workflow_arrow()

    workflow_box("HISAT2")
    workflow_arrow()

    workflow_box("SAMtools")
    workflow_arrow()

    workflow_box("StringTie")

    st.markdown(
        """
        <div class="interpretation">
        <b>Interpretation:</b>
        Read-back mapping evaluates support of assembled transcripts by
        the original sequencing reads. TransDecoder predicts coding regions,
        while DIAMOND provides rapid protein homology annotation.
        </div>
        """,
        unsafe_allow_html=True,
    )


# ============================================================
# WORKFLOW
# ============================================================

elif page == "Workflow":

    page_header()

    st.header("Nextflow DSL2 Architecture")

    workflow_box("GENOME_FASTQC")
    workflow_arrow()

    workflow_box("GENOME_FASTP")
    workflow_arrow()

    workflow_box("GENOME_FASTQC_CLEAN")

    c1, c2 = st.columns(2)

    with c1:
        workflow_box("GENOME_JELLYFISH")

    with c2:
        workflow_box("GENOME_SPADES")

    st.markdown("### Assembly Validation")

    c1, c2 = st.columns(2)

    with c1:
        workflow_box("GENOME_QUAST")

    with c2:
        workflow_box("GENOME_BUSCO")

    st.subheader("Validated Genome Modules")

    modules = pd.DataFrame(
        {
            "Process": [
                "GENOME_FASTQC",
                "GENOME_FASTP",
                "GENOME_FASTQC_CLEAN",
                "GENOME_JELLYFISH",
                "GENOME_SPADES",
                "GENOME_QUAST",
                "GENOME_BUSCO",
            ],
            "Status": [
                "Validated",
                "Validated",
                "Validated",
                "Validated",
                "Validated",
                "Validated",
                "Validated",
            ],
        }
    )

    st.dataframe(
        modules,
        width="stretch",
        hide_index=True,
    )

    st.markdown(
        '<div class="status-complete">'
        '✓ 7/7 genome modules successfully passed '
        'Nextflow stub validation.'
        '</div>',
        unsafe_allow_html=True,
    )