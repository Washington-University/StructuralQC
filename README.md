## Description

Generating Workbench Scenes for Structural Quality Control

Authors: Michael Harms and Donna Dierker

## Use

1. Download the `StructuralQC-x.y.z.zip` archive from GitHub:

    * Visit: https://github.com/Washington-University/StructuralQC/releases
    * Under `Downloads` choose the `Source code (zip)` link for the latest release
    * The resulting `.zip` file will be named `StructuralQC-x.y.z` where `x.y.z` reflects the version number.

2. Unzip the archive in a directory where you have read and write permission.

    * The resulting subdirectory will be named `StructuralQC-x.y.z` (e.g., StructuralQC-1.2.0)
    * The StructuralQC-x.y.z directory will contain:
        * a single script -- `GenerateStructuralScenes.sh` and
        * a `templates` directory that contains files that are needed to render the scenes.
    * You will probably invoke the script multiple times (i.e., for different batches of subjects).

3. Use a text editor to edit the following variables in the `GenerateStructuralScenes.sh` script:

    ~~~~
    SubjList="SubjID1 SubjID2 SubjID3"
    TemplatesFolder="/location/of/unpacked/StructuralQC/templates"
    StudyFolder="/location/of/subject/data/directories"
    OutputSceneFolder=SEE_BELOW
	CopyTemplates=TRUE or FALSE

    ~~~~

    * `SubjList` is a space delimited list of subject ID's to be processed.
    * `TemplatesFolder` is the location of the `templates` subdirectory in your 
      `StructuralQC-x.y.z` folder on your system.
    * `StudyFolder` is the directory containing the subject data (organized in
      standard ConnectomeDB file structure).
    * `OutputSceneFolder` controls where the per-subject scenes (and a small number of
	  other created files) get saved. 
	  	* If set to the empty string (`""`), the files for each subject will go into their `$StudyFolder/$Subject/MNINonLinear/StructuralQC` directory.  Obviously, this requires that you have write permission into the
	  `$StudyFolder` tree!
	    * Otherwise, it specifies the "common" directory where the scene files go for all subjects.
	* `CopyTemplates`
		* If TRUE, the script will copy reference files (S1200* and mean MNI152 T1 atlas target) to `OutputSceneFolder` (per the interpretation provided above), and use the copies at that location in the scene.
		* If FALSE, the script determines the relative path to `$TemplatesFolder`, and uses that for creating the scene.

4. Enter this command at a terminal window:

    ~~~~
    bash GenerateStructuralScenes.sh
    ~~~~

5. Confirm the scenes were generated in `OutputSceneFolder`.

6. View the scene file using wb_view:

    ~~~~
    wb_view "$Subject".structuralQC.wb.scene
    ~~~~

    Note that each scene file actually contains multiple scenes available for showing in `wb_view`.
