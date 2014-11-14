#!/usr/bin/env perl

use 5.010;
use strict;
use warnings FATAL => 'all';
use IPC::System::Simple qw(capture system);
use File::Temp;
use File::Spec;
use File::Basename;
use autodie qw(open);
use Test::More tests => 6;

my $cmd     = File::Spec->catfile('bin', 'pairfq');
my $fq_data = _build_fq_data();
my $fa_data = _build_fa_data();

my $tmpfq1_out = File::Temp->new( TEMPLATE => "pairfq_fq_XXXX",
				  DIR      => 't',
				  SUFFIX   => ".fastq",
				  UNLINK   => 0 );

my $tmpfq2_out = File::Temp->new( TEMPLATE => "pairfq_fq_XXXX",
				  DIR      => 't',
				  SUFFIX   => ".fastq",
				  UNLINK   => 0 );

my $tmpfa1_out = File::Temp->new( TEMPLATE => "pairfq_fa_XXXX",
				  DIR      => 't',
				  SUFFIX   => ".fasta",
				  UNLINK   => 0 );

my $tmpfa2_out = File::Temp->new( TEMPLATE => "pairfq_fa_XXXX",
				  DIR      => 't',
				  SUFFIX   => ".fasta",
				  UNLINK   => 0 );

system([0..5],"$cmd splitpairs -i $fq_data -f $tmpfq1_out -r $tmpfq2_out");
system([0..5],"$cmd splitpairs -i $fa_data -f $tmpfa1_out -r $tmpfa2_out");

my $tmpfq1 = $tmpfq1_out->filename;
my $tmpfq2 = $tmpfq2_out->filename;
my $tmpfa1 = $tmpfa1_out->filename;
my $tmpfa2 = $tmpfa2_out->filename;

open my $fq1, '<', $tmpfq1;
open my $fq2, '<', $tmpfq2;
open my $fa1, '<', $tmpfa1;
open my $fa2, '<', $tmpfa2;

my ($fq_fct, $fq_rct, $fa_fct, $fa_rct) = (0, 0, 0, 0);
while (<$fq1>) {
    s/^\s+|\s+$//g;
    $fq_fct++ if /\/1$/;
}
close $fq1;

while (<$fq2>) {
    s/^\s+|\s+$//g;
    $fq_rct++ if /\/2$/;
}
close $fq2;

is($fq_fct,            6, 'Correct number of forward fastq reads split');
is($fq_rct,            6, 'Correct number of reverse fastq reads split');
is($fq_fct + $fq_fct, 12, 'Correct number of total fastq reads split');
unlink $fq_data, $tmpfq1, $tmpfq2;

while (<$fa1>) {
    s/^\s+|\s+$//g;
    $fa_fct++ if /\/1$/;
} 
close $fa1;

while (<$fa2>) {
    s/^\s+|\s+$//g;
    $fa_rct++ if /\/2$/;
}
close $fa2;

is($fa_fct,            6, 'Correct number of forward fasta reads split');
is($fa_rct,            6, 'Correct number of reverse fasta reads split');
is($fa_fct + $fa_fct, 12, 'Correct number of total fasta reads split');
unlink $fa_data, $tmpfa1, $tmpfa2;

