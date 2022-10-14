#!/bin/bash
#
#-------- Compile exo_coldens and wesely  --------
#
# Louis Marelle, 2022/10/04
#

# Load modules used for WRF compilation
module purge
module load gcc/11.2.0
module load openmpi/4.0.7 
module load netcdf-c/4.7.4
module load netcdf-fortran/4.5.3
module load hdf5/1.10.7
module load jasper

# Export compiler and NetCDF environment variables
export FC=gfortran
export NETCDF_DIR=/home/marelle/tools/NETCDF_DIR_GFORTRAN/

# Clean up and compile
rm -f *.o *.mod exo_coldens wesely
make clean
./make_util wesely
./make_util exo_coldens

