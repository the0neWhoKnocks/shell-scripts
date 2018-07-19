######################################################################
#                                                                    #
# [ Installation ]                                                   #
#                                                                    #
# I created a dir in my home dir called "sh" (for shell scripts).    #
# With that in mind, you can add the attached script in the sh dir,  #
# and add the below line to your .bashrc or .zshrc file.             #
#                                                                    #
# source ~/sh/git-functions.sh                                       #
#                                                                    #
######################################################################

source $(dirname $0)/colors.sh

##
# This is the branch that serves as the default root branch
# usually this'd be 'master', but in some projects it may be
# different. It's primarily used in the case where you try to
# delete a branch you're currently in. You will be moved to
# this branch, allowing the previous branch to be deleted.
gitProjectRoot="master"

##
# Updates current git branch
function git-update () {
  local currBranch=$(git rev-parse --abbrev-ref HEAD)
  local parentBranch=$(git config "branch.$currBranch.parent")
  thereAreChanges=$(echo -ne $(git diff --exit-code))

  if [[ "$thereAreChanges" != "" ]]; then
    echo;
    echo -e " ${BCya}[STASH]${RCol} changes"
    git stash
  fi

  if [[ "$1" != "" && "$2" != "" ]]; then
    echo;
    echo -e " ${BCya}[REBASING]${RCol} from \"$1\" to \"$2\""
    echo;
    git pull --rebase $1 $2
  else
    # only try to rebase if there's a parent branch
    if [[ "$parentBranch" != "" ]]; then
      echo;
      echo -e " ${BCya}[REBASING]${RCol} from parent \"$parentBranch\""
      echo;
      git pull --rebase origin "$parentBranch"
    else
      echo;
      echo -e " ${BCya}[PULLING]${RCol} new changes"
      echo;
      git pull
    fi
  fi

  if [[ "$thereAreChanges" != "" ]]; then
    echo;
    echo -e " ${BCya}[UN-STASH]${RCol} changes"
    git stash apply
  fi
}
alias gu='git-update'

