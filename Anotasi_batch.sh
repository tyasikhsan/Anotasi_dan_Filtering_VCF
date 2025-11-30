#!/bin/bash
# ==============================================
# Batch Annotation Script: SnpEff + ClinVar
# For samples starting with 0G00
# Memory limit: 16 GB
# Annotates with ALL ClinVar INFO fields automatically
# ==============================================

# --- USER SETTINGS ---
SNPEFF_JAR="snpEff.jar"      # Path to snpEff.jar
GENOME="GRCh38.99"           # Genome database for snpEff
CLINVAR="clinvar.chr.vcf.gz" # ClinVar reference VCF
#INPUT_DIR="/home/jovyan/analysis/wgs/snpEff" # Working folder for input/output

#acceptingArgument1asWorkingdir
INPUT_DIR=$1

LOGFILE="annotation_log_$(date +%Y%m%d_%H%M).log"

# Move to working directory
cd "$INPUT_DIR" || exit
echo "[$(date)] Starting annotation pipeline in: $PWD" | tee -a "$LOGFILE"

# --- Check ClinVar index ---
if [ ! -f "${CLINVAR}.tbi" ]; then
  echo "[$(date)] ClinVar index not found — creating..." | tee -a "$LOGFILE"
  tabix -p vcf "$CLINVAR"
fi

# --- Extract ALL INFO fields from ClinVar automatically ---
echo "[$(date)] Extracting all INFO fields from ClinVar header..." | tee -a "$LOGFILE"
ALL_INFO=$(bcftools view -h "$CLINVAR" | grep "^##INFO=<ID=" | \
            sed -E 's/##INFO=<ID=([^,]+),.*/INFO\/\1/' | tr '\n' ',' | sed 's/,$//')

if [ -z "$ALL_INFO" ]; then
  echo "[$(date)] ❌ Failed to extract INFO fields from ClinVar header." | tee -a "$LOGFILE"
  exit 1
fi
echo "[$(date)] Found $(echo "$ALL_INFO" | tr ',' '\n' | wc -l) INFO fields." | tee -a "$LOGFILE"

# --- Process only VCFs starting with 0G00 ---
for IN in 0G00*.vcf.gz; do
  if [ ! -f "$IN" ]; then
    echo "[$(date)] No files found starting with 0G00. Exiting." | tee -a "$LOGFILE"
    exit 1
  fi

  SAMPLE=$(basename "$IN" .vcf.gz)
  OUT_ANNOT="annotated_snpeff_${SAMPLE}.vcf.gz"
  OUT_CLIN="annotated_with_clinvar_${SAMPLE}.vcf.gz"

  echo "----------------------------------------------" | tee -a "$LOGFILE"
  echo "[$(date)] Processing: $SAMPLE" | tee -a "$LOGFILE"

  # --- Step 1: SnpEff annotation ---
  if [ ! -f "$OUT_ANNOT" ]; then
    echo "[$(date)] Running SnpEff..." | tee -a "$LOGFILE"
    if java -Xmx16g -jar "$SNPEFF_JAR" "$GENOME" "$IN" 2>>"$LOGFILE" | bgzip -c > "$OUT_ANNOT"; then
      tabix -p vcf "$OUT_ANNOT"
      echo "[$(date)] ✅ SnpEff completed for $SAMPLE" | tee -a "$LOGFILE"
    else
      echo "[$(date)] ❌ SnpEff failed for $SAMPLE" | tee -a "$LOGFILE"
      continue
    fi
  else
    echo "[$(date)] Skipping SnpEff — already annotated." | tee -a "$LOGFILE"
  fi

  # --- Step 2: ClinVar annotation (ALL INFO fields) ---
  if [ ! -f "$OUT_CLIN" ]; then
    echo "[$(date)] Annotating with ClinVar (all INFO fields)..." | tee -a "$LOGFILE"
    if bcftools annotate \
        -a "$CLINVAR" \
        -c CHROM,POS,REF,ALT,${ALL_INFO} \
        -O z -o "$OUT_CLIN" "$OUT_ANNOT" 2>>"$LOGFILE"; then
      bcftools index "$OUT_CLIN"
      echo "[$(date)] ✅ ClinVar (all INFO) annotation completed for $SAMPLE" | tee -a "$LOGFILE"
    else
      echo "[$(date)] ❌ ClinVar annotation failed for $SAMPLE" | tee -a "$LOGFILE"
      continue
    fi
  else
    echo "[$(date)] Skipping ClinVar — already annotated." | tee -a "$LOGFILE"
  fi
done

echo "==============================================" | tee -a "$LOGFILE"
echo "[$(date)] 🎉 All 0G00 samples processed successfully." | tee -a "$LOGFILE"
echo "Log saved to: $LOGFILE"
