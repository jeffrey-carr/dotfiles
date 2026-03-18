#!/usr/bin/env zsh
# TODOs:
#   - TUI with updated `gt ls` in the right pane?
#   - prefix of branches to ignore - both in branching and in linear paths

# ANSI color codes
RED="\033[31m"
GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
RESET="\033[0m"

lint_and_test() {
    # Run linting
    pipenv run inv lint >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}󱝱 Linting failed on ${GREEN}$(git rev-parse --abbrev-ref HEAD)${RESET}"
        return 1
    else
        echo -e "${BLUE}󰃣 Linting passed${RESET}"
    fi

    # Run testing
    pipenv run inv test >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}󰤒 Testing failed on ${GREEN}$(git rev-parse --abbrev-ref HEAD)${RESET}"
        return 1
    else
        echo -e "${BLUE}󰙨 Tests passed${RESET}"
    fi

    return 0
}

while true; do
    echo -e "${YELLOW}Checking $(git rev-parse --abbrev-ref HEAD)${RESET}..."
    lint_and_test
    if [ $? -ne 0 ]; then
        break
    fi

    # Capture output from `gt up`
    gt_output=$(gt up --no-interactive 2>&1)
    if [[ $gt_output == *"Already at the top most branch in the stack"* ]]; then
        echo "Reached the top of the stack, all done."
        break
    fi
    if [[ $gt_output == *"ERROR: Cannot get upstack branch in non-interactive mode; multiple choices available:"* ]]; then
        echo "Found a fork, stopping so you can pick which direction to go."
        gt up
    fi
done
