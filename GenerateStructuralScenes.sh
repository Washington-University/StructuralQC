#!/bin/bash

## Generating Workbench Scenes for Structural Quality Control
##
## Authors: Michael Harms and Donna Dierker
##
## ----------------------------------------------------------

## EDIT the following variables ##

#set -x  # If you want a verbose listing of all the commands, uncomment this line

SubjList="SubjID1 SubjID2 SubjID3"  # SPACE separated list of subject IDs

# All 3 of the following folder locations can be specified with either an 
# absolute path or a path *relative to this script*, without consequence.
TemplatesFolder="/location/of/unpacked/StructuralQC/templates"
StudyFolder="/location/of/subject/data/directories"

# OutputSceneFolder: If left as the empty ("") string, the scene file for 
# each subject (and a small number of other created files) 
# will go into $StudyFolder/$Subject/MNINonLinear/StructuralQC.
#    Obviously, that is only an option if you have write-permission into 
#    the $StudyFolder tree!
# Otherwise, it specifies the "common" directory where the scene files go
# for all subjects
OutputSceneFolder=""  # EMPTY string has special interpretation -- see above!
#OutputSceneFolder="/location/of/common/output/directory/for/all/subjects"

# Some of the scenes display files in $TemplatesFolder (specifically, the MNI152 
# volume template and group myelin maps from the S1200 release of HCP-YA).
# The following variable controls whether those files get copied from $TemplatesFolder
# to $OutputSceneFolder (use 'TRUE') or not (use 'FALSE', in which case the script determines
# the relative path to the $TemplatesFolder, and uses that in creating the scene).
# N.B. If you use 'TRUE', and $OutputSceneFolder is empty (""), then you'll be creating a
# copy of the template files for each individual subject.
CopyTemplates=FALSE


### --------------------------------------------- ###
### From here onward should not need any modification

verbose=0

# Convert TemplatesFolder and StudyFolder to absolute paths (for convenience in reporting locations).
# Do NOT do the same here with OutputSceneFolder, for which the empty string has special meaning!
TemplatesFolder=$(cd $TemplatesFolder; pwd)
StudyFolder=$(cd $StudyFolder; pwd)

# ----------------------------
# Function to copy just the specific files in 'templates' that are needed
# ----------------------------
function copyTemplateFiles {
	local templateDir=$1
	local targetDir=$2

	if (( verbose )); then
		echo "Copying template files to $targetDir"
	fi
	cp $templateDir/S1200.{MyelinMap,sulc}* $targetDir/.
	cp $templateDir/MNI152_T1_0.8mm.nii.gz $targetDir/.
}

# ----------------------------
# Function to determine relative paths
# ----------------------------

# We want to use relative paths in the scene file, so that it is robust
# against changes in the base directory path.  As long as the relative
# paths between $OutputSceneFolder, $TemplatesFolder, and $StudyFolder are
# preserved, the scene should still work, even if the base directory changes
# (i.e., if the files are moved, or accessed via a different mount point).

# To determine the relative paths, 'realpath --relative-to' is not a robust
# solution, as 'realpath' is not present by default on MacOS, and the 
# '--relative-to' option is not supported on older Ubuntu versions.
# So, use the following perl one-liner instead, 
# from https://stackoverflow.com/a/17110582

function relativePath {
  # both $1 and $2 are absolute paths beginning with /
  # returns relative path from $1 to $2
  local source=$(cd $1; pwd)
  local target=$(cd $2; pwd)
  local relPath=""

  relPath=$(perl -e 'use File::Spec; print File::Spec->abs2rel(@ARGV) . "\n"' $target $source)
  echo $relPath
}

# ----------------------------
# Define variables containing the "dummy strings" used in the template scene
# ----------------------------

# The following are matched to actual strings in the TEMPLATE_structuralQC.scene file
StudyFolderDummyStr="StudyFolder"
SubjectIDDummyStr="SubjectID"
TemplatesFolderDummyStr="TemplatesFolder"

# ----------------------------
# Parameter checks
# ----------------------------

if ! [[ "$CopyTemplates" =~ ^(TRUE|FALSE)$ ]]; then
	echo "ERROR: Invalid entry for CopyTemplates parameter"
	exit 1
