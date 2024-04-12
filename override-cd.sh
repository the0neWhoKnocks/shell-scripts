#!/bin/bash

function cd {
  function log {
    if [ -n "$DEBUG_CD" ]; then
      echo "[cd] $1"
    fi
  }
  
  function teardown {
    log "Not in required dir"
    
    if [ -n "$REPO_FUNCS" ]; then
      echo "╭─────────"
      for currFunc in "$REPO_FUNCS[@]"; do
        unset -f $currFunc
        echo "│[REMOVED] Function: '${currFunc}'"
      done
      echo "╰─────────"
      
      unset REPO_FUNCS
      log "Clean-up for repo complete"
    fi
  }
  
  if [[ "$1" != "--init" ]]; then
    log "Called with: '$@'"
    builtin cd "$@" # perform the actual cd
  fi
  
  # skip the extra overhead when running within a subshell
  if [[ $ZSH_SUBSHELL -eq 1 ]] || [[ $BASH_SUBSHELL -eq 1 ]]; then
    return 0;
  fi
  
  log "Current directory: '$PWD'"
  local inApps=false
  case "$PWD" in
    *"Projects/Code/Apps/"*) inApps=true ;;
    *) ;;
  esac
  
  if [ -d "./.git" ]; then
    log "In git repo"
    
    local currBranch=$(git rev-parse --abbrev-ref HEAD)
    # NOTE: `remote update` is a slow operation, so entering a repo will seem laggy.
    local updateStatus=$(git remote update; git status -uno)
    
    if \
      echo "$updateStatus" | grep -q "branch is behind" \
      || echo "$updateStatus" | grep -q "have diverged" \
    ; then
      echo "╭───────"
      echo "│[WARNING] Local repo out of sync with Upstream repo."
      echo "╰───────"
      
      while true; do
        read "yn?Update Local repo (y/n)?: "
        case $yn in
          [Yy]* )
            local thereAreChanges=$(echo -ne $(git diff --exit-code))
            if [[ "$thereAreChanges" != "" ]]; then
              echo;
              echo "[STASH] changes"
              git stash
            fi
            
            git pull --rebase origin "${currBranch}"
            
            if [[ "$thereAreChanges" != "" ]]; then
              echo;
              echo "[UN-STASH] changes"
              git stash apply
            fi
            break
            ;;
          [Nn]* ) break;;
          * ) echo "Please answer yes or no.";;
        esac
      done
    fi
  fi
  
  if [ "$inApps" = true ]; then
    log "In required dir"
    
    local repoFile="${PWD}/bin/repo-funcs.sh"
    if [ -d ".git" ] && [ -f "${repoFile}" ]; then
      log "  Sourcing: ${repoFile}"
      source "${repoFile}"
      echo "╭───────"
      for currFunc in "$REPO_FUNCS[@]"; do
        echo "│[ADDED] Function: '${currFunc}'"
      done
      echo "╰───────"
      
      log "  Done"
    else
      teardown
    fi
  else
    teardown
  fi
}

# Run when initially loading the shell to ensure check is run if shell started in repo root
cd --init
