process unicycler_hybrid {
	container 'staphb/unicycler:0.5.0'

	tag "ASSEMBLING GENOMES"

	publishDir (
	path: "${params.out_dir}/02_ont_assembly",
	mode: 'copy',
	overwrite: 'true'
	)
	
	input:
	tuple val(sample), path(fastq_1), path(fastq_2), path(fastq_ont)

	output:
	tuple val(sample), path("${sample}/*.fasta"), emit: assembly
	tuple val(sample), path("${sample}/*.gfa") 
	tuple val(sample), path("${sample}/*.log") 

	script:
	"""
	mkdir -p $sample
	
	unicycler -1 $fastq_1 -2 $fastq_2 -l $fastq_ont -o $sample --keep 0 --kmers 71
	
	mv ${sample}/assembly.fasta ${sample}/${sample}.fasta
	mv ${sample}/assembly.gfa ${sample}/${sample}.gfa
	mv ${sample}/unicycler.log ${sample}/${sample}_run.log
	
	"""
}
