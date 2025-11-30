# Anotasi_dan_Filtering_VCF
Ini adalah kumpulan script (bash dan py) untuk menjalankan proses anotasi dengan menggunakan snpEff dan Clinvar, dan juga melakukan proses filtering berdasarkan kolom CLEANSIG, dan Filtering menggunakan daftar gen yang dituju.

Sementara ini, terdapat 4 script yang bisa digunakan :
1. Script Anotasi_batch.sh digunakan untuk melakukan anotasi terhadap file VCF
2. Script convert_to_tsv.sh agar data lebih mudah ditampilkan
3. Script Filtering_batch.sh untuk melakukan Filtering terhadap kolom CLNSIG yang memiliki nilai Pathogenic, Likely Pathogenic, dan Uncerctain Significance
4. Script Filter_gene_batch.py untuk melakukan filtering berdasarkan list/daftar gen yang ditarget

Catatan :
-Sementara di script ini belum disesuaikan path untuk bisa dipanggil dari mana saja -- butuh penyesuaian PATH
-Sementara Running hanya bisa dilakukan dengan data dan berada 1 folder yang sama dengan :
   SNPEFF_JAR="snpEff.jar"      # Path to snpEff.jar
   GENOME="GRCh38.99"           # Genome database for snpEff
   CLINVAR="clinvar.chr.vcf.gz" # ClinVar reference VCF
-Perlu penyesuaian lebih lanjut
- akan dihasilkan logfile untuk mencatat proses anotasi,dll
