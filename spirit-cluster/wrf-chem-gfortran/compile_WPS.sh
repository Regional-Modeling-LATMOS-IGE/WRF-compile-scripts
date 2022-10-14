#!/bin/bash
#-------- Set everything for WPS compilation --------

# To use: 
# source this_script.sh
# Select gfortran compiler (dmpar) (3)

# Then to compile WPS: 
# nohup ./compile 2>&1 > compile.log &
# or:
# ./compile 2>&1 | tee compile.log

# Load the modules needed for WPS compilation
module purge
module load gcc/11.2.0
module load openmpi/4.0.7
module load netcdf-c/4.7.4
module load netcdf-fortran/4.5.3
module load hdf5/1.10.7
module load jasper
export CFLAGS="-I${OPENMPI_ROOT}/include -m64"
export LDFLAGS="-L${OPENMPI_ROOT}/lib -lmpi"
export NETCDF=/home/marelle/tools/NETCDF_DIR_GFORTRAN/
export PHDF5=${HDF5_ROOT}
export HDF5=${HDF5_ROOT}
export MPI_LIB=-L${OPENMPI_ROOT}/lib
export TOOLDIR=/home/onishi/tools_spirit
export PATH=$TOOLDIR/bin:$PATH
export PATH=$TOOLDIR/lib:$PATH
export JASPERLIB=$JASPER_ROOT/lib
export JASPERINC=$JASPER_ROOT/include

# Set the environment variables needed for WPS compilation
export HDF5_DISABLE_VERSION_CHECK=1
export WRFIO_NCD_NO_LARGE_FILE_SUPPORT=0
export WRFIO_NCD_LARGE_FILE_SUPPORT=1

./clean -a
./clean -aa

# Configure WPS - Pick 3.  Linux x86_64, gfortran    (dmpar)
export WRF_DIR=~/WRF/src/WRF-Chem-Polar/WRFV4
./configure

echo "SET PATHS DONE"
echo "Do not forget to update the path to WRF, WRF_DIR, in configure.wps"

# Try to do this automatically
sed -i "s:.*\(WRF_DIR.*=[ \t]\+\).*\.\.\/WRFV3:\1$WRF_DIR:" configure.wps

# nohup ./compile 2>&1 > compile.log &
./compile 2>&1 | tee compile.log
