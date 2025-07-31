#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "--- SSH Agent & Key Management ---"

# 1. Start SSH Agent if not already running
if [ -z "$SSH_AGENT_PID" ]; then
    echo "Starting SSH agent..."
    # 'eval' is necessary to set the SSH_AGENT_PID and SSH_AUTH_SOCK variables
    eval "$(ssh-agent -s)"
else
    echo "SSH agent is already running (PID: $SSH_AGENT_PID)."
fi

# Define key paths
SSH_KEY_PATH="$HOME/.ssh/id_rsa"
SSH_PUB_KEY_PATH="$HOME/.ssh/id_rsa.pub"

# Ensure .ssh directory exists with correct permissions
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# 2. Check for existing keys and prompt for overwrite
if [ -f "$SSH_KEY_PATH" ]; then
    read -p "Existing SSH key ($SSH_KEY_PATH) found. Overwrite? (y/N) " overwrite_choice
    if [[ ! "$overwrite_choice" =~ ^[Yy]$ ]]; then
        echo "Key generation aborted by user. Exiting."
        exit 0
    fi
    echo "Overwriting existing SSH keys..."
else
    echo "No existing SSH key found. Generating new keys..."
fi

# 3. Generate new SSH key pair (4096-bit RSA, no passphrase for automation)
# `yes |` pipes 'y' to the overwrite prompt from ssh-keygen if the file exists.
# -N "" sets an empty passphrase. For stronger security, you might add a passphrase later.
yes | ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N ""

# Ensure private key has correct permissions
chmod 600 "$SSH_KEY_PATH"

echo "New SSH key pair generated:"
ls -l "$SSH_KEY_PATH"*

# 4. Add the new private key to the SSH agent
echo "Adding new private key to SSH agent..."
# Use ssh-add -q (quiet) to suppress verbose output if not needed.
ssh-add "$SSH_KEY_PATH" || echo "Note: If 'ssh-add' failed, ensure it's installed and agent is running correctly."

echo "--- SSH Key setup complete. ---"
echo "Your new public key is located at: $SSH_PUB_KEY_PATH"
echo "Please add this public key to your GitHub account settings to authorize your device."
echo "You can view it using: cat $SSH_PUB_KEY_PATH"
