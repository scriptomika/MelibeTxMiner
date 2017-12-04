#!/bin/bash
#usage: ./blast_align_genometree.sh  <peptidetranscriptome> <gene_directory> <BLAST evalue cut-off> <raxml_run_ID>
#example: ./blast_align_genometree.sh  MeliTSAFLT.pep.fa BMAL 1e-20 run1

## dependencies to install:
# ncbi blast+
# muscle
# raxmlHPC
 
## dependencies provided:
# get_seqs.pl
# genome_pep_BLAST.pl (uses Bio::Tools::Run::StandAloneBlast; Bio::Seq; Bio::AlignIO; Bio::DB::Fasta; Bio::SeqIO;
# fasta_formatter

tx=$1
genedir=$2
evalue=$3
run=$4

if [[ ! $# -eq 4 ]] ; then
    echo '** Arguments missing **'
    echo '   --Provide directory (i.e., gene) name, an evalue cut-off for BLAST, and a unique run identifier'
    echo '   --Example: ./blast_align_genometree.sh BMAL 1e-20 run1'
    echo ''
    exit 1
fi
if [[ ! -s  ./${2}/baits.fa ]] ; then
    echo '** No reference sequences detected **'
    echo '   --Put a fasta file named baits.fa in the gene directory'
    echo '   --OR, check spelling of gene directory'
    echo ''
    exit 1
fi

### Step 0: compile fasta of representative peptides to use as queries called 'baits.fa'
#then, clean up bait sequence headers
echo "Cleaning up Fasta headers...";echo "";
cat ./${genedir}/baits.fa | perl -p -e 's/(\.|\ |-|\|)/_/g'|perl -p -e 's/(\[|\]|\(|\)|:)//g'  > ./${genedir}/cleanbaits.fa
if [[ ! -s ${tx}.clean.pep.fa ]] ; then 
   cat $tx |perl -p -e 's/(\.|\:\:)/_/g' | perl -p -e 's/\*//g' > ${tx}.clean.pep.fa
fi

### Step 1: blast search genomes

#get genome matches
./scripts/genome_pep_BLAST.pl ./${genedir}/cleanbaits.fa ./blastDBs/
cat GENBLAST* | fasta_formatter -w 0 |perl -p -e 's/_\n/\n/g' > ./${genedir}/genomehits.fas
mv GENBLAST* ./${genedir}/

## remove duplicate lines 
cat ./${genedir}/genomehits.fas| perl -p -e 's/\n+/_____/g ' |\
perl -p -e 's/_____\>/\n\>/g'| perl -p -e 's/_____$/\n/g' |sort |uniq |\
perl -p -e 's/_____/\n/g' | perl -p -e 's/\*//g'  > genome.deduplicated.fas

### Step 2: blast search transcriptome
#get transcriptome peptide hits by blastp on translated transcriptome
echo "BLASTING transcriptome ...";echo "";
blastp -query ./${genedir}/baits.fa -subject ${tx}.clean.pep.fa -outfmt 6 -evalue $evalue | cut -f2 |sort|uniq > pep_matches
./scripts/get_seqs.pl --db ${tx}.clean.pep.fa --table pep_matches --col 1 --selected tx_hits_pep.fas
cat tx_hits_pep.fas | fasta_formatter -w 0 > txtemp
rm pep_matches tx_hits_pep.fas blast.out

### Step 3: Align transcriptome hits with genome and representative seqs

#create alignment with full-length seqs, then add in fragments from assembly
muscle -in genome.deduplicated.fas -out temp; cat temp|fasta_formatter -w 0 > genome.deduplicated.aln
split -l 2 txtemp transcript_seqs_to_add_in
for i in $(ls transcript_seqs_to_add_in*); 
do muscle -profile -in1 genome.deduplicated.aln -in2 $i -out temp;
cat temp|fasta_formatter -w 0 > deduplicated.aln ;
done
rm   temp txtemp deduplicated.fas transcript_seqs_to_add*
./scripts/fasta2relaxedPhylip.pl  deduplicated.aln
mv deduplicated.aln.phylip ./${genedir}/
rm deduplicated.aln

### Step 4: ML tree inference

raxmlHPC -s ./${genedir}/deduplicated.aln.phylip -m PROTGAMMAWAG -n $run -p 1234
mv RAxML* ./${genedir}/