##
# Displays a list of modified files and their location path
function git-changes (){
  local changeCount=0
  local modifiedFiles=""
  local modifiedCount=0
  local untrackedFiles=""
  local untrackedCount=0

  while read line; do
    # the status of the file. status is a reserved var
    local stat=$(echo "$line" | egrep -io '^(\w)')
    # the file name
    file=$(echo `basename "${line}"`)
    # the file path
    fp=$(dirname "$line") && fp=$(echo "${fp#* }")


    if [[ "$fp" != "" && "$fp" != "." ]]; then
      fp=" ${BBla}($fp)${RCol} \n\n"
    else
      file=$(echo ${line#* }) # fix root level filenames
      fp="\n\n"
    fi

    # if the status is set, add a space and proper coloring
    if [ "$stat" != "" ]; then
      # ${red}$stat${reset}
      modifiedFiles=$(echo -e "$modifiedFiles${Cya}$file$fp ${BBla}")
      modifiedCount=$((modifiedCount+1))
    elif [ "$file" != "" ]; then
      untrackedFiles=$(echo -e "$untrackedFiles${reset}${Red}$file$fp ")
      untrackedCount=$((untrackedCount+1))
    fi

    if [ "$file" != "" ]; then
      changeCount=$((changeCount+1))
    fi

  done < <(git status -s)

  echo -e "\n\n";
  echo -e "${BBla}████████████████████████████████████████████"
  echo -e "\n Modified Files ${RCol}($modifiedCount)${BBla} \n"
  echo -e " $modifiedFiles"
  echo -e "------------------------------------------- \n"
  echo -e " Untracked Files ${RCol}($untrackedCount)${BBla} \n"
  echo -e " $untrackedFiles"
  echo -e "\n                         ${BBla}Files Changed ${RCol}($changeCount)${BBla}"
  echo -e "████████████████████████████████████████████ \n\n"
}
alias gc='git-changes'

##
# Creates a user defined git branch locally and pushes it up to remote
function git-add-branch () {
  local branchName="$1"

  if [[ "$branchName" != "" ]]; then
    # verify the branch name adheres to the branching model
    if [[ "$branchName" != *\/* ]]; then
      echo;
      echo -e " ${BRed}[ERROR]${RCol} The name ${BYel}$branchName${RCol} doesn't match our current branching model."
      echo;
      echo " Select one of the scheming prefixes below."
      echo;
      echo " ${BYel}(1)${RCol} bugfix/"
      echo " ${BYel}(2)${RCol} feature/"
      echo " ${BYel}(3)${RCol} hotfix/"
      echo " ${BYel}(4)${RCol} release/"
      echo " ${BYel}(5)${RCol} I don't want to follow the branching model "
      echo;

      # capture the user's choice
      echo -n ""
      read selectedOption

      case $selectedOption in
        1)
          branchName="bugfix/$branchName"
        ;;
        2)
          branchName="feature/$branchName"
        ;;
        3)
          branchName="hotfix/$branchName"
        ;;
        4)
          branchName="release/$branchName"
        ;;
      esac
    fi

    local parentBranch=$(git rev-parse --abbrev-ref HEAD)

    echo;
    echo -e " ${BCya}[CREATING]${RCol} local branch ${BYel}$branchName${RCol}"
    git checkout -b $branchName

    echo;
    echo -e " ${BCya}[ADDING]${RCol} ${BYel}$branchName${RCol} to your remote origin"
    git push --no-verify -u origin $branchName

    echo;
    echo -e " ${BCya}[SETTING]${RCol} the remote for ${BYel}$branchName${RCol} to origin"
    git config "branch.$branchName.remote" "origin"
    echo -e " ${BCya}[SETTING]${RCol} a reference to the parent ${BYel}$parentBranch${RCol}"
    git config "branch.$branchName.parent" "$parentBranch"
  else
    echo " usage: git-add-branch <branch-name>"
    echo " usage: gab <branch-name>"
  fi
}
alias gab='git-add-branch'

##
# Deletes a user defined git branch locally and removes it from remote
function git-delete-branch () {
  if [[ "$1" != "" ]]; then
    local currBranch parentBranch thereAreChanges okToProceed

    currBranch=$(git rev-parse --abbrev-ref HEAD)
    parentBranch=$(git config "branch.$currBranch.parent")
    thereAreChanges=$(echo -ne $(git diff --exit-code))
    okToProceed=1

    # if there isn't a parent branch, use the root branch
    if [[ "$parentBranch" == "" ]]; then
      echo;
      echo -e " ${BCya}[SETTING]${RCol} parentBranch to ${BYel}$gitProjectRoot${RCol}"
      parentBranch=$gitProjectRoot
    fi

    # if there are changes stash them
    if [[ "$thereAreChanges" != "" ]]; then
      echo;
      echo -e " ${BCya}[STASH]${RCol} changes"
      git stash
    fi

    if [[ "$currBranch" == "$1" ]]; then
      # check if the branch exists before switching
      git show-ref --verify --quiet refs/heads/$parentBranch
      if [[ "$?" == "1" ]]; then
        echo;
        echo -e " ${BRed}[ERROR]${RCol} The branch assigned to parentBranch:${BYel}$parentBranch${RCol} doesn't exist locally."

        if [[ "$thereAreChanges" != "" ]]; then
          echo -e " ${BCya}[UN-STASH]${RCol} changes"
          git stash apply
        fi

        okToProceed=0
      else
        echo;
        echo -e " ${BRed}[ERROR]${RCol} You're trying to delete a branch you're currently in."
        echo;
        echo -e " ${BCya}[SWITCHING]${RCol} to ${BYel}$parentBranch${RCol} branch for now so ${BYel}$1${RCol} can be deleted."
        git checkout $parentBranch
      fi
    fi

    if [ $okToProceed -eq 1 ]; then
      echo;
      echo -e " ${BCya}[DELETING]${RCol} ${BYel}$1${RCol} from remote origin"
      git push origin --delete --no-verify $1

      echo;
      echo -e " ${BCya}[DELETING]${RCol} ${BYel}$1${RCol} from your local repo"
      git branch -D $1

      if [[ "$thereAreChanges" != "" ]]; then
        echo;
        echo -e " ${BCya}[UN-STASH]${RCol} changes"
        git stash apply
      fi
    fi

  else
    echo;
    echo "usage: git-delete-branch <branch-name>"
    echo "usage: gdb <branch-name>"
  fi
}
alias gdb='git-delete-branch'

##
# There are use cases where you'll be changing versioned files but you never
# want them committed. This allows you to easily add, remove, or list files
# with the assume-unchanged flag.
#
# - mark versioned files as 'assume-unchanged'
# - remove the 'assume-unchanged' flag from a file
# - list files marked as 'assume-unchanged'
function git-assume-unchanged () {
  function gunUsage () {
    echo;
    echo " usage: git-assume-unchanged [-l] [-h] [-r <file>] [-a <file>]"
    echo " usage: gun [-l] [-h] [-r <file>] [-a <file>]"
    echo;
    echo " h  Shows usage and examples"
    echo " l  List all files marked as assume-unchanged"
    echo " a  Add the assume-unchanged flag to a file"
    echo " r  Remove the assume-unchanged flag from a file"
    echo;
  }

  while getopts ":hlr:a:" opt; do
    case $opt in
      h)
        gunUsage
      ;;
      # list all files
      l)
        echo;
        echo -e "${BGre}Files marked as assume-unchanged ${RCol}"
        echo;
        git ls-files -v | grep "^[[:lower:]]"
      ;;
      # will add the 'assume-unchanged' flag to a file
      a)
        echo;
        echo -e "${BCya}[ADDING]${RCol} 'assume-unchanged' flag to $OPTARG"
        echo;
        git update-index --assume-unchanged $OPTARG
      ;;
      # will remove the 'assume-unchanged' flag from a file
      r)
        echo;
        echo -e "${BCya}[REMOVING]${RCol} 'assume-unchanged' flag from $OPTARG"
        echo;
        git update-index --no-assume-unchanged $OPTARG
      ;;
      \?)
        echo -e " ${BRed}[ERROR]${RCol} Invalid option: -$OPTARG" >&2
        gunUsage
      ;;
      :)
        echo -e " ${BRed}[ERROR]${RCol} Option -$OPTARG requires an argument." >&2
        gunUsage
      ;;
    esac
  done

  if [[ "$1" == "" ]]; then
    gunUsage
  fi
}
alias gun='git-assume-unchanged'

##
# A shorthand function to create patches of changes in your current branch
function git-patch () {
  function manual () {
    echo;
    echo "Usage: git-patch <patch-name> [options] [arguments]"
    echo "       gp <patch-name> [options] [arguments]"
    echo "       gp patch_name"
    echo "       gp \"../Some folder/patch_name\""
    echo "       gp patch_name -c 2"
    echo;
    echo "Options:"
    echo "-h, --help                  Displays the manual"
    echo "-c, --commit-count <count>  Create a patch from a number of previous commits"
    echo;
    return 0;
  }

  while [[ "$*" ]]; do
    case $1 in
      "-c"|"--commit-count")
        local commitCount="$2";
        shift 2;
      ;;
      "-h"|"--help")
        manual;
        return 0;
      ;;
      *)
        local fileName="$1";
        shift 1;
      ;;
    esac
  done

  # Throw error if no file name passed.
  if [ -z ${fileName+x} ]; then
    echo;
    echo -e " ${BRed}[ERROR]${RCol} Patch name required";
    return manual;
  else
    local patchName="$fileName.patch"
  fi

  # If no commit number set, check if there are un-staged changes and patch those.
  if [ -z ${commitCount+x} ]; then
    local diff=$(git diff);

    if [[ "$diff" != "" ]]; then
      git diff --no-color > "$patchName"
      echo;
      echo -e " ${BCya}[CREATED]${RCol} $patchName"
    else
      echo;
      echo -e " ${BRed}[ERROR]${RCol} No un-staged changes found, and \`--commit-count\` not specified";
      return 1;
    fi
  else
    [[ "$commitCount" == "1" ]] && s="" || s="s"

    git format-patch HEAD~$commitCount --no-stat --stdout > "$patchName"
    echo;
    echo -e " ${BCya}[CREATED]${RCol} $patchName from $commitCount commit$s"
  fi
}
alias gp='git-patch'

##
# A shorthand function to rename a local and remote branch
function git-rename-branch () {
  if [[ "$1" != "" && "$2" != "" ]]; then
    # Rename branch locally
    git branch -m "$1" "$2"
    # Delete the old branch
    git push --no-verify origin :"$1"
    # Push the new branch, set local branch to track the new remote
    git push --no-verify --set-upstream origin "$2"
  else
    echo;
    echo "usage: git-rename-branch <old-branch-name> <new-branch-name>"
    echo "       grb <old-branch-name> <new-branch-name>"
    echo;
    echo "example: grb tst-branch test-branch"
  fi
}
alias grb='git-rename-branch'

##
# Stop tracking a file or directory that was previously committed
function git-untrack () {
  if [[ "$1" != "" ]]; then
    git rm -r --cached "$1"
  else
    echo;
    echo "usage: git-untrack <folder-or-file>"
    echo "       gut <folder-or-file>"
    echo;
    echo "example: gut path/to/file.txt"
    echo "example: gut path/to/folder/"
  fi
}
alias gut='git-untrack'

##
# View all files staged to be committed
function git-view-staged () {
  git status -uno
}
alias gvs='git-view-staged'

##
# Squash a specified number of commits into one commit
function git-squash () {
  if [[ "$1" != "" ]]; then
    thereAreChanges=$(echo -ne $(git diff --exit-code))

    if [[ "$thereAreChanges" != "" ]]; then
      echo;
      echo -e " ${BCya}[STASH]${RCol} changes"
      echo;

      git stash
    fi

    git rebase -i HEAD~$1

    if [[ "$thereAreChanges" != "" ]]; then
      echo;
      echo -e " ${BCya}[UN-STASH]${RCol} changes"
      git stash apply
    fi

    echo;
    echo "If something went wrong during the squash, just run 'git-undo-squash' or 'gus'"
    echo;
  else
    echo;
    echo "usage: git-squash <number-of-revisions>"
    echo "       gs <number-of-revisions>"
    echo;
    echo "example: gs 2"
    echo;
    echo "Do you want to view the logs?"
    echo " Y / N"
    echo;

    # capture the user's choice
    echo -n ""
    read selectedOption

    if [[ "$selectedOption" == "y" || "$selectedOption" == "Y" ]]; then
      git log --stat --pretty=format:" %C(yellow)%h%C(reset) - %C(cyan)%aN%C(reset) : %s"
    fi
  fi
}
alias gs='git-squash'

##
# Squash a specified number of commits into one commit
function git-undo-squash () {
  echo;
  echo "- Find the HEAD revision ( HEAD{<number>} ) from reflog"
  echo "- Enter 'q' to exit the log"
  echo;
  echo "Do you want to view the reflog?"
  echo " Y / N"
  echo;

  # capture the user's choice
  echo -n ""
  read selectedOption

  if [[ "$selectedOption" == "y" || "$selectedOption" == "Y" ]]; then
    git reflog

    echo;
    echo "Enter in the HEAD revision number or type 'exit'"
    echo;

    # capture the user's choice
    echo -n ""
    read revisionNumber

    if [[ "$revisionNumber" == "exit" ]]; then
      exit 0;
    else
      git reset --hard HEAD@{$revisionNumber}
    fi
  fi
}
alias gus='git-undo-squash'

##
# Displays the number of commits for all users or by a specified user
function git-brag () {
  local proceed=true

  function bragUsage () {
    echo;
    echo " usage: git-brag [-h] [-u <user_name>]"
    echo " usage: gb [-h] [-u <user_name>]"
    echo;
    echo " h - Shows usage and examples"
    echo " u - A user's name. This utilizes case insensitive Regular"
    echo "     Expression so you could do something like"
    echo "     \"First, Last|Last, First|first last\" to find all instances"
    echo "     of a user."
    echo;
    proceed=false
  }

  while getopts ":hu:" opt; do
    case $opt in
      h)
        bragUsage
      ;;
      # A user name was supplied, store it and check later
      u)
        userName="$OPTARG"
      ;;
      \?)
        echo;
        echo -e " ${BRed}[ERROR]${RCol} Invalid option: -$OPTARG" >&2
        bragUsage
      ;;
      :)
        echo;
        echo -e " ${BRed}[ERROR]${RCol} Option -$OPTARG requires an argument." >&2
        bragUsage
      ;;
    esac
  done

  if $proceed ; then
    if [[ "$userName" != "" && "$userName" != "%n" ]]; then
      local totalCommits=0

      echo;

      while read line; do
        # This is pretty slow currently and should be refactored
        local ptrnMatch=$(echo "$line" | grep -io "$userName")

        if [[ "$ptrnMatch" != "" ]]; then
          echo " ${BCya}[FOUND]${RCol} $line"
          local count=$(echo "$line" | grep -o "^[0-9]*");
          let "totalCommits += $count"
        fi
      done < <(git shortlog -s -n)

      echo;
      echo " The user matching ${BYel}$userName${RCol} has ${BGre}$totalCommits${RCol} commits"
      echo;
    else
      while read line; do
        echo "$line"
      done < <(git shortlog -s -n)
    fi
  fi
}
alias gb='git-brag'

##
# Adds all modified tracked files, including deleted files.
# If you have new files you'll have to add them separately.
function git-add-modified () {
  git add -u
}
alias gam='git-add-modified'

##
# Removes an added file/folder from staged files
function git-undo-add () {
  if [[ "$1" != "" ]]; then
    echo;
    echo -e " ${BCya}[UN-STAGING]${RCol} ${BYel}$1${RCol}"
    echo;

    git reset HEAD "$1"

  else
    echo;
    echo "usage: git-undo-add <file-or-folder-name>"
    echo "       gua <file-or-folder-name>"
    echo;
    echo "example: gua \"some/path to/a/file.jpg\""
    echo;
  fi
}
alias gua='git-undo-add'

##
# Resets back to where you were before the last commit, keeps what was added.
function git-undo-commit () {
  echo;
  echo -e " ${BCya}[RESETTING]${RCol} last commit"
  echo;

  git reset --soft HEAD~1
}
alias guc='git-undo-commit'

##
# Allows for restoring a previously deleted & committed file.
function git-restore-file () {
  if [[ "$1" != "" ]]; then
    echo;
    echo -e " ${BCya}[RESTORING]${RCol} ${BYel}$1${RCol}"
    echo;

    git checkout $(git rev-list -n 1 HEAD -- "$1")~1 -- "$1"

  else
    echo;
    echo "usage: git-restore-file <full-path-to-file>"
    echo "       grf <full-path-to-file>"
    echo;
    echo "example: grf \"some/path to/a/file.js\""
    echo;
  fi
}
alias grf='git-restore-file'

##
# Resets any file permission changes that were made.
function git-reset-perms () {
  echo;
  echo -e " ${BCya}[RESETTING]${RCol} file permissions"
  echo;

  git diff -p -R --no-color \
    | grep -E "^(diff|(old|new) mode)" --color=never \
    | git apply -v
}
alias grp='git-reset-perms'
