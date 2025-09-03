#!/bin/bash

# Only run within an interactive context
if [ -t 0 ]; then
  ##
  # store previous session data
  onExit() {
    if [[ "${PWD}" != "${HOME}" ]]; then
      echo "export CUSTOM__PREV_DIR='${PWD}'" > ~/.prev_term
    fi
  }

  trap onExit EXIT

  if [ -f ~/.prev_term ]; then
    source ~/.prev_term
    
    # only prompt to load previous dir if one has been saved, and a new shell was started
    if [[ "${CUSTOM__PREV_DIR}" != "" ]] && [[ "${PWD}" == "${HOME}" ]]; then  
      while true; do
        read "yn?Load '${CUSTOM__PREV_DIR}' (Y/n)?: "
        case $yn in
          [Nn]* ) break;;
          * )
            cd "${CUSTOM__PREV_DIR}"
            break
            ;;
        esac
      done
    fi
  fi
fi

