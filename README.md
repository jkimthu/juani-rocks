# juani-rocks
Most def she does!

last edit: Jen, 2022 Jan 19
commit: for image analysis of juani's phase + gfp experiments


Repository contents:

1. gfp_phase_analysis.m
/ takes image data (.tiff) and applies image processing to recognize cells and extract property data. cells are linked through time via a particle tracking step, and then the linked data is assembled and saved in a data structure, D. To limit errors, there is a quality control step (well, actually 4) that produces the final data structure, D5, from which further analyses can be performed.

/ this script (#1) uses the following functions from this repository:

2.		i. ParticleTrim_gfp.m
3.	   ii. Particle_Track_gfp.m

 

4. buildDM_gfp.m
/ takes the output data structure, D5, from gfp_phase_analysis.m and creates a matrix for easier plotting. Similar format to buildDM.m, but includes a data column for average GFP intensity of each bacterial cell / particle.

