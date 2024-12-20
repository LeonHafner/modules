process EIDO_CONVERT {
    tag "$samplesheet"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/74/74fe7c4f58b338909dae8ed74840d8f8fbab5ff40ec631f5705c8c7adfafdb6f/data' :
        'community.wave.seqera.io/library/eido_peppy:28c1b18c35613800' }"

    input:
    path samplesheet
    val format
    path pep_input_base_dir

    output:
    path "versions.yml"           , emit: versions
    path "${prefix}.${format}"    , emit: samplesheet_converted

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "samplesheet_converted"
    """
    eido \\
        convert \\
        -f $format \\
        $samplesheet \\
        $args \\
        -p samples=${prefix}.${format}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        eido: \$(echo \$(eido --version 2>&1) | sed 's/^.*eido //;s/ .*//' )
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "samplesheet_converted"
    """
    touch ${prefix}.${format}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        eido: \$(echo \$(eido --version 2>&1) | sed 's/^.*eido //;s/ .*//' )
    END_VERSIONS
    """
}
