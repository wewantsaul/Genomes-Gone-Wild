process unicycler_ont {
	container 'staphb/unicycler:0.5.0'

	tag "ASSEMBLING GENOMES"

	publishDir (
	path: "${params.out_dir}/02_ont_assembly",
	mode: 'copy',
	overwrite: 'true'
	)
	
	input:
	tuple val(sample), path(fastq)

	output:
	tuple val(sample), path("${sample}/*.fasta"), emit: assembly
	tuple val(sample), path("${sample}/*.gfa") 
	tuple val(sample), path("${sample}/*.log") 

	script:
	"""
	mkdir -p $sample
	
	unicycler -l $fastq -o $sample --keep 0
	
	mv ${sample}/assembly.fasta ${sample}/${sample}.fasta
	mv ${sample}/assembly.gfa ${sample}/${sample}.gfa
	mv ${sample}/unicycler.log ${sample}/${sample}_run.log
	
	"""
}
