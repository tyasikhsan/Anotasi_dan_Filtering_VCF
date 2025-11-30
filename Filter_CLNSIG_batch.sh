#!/bin/bash
# ==========================================================
# Filter Cleansig
# Keeps: CHROM, POS, REF, ALT, INFO/CLNSIG, INFO/CLNDN, INFO/ANN
# ==========================================================

# --- USER SETTINGS ---
INPUT_DIR="/home/jovyan/analysis/wgs/snpEff/tsv_output"   # Folder with VCF files
OUTPUT_DIR="${INPUT_DIR}/filtered_output"            # Output folder for TSVs
LOGFILE="filter_CLNSIG_output_$(date +%Y%m%d_%H%M).log"

# Create output directory if missing
mkdir -p "$OUTPUT_DIR"

# Move into input directory
cd "$INPUT_DIR" || exit
echo "[$(date)] Starting Filtering TSV for clnsig column in: $PWD" | tee -a "$LOGFILE"

# --- Loop through all tsv files ---
for TSV in *.tsv; do
  if [ ! -f "$TSV" ]; then
    echo "[$(date)] ❌ No .tsv files found in $INPUT_DIR" | tee -a "$LOGFILE"
    exit 1
  fi

  SAMPLE=$(basename "$TSV" .tsv)
  FLT="${OUTPUT_DIR}/Filtered_${SAMPLE}.tsv"

  echo "---------------------------------------------" | tee -a "$LOGFILE"
  echo "[$(date)] Filtering $TSV" | tee -a "$LOGFILE"

  # --- Extract fields with bcftools ---
 # if bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/GENEINFO\t%INFO/CLNSIG\t%INFO/CLNDN\n' "$VCF" > "$TSV" 2>>"$LOGFILE"; then
 if grep -E -i "Pathogenic|Likely_pathogenic|Uncertain_significance" "$TSV" >> "$FLT" 2>>"$LOGFILE"; then
    echo "[$(date)] ✅ Successfully filtered: $TSV into $FLT" | tee -a "$LOGFILE"
    sed -i '1i #Chromosome\tPosition\tRef_Allele\tAlt_Allele\tGene_Info\tClinical_Significance\tCLNDN' "$FLT"
  else
    echo "[$(date)] ❌ Conversion failed for: $TSV" | tee -a "$LOGFILE"
  fi
done

echo "=============================================" | tee -a "$LOGFILE"
echo "[$(date)] 🎉 All tsv filtered!" | tee -a "$LOGFILE"
echo "Output folder: $OUTPUT_DIR"
