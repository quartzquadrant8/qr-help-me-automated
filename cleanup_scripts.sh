#!/bin/bash
set -e

echo "--- Mass Removing Comments and Empty Lines from Scripts ---"

# CRITICAL FIX: Changed array assignment to a space-separated list for broader shell compatibility
for script in "app.py" "run.sh" "setup_ssh.sh" "git_push_workflow.sh"; do
    if [ -f "$script" ]; then
        echo "Processing $script..."
        # Remove full-line comments (lines starting with # and optional whitespace)
        sed -i.bak -E '/^[[:space:]]*#.*/d' "$script"
        # Remove empty lines or lines containing only whitespace
        sed -i.bak '/^[[:space:]]*$/d' "$script"
        echo "   Cleaned $script."
    else
        echo "   Warning: Script not found: $script. Skipping."
    fi
done

echo ""
echo "--- Annotation Removal Complete ---"
echo "Backup files with '.bak' extension have been created (e.g., app.py.bak)."
echo "You can review these changes. For further reduction of 'echo' statements, manual review is recommended."
echo "Now, you can update and push these changes to GitHub."
echo "Run: ./git_push_workflow.sh"