#
# private methods
#
sub _build_fq_data {
    my $tmpfq = File::Temp->new( TEMPLATE => "pairfq_fq_XXXX",
				 DIR      => 't',
				 SUFFIX   => ".fastq",
				 UNLINK   => 0 );
    
    my $tmpfq_name = $tmpfq->filename;
    
    say $tmpfq '@HWI-ST765:123:D0TEDACXX:5:1101:2872:2088/1';
    say $tmpfq 'TTGTCTTCCAGATAATTCCGCTATGTTCAACAAATATGTTAGATTCAAGTTTTTCTTGATAAACCTATTTAAAACCATGAAACTGATTCAATCGATTCAAT';
    say $tmpfq '+';
    say $tmpfq 'CCCFFFFFHHHHGJJJJJJIJJJJJJJJJJJJJJJJIIIIJJJIJJIJJHIJJJJJIJIJJJIJJJJJJJJJIJJIJJHHHHHHFFFFFFEEEDEDDDDED';
    say $tmpfq '@HWI-ST765:123:D0TEDACXX:5:1101:2872:2088/2';
    say $tmpfq 'ATTGTGTTATAAAGTTTATTTCTATTTCCGTTGCAACTTAAATCTGATTTACATTCATTTTACTTAAACAAACACAATCAAAAGAAACTCAGATCCTACAA';
    say $tmpfq '+';
    say $tmpfq 'CCCFDFFFHHHHHIHIJJJJJJJJJJJJJJJJJJJJJJJIJIIIJJJJJJJJJJJJIJIJJJJJJJIJJJJJJJJJGIJJHHHHHFBEDFDDEEDDDDDDD';
    say $tmpfq '@HWI-ST765:123:D0TEDACXX:5:1101:6511:2225/1';
    say $tmpfq 'GGGGTTTGAATTGGAATTGAACAAACTCGTGGGACCCCTAGACTGACCGGCTATATACTCAACCTGCTCTAAAGTAAGTGTGGGACACTCGAGCGTGTCGT';
    say $tmpfq '+';
    say $tmpfq '@BCFDFFFHHHHHJJJJJJJJIJJJJIJJGIJJIIJJJEIJJJJIJJJJJJIJHHHHHHHFFFFFAEEEEDDDCDCCDCCEDDDDDDDDDDBBDDBDBDB<';
    say $tmpfq '@HWI-ST765:123:D0TEDACXX:5:1101:6511:2225/2';
    say $tmpfq 'AAAGAAGACGGTGACTGAGTGCAATGATTTGTTCGAGAGTTTTGCACATTCTGATATGGACTACAGCACTGCCAGCAGGACTTCCATTCCTGTTACTACCA';
    say $tmpfq '+';
    say $tmpfq 'CCCFFFFFHHHDHIIIGIJHGIJJJJJJJJIIJJIGIIJGIIJJJJJJJJIJIIIJJIJIJJIJJJIJJJIHHHHFFFFDDECEEDDEEFDDDDDDDEDD>';
    say $tmpfq '@HWI-ST765:123:D0TEDACXX:5:1101:12346:2094/1';
    say $tmpfq 'CGTTCGTTAATTTAGTTAATTTAATTTAATTGCAAATTTTGGATTTTTAGAAACTCTCCCTCTCAAACATAAAAAATAGTTAGTGTCGCATCAGTGTCAGT';
    say $tmpfq '+';
    say $tmpfq '@C@FFFFFHFHHHHGHHIJJJJIIJJJIJGGIGHIJHIJJJJIIJJJJIGIIIJEIJJIIIGHIIGIJJJIIIIIHEFFBCFFC>AECDDDDDDCCCDDDD';
    say $tmpfq '@HWI-ST765:123:D0TEDACXX:5:1101:12346:2094/2';
    say $tmpfq 'TCAATTAAGTCCAAATAAAGTAATCAATGCAATTGCCAAAGAGTCCGCGGCAACGGCGCCAAAAAACTTGATGTGCTAAAAGTAGTTTAATAAAACAACTA';
    say $tmpfq '+';
    say $tmpfq '@CCFFFEFHFFFFIIJIIJIIFHIJJGGHIJJIJIJJIJJIIIFHIJIJIIIGJGHGDDDDDDDDDDDDDDDDDCDDDDDDDDDDCDDEDDEDCCCBDDDD';
    say $tmpfq '@HWI-ST765:123:D0TEDACXX:5:1101:16473:2185/1';
    say $tmpfq 'GCGTGTTGGGCTGACGCCAACCAAATGACGGTGGTTAGGATGGCGGTCAGGTCCTCGACGTTAGCCAATGTGGGCCACCATGTCTCATTGCGAAGTTCAGC';
    say $tmpfq '+';
    say $tmpfq '@CCDDFDFFHGHFJIGGHGEHGGHGGIEGHI6BF?BFHECBHHGGHDEFCE>;>@CB@BBBBDBDC@CDCDD@B22<?@BD>:C:AA>CCDDB@@8@DCCC';
    say $tmpfq '@HWI-ST765:123:D0TEDACXX:5:1101:16473:2185/2';
    say $tmpfq 'GTTGATTATGTTCTCATGCATACAGGGGTATGGCGATCCCGGACCCAAGTCAGCGACATGGACTCAAGCTTTTAATCGAAGACTACCCGTACGCTTCTGAC';
    say $tmpfq '+';
    say $tmpfq '@@BFFFFDHHHHDHIJHJIJJJJGHIJIFDCHJCHIGIJJIJJJIIIIIHCEIGHHFFFEECEEDDD>A>ACDDDDDBBABBDDDCDBDDBBDDB@BCDCC';
    say $tmpfq '@HWI-ST765:123:D0TEDACXX:5:1101:16583:2310/1';
    say $tmpfq 'CCATCCCCTCTCATCTATCCAAAGCCAACCGTATAATCATGGAACTTGAGAAACAACGCATTCGAGCAAAATATCTCAACAAGAAGTCTATGTTTATGTTT';
    say $tmpfq '+';
    say $tmpfq 'CCCFFFFFHHHHHIGIIIJJJJJJJJJJJHIGHGJIJIJJIJIJIIGIIJGJGHGIEIJGIHGGHFEFFFEEEFFDEDDDDBDDDD>ACADD@DEDDDDED';
    say $tmpfq '@HWI-ST765:123:D0TEDACXX:5:1101:16583:2310/2';
    say $tmpfq 'TCCCTTTTATTTATTTTGTTTTTATGAACTTTTGTGATATTGTTGATCACTAGCAGTGGTGTAGCATTGGTGCTATTTGGTACGGTTTACCCTGCACGCGG';
    say $tmpfq '+';
    say $tmpfq 'CCCFFFFFGHHHHIJJJJHIJJJGJJJJIIJJJJFEHIIIIIIIJJJJJJIIJJIIGHJFDDFGGHCHIGFFHIJJJJJIEHGHFEFDECCCE(;ACBDDD';
    say $tmpfq '@HWI-ST765:123:D0TEDACXX:5:1101:17034:2404/1';
    say $tmpfq 'CATTTGCGGTACTTCACACTAGCATGATGATGAAGGGTGCAATCGTTGCACAAGGGTGCAGTTCCGTTGTATGGCTTTCTAGCAGGGGGTTGAGTTGGTTG';
    say $tmpfq '+';
    say $tmpfq '@CCFFFFFHHHHHIJJJJJJJJJJJJJJJJJJJJJJJ?FHIJIIJIIIJIJJJJJJ@FHIJEIHHHAHFFFFFEDEEDDDEDDDDDDDD9@DCD@DCD@BB';
    say $tmpfq '@HWI-ST765:123:D0TEDACXX:5:1101:17034:2404/2';
    say $tmpfq 'AAAGGTGACAAGAAACCAATCGAAGAATCAAAACCTAAGGATAAACAGACTGAATCCTCCAAGAAGTCAAAGAAGCGGAAGGCTTCTCAGAACTTCACCGT';
    say $tmpfq '+';
    say $tmpfq 'BCCFFDDFHHHHHJJJJJJJJJJJJJJJJJJJJJJJJJJJIJJJJJJJJJIJJJJJJJJGIJJJJJHIHGHHHHFFFDCDDDDDDDDDEDDCDDDDDDDDB';

    return $tmpfq_name;
}

