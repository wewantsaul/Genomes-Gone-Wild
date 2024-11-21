process quast {
	container 'staphb/quast:5.2.0'

	tag "ASSESSING GENOMES"

	publishDir (
	path: "${params.out_dir}",
	mode: 'copy',
	overwrite: 'true'
	)
	
	input:
	file(assembly)
	path(ref_seq)

	output:
	path("*")

	script:
	"""
	mkdir -p 03_assembly_summary
	
	quast.py $assembly -r $ref_seq -o 03_assembly_summary

	"""
}
