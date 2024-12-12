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
        unset -f "orig_$currFunc"
        echo "│[REMOVED] Function: '${currFunc}'"
      done
      echo "╰─────────"
      
      unset REPO_FUNCS
      log "Clean-up for repo complete"
    fi
  }
  
  function loadRepoFile {
    local label="ADDED"
    if [[ "$1" == "update" ]]; then
      label="UPDATED"
    fi
    
    source "${repoFile}"
    echo "╭───────"
    for currFunc in "$REPO_FUNCS[@]"; do
      echo "│[${label}] Function: '${currFunc}'"
      
      # rename function so it can be wrapped
      eval orig_"$(declare -f ${currFunc})"
      # wrap function
      eval "function ${currFunc} { verifyRepoFuncsCurrent \"${currFunc}\"; orig_${currFunc} }"
    done
    echo "╰───────"
  }
  
  function verifyRepoFuncsCurrent {
    log "Verify repo file: ${repoFile}"
    
    local currSHA=$(genRepoFileSHA)
    log "        Repo file SHA: ${repoFileSHA}"
    log "Current repo file SHA: ${currSHA}"
    
    if [[ "$repoFileSHA" != "$currSHA" ]]; then
      echo;
      echo "Repo file not current, updating functions ..."
      repoFileSHA=$currSHA
      loadRepoFile 'update'
    fi
  }
  
  function genRepoFileSHA {
    # `printf` reads the spaces in the return as arguments and only prints
    # the first argument (the SHA). The `echo` is to ditch the `%` from `printf`.
    local sha=$(printf $(sha256sum "$repoFile"); echo)
    echo "$sha"
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
    
    local currBranch=$(git rev-parse -q --verify --abbrev-ref HEAD)
    # Account for cases where a repo was initialized but has no commits.
    if [[ "$currBranch" != "" ]]; then
      # NOTE: `remote update` is a slow operation, so entering a repo will seem laggy.
      git remote update &> /dev/null
      local updateStatus=$(git status -uno)
      
      if \
        echo "$updateStatus" | grep -q "branch is behind" \
        || echo "$updateStatus" | grep -q "have diverged" \
      ; then
        echo "╭───────"
        echo "│[WARNING] Local repo out of sync with Upstream repo."
        echo "╰───────"
        
        if echo "$SHELL" | grep -q "/zsh"; then
          read "yn?Update Local repo (y/n)?: "
        else
          read -p "Update Local repo (y/n)?: " yn
        fi
        
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
            ;;
          [Nn]* ) ;;
          * ) echo "Please answer yes or no.";;
        esac
      fi
    fi
  fi
  
  if [ "$inApps" = true ]; then
    log "In required dir"
    
    # NOTE: `repoFile` & `repoFileSHA` can't be `local` since `verifyRepoFuncsCurrent` will be called from external scripts
    repoFile="${PWD}/bin/repo-funcs.sh"
    if [ -d ".git" ] && [ -f "${repoFile}" ]; then
      repoFileSHA=$(genRepoFileSHA)
      log "  Repo file SHA: ${repoFileSHA}"
      log "  Sourcing: ${repoFile}"
      loadRepoFile
      
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
