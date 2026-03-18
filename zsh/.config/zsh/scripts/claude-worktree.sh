#!/bin/zsh
# Usage: claudetree <branch-name>

BRANCH_NAME=$1
TARGET_DIR="../$BRANCH_NAME"
MAIN_DIR=$(pwd)
BASE_BRANCH=$(git branch --show-current)

if [ -z "$BRANCH_NAME" ]; then
  echo "Branch name is required"
  exit 1
fi

if [[ -z "$BASE_BRANCH" ]]; then
  echo "⚠️ Error: Your main repository is not currently on a branch."
  echo "Please 'git checkout' a base branch before running claudetree."
  exit 1
fi

# 1. Stack the branch with Graphite
gt create "$BRANCH_NAME" -m "Claude task: $BRANCH_NAME"

# 2. CAPTURE the exact branch name Graphite just created (e.g., jc-branch-name)
ACTUAL_BRANCH=$(git branch --show-current)

# 3. Step off the branch so the worktree can claim it
git checkout "$BASE_BRANCH" --quiet || exit 1

# 4. Add worktree ATTACHED to the ACTUAL branch
git worktree add "$TARGET_DIR" "$ACTUAL_BRANCH" || exit 1
cd "$TARGET_DIR" || exit 1

# 5. Setup environment
if [ -d "$MAIN_DIR/.venv" ]; then
    ln -s "$MAIN_DIR/.venv" .venv
fi
if [ -f "$MAIN_DIR/.env" ]; then
    ln -s "$MAIN_DIR/.env" .env
fi

echo "Worktree ready at $TARGET_DIR (Branch: $ACTUAL_BRANCH)"

# 6. Launch interactive session
claude

# 7. Safe Cleanup
cd "$MAIN_DIR" || exit 1
echo "---"

if read -q "REPLY?Claude session ended. Do you want to delete the worktree? [y/N] "; then
  echo ""

  # Remove symlinks so Git doesn't trip over them
  rm -f "$TARGET_DIR/.venv" "$TARGET_DIR/.env"
  
  # Try safe removal
  if git worktree remove "$TARGET_DIR"; then
    echo "Worktree removed."
    exit 0
  else
    # Stop here! Let Git block the deletion to save uncommitted code.
    echo "\n⚠️ Cleanup aborted! You have uncommitted changes in $TARGET_DIR."
    echo "Go commit them using 'gt modify -c -a', then remove the worktree manually."
    exit 1
  fi
fi
