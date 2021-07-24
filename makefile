dataset ?= juan-de-fuca
type ?= bacterial
contigs ?= $(dataset)/$(type)_contigs.fasta

crass:
	nextflow run nf-crispr -resume -entry crass \
	  --reads "$(dataset)/bacterial-reads/*_{1,2}.fastq" \
	  --outdir $(dataset)/crispr_pipeline

mapping:
	nextflow run nf-crispr -resume -entry mapping \
	  --reads "$(dataset)/crispr_pipeline/seqtk/*_{1,2}.fastq" \
	  --contigs $(contigs) \
	  --outdir $(dataset)/crispr_pipeline

all:
	@make crass dataset=$(dataset)
	python concatenate_bins.py $(dataset)/bacterial-bins/fasta $(dataset)/bacterial_contigs.fasta
	@make mapping dataset=$(dataset) type=bacterial
	@make mapping dataset=$(dataset) type=viral
