#!/bin/bash
#SBATCH --job-name=CompileWRF               # nom du job
#SBATCH --partition=zen16                   # Nom d'une partition pour une exÃ©tion cpu
#SBATCH --ntasks=1                          # nombre de taches
#SBATCH --ntasks-per-node=1                 # nombre de taches MPI par noeud
#SBATCH --mem=10GB                          # memory limit
#SBATCH --time=04:00:00                     # temps d execution maximum demande (HH:MM:SS)
#SBATCH --output=CompileWRF%j.out       # nom du fichier de sortie
#SBATCH --error=CompileWRF%j.out        # nom du fichier d'erreur (ici en commun avec la sortie)

export LANG=en_US.utf8
export LC_ALL=en_US.utf8
echo $PWD

export WRFDIR=$PWD

rm -rf prepare_for_run_gfortran
cat > prepare_for_run_gfortran << EOF
module purge
module load gcc/11.2.0
module load openmpi/4.0.7
module load netcdf-c/4.7.4
module load netcdf-fortran/4.5.3
module load hdf5/1.10.7
module load jasper
export CFLAGS="-I\${OPENMPI_ROOT}/include -m64"
export LDFLAGS="-L\${OPENMPI_ROOT}/lib -lmpi"
export NETCDF=/home/marelle/tools/NETCDF_DIR_GFORTRAN/
export PHDF5=\${HDF5_ROOT}
export HDF5=\${HDF5_ROOT}

export MPI_LIB=-L\${OPENMPI_ROOT}/lib
EOF

cd $WRFDIR
source prepare_for_run_gfortran
echo $MPI_LIB
export TOOLDIR=/home/onishi/tools_spirit
export PATH=$TOOLDIR/bin:$PATH
export PATH=$TOOLDIR/lib:$PATH
export JASPERLIB=$JASPER_ROOT/lib
export JASPERINC=$JASPER_ROOT/include
export HDF5_PATH=$HDF5
## default setting ##
export EM_CORE=1
export NMM_CORE=0
## end of default setting ##
export WRF_CHEM=0
export WRF_KPP=0
export YACC="/usr/bin/byacc -d"
export FLEX_LIB_DIR=/usr/lib/x86_64-linux-gnu/
export HDF5_DISABLE_VERSION_CHECK=1
export WRFIO_NCD_NO_LARGE_FILE_SUPPORT=0
export WRFIO_NCD_LARGE_FILE_SUPPORT=1

cd $WRFDIR

./clean -a
./clean -aa

sed -i '/^[[:blank:]]*image.inmem_=1/c\\/\*      image.inmem_=1;   \*\/' $WRFDIR/external/io_grib2/g2lib/enc_jpeg2000.c
sed -i '/I_really_want_to_output_grib2_from_WRF/s/FALSE/TRUE/g' $WRFDIR/arch/Config.pl

# Select option 34, gfortran with dmpar
./configure <<EOF
34

EOF

rm -rf prepare_for_run_gfortran

sed -ie 's/hdf5hl_fortran/hdf5_hl_fortran/' ./configure.wrf

ulimit -s unlimited
./compile em_real 2>&1 |tee compile.log

