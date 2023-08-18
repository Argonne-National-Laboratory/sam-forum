## PB-FHR Reference Plant BlueCRAB Model
# Authors: Gang Yang, Javier Ortensi, Travis Mui
# August 2023

Verified working version of BlueCRAB: git commit 49f6360 on 2023-08-13

# This directory contains the following input files:

- `pb-fhr_griffin_ss.i` : Griffin steady state (SS) input file
- `pb-fhr_griffin_ulof.i` : Griffin unprotected loss-of-flow (ULOF) input file (restart from SS)
- `PB-FHR-RCCS.i` : SAM steady state (SS) input file
- `PB-FHR-RCCS-ULOF.i` : SAM unprotected loss-of-flow (ULOF) input file (restart from SS)
- `gFHR_pebble_triso_ss.i` : Pebble heat conduction sub-app input file

# The following support files are also included:

- `PB-FHR-neutronics.e` : Exodus mesh file for the Griffin neutronics core model
- `PB-FHR-2d_mesh_in.e` : Exodus mesh file for the SAM thermal hydraulics 2D core model
- `gFHR_4g_pebble.xml` : Neutronics cross-sections for the PB-FHR core
- `DRAGON5_DT.xml` : Neutronics cross-sections for depletion calculations
- `pebble_heat_pos.txt` : Table of spatial positions for the pebble heat conduction sub-apps
- `water_eos_P101325_1000.csv` : Water fluid properties at 101.325 kPa for the SAM RCCS model
- `ss.pbs` : PBS batch submission script to run the SS portion of the model
- `ulof.pbs` : PBS batch submission script to run the ULOF portion of the model

# Execution instructions:

The PB-FHR model is setup as a MultiApp problem with Griffin as the primary application and SAM and pebble heat conduction as sub-apps. When executing this model, the Griffin input file should be specified.

1. Run the steady state. On 48 cpus / 1 node on INL HPC Sawtooth, this requires ~1 hour of runtime.

`mpiexec -np 48 blue_crab-opt -i pb-fhr_griffin_ss.i`
OR
`qsub ss.pbs`

2. Run the coupled ULOF transient (first 1000 seconds), restarting from the steady state solution. On 48 cpus / 1 node on INL HPC Sawtooth, this requires ~3 hours of runtime.

`mpiexec -np 48 blue_crab-opt -i pb-fhr_griffin_ulof.i`
OR
`qsub ulof.pbs`
