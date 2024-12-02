#!/bin/bash

# Set default values for arguments
FOLDER=${1:-.}
N=${2:-0}

# Validate the folder
if [[ ! -d "$FOLDER" ]]; then
    echo "Error: '$FOLDER' is not a valid directory."
    exit 1
fi

# Count the number of fasta files
fasta_files=$(find "$FOLDER" -type f \( -name "*.fa" -o -name "*.fasta" \))
fasta_count=$(echo "$fasta_files" | wc -l)

if [[ "$fasta_count" -eq 0 ]]; then
    echo "There are no fasta files in this folder or its subfolders."
    exit 0
fi

echo "There are $fasta_count fasta files."

# Count unique IDs in fasta files
unique_ids=$(grep ">" $fasta_files 2>/dev/null | awk '{print $1}' | sort | uniq -c | wc -l)
echo "There are $unique_ids unique IDs in readable files."
echo

# Validate the second argument
if [[ ! "$N" =~ ^[0-9]+$ ]]; then
    echo "Error: Second argument must be a positive integer."
    exit 2
fi

# Process each fasta file
for file in $fasta_files; do
    echo
    echo "========== $file report =========="
    echo

    # Check if the file is empty
    if [[ ! -s "$file" ]]; then
        echo "- File is empty."
        echo "//////////////////////////////////////////////////////////////////////////"
        continue
    fi

    # Check if the file is readable and not binary
    content=$(grep -v ">" "$file" 2>/dev/null | sed 's/-//g' | tr '[:lower:]' '[:upper:]')
    if [[ -r "$file" && "$content" =~ [A-Z]+$ ]]; then
        echo "- File is readable."
    else
        echo "- File is not readable or is a binary file."
        echo "//////////////////////////////////////////////////////////////////////////"
        continue
    fi

    # Check if the file is a symlink
    if [[ -h "$file" ]]; then
        echo "- It is a symlink."
    else
        echo "- It is not a symlink."
    fi

    echo

    # Count the number of sequences and their total length
    sequence_count=$(grep -c ">" "$file")
    if [[ "$sequence_count" -eq 0 ]]; then
        echo "- There are no sequences in this file."
    elif [[ "$sequence_count" -eq 1 ]]; then
        echo "- There is one sequence in this file."
        grep -v ">" "$file" | sed 's/-//g' | awk '{x += length($0)} END {print "- Total length of sequence: " x}'
    else
        echo "- There are $sequence_count sequences in this file."
        grep -v ">" "$file" | sed 's/-//g' | awk '{x += length($0)} END {print "- Total length of sequences: " x}'
    fi

    echo

    # Check if the file contains nucleotides or amino acids
    if [[ "$content" =~ ^[ATGCN]+$ ]]; then
        echo "- This file only contains nucleotides."
    else
        echo "- This file contains amino acids."
    fi

    echo

    # Print the whole file or only N first and last lines
    total_lines=$(wc -l < "$file")
    if [[ "$N" -ne 0 ]]; then
        if [[ "$total_lines" -le $((2 * N)) ]]; then
            cat "$file"
        else
            head -n "$N" "$file"
            echo "..."
            tail -n "$N" "$file"
        fi
    fi

    echo
    echo "//////////////////////////////////////////////////////////////////////////"
done