fi

# ----------------------------
# Begin main action of script
# ----------------------------

scriptDir=$(pwd)

# If $OutputSceneFolder is not empty, then we are using a common $OutputSceneFolder for all subjects,
# in which case it is more efficient to do the following operations once, rather than repeatedly
# within the Subject loop
if [ -n "$OutputSceneFolder" ]; then
	OutputSceneFolderSubj=$OutputSceneFolder
	mkdir -p $OutputSceneFolderSubj
	relPathToStudy=$(relativePath $OutputSceneFolderSubj $StudyFolder)
	if [ "$CopyTemplates" = "TRUE" ]; then
		copyTemplateFiles $TemplatesFolder $OutputSceneFolderSubj
		relPathToTemplates="."
	else
		relPathToTemplates=$(relativePath $OutputSceneFolderSubj $TemplatesFolder)
	fi
	if (( verbose )) ; then
		echo "TemplatesFolder: $TemplatesFolder"
		echo "StudyFolder: $StudyFolder"
		echo "OutputSceneFolder: $(cd $OutputSceneFolderSubj; pwd)"
		echo "... relative path to template files (from OutputSceneFolder): $relPathToTemplates"
		echo "... relative path to StudyFolder (from OutputSceneFolder): $relPathToStudy"
	fi
fi

