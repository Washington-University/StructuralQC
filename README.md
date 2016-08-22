# /home/HCPpipeline/pipeline_tools directory

## Description

This directory contains installations of tools to be used by XNAT pipelines 
running on the CHPC cluster for/in the HCPpipeline account.  These directories
are referenced by the set up files that are invoked to set up the environment
used by XNAT pipeline runs. In particular, there are directories here for 
various versions of the HCP Pipeline Scripts that are to be used by XNAT 
pipelines for different projects: e.g. HCP Phase 2 mainline 3T, 7T, different
LifeSpan projects, etc.

## Subdirectories

* fix1.06

  - ICA FIX scripts

* gradunwarp-1.0.2

  - HCP modified version of the gradient unwarping Python code

* msm

* Pipelines

  - Version of the HCP Pipeline Scripts to be used by the mainline (S500, S900, 
	etc.) releases of HCP data
  - Note that this is intended to be maintained as a symbolic link to a directory
	containing the actual HCP Pipeline Scripts version (e.g. 3.3, 3.4, etc.)

* Pipelines-3.4.0, Pipelines-3.4.1RCd, Pipelines-3.6.0RCb, etc.

  - Specific versions (as indicated in the name) of the HCP Pipeline Scripts 
  - Generally these would be symbolically linked to be project specific 
	directory names

* Pipelines_7T

  - Version of the HCP Pipeline Scripts to be used for 7T releases of data
  - Note that this is intended to be maintained as a symbolic link to a directory
	containing the actual HCP Pipeline Scripts version (e.g. 3.3, 3.4, etc.)

* Pipelines_MSM_All

  - Version of the HCP Pipeline Scripts to be used for the MSM-All processing
    of the mainline HCP data
  - Should be a symbolic link

* Pipelines_UMINN_Prisma_3T 

  - Version of the HCP Pipeline Scripts used for Prisma 3T data from the 
	University of Minnesota
  - Should be a symbolic link

* Pipelines_WU_L1A, Pipelines_WU_L1B

  - Versions of the HCP Pipeline Scripts use for LifeSpan 1A and 1B processing.
  - Symbolic links

* workbench-v1.0

  - Installation of Connectome Workbench
# StructuralQC
