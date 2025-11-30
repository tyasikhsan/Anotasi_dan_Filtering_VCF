#!/bin/bash
# ==========================================================
# Filter Cleansig
# Keeps: CHROM, POS, REF, ALT, INFO/CLNSIG, INFO/CLNDN, INFO/ANN
# ==========================================================

# --- USER SETTINGS ---
INPUT_DIR="/home/jovyan/analysis/wgs/snpEff"   # Folder with VCF files
OUTPUT_DIR="${INPUT_DIR}/BATCH3_tsv_output"            # Output folder for TSVs
LOGFILE="batch3_converting_vcf_tsv_$(date +%Y%m%d_%H%M).log"

# Create output directory if missing
mkdir -p "$OUTPUT_DIR"

# Move into input directory
cd "$INPUT_DIR" || exit
echo "[$(date)] Starting Converting VCF file: $PWD" | tee -a "$LOGFILE"

# --- Loop through all vcf.gz files ---
for VCF in annotated_with_clinvar*.vcf.gz; do
  if [ ! -f "$VCF" ]; then
    echo "[$(date)] ❌ No .vcf.gz files found in $INPUT_DIR" | tee -a "$LOGFILE"
    exit 1
  fi

  SAMPLE=$(basename "$VCF" .vcf.gz)
  TSV="${OUTPUT_DIR}/${SAMPLE}.tsv"

  echo "---------------------------------------------" | tee -a "$LOGFILE"
  echo "[$(date)] creating $TSV" | tee -a "$LOGFILE"

  # --- Extract fields with bcftools ---
  if bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/GENEINFO\t%INFO/CLNSIG\t%INFO/CLNDN\n' "$VCF" > "$TSV" 2>>"$LOGFILE"; then
    echo "[$(date)] ✅ Successfully converted: $TSV" | tee -a "$LOGFILE"
  else
    echo "[$(date)] ❌ Conversion failed for: $VCF" | tee -a "$LOGFILE"
  fi
  #Adding header for Column Name
  sed -i '1i Chromosome\tPosition\tRef_Allele\tAlt_Allele\tGene_Info\tClinical_Significance\tCLNDN' "$TSV"
done

echo "=============================================" | tee -a "$LOGFILE"
echo "[$(date)] 🎉 All .vcf.gz files converted to TSV!" | tee -a "$LOGFILE"
echo "Output folder: $OUTPUT_DIR"