# Loop over subjects
for Subject in $SubjList; do
	
  echo "Subject: $Subject"

  # If $OutputSceneFolder is empty, then we use $StudyFolder/$Subject/MNINonLinear/StructuralQC
  # as the output folder for each individual subject
  if [ -z "$OutputSceneFolder" ]; then
	OutputSceneFolderSubj=$StudyFolder/$Subject/MNINonLinear/StructuralQC
	mkdir -p $OutputSceneFolderSubj
	# Note: the TEMPLATE scene file is designed with "StudyFolder" as the "base" of its paths,
	# so want to still compute the relative path to $StudyFolder (rather than say $StudyFolder/$Subject/MNINonLinear)
	relPathToStudy=$(relativePath $OutputSceneFolderSubj $StudyFolder)
	if [ "$CopyTemplates" = "TRUE" ]; then
		copyTemplateFiles $TemplatesFolder $OutputSceneFolderSubj
		relPathToTemplates="."
	else
		relPathToTemplates=$(relativePath $OutputSceneFolderSubj $TemplatesFolder)
	fi
	if (( verbose )) ; then
		echo "... TemplatesFolder: $TemplatesFolder"
		echo "... StudyFolder: $StudyFolder"
		echo "... OutputSceneFolder: $(cd $OutputSceneFolderSubj; pwd)"
		echo "...... relative path to template files (from OutputSceneFolder): $relPathToTemplates"
		echo "...... relative path to StudyFolder (from OutputSceneFolder): $relPathToStudy"
	fi
  fi

  # Replace dummy strings in the template scenes to generate
  # a scene file appropriate for each subject
  SubjectSceneFile=$OutputSceneFolderSubj/"$Subject".structuralQC.wb.scene
  sed -e "s|${StudyFolderDummyStr}|${relPathToStudy}|g" \
	  -e "s|${SubjectIDDummyStr}|${Subject}|g" \
	  -e "s|${TemplatesFolderDummyStr}|${relPathToTemplates}|g" \
	  $TemplatesFolder/TEMPLATE_structuralQC.scene > $SubjectSceneFile

  # Define some convenience variables
  AtlasSpaceFolder=$StudyFolder/$Subject/MNINonLinear
  mesh="164k_fs_LR"

  # If StrainJ maps don't exist for the various registrations, 
  # but ArealDistortion maps do, use those instead
  for regName in FS MSMSulc MSMAll; do
	if [[ ! -e $AtlasSpaceFolder/$Subject.StrainJ_$regName.$mesh.dscalar.nii && -e $AtlasSpaceFolder/$Subject.ArealDistortion_$regName.$mesh.dscalar.nii ]]; then
	  echo "... using ArealDistortion_${regName} map in place of StrainJ_${regName}"
	  # Following version of sed "in-place" replacement should work on both Linux and MacOS
	  sed -i.bak "s|StrainJ_${regName}|ArealDistortion_${regName}|g" $SubjectSceneFile
	  rm $SubjectSceneFile.bak
	fi
  done

  ## Create a surface-mapped version of the FNIRT volume distortion (for easy visualization).
  ## We could use wb_command -volume-distortion on MNINonLinear/xfms/acpc_dc2standard.nii.gz, 
  ## but its "isotropic" distortion (1st volume) is basically the same as the -jout (Jacobian) 
  ## output of fnirt (highly correlated, but there is a small bias between the two, perhaps
  ## because the fnirt jacobian doesn't include the affine component)?
  ## So, since the fnirt jacobian is already part of the HCPpipelines output, we'll
  ## use that for convenience

  AtlasSpaceFolder=$StudyFolder/$Subject/MNINonLinear

  # volumeDistortion=$OutputSceneFolderSubj/$Subject.voldistort.nii.gz
  # wb_command -volume-distortion $AtlasSpaceFolder/xfms/acpc_dc2standard.nii.gz \
  # 	  $volumeDistortion -fnirt $AtlasSpaceFolder/xfms/standard2acpc_dc.nii.gz
  # wb_command -volume-math "ln(x)/ln(2)" $volumeDistortion -var x $volumeDistortion

  # # Reverse the order
  # volumeDistortion=$OutputSceneFolderSubj/$Subject.voldistortRev.nii.gz
  # wb_command -volume-distortion $AtlasSpaceFolder/xfms/standard2acpc_dc.nii.gz \
  # 	  $volumeDistortion -fnirt $AtlasSpaceFolder/xfms/acpc_dc2standard.nii.gz
  # wb_command -volume-math "ln(x)/ln(2)" $volumeDistortion -var x $volumeDistortion

  # Convert FNIRT's Jacobian to log base 2
  jacobian=$AtlasSpaceFolder/xfms/NonlinearRegJacobians.nii.gz
  jacobianLog2=$OutputSceneFolderSubj/$Subject.NonlinearRegJacobians_log2.nii.gz
  wb_command -volume-math "ln(x)/ln(2)" $jacobianLog2 -var x $jacobian

  # Set palette properties
  posMinMax="0 2"
  negMinMax="0 -2"
  paletteName="ROY-BIG-BL"
  thresholds="-1 1"
  wb_command -volume-palette $jacobianLog2 MODE_USER_SCALE \
	  -pos-user $posMinMax -neg-user $negMinMax -interpolate true -palette-name $paletteName \
	  -disp-pos true -disp-neg true -disp-zero false \
	  -thresholding THRESHOLD_TYPE_NORMAL THRESHOLD_TEST_SHOW_OUTSIDE $thresholds

  # Map to surface
  mapName=NonlinearRegJacobians_FNIRT
  for hemi in L R; do 
	  surf=$AtlasSpaceFolder/$Subject.$hemi.midthickness.$mesh.surf.gii
	  # Warpfields are smooth enough that trilinear interpolation is fine in -volume-to-surface-mapping
	  wb_command -volume-to-surface-mapping $jacobianLog2 $surf \
		  $OutputSceneFolderSubj/$Subject.$mapName.$hemi.$mesh.func.gii -trilinear
  done

  # Convert to dscalar and set palette properties
  # For convenience, switch into $OutputSceneFolderSubj for final operations
  cd $OutputSceneFolderSubj
  wb_command -cifti-create-dense-scalar $Subject.$mapName.$mesh.dscalar.nii \
	  -left-metric $Subject.$mapName.L.$mesh.func.gii \
	  -right-metric $Subject.$mapName.R.$mesh.func.gii
  wb_command -set-map-names $Subject.$mapName.$mesh.dscalar.nii -map 1 ${Subject}_$mapName
  wb_command -cifti-palette $Subject.$mapName.$mesh.dscalar.nii MODE_USER_SCALE \
	  $Subject.$mapName.$mesh.dscalar.nii \
	  -pos-user $posMinMax -neg-user $negMinMax -interpolate true -palette-name $paletteName \
	  -disp-pos true -disp-neg true -disp-zero false

  # Cleanup
  rm $Subject.$mapName.{L,R}.$mesh.func.gii

  cd $scriptDir

done  # Subject loop
