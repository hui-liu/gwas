# Input:   SOURCE_FILE - relative path to BED/BIM/FAM  e.g. ../../CKID_Cleaned/whites_ckid/whites_ckid
#          OUTPUT_DIR  - file to place results, intermediates and logs
#          PREFIX      - file name prefix              e.g. whites_ckid
# Output:  ${PREFIX}.evec and ${PREFIX}.pdf files

SOURCE_FILE=$1
OUTPUT_DIR=$2
PREFIX=$3

SCRIPT_DIR=${0%/*}

if [ ! -f "${SOURCE_FILE}.bed" ]
then
	echo "BED does not exist: ${SOURCE_FILE}.bed"
	exit
fi

echo "Input: ${SOURCE_FILE}"
echo "Output to: ${OUTPUT_DIR}"
echo "Prefix: ${PREFIX}"
mkdir -p ${OUTPUT_DIR}

. ${SCRIPT_DIR}/01-exclude-high-LD-snps.sh 
. ${SCRIPT_DIR}/02-save-ped.sh 
. ${SCRIPT_DIR}/03-convertf.sh 
. ${SCRIPT_DIR}/04-smartpca.sh

export OUTPUT_DIR
export PREFIX
Rscript ${SCRIPT_DIR}/05-plot-pca-results.R