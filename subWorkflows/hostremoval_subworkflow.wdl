import "./tasks/interleave.wdl" as interleaveTask
import "./tasks/hostremoval.wdl" as hostremovalTask

workflow hostremoval_subworkflow {
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

  File? hostRemovalFlash
  File? hostRemovalFwd
  File? hostRemovalRev
  Boolean flashBoolean
  File interleaveShell
  Int identityPercentage
  Int coverage
  String outputPrefix
  String removalSequence
  String sampleName

  call interleaveTask.interleave_task {
    input: 
    flashBoolean = flashBoolean,
    outputPrefix = outputPrefix,
    interleaveShell = interleaveShell,
    hostRemovalFlash = hostRemovalFlash,
    hostRemovalFwd = hostRemovalFwd,
    hostRemovalRev = hostRemovalRev
  }

  call hostremovalTask.hostremoval_task {
    input: 
    removalSequence = removalSequence,
    outputPrefix = outputPrefix,
    interleavedSequence = interleave_task.interLeavedFile,
    sampleName=sampleName,
    coverage=coverage,
    identityPercentage=identityPercentage
  }

  output {
    File hostRemovedFwdReads = hostremoval_task.hostRemovedFwdReads
    File hostRemovedRevReads = hostremoval_task.hostRemovedRevReads
  }
}