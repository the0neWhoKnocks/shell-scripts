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
        echo " [STASH] changes"
        git stash
    fi

    if [[ "$1" != "" && "$2" != "" ]]; then
		git pull --rebase $1 $2
	else
        echo;
        echo " [PULLING] from parent \"$parentBranch\""
        git pull --rebase origin "$parentBranch"
	fi

    if [[ "$thereAreChanges" != "" ]]; then
        echo;
        echo " [UN-STASH] changes"
        git stash pop
    fi
}
alias gu='git-update'

##
# Displays a list of modified files and their location path
function git-changes (){
    local esc=$(printf '\033')
    local bold="${esc}[1m"
    local reset="${esc}[0m"
    local red="${bold}${esc}[31m"
    local darkRed="${esc}[31m"
    local cyan="${esc}[36m"
    local gray="${bold}${esc}[30m"
    local changeCount=0
    local modifiedFiles=""
    local modifiedCount=0
    local untrackedFiles=""
    local untrackedCount=0

    while read line; do
        # the status of the file. status is a reserved var
        local stat=$(echo "$line" | egrep -io '^(\w)')
        # the file name
        file=$(echo ${line##*/})
        # the file path
        fp=$(dirname "$line") && fp=$(echo "${fp#* }")

        if [[ "$fp" != "" && "$fp" != "." ]]; then
            fp=" ${gray}($fp)${reset} \n\n"
        else
            file=$(echo ${line#* }) # fix root level filenames
            fp="\n\n"
        fi

        # if the status is set, add a space and proper coloring
        if [ "$stat" != "" ]; then
            # ${red}$stat${reset} 
            modifiedFiles=$(echo "$modifiedFiles${cyan}$file$fp ${gray}")
            modifiedCount=$((modifiedCount+1))
        elif [ "$file" != "" ]; then
            untrackedFiles=$(echo "$untrackedFiles${reset}${darkRed}$file$fp ")
            untrackedCount=$((untrackedCount+1))
        fi

        if [ "$file" != "" ]; then
            changeCount=$((changeCount+1))
        fi

    done < <(git status -s)
    
    echo -e "\n\n";
    echo -e "${gray}████████████████████████████████████████████"
    echo -e "\n Modified Files ${reset}($modifiedCount)${gray} \n"
    echo -e " $modifiedFiles"
    echo -e "------------------------------------------- \n"
    echo -e " Untracked Files ${reset}($untrackedCount)${gray} \n"
    echo -e " $untrackedFiles"
    echo -e "\n                         ${gray}Files Changed ${reset}($changeCount)${gray}"
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
            echo " [ERROR] name: \"$branchName\" doesn't match our current branching model."
            echo;
            echo " Select one of the scheming prefixes below."
            echo;
            echo " (1) bugfix/"
            echo " (2) feature/"
            echo " (3) hotfix/"
            echo " (4) release/"
            echo " (5) I don't want to follow the branching model "
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
        echo " [CREATING] branch: $branchName"
		git checkout -b $branchName
		
		echo;
		echo " [ADDING] '$branchName' to your remote origin"
		git push -u origin $branchName
		
		echo;
		echo " [SETTING] the remote for '$branchName' to origin"
        git config "branch.$branchName.remote" "origin"
        echo " [SETTING] a reference to the parent '$parentBranch'"
		git config "branch.$branchName.parent" "$parentBranch"
	else
		echo " usage: git-new-branch <branch-name>"
	fi
}
alias gab='git-add-branch'

##
# Deletes a user defined git branch locally and removes it from remote
function git-del-branch () {
    if [[ "$1" != "" ]]; then
		local currBranch parentBranch thereAreChanges okToProceed

		currBranch=$(git rev-parse --abbrev-ref HEAD)
		parentBranch=$(git config "branch.$currBranch.parent")
		thereAreChanges=$(echo -ne $(git diff --exit-code))
		okToProceed=1

		# if there isn't a parent branch, use the root branch
		if [[ "$parentBranch" == "" ]]; then
			echo;
			echo " [SETTING] parentBranch to $gitProjectRoot"
			parentBranch=$gitProjectRoot
		fi

		# if there are changes stash them
		if [[ "$thereAreChanges" != "" ]]; then
			echo;
			echo " [STASH] changes"
			git stash
		fi
		
        if [[ "$currBranch" == "$1" ]]; then
            # check if the branch exists before switching
			git show-ref --verify --quiet refs/heads/$parentBranch
			if [[ "$?" == "1" ]]; then
				echo;
				echo " [ERROR] The branch assigned to parentBranch:$parentBranch doesn't exist locally."
				
				if [[ "$thereAreChanges" != "" ]]; then
					echo " [UN-STASH] changes"
					git stash pop
				fi
				
				okToProceed=0
			else
	            echo;
	            echo " You're trying to delete a branch you're currently in."
	            echo " [SWITCHING] to '$parentBranch' branch for now so '$1' can be deleted."
	            git checkout $parentBranch
			fi
        fi
		
		if [ $okToProceed -eq 1 ]; then
			echo;
	        echo " [DELETING] '$1' from remote origin"
			git push origin --delete $1
			
			echo;
			echo " [DELETING] '$1' from your local repo"
			git branch -D $1
			
			if [[ "$thereAreChanges" != "" ]]; then
				echo;
				echo " [UN-STASH] changes"
				git stash pop
			fi
		fi
        
	else
		echo;
        echo "usage: git-del-branch <branch-name>"
	fi
}
alias gdb='git-del-branch'


##
# - mark versioned files as 'assume-unchanged'
# - remove the 'assume-unchanged'
# - list files marked as 'assume-unchanged'
function gun () {
    function gunUsage () {
        echo;
        echo " usage: gun [-l] [-h] [-r <file>] [-a <file>]"
        echo;
        echo " h  Shows usage and examples for gun"
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
                echo "[ Files marked as assume-unchanged ]"
                echo;
                git ls-files -v | grep "^[[:lower:]]"
            ;;
            # will add the 'assume-unchanged' flag to a file
            a)
                echo;
                echo "[ADDING] 'assume-unchanged' flag to $OPTARG"
                echo;
                git update-index --assume-unchanged $OPTARG
            ;;
            # will remove the 'assume-unchanged' flag from a file
            r)
                echo;
                echo "[REMOVING] 'assume-unchanged' flag from $OPTARG"
                echo;
                git update-index --no-assume-unchanged $OPTARG
            ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                gunUsage
            ;;
            :)
                echo "Option -$OPTARG requires an argument." >&2
                gunUsage
            ;;
        esac
    done

    if [[ "$1" == "" ]]; then
        gunUsage
    fi
}
