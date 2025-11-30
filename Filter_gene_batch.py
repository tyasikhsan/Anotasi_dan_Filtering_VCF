#!/usr/bin/env python3
import os
import csv

# === Configuration ===
input_dir = "BATCH2_tsv_output"           # Folder containing input TSV files
output_dir = "BATCH2_filtered_tsv_by_1200_genes"       # Folder for filtered outputs
gene_list_file = "1200genes.txt"   # Text file with gene names (one per line)
gene_column = "Gene_Info"     # Column name to match genes

# === Load gene list ===
with open(gene_list_file) as f:
    target_genes = set(line.strip().split(":")[0] for line in f if line.strip())

os.makedirs(output_dir, exist_ok=True)

# === Process each TSV file ===
for filename in os.listdir(input_dir):
    if not filename.endswith(".tsv"):
        continue

    input_path = os.path.join(input_dir, filename)
    output_path = os.path.join(output_dir, filename.replace(".tsv", "_filtered.tsv"))

    print(f"🔍 Processing: {filename}")

    with open(input_path, newline='') as infile, open(output_path, "w", newline='') as outfile:
        reader = csv.DictReader(infile, delimiter="\t")
        writer = csv.DictWriter(outfile, fieldnames=reader.fieldnames, delimiter="\t")
        writer.writeheader()

        # Stream line by line
        for row in reader:
            gene_info = row.get(gene_column, "")
            # Example: "PNPLA6:10908" → take "PNPLA6"
            gene_name = gene_info.split(":")[0] if gene_info else ""
            if gene_name in target_genes:
                writer.writerow(row)

    print(f"✅ Saved filtered file: {output_path}")

print("\n🎉 All files filtered by 1200genes processed successfully!")
