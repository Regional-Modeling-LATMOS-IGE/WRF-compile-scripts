#!/bin/bash
#SBATCH --job-name=CompileWRFChem           # nom du job
#SBATCH --partition=zen16                   # Nom d'une partition pour une exÃ©tion cpu
#SBATCH --ntasks=1                          # nombre de taches
#SBATCH --ntasks-per-node=1                 # nombre de taches MPI par noeud
#SBATCH --mem=10GB                          # memory limit
#SBATCH --time=04:00:00                     # temps d execution maximum demande (HH:MM:SS)
#SBATCH --output=CompileWRFChem%j.out       # nom du fichier de sortie
#SBATCH --error=CompileWRFChem%j.out        # nom du fichier d'erreur (ici en commun avec la sortie)

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
export WRF_CHEM=1
export WRF_KPP=1
export YACC="/usr/bin/byacc -d"
export FLEX_LIB_DIR=/usr/lib/x86_64-linux-gnu/
export HDF5_DISABLE_VERSION_CHECK=1
export WRFIO_NCD_NO_LARGE_FILE_SUPPORT=0
export WRFIO_NCD_LARGE_FILE_SUPPORT=1

cd $WRFDIR/chem/KPP/kpp/kpp-2.1/src/
/usr/bin/flex scan.l

sed -i '
1 i \
#define INITIAL 0 \
#define CMD_STATE 1 \
#define INC_STATE 2 \
#define MOD_STATE 3 \
#define INT_STATE 4 \
#define PRM_STATE 5 \
#define DSP_STATE 6 \
#define SSP_STATE 7 \
#define INI_STATE 8 \
#define EQN_STATE 9 \
#define EQNTAG_STATE 10 \
#define RATE_STATE 11 \
#define LMP_STATE 12 \
#define CR_IGNORE 13 \
#define SC_IGNORE 14 \
#define ATM_STATE 15 \
#define LKT_STATE 16 \
#define INL_STATE 17 \
#define MNI_STATE 18 \
#define TPT_STATE 19 \
#define USE_STATE 20 \
#define COMMENT 21 \
#define COMMENT2 22 \
#define EQN_ID 23 \
#define INL_CODE 24
' $WRFDIR/chem/KPP/kpp/kpp-2.1/src/lex.yy.c

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

