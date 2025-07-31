#!/bin/bash
set -e

echo "--- Git Workflow Automation ---"

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not in a Git repository. Please navigate to your project root (e.g., cd ~/qr-help-me-automated)."
    exit 1
fi

if ! git rev-parse --verify main > /dev/null 2>&1; then
    echo "Error: Local 'main' branch does not exist. Please create it or check out your target branch."
    exit 1
fi
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" != "main" ]; then
    echo "Currently on branch '$current_branch'. Switching to 'main' branch..."
    git checkout main || { echo "Error: Failed to switch to 'main' branch. Resolve any uncommitted changes first. Exiting."; exit 1; }
fi

if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} > /dev/null 2>&1; then
    echo "Local 'main' branch is not tracking a remote branch. Setting upstream to 'origin/main'..."
    git branch --set-upstream-to=origin/main main || { echo "Error: Failed to set upstream for 'main' branch. Ensure 'origin' remote exists. Exiting."; exit 1; }
fi

echo "Adding all changes to staging area..."
git add .

if git diff --cached --quiet; then
    echo "No changes to commit. Staging area is empty."
else
    read -p "Enter commit message: " commit_message
    if [ -z "$commit_message" ]; then
        echo "Commit message cannot be empty. Aborting commit."
        exit 1
    fi
    git commit -m "$commit_message"
fi

echo "Fetching latest changes from remote 'origin'..."
git fetch origin

echo "Rebasing local 'main' branch onto 'origin/main'..."
echo "--- ATTENTION: MANUAL INTERVENTION MAY BE REQUIRED ---"
echo "If conflicts occur during rebase, Git will pause. You must:"
echo "  1. Resolve conflicts manually in the affected files."
echo "  2. Stage the resolved files: 'git add <resolved_file(s)>'"
echo "  3. Continue the rebase: 'git rebase --continue'"
echo "To abort the rebase at any time: 'git rebase --abort'"
echo "----------------------------------------------------"
git rebase origin/main

echo "Pushing changes to GitHub 'origin/main'..."
git push origin main || {
    echo "Push failed. This can happen after a rebase if remote diverged significantly."
    echo "Consider 'git push --force-with-lease origin main' IF you are certain you want to overwrite remote history."
    echo "WARNING: Forcing a push overwrites remote history and can affect collaborators."
    exit 1
}

echo "--- Git workflow complete. ---"
