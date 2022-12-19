function cd () {
  builtin cd "$@" # perform the actual cd
  
  case "$PWD" in
    *"Projects/Code/Apps"*) inApps=true ;;
    *) ;;
  esac

  if [ -n "$inApps" ]; then
    # echo "in apps dir"
    if [ -d ".git" ] && [ -f "./bin/aliases.sh" ]; then
      source "./bin/aliases.sh"
      echo "[cd] Sourced aliases for app repo"
    fi
  else
    # echo "not in apps dir"
  fi
}