sub _build_fa_data {
    my $tmpfa = File::Temp->new( TEMPLATE => "pairfq_fa_XXXX",
				 DIR      => 't',
				 SUFFIX   => ".fasta",
				 UNLINK   => 0 );
    
    my $tmpfa_name = $tmpfa->filename;

    say $tmpfa '>HWI-ST765:123:D0TEDACXX:5:1101:2872:2088/1';
    say $tmpfa 'TTGTCTTCCAGATAATTCCGCTATGTTCAACAAATATGTTAGATTCAAGTTTTTCTTGATAAACCTATTTAAAACCATGAAACTGATTCAATCGATTCAAT';
    say $tmpfa '>HWI-ST765:123:D0TEDACXX:5:1101:2872:2088/2';
    say $tmpfa 'ATTGTGTTATAAAGTTTATTTCTATTTCCGTTGCAACTTAAATCTGATTTACATTCATTTTACTTAAACAAACACAATCAAAAGAAACTCAGATCCTACAA';
    say $tmpfa '>HWI-ST765:123:D0TEDACXX:5:1101:6511:2225/1';
    say $tmpfa 'GGGGTTTGAATTGGAATTGAACAAACTCGTGGGACCCCTAGACTGACCGGCTATATACTCAACCTGCTCTAAAGTAAGTGTGGGACACTCGAGCGTGTCGT';
    say $tmpfa '>HWI-ST765:123:D0TEDACXX:5:1101:6511:2225/2';
    say $tmpfa 'AAAGAAGACGGTGACTGAGTGCAATGATTTGTTCGAGAGTTTTGCACATTCTGATATGGACTACAGCACTGCCAGCAGGACTTCCATTCCTGTTACTACCA';
    say $tmpfa '>HWI-ST765:123:D0TEDACXX:5:1101:12346:2094/1';
    say $tmpfa 'CGTTCGTTAATTTAGTTAATTTAATTTAATTGCAAATTTTGGATTTTTAGAAACTCTCCCTCTCAAACATAAAAAATAGTTAGTGTCGCATCAGTGTCAGT';
    say $tmpfa '>HWI-ST765:123:D0TEDACXX:5:1101:12346:2094/2';
    say $tmpfa 'TCAATTAAGTCCAAATAAAGTAATCAATGCAATTGCCAAAGAGTCCGCGGCAACGGCGCCAAAAAACTTGATGTGCTAAAAGTAGTTTAATAAAACAACTA';
    say $tmpfa '>HWI-ST765:123:D0TEDACXX:5:1101:16473:2185/1';
    say $tmpfa 'GCGTGTTGGGCTGACGCCAACCAAATGACGGTGGTTAGGATGGCGGTCAGGTCCTCGACGTTAGCCAATGTGGGCCACCATGTCTCATTGCGAAGTTCAGC';
    say $tmpfa '>HWI-ST765:123:D0TEDACXX:5:1101:16473:2185/2';
    say $tmpfa 'GTTGATTATGTTCTCATGCATACAGGGGTATGGCGATCCCGGACCCAAGTCAGCGACATGGACTCAAGCTTTTAATCGAAGACTACCCGTACGCTTCTGAC';
    say $tmpfa '>HWI-ST765:123:D0TEDACXX:5:1101:16583:2310/1';
    say $tmpfa 'CCATCCCCTCTCATCTATCCAAAGCCAACCGTATAATCATGGAACTTGAGAAACAACGCATTCGAGCAAAATATCTCAACAAGAAGTCTATGTTTATGTTT';
    say $tmpfa '>HWI-ST765:123:D0TEDACXX:5:1101:16583:2310/2';
    say $tmpfa 'TCCCTTTTATTTATTTTGTTTTTATGAACTTTTGTGATATTGTTGATCACTAGCAGTGGTGTAGCATTGGTGCTATTTGGTACGGTTTACCCTGCACGCGG';
    say $tmpfa '>HWI-ST765:123:D0TEDACXX:5:1101:17034:2404/1';
    say $tmpfa 'CATTTGCGGTACTTCACACTAGCATGATGATGAAGGGTGCAATCGTTGCACAAGGGTGCAGTTCCGTTGTATGGCTTTCTAGCAGGGGGTTGAGTTGGTTG';
    say $tmpfa '>HWI-ST765:123:D0TEDACXX:5:1101:17034:2404/2';
    say $tmpfa 'AAAGGTGACAAGAAACCAATCGAAGAATCAAAACCTAAGGATAAACAGACTGAATCCTCCAAGAAGTCAAAGAAGCGGAAGGCTTCTCAGAACTTCACCGT';
    
    return $tmpfa_name;
}
