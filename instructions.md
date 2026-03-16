# 🎯 Dev Setup: The "Terminal-as-an-OS" Vision

## 1. Core Philosophy

* **Total Terminal Immersion:** The workflow should be designed so that 95% of the workday is spent within the terminal.
* **Zero-Latency Context Switching:** Switching between a work project, a personal project, and a configuration file should take less than two seconds.
* **Aesthetic Consistency:** A single color palette must govern the entire visual experience to reduce cognitive load.
* **Native & Portable:** The setup must feel like a native part of macOS but be fully version-controlled for easy recovery or migration via GitHub.

---

## 2. Primary Requirements

### Workspace & Context Management

* **Ephemeral & Persistent Sessions:** Ability to spin up a project environment, leave it running, and return to it later exactly where it was left.
* **Fuzzy Project Discovery:** A search-based interface to jump to any directory in the development folders without typing paths.
* **Pane-Based Layouts:** The ability to see code, running logs, and an AI assistant simultaneously in a single terminal window.

### Unified Theming

* **Global Color Sync:** A single command or trigger that updates the color scheme for the terminal emulator, the multiplexer, and the text editor at once.
* **Light/Dark Adaptability:** The system should support high-quality light and dark variants (e.g., Catppuccin Latte/Mocha) to accommodate different lighting conditions.

### AI-Enhanced Workflow

* **Ambient AI Presence:** A way to have **Claude Code** (or similar CLI agents) active in the current workspace, allowing it to "watch" and "act" on the codebase while the engineer remains in the editor.
* **Integrated Shell/AI Communication:** Seamlessly moving text or context between the terminal shell, the editor, and the AI agent.

---

## 3. High-Efficiency Suggestions (The "Ideabase")

### Navigation & Discovery

* **Frequented Path Memory:** A navigation system that learns which directories are visited most and allows for "shorthand" jumping (e.g., typing `z web` to go to `~/dev/projects/web-apps`).
* **Project-Specific Bookmarking:** A way to "mark" 3–4 specific files within a massive backend project and jump between them via home-row hotkeys.

### Automation & Tooling

* **Automated App Provisioning:** A single file that lists every macOS app, CLI tool, and font required for the setup, allowing a new machine to be "bootstrapped" with one command.
* **Alfred-to-Terminal Bridges:** Custom Alfred triggers that allow for starting specific terminal "sessions" directly from the macOS search bar.
* **Git-Integrated Status Bars:** A persistent visual indicator of the current branch, git status, and background job count that is consistent across the terminal and the editor.

### Editor (Neovim) specific

* **File-System Editing:** The ability to treat the directory structure like a text file—renaming, moving, or deleting files using standard editor commands.
* **Language-Specific Intelligence:** Deep, automated integration for Go and TypeScript that handles formatting, linting, and "Go to Definition" without manual setup per project.

### System Control

* **Native macOS Keyboard Tuning:** Overriding system-level repeat rates and delay timings to match the speed of a high-end mechanical keyboard/Vim workflow.
* **CLI Secret Management:** A method for handling API keys and environment variables that keeps them out of the GitHub dotfiles but makes them available to the terminal sessions automatically.

