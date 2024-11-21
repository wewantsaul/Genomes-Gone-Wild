process compile {

	tag "COMPILING ASSEMBLY FILES"

	publishDir (
	path: "${params.out_dir}",
	mode: 'copy',
	overwrite: 'true'
	)
	
	input:
	tuple val(sample), path(assembly)

	output:
	file("unicycler_assemblies/*.fasta")

	script:
	"""
	mkdir -p unicycler_assemblies
	
	cp -f $assembly unicycler_assemblies/${sample}.fasta
	"""
}
