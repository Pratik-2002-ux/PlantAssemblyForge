# PlantAssemblyForge Results Summary

## Final genome dataset

- Organism: Arabidopsis thaliana
- SRA run: SRR1946456
- Sequencing: Illumina paired-end WGS
- Cleaned sequence: ~1.859 Gb
- Approximate cleaned coverage: ~15.49x

## SPAdes genome assembly

| Metric | Result |
|---|---:|
| Contig assembly size | 107.21 Mb |
| Scaffold assembly size | 107.24 Mb |
| Contig N50 | 7,429 bp |
| Scaffold N50 | 8,515 bp |
| Largest scaffold | 56,462 bp |
| GC | 36.21% |

## QUAST

| Metric | Contigs | Scaffolds |
|---|---:|---:|
| Genome fraction (%) | 81.706 | 81.892 |
| Duplication ratio | 1.003 | 1.003 |
| NGA50 | 5,280 bp | 5,971 bp |
| Misassemblies | 2,522 | 2,535 |
| Mismatches / 100 kbp | 612.47 | 616.08 |
| Indels / 100 kbp | 132.48 | 136.22 |

## BUSCO

Lineage: eudicotyledons_odb12.2

C:95.4% [S:93.9%,D:1.5%], F:3.4%, M:1.3%, n:1990

- Complete BUSCOs: 1,898
- Single-copy: 1,869
- Duplicated: 29
- Fragmented: 67
- Missing: 25

## Transcriptome branch

- De novo transcriptome assembly: RNA-SPAdes
- Read-back mapping: 73.85%
- Reference-guided reconstruction: HISAT2 + SAMtools + StringTie
- Assembly evaluation: rnaQUAST
- ORF prediction: TransDecoder
- Functional homology: DIAMOND
