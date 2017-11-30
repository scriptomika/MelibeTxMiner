#!/usr/bin/perl 

#replace placeholder (line11) with absolute path to blastDBs directory
use strict;
use Bio::Tools::Run::StandAloneBlast;
use Bio::Seq;
use Bio::AlignIO;
use Bio::DB::Fasta;
use Bio::SeqIO;

my $blastpath = $ARGV[1];

 my @genomenames = 
(
'Acropora',
'Acyrthosipon',
'Amphemidon',
'Apis',
'Branchiostoma',
'Brugia',
'Caenorhabditis',
'Capitella',
'Ciona',
'Danaus',
'Daphnia',
'Drosophila',
'Gallus',
'Heliconius',
'Homo',
'Hydra',
'Ixodes',
'Latimeria',
'Lottia',
'Mnemiopsis',
'Nematostella',
'Octopus',
'Pinctata',
'Rhodneus',
'Salpingoeca',
'Strigamia',
'Strongylocentrous',
'Taeniopygia',
'Tetranychus',
'Tribolium',
'Trichoplax',
'Xenopus'
);

  my @fastanames = (
'Acropora_ed.fas',
'Acyrthosipon.fas',
'Amphemidon.fas',
'Apis.fas',
'proteins.Brafl1.fasta',
'Brugia.fas',
'Caenorhabditis.fas',
'FilteredModelsv1.0.aa.fasta',
'Ciona.fas',
'Danaus.fas',
'Daphnia.fas',
'Drosophila.fas',
'Gallus.fas',
'Hmelpomene_v1-0_Oct24_peptide_haplotype.fas',
'Homo_sapiens.GRCh37.75.pep.all.fa',
'Hydra.fas',
'Ixodes.fas',
'Latimeria.fas',
'Lottia.fas',
'Mnemiopsis.fas',
'Nematostella.fas',
'Obimaculoides_280_peptide.fa',
'Pinctata.fas',
'Rhodneus.fas',
'Salpingoeca.fas',
'Strigamia.fas',
'Strongylocentrous.fas',
'Taeniopygia_guttata.taeGut3.2.4.75.pep.abinitio.fa',
'Tetranychus.fas',
'Tribolium.fas',
'Trichoplax.fas',
'Xenopus.fas'
);

  my $n = 0;

  #get sequences to blast
  my $in  = Bio::SeqIO->new(-file => $ARGV[0] , '-format' => 'Fasta');
  while ( my $seq = $in->next_seq() ) {
    my $outfile = "GENBLAST".$seq->id.".fas";
    open (OUTFILE, ">".$outfile);
    close OUTFILE;
    print "Blasting Bait : ".$seq->id." \n";
    open (OUTFILE, ">>".$outfile);
   print OUTFILE (">BAIT_".$seq->id."\n");
    print OUTFILE ($seq->seq."\n");

    while($genomenames[$n]){
       print "\tagainst ".$genomenames[$n]."\n";
       # Setup blastp
       my $factory = Bio::Tools::Run::StandAloneBlast->new('program' => 
'blastall', 
						  'outfile' => 
'blast.out');

       #SET PARAMETERS OF BLAST
       $factory->b('10'); 		#NUMBER of BLAST HITS TO RETAIN
       $factory->p('blastp');
       $factory->v('0.01');
       $factory->e('10e-40');


       #LOCATION OF LOCAL BLAST DB HERE
       my $currentgenome = $blastpath.$genomenames[$n];
       $factory->d($currentgenome);
       my $blast_report = $factory->blastall($seq);


       #Parse blast output

       my $blastin = new Bio::SearchIO(-format => 'blast', 
                               -file   => 'blast.out');

       my $currentfasta = $blastpath.$fastanames[$n];

       while( my $result = $blastin->next_result ) {
         while( my $hit = $result->next_hit ) {
           while( my $hsp = $hit->next_hsp ) {
	      grab($currentfasta, $hit->name, $genomenames[$n]."_");
           }   
         }
       }
    $n++;
    }
    $n=0;
    close OUTFILE;
  }


sub grab
{
#grab.pl grabs sequences from fasta file whose names match
#those in an input file
#
#usage:
#grab nameoffastavile nameofseq

# create database from directory of fasta files
  my $fastafile = $_[0];
  my $db      = Bio::DB::Fasta->new($fastafile);


# open out file
  my $seqio_obj = Bio::SeqIO->new(-format =>'fasta' );

  my $currentinput =  $_[1];

# grab sequence object
        my $obj     = $db->get_Seq_by_id($currentinput);
        if($obj){
                my $seq_obj = $obj;

		print OUTFILE (">".$_[2].$seq_obj->id."\n");
		print OUTFILE ($seq_obj->seq."\n");
        }else{
                #print "grab.pl Did NOT Find ".$currentinput."\n";
        }

}


