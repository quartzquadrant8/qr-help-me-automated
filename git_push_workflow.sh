#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "--- Git Workflow Automation ---"

# Ensure we are in a Git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not in a Git repository. Please navigate to your project root (e.g., cd ~/qr-help-me-automated)."
    exit 1
fi

# 1. Check if 'origin' remote is set, and prompt to add it if not.
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "Git remote 'origin' is not set. You need to link your local repository to your GitHub repository."
    read -p "Please enter your GitHub repository SSH URL (e.g., git@github.com:yourusername/your-repo-name.git): " GITHUB_REPO_URL
    if [ -z "$GITHUB_REPO_URL" ]; then
        echo "Error: GitHub repository URL cannot be empty. Aborting."
        exit 1
    fi
    git remote add origin "$GITHUB_REPO_URL" || { echo "Error: Failed to add remote 'origin'. Check URL. Exiting."; exit 1; }
    echo "Remote 'origin' added: $GITHUB_REPO_URL"
fi

# Ensure 'main' branch exists locally and is checked out
if ! git rev-parse --verify main > /dev/null 2>&1; then
    echo "Error: Local 'main' branch does not exist. Please create it first using 'git branch -M main' and commit some changes."
    exit 1
fi
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" != "main" ]; then
    echo "Currently on branch '$current_branch'. Switching to 'main' branch..."
    git checkout main || { echo "Error: Failed to switch to 'main' branch. Resolve any uncommitted changes first. Exiting."; exit 1; }
fi

# 2. Add all changes
echo "Adding all changes to staging area..."
git add .

# Check if there's anything to commit (avoids empty commit errors)
if git diff --cached --quiet; then
    echo "No changes to commit. Staging area is empty."
else
    # 3. Commit changes
    read -p "Enter commit message: " commit_message
    if [ -z "$commit_message" ]; then
        echo "Commit message cannot be empty. Aborting commit."
        exit 1
    fi
    git commit -m "$commit_message"
fi

# 4. Push changes to GitHub (handle initial push vs. subsequent pushes)
echo "Pushing changes to GitHub..."

# Check if the current branch has an upstream branch set
# @{u} refers to the upstream branch. If it's not set, this command returns an error.
if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} > /dev/null 2>&1; then
    echo "Local 'main' branch is not tracking a remote branch. Performing initial push to 'origin/main' and setting upstream..."
    # This command pushes and sets the upstream branch for the first time.
    git push -u origin main || {
        echo "Error: Initial push failed. Please ensure the remote repository exists on GitHub and your SSH key is correctly added."
        exit 1
    }
else
    # If upstream is already set, perform fetch and rebase, then push.
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
    git rebase origin/main || { echo "Error: Git rebase failed. Resolve conflicts or abort. Exiting."; exit 1; }

    echo "Pushing changes to GitHub 'origin/main' after rebase..."
    git push origin main || {
        echo "Push failed. This can happen after a rebase if remote diverged significantly."
        echo "Consider 'git push --force-with-lease origin main' IF you are certain you want to overwrite remote history."
        echo "WARNING: Forcing a push overwrites remote history and can affect collaborators."
        exit 1
    }
fi

echo "--- Git workflow complete. ---"
