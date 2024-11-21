nextflow.enable.dsl=2

include {unicycler_illumina} from './modules/unicycler_illumina.nf'
include {unicycler_ont} from './modules/unicycler_ont.nf'
include {unicycler_hybrid} from './modules/unicycler_hybrid.nf'
include {quast} from './modules/quast.nf'
include {compile} from './modules/compile.nf'
include {flye} from './modules/flye.nf'
include {medaka} from './modules/medaka.nf'
include {bwa} from './modules/bwa.nf'
include {polypolish} from './modules/polypolish.nf'
include {polca} from './modules/polca.nf'


workflow {

    if (params.assemblyType == 'illumina') {
    // Check if only Illumina reads directory is provided
    if (params.qcreads_illumina == null || params.qcreads_illumina.isEmpty()) {
        error "Please provide the input directory using --qcreads_illumina for Illumina reads."
    }

	} else if (params.assemblyType == 'ont') {
    // Check if only ONT reads directory is provided
    if (params.qcreads_ont == null || params.qcreads_ont.isEmpty()) {
        error "Please provide the input directory using --qcreads_ont for ONT reads."
    }

	} else if (params.assemblyType == 'hybrid') {
    // Check if both Illumina and ONT reads directories are provided
    if ((params.qcreads_illumina == null || params.qcreads_illumina.isEmpty()) || (params.qcreads_ont == null || params.qcreads_ont.isEmpty())) {
        error "Please provide both input directories using --qcreads_illumina for Illumina reads and --qcreads_ont for ONT reads for 'hybrid' assembly."
    }

	} else {
    error "Invalid --assemblyType provided: ${params.assemblyType}"
	}

    if (params.assemblyType == 'illumina') {
        Channel
			.fromFilePairs("${params.qcreads_illumina}/*_{1,2}.{fastq,fq}{,.gz}", flat:true)
            .ifEmpty {
                error "Cannot find any Illumina reads matching: ${params.qcreads_illumina}"
            }
            .set {illumina_reads}
	
	main:
	
        unicycler_illumina(illumina_reads)
        quast(unicycler_illumina.out.assembly.collect(), params.ref_genome)
		compile(unicycler_illumina.out.assembly)

    } else if (params.assemblyType == 'ont') {
        Channel
			.fromPath("${params.qcreads_ont}/*.{fastq,fq}{,.gz}")
			.map {file -> tuple(file.simpleName, file)}	
			.set{ont_reads}

        unicycler_ont(ont_reads)
		quast(unicycler_ont.out.assembly.collect(), params.ref_genome)
		compile(unicycler_ont.out.assembly)

    } else if (params.assemblyType == 'srf-hybrid') {
		Channel
			.fromFilePairs("${params.qcreads_illumina}/*_{1,2}.{fastq,fq}{,.gz}", flat:true)
			.set{illumina_reads}
		
		Channel
			.fromPath("${params.qcreads_ont}/*.{fastq,fq}{,.gz}")
			.map {file -> tuple(file.simpleName, file)}	
			.set{ont_reads}
		
		unicycler_hybrid(illumina_reads.join(ont_reads))
		quast(unicycler_hybrid.out.assembly.collect(), params.ref_genome)
		compile(unicycler_hybrid.out.assembly)
	
    } else if (params.assemblyType == 'lrf-hybrid') {
        Channel
			.fromFilePairs("${params.qcreads_illumina}/*_{1,2}.{fastq,fq}{,.gz}", flat:true)
			.set{illumina_reads}
		
		Channel
			.fromPath("${params.qcreads_ont}/*.{fastq,fq}{,.gz}")
			.map {file -> tuple(file.simpleName, file)}	
			.set{ont_reads}

        flye(illumina_reads.join(ont_reads))
		quast(unicycler_hybrid.out.assembly.collect(), params.ref_genome)
		compile(unicycler_hybrid.out.assembly)
        

	} else {
        error "Invalid --assemblyType provided: ${params.assemblyType}"
    }
}

// hybrid: nextflow run assembly.nf --assemblyType hybrid --qcreads_illumina /path/to/illumina_reads --qcreads_ont /path/to/ont_reads
// illumina: nextflow run assembly.nf --assemblyType illumina --qcreads_illumina /path/to/illumina_reads
// ont: nextflow run assembly.nf --assemblyType ont --qcreads_ont /path/to/ont_reads