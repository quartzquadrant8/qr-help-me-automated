#!/bin/bash
set -e

echo "--- SSH Agent & Key Management ---"

if [ -z "$SSH_AGENT_PID" ]; then
    echo "Starting SSH agent..."
    eval "$(ssh-agent -s)"
else
    echo "SSH agent is already running (PID: $SSH_AGENT_PID)."
fi

SSH_KEY_PATH="$HOME/.ssh/id_rsa"
SSH_PUB_KEY_PATH="$HOME/.ssh/id_rsa.pub"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

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

yes | ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N ""

chmod 600 "$SSH_KEY_PATH"

echo "New SSH key pair generated:"
ls -l "$SSH_KEY_PATH"*

echo "Adding new private key to SSH agent..."
ssh-add "$SSH_KEY_PATH" || echo "Note: If 'ssh-add' failed, ensure it's installed and agent is running correctly."

echo "--- SSH Key setup complete. ---"
echo "Your new public key is located at: $SSH_PUB_KEY_PATH"
echo "Please add this public key to your GitHub account settings to authorize your device."
echo "You can view it using: cat $SSH_PUB_KEY_PATH"
