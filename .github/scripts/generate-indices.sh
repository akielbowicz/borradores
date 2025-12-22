#!/bin/bash
# Generate index.org files for navigation
# This creates an index file for each directory containing .org files
# and a main index.org at the root level

set -e

# Generate index for each directory
for dir in */; do
    # Skip hidden directories, _site, and vendor
    if [[ "$dir" == .* ]] || [[ "$dir" == "_site/" ]] || [[ "$dir" == "vendor/" ]]; then
        continue
    fi

    dir_name="${dir%/}"

    # Check if directory has any .org files
    if ! ls "$dir_name"/*.org >/dev/null 2>&1; then
        continue
    fi

    echo "Generating index for: $dir_name"

    # Create directory index with parent link
    echo "- [[../index.html][..]]" > "$dir_name.org"
    echo "" >> "$dir_name.org"

    # Add links to all .org files in the directory (converted to .html)
    ls "$dir_name"/*.org | while read -r file; do
        basename=$(basename "$file" .org)
        htmlpath="${file%.org}.html"
        echo "- [[$htmlpath][$basename]]" >> "$dir_name.org"
    done
done

# Generate main index.org
echo "Generating main index.org"
echo "#+TITLE: Borradores - Index" > index.org
echo "" >> index.org

# Add links to all top-level .org files (except index.org itself, converted to .html)
for file in *.org; do
    if [[ "$file" != "index.org" ]]; then
        basename=$(basename "$file" .org)
        htmlfile="${file%.org}.html"
        echo "- [[$htmlfile][$basename]]" >> index.org
    fi
done

echo "Index generation complete"
