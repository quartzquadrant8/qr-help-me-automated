# Discreet Emergency QR Code Generator

This project provides a simple, self-hosted web page that displays a QR code containing a user-provided phone number. It's designed to be discreetly accessible on a mobile device for emergency situations, allowing someone to scan the QR code to quickly get a contact number.

The server is built with Flask (Python) and the QR code is generated client-side using JavaScript.

## Setup & Usage

### Dependencies

To run this project, you need the following installed in your Termux (Android) environment:

* **Python 3** (with `venv` module)
* **pip** (Python package installer)
* **wget** (for downloading static assets)
* **sed** (for modifying HTML)
* **git** (for version control)
* **Flask** (Python web framework, installed into a virtual environment by the setup script)
* **OpenSSH** (for `ssh-agent`, `ssh-keygen`, `ssh-add` - needed for Git SSH authentication)

### For Android Users (Termux)

This project is optimized for self-hosting on an Android device using Termux.

1.  **Run the Full Setup Script (This Script):**
    Ensure you are in your Termux home directory (`~`) and execute this entire script. It will set up everything.

    ```bash
    # (The script you just pasted and ran to set up everything)
    ```

2.  **Run the Flask Application:**
    After this setup script completes successfully, navigate into the project and execute the `run.sh` script, providing your phone number as an argument.

    ```bash
    cd qr-help-me-automated/qr-help-me-automated
    ./run.sh +15551234567 # Replace with your actual phone number (e.g., +12345678900)
    ```

3.  **Access the QR Code in Your Browser:**
    Since you are likely on mobile data (no Wi-Fi), you must access the server using the localhost address:
    * Open your Android's web browser (Chrome, Firefox, Brave).
    * Go to: `http://127.0.0.1:5000`

    You should see the "Scan This Code For Help" page with the QR code displayed.

### For iOS Users

Directly hosting a Python Flask server on an iOS device is generally **not supported** without jailbreaking or very specific development tools (like Playgrounds for SwiftUI, or highly restricted browser-based Python interpreters).

* **Recommendation:** If you need to access this functionality on iOS, you would need to host the Flask application on a different device (e.g., a laptop or cloud server) that has Wi-Fi, and then access that server's IP address from your iOS device's browser.

### Git Workflow & SSH Setup

This project uses Git for version control and relies on SSH for secure communication with GitHub.

1.  **SSH Key Setup:**
    Before pushing to GitHub via SSH, ensure your SSH keys are set up. Run this script from your project's root directory (`~/qr-help-me-automated/qr-help-me-automated`). It will generate them and add to your SSH agent. **You then need to add your new public key (`~/.ssh/id_rsa.pub`) to your GitHub account settings.**

    ```bash
    ./setup_ssh.sh
    ```

2.  **Git Add, Commit, Push Workflow:**
    To add your changes, commit them, pull remote changes (with rebase), and push to GitHub, run this script from your project's root directory.

    ```bash
    ./git_push_workflow.sh
    ```
    **Note:** The `git rebase` step can pause if there are merge conflicts. You will need to resolve these manually and then use `git add .` and `git rebase --continue`.

## Project Structure

```
qr-help-me-automated/
├── app.py                     # Flask application
├── templates/
│   └── index.html             # HTML template for the QR code page
├── static/
│   └── qrcode.min.js          # JavaScript library for QR code generation
├── run.sh                     # Script to set up venv, embed number, and run Flask
├── setup_ssh.sh               # Script to manage SSH keys
├── git_push_workflow.sh       # Script to add, commit, rebase, and push to Git
├── requirements.txt           # Python dependencies
└── .gitignore                 # Files and directories to ignore in Git
├── README.md                  # Project documentation
```
