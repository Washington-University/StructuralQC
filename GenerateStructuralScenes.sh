#!/bin/bash

## Generating Workbench Scenes for Structural Quality Control
##
## Authors: Michael Harms and Donna Dierker

set -x

## Edit the following four variables
SubjList="176239 199958 415837 433839 943862 987983"

OutputFolder="/location/of/my/QC/output/directory"
StudyFolder="/location/of/subject/data/directories"
TemplateFolder="/location/of/unpacked/StructuralQC/templates"

# The following only needs modification if you have modified the
# provided TEMPLATE_structuralQC.scene file
DummyPath="DUMMYPATH" #This is an actual string in the TEMPLATE_structuralQC.scene file.

### From here onward should not need any modification
### --------- ###

mkdir -p $OutputFolder
cp -r $TemplateFolder/. $OutputFolder

# Replace both the path and the subject ID in the template scenes to generate
# a scene file appropriate for each subject
for Subject in $SubjList; do

  sed "s#$DummyPath#$StudyFolder#g" $OutputFolder/TEMPLATE_structuralQC.scene | sed "s#100307#$Subject#g" > $OutputFolder/"$Subject".structuralQC.wb.scene

done

