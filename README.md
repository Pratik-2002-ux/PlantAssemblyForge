# PlantAssemblyForge

PlantAssemblyForge is a modular Nextflow DSL2 workflow for reproducible plant genome and transcriptome assembly, quality control, validation, and functional analysis.

## Genome Workflow

FASTQ → FastQC → fastp → Post-QC → Jellyfish → SPAdes → QUAST → BUSCO

## Genome Dataset

- Organism: Arabidopsis thaliana
- SRA accession: SRR1946456
- Strategy: Whole-genome sequencing
- Layout: Paired-end Illumina
- Read length: 100 bp

## Genome Assembly Results

| Metric | Result |
|---|---:|
| Assembly size | 107.24 Mb |
| Largest scaffold | 56,462 bp |
| Scaffold N50 | 8,515 bp |
| Genome fraction | 81.892% |
| Duplication ratio | 1.003 |
| NGA50 | 5,971 bp |
| GC content | 36.21% |
| BUSCO completeness | 95.4% |

BUSCO completeness:

`C:95.4% [S:93.9%, D:1.5%], F:3.4%, M:1.3%, n:1990`

## Genome Modules

1. GENOME_FASTQC
2. GENOME_FASTP
3. GENOME_FASTQC_CLEAN
4. GENOME_JELLYFISH
5. GENOME_SPADES
6. GENOME_QUAST
7. GENOME_BUSCO

All seven genome modules were successfully validated using Nextflow DSL2 stub execution.

## Transcriptome Workflow

The repository also contains modules for RNA-SPAdes, HISAT2, SAMtools, StringTie, Bowtie2 read-back validation, rnaQUAST, TransDecoder, DIAMOND, and MultiQC.

## Installation

```bash
conda env create -f environment.yml
conda activate plantassembly
```

## Validate the Genome Workflow

```bash
nextflow -C conf/genome.config run genome_main.nf -stub-run
```

## Run the Genome Workflow

```bash
nextflow -C conf/genome.config run genome_main.nf
```

## Repository Structure

```text
PlantAssemblyForge/
├── genome_main.nf
├── main.nf
├── nextflow.config
├── conf/
├── config/
├── modules/
├── workflows/
├── results_summary/
├── environment.yml
├── CITATION.cff
└── LICENSE

## Interactive Results Dashboard

PlantAssemblyForge includes an interactive Streamlit dashboard for visual exploration and interpretation of genome and transcriptome analysis results.

### Dashboard Features

- Sequencing quality-control summary
- Raw vs cleaned read comparison
- Genome assembly statistics
- QUAST assembly evaluation
- BUSCO gene-space completeness
- Interactive Jellyfish 21-mer spectrum
- Transcriptome assembly and annotation summary
- Nextflow DSL2 workflow architecture
- Scientific interpretation of major assembly metrics

### Launch the Dashboard

Activate the Conda environment:

```bash
conda activate plantassembly
```

Launch PlantAssemblyForge:

```bash
streamlit run app/app.py
```

The dashboard will normally be available at:

```text
http://localhost:8501
```

### Dashboard Navigation

```text
Overview
├── Quality Control
├── Genome Assembly
├── QUAST
├── BUSCO
├── k-mer Analysis
├── Transcriptome
└── Workflow
```
```

## Results

Compact representative outputs are provided in `results_summary/`.

Raw sequencing data, reference databases, BUSCO datasets, large assembly FASTA files, Nextflow work directories, and intermediate files are excluded from Git version control.

## License

MIT License