task multiqc_task {
        Array[File] fastqcArray
        Int MQC_threads
        Int MQC_minutes
        Int MQC_mem
        String outputPrefix

        command {
                for file in ${sep=' ' fastqcArray}; do
                        cp $file .
                done

                multiqc -n ${outputPrefix}.mqc_report.html .
        }
        runtime {
                runtime_minutes: '${MQC_minutes}'
                cpus: '${MQC_threads}'
                mem: '${MQC_mem}'
        }
        output {
                File multiqcHTML = "${outputPrefix}.mqc_report.html"
        }

    meta {
        author: "Bobbie Shaban"
        email: "bshaban@unimelb.edu.au"
        description: "<DESCRIPTION>"
    }
    parameter_meta {
        # Inputs:
        Input1: "itype:<TYPE>: <DESCRIPTION>"
        # Outputs:
        Output1: "otype:<TYPE>: <DESCRIPTION>"
    }
}

