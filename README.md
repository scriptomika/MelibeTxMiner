# MelibeTxMiner
## Phylogenomics pipeline to identify circadian genes in nudibranch molluscs ###


This repository contains the scripts needed to conduct phylogenomic screens of nudibranch transcriptome assemblies. The assemblies are available to download here[link].

## Please cite:
[citation]


### Step 1
Blast search genomes using NCBI BLAST+ and a manually compiled fasta of representative peptide queries called 'baits.fa'
### Step 2 
Blast search peptide-translated transcriptome using NCBI BLAST+ and a manually compiled fasta of representative peptide queries called 'baits.fa'
### Step 3
Align transcriptome hits with genome and representative seqs using MUSCLE
### Step 4
ML tree inference using RAxML

### INSTALLATION

### Ensure the following dependencies are in the $PATH (installed on your machine)

- blastp (included in the ncbi BLAST+ suite)
- muscle
- raxmlHPC
- Perl Bio modules (Bio::Tools::Run::StandAloneBlast; Bio::Seq; Bio::AlignIO; Bio::DB::Fasta; Bio::SeqIO)

### Input data needed:
- blastDBs/
Publicly available animal genome peptide models (fasta) and formatted for peptide blast (i.e., .phr, .pin, .psq, .fas, .index)
See README in blastDBs for FTP links to genomes.

- peptide-translated transcriptome(s)
 - MeliTSAFLT.pep.fa [link]

The pipeline can then be executed by calling the shell script 'blast_align_genometree.sh'

###  Repository contents:
  
###### blast_align_genometree.sh
shell script to execute all steps of pipeline. Required arguments: 
- peptide-translated transcriptome fasta to search, 
- name of directory containing blast-query fasta file (baits.fa),
- minimum e-value,
- name for RAxML run
example command usage:
> - ./blast_align_genometree.sh MeliTSAFLT.pep.fa BMAL 1e-20 treerun1

###### scripts/
accessory scripts required within main shell script
- fasta_formatter
- get_seqs.pl
- genome_pep_BLAST.pl (uses Bio::Tools::Run::StandAloneBlast; Bio::Seq; Bio::AlignIO; Bio::DB::Fasta; Bio::SeqIO;)
- fasta2relaxedPhylip.pl

###### BMAL/, CLOCK/, etc
  # directories created for genes to screen.
  # each contains a file of representive sequences 'baits.fa' which may be ammended.
  # note that directory name is included in the execution command

