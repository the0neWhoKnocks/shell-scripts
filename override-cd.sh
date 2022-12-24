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
  
  log "Current directory: '$PWD'"
  inApps=false
  case "$PWD" in
    *"Projects/Code/Apps/"*) inApps=true ;;
    *) ;;
  esac
  
  if [ "$inApps" = true ]; then
    log "In required dir"
    
    repoFile="${PWD}/bin/repo-funcs.sh"
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
