#!/bin/bash
#
#-------- Compile megan_bio_emiss with gfortran --------
#
# Louis Marelle, 2022/10/04
#

rm -f *.o *.mod megan_bio_emiss

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
export NETCDF=/home/marelle/tools/NETCDF_DIR_GFORTRAN/
export NETCDF_DIR=/home/marelle/tools/NETCDF_DIR_GFORTRAN/

# Write compiler and NetCDF library to stdout
echo " "
echo "Using $FC fortan90 compiler"
echo "============================================================================="
echo "netcdf top level directory NETCDF_DIR = ${NETCDF_DIR}"
echo "netcdf top level directory NETCDF = ${NETCDF}"
echo "============================================================================="

# Clean up and compile
make clean >& /dev/null
make megan_bio_emiss AR_LIBS="-lnetcdf -lnetcdff"
make cleanup >& /dev/null
# echo "++++++++++++++++++++"
# echo "megan_bio_emiss built OK"
# echo "++++++++++++++++++++"
