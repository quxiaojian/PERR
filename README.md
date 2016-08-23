##PERR-Paired End Reads Recruitment<br />
Given the mapped reads output from bowtie2 as seeds it recruits overlapped reads from original fastq by extending seeds.<br />
Copyright (C) 2016 Xiao-Jian Qu<br />

##CONTACT<br />
quxiaojian@mail.kib.ac.cn<br />

##PREREQUISITES<br />
GNU<br />
Perl<br />
Linux (Ubuntu) or Windows (I do not have a try.)<br />

##GENERAL INTRODUCTION to PERR<br />
  This script was originally developped for Illumina data. As the develepment of NGS technology, sequencing is more and more cheap and common. So many scientists could easily acquire sequnce information. My first touch of NGS reads is in 2014.1. I used the time- and labor-consuming methods (Jansen et al. 2005) to extract or enrich chloroplast, which need approximately 50 g fresh plant leaf materials and many kinds of reagent and solution. Oh, my god! It's not a small number. Sadly, the plastid DNA of some species are not well got by extracting only once. In the end, I got ten species plastid DNA using two weeks. Then I assembled all ten plastomes using CLC Genomics Workbench. Luckily, I got complete circular plastome maps of these ten species.<br />

  In about 2014.6, my senior brother (Peng-Fei Ma) in our big group assembled complete circular plastomes of bamboo from total genomic DNA. I felt amazing at that time, because extracting total genomic DNA could save a lot of time. In about 2016.4, my junior brother (Jian-Jun Jin) in our group gave us a presentation about how to get compelete plastome. Please see [here](https://github.com/Kinggerm/GetOrganelle). At the same time, I am learning Perl language as a fresher. So after finishing writing my degree paper at three months later (2016.7), I wrote this script as a practice to improve my programming skills. The major pipeline (mapping, recruiting and assembling) is similar to his or other previous published ones, but my script will need less time in recruiting step. In this month (2016.8), after testing this script many times in my spare evening time, I upload it and related test files to my github. Thanks for Dr. Jin giving me some valuable suggestions, which save me much time in performing test and improvement.<br />

  PERR (Paired End Reads Recruitment) is capable of assembling complete plastome using plastomes of distantly related plant species, or even plastome genes as reference. PERR is highly efficient in recruiting paired-end reads. Meanwhile, it will consume computer memory. 2Gb paired-end reads data need ca. 8Gb memory. 5Gb paired-end reads data need ca. 16Gb memory. Three steps will be conducted to assemble complete plastomes (or mito-genomes): (1) generating seed reads by mapping raw paired-end reads to reference plastome sequences, (2) recruiting overlapped reads from raw paired-end reads by extending seed reads, then using recruited overlapped reads as new seed reads, and iterate this step until no overlapped reads are recruited, (3) assembling reads (mapped reads plus recruited reads) output from step 2. The first two steps will consume ca. 5+10 min at most for totally 5Gb paired-end reads data. The time for third step could not be identically determined. Specifically, many aspects, such as sequencing quality, kmer numbers, etc could affect the final time. Two other aspects could be also considered. First, if you want to exclude the interference signal from mitochondrial genome (vice versa), you can map raw paired-end reads to reference of mitochondrial genome and delete those mito-realted reads from raw paired-end reads. Then, using dealt raw paired-end reads (deleting mito-related reads) to extend seed reads in second step. This aspect can also save assembling time. In the end, you will get a complete circular plastome. Second, if no complete circular plastome maps are got, you can perform mapping (step 1) and assembling (step 3) one or few times to fill the plastome gap. Furthermore, you can get complete circular mitochondrial genome when your library are large enough and the sequencing depth are deep enough. Detailed examples are showed below.<br />


##SIMILAR SCRIPTS<br />
[MITObim](https://github.com/chrishah/MITObim)<br />
[GetOrganelle](https://github.com/Kinggerm/GetOrganelle)<br />
[ARC](https://github.com/ibest/ARC)<br />
[ORG.Asm](https://git.metabarcoding.org/org-asm/org-asm/wikis/home)<br />

##PREPARATIONS<br />
(1) download [Bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml) and put it in your PATH.<br />
(2) download this repository to your local computer (git clone git://github.com/quxiaojian/PERR.git), and put all scripts in your PATH, and make all scripts read, write and executable (chmod -r a+rwx scripts).<br />

You can test PERR.pl by type ~/PATH/TO/PERR.pl, which will show the usage information:<br />
```
    PERR.pl -k -i -f -r -s1 -s2
    Copyright (C) 2016 Xiao-Jian Qu
    Please report log file to me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-k -kmer]           kmer value or specifically overlap value between two reads (default: 101).
    [-i -run]            the extending runs of reads recruitment (default: 10000).
    [-f -forward]        raw forward fastq.
    [-r -reverse]        raw reverse fastq.
    [-s1 -seed1]         mapped forward reads from bowtie2 as seed reads (default: seed_reads.1).
    [-s2 -seed2]         mapped reverse reads from bowtie2 as seed reads (default: seed_reads.2).
```
(3) download assemble softwares such as [spades](http://bioinf.spbau.ru/spades) or [velvet](https://github.com/dzerbino/velvet), and assembly graph visiual software [bandage](https://github.com/rrwick/Bandage). Also put it in your PATH.<br />

##NOTES<br />
(1) Your raw paired-end reads filename should be xxx_1.fq and xxx_2.fq, so the scripts do not need to revise.<br />
(2) The format of "Sequence identifier" (first line of every four lines, beginning with @ symbol) for my own Illumina fq data is as follows: @EAS139:136:FC706VJ:2:5:1000:12850 1:N:0 @EAS139:136:FC706VJ:2:5:1000:12850 2:N:0<br />
Please check: http://support.illumina.com/help/SequencingAnalysisWorkflow/Content/Vault/Informatics/Sequencing_Analysis/CASAVA/swSEQ_mCA_FASTQFiles.htm.
You can check sequence identifier for your Illumina fq data.<br />
(3) The kmer value in PERR can be set by yourself. The best value maybe 80% of read length. You can try several times for you case.<br />
(4) The extending runs in PERR can be set to a more bigger value. PERR will stop recruiting when no overlapped reads can be extended.<br />

##TUTORIALS<br />
  TUTORIAL I and II are more similar. They are applied to enriched chloroplast DNA and total genomic DNA, respectively. I have writen several perl scripts to generate bash file (.sh), which can be used to assemble plastomes or mito-genomes in batch processing mode. Such as batch mapping, batch removing mt or cp reads from raw fq reads, batch recruiting and batch assembling. Please see how to operate in following specific tutorials.<br />

```
bowtie_bash.pl
generate bash file (.sh) for performing batch mapping.
remove_cp_or_mt_from_fq.pl
remove mt or cp reads from raw fq reads in batch processing mode.
perr_bash.pl
generate bash file (.sh) for performing batch recruiting.
PERR.pl
main script for recruiting reads.
spades_bash.pl
generate bash file (.sh) for performing assembly.
```

###TUTORIAL I<br />
assemble plastomes from enriched chloroplast DNA<br />

**First**, indexing your reference (cp or mt).<br />
```
bowtie2-build reference.fasta reference
```

**Second**, acquiring seed reads by mapping your raw fq reads to your reference.<br />
```
    bowtie_bash.pl -i -p -r -o
    Copyright (C) 2016 Xiao-Jian Qu
    Please contact me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-i -indir]          The input dir for multiple subdirs containing paired-end reads (default: Reads).
    [-p -organelle]      The cp or mt that you want to map your reads to (default: cp).
    [-r -ref]            The reference of indexed cp or mt (default: reference).
    [-o -outdir]         The output dir for your bash file (default: .).
```

**Third**, recruiting overlapped reads from raw fq reads using seed reads mentioned above.<br />
```
    perr_bash.pl -i -k -f -s -o
    Copyright (C) 2016 Xiao-Jian Qu
    Please contact me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-i -indir]          The input dir for multiple subdirs containing paired-end reads (default: Reads).
    [-k -kmer]           The kmer value (default: 101).
    [-p -organelle]      The cp or mt that you have removed from raw fq file, you can ignore this argument when not assigned (default: mt).
    [-f -fq]             The raw fq file you want to extend, F equal to _1.fq and _2.fq, T equal to _1_remove_mt.fq and _2_remove_mt.fq (default: T).
    [-s -seed]           The cp or mt that you want to extend (default: cp).
    [-o -outdir]         The output dir for your bash file (default: .).
```

**Fourth**, assembling seed reads plus recruited reads using spades (velvet).<br />
```
    spades_bash.pl -i -k -p -o
    Copyright (C) 2016 Xiao-Jian Qu
    Please contact me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-i -indir]          The input dir for multiple subdirs containing paired-end reads (default: Reads).
    [-k -kmer]           The kmer value (default: 91,95,101,105,111,115).
    [-p -organelle]      The cp or mt that you want to assembly (default: cp).
    [-o -outdir]         The output dir for your bash file (default: .).
```

**Fifth**, checking your assembling results using bandage.<br />
**Sixth**, if no complete circular plastome are got, repeat mapping (Second) and assembling (Fourth) one or few times.<br />

###TUTORIAL II<br />
assemble plastomes (mito-genomes) from total genomic DNA<br />

**First**, indexing your reference (cp or mt).<br />
```
bowtie2-build reference.fasta reference
```

**Second**, acquiring seed reads by mapping your raw fq reads to your reference.<br />
```
    bowtie_bash.pl -i -p -r -o
    Copyright (C) 2016 Xiao-Jian Qu
    Please contact me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-i -indir]          The input dir for multiple subdirs containing paired-end reads (default: Reads).
    [-p -organelle]      The cp or mt that you want to map your reads to (default: cp).
    [-r -ref]            The reference of indexed cp or mt (default: reference).
    [-o -outdir]         The output dir for your bash file (default: .).
```

**Third**, removing mt reads from raw fq reads when assembling plastomes.<br />
```
    remove_cp_or_mt_from_fq -i -p -o
    Copyright (C) 2016 Xiao-Jian Qu
    Please contact me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-i -indir]          The input dir for multiple subdirs containing paired-end reads (default: Reads).
    [-p -organelle]      The cp or mt that you want to remove (default: mt).
    [-o -outdir]         The output dir for your log file (default: .).
```

**Fourth**, recruiting overlapped reads from dealt fq reads (removed mt reads) using seed reads mentioned above.<br />
```
    perr_bash.pl -i -k -p -f -s -o
    Copyright (C) 2016 Xiao-Jian Qu
    Please contact me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-i -indir]          The input dir for multiple subdirs containing paired-end reads (default: Reads).
    [-k -kmer]           The kmer value (default: 101).
    [-p -organelle]      The cp or mt that you have removed from raw fq file, you can ignore this argument when not assigned (default: mt).
    [-f -fq]             The raw fq file you want to extend, F equal to _1.fq and _2.fq, T equal to _1_remove_mt.fq and _2_remove_mt.fq (default: T).
    [-s -seed]           The cp or mt that you want to extend (default: cp).
    [-o -outdir]         The output dir for your bash file (default: .).
```

**Fifth**, assembling seed reads plus recruited reads using spades (velvet).<br />
```
    spades_bash.pl -i -k -p -o
    Copyright (C) 2016 Xiao-Jian Qu
    Please contact me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-i -indir]          The input dir for multiple subdirs containing paired-end reads (default: Reads).
    [-k -kmer]           The kmer value (default: 91,95,101,105,111,115).
    [-p -organelle]      The cp or mt that you want to assembly (default: cp).
    [-o -outdir]         The output dir for your bash file (default: .).
```

**Sixth**, checking your assembling results using bandage.<br />
**Seventh**, if no complete circular plastome are got, repeat mapping (Second) and assembling (Fifth) one or few times.<br />

###TUTORIAL III<br />
assemble plastomes (mito-genomes) using barcode seeds<br />

To be continued...

