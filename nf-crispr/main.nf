nextflow.enable.dsl = 2
params.options = [:]

include {CRASS_FINDER} from '../../nf-modules/modules/crass/finder/main.nf'
include {SEQTK_SUBSEQ} from '../../nf-modules/modules/seqtk/subseq/main.nf'
include {BWA_INDEX} from '../../nf-modules/modules/bwa/index/main.nf'
include {BWA_MEM} from '../../nf-modules/modules/bwa/mem/main.nf'


workflow crass {

    reads = Channel.fromFilePairs(params.reads).map{[[id: it[0]], it[1]]}

    crispr_reads = CRASS_FINDER( reads ).fasta
    
    crispr_read_ids = crispr_reads
        .map{it[1]}.flatten()
        .splitFasta( record: [id: true, seqString: true ])
        .map{record -> record.id}
        .unique()
        .collectFile(name: "crispr_read_ids.txt", newLine: true)
    
    crispr_reads_fq = SEQTK_SUBSEQ(
        reads,
        crispr_read_ids.first()
    ).fastq
}

workflow mapping {
    contigs = file(params.contigs)
    crispr_reads = Channel.fromFilePairs(params.reads).map{[[id: it[0]], it[1]]}
    
    bwa_idx = BWA_INDEX( contigs ).index

    coverage = BWA_MEM(
        crispr_reads,
        bwa_idx
    )
}

