##################################################################################
#                                                                                #
# [ Installation ]                                                               #
#                                                                                #
# I created a dir in my home dir called `sh` (for shell scripts). With that in   #
# mind, you can add the attached script in the sh dir, and add the below line to #
# your .bashrc or .zshrc file.                                                   #         
#                                                                                #
# source ~/sh/docker.sh                                                          #
#                                                                                #
# In case the below (top 2) vars aren't set in your shell, you'll want to add    #
# them, and then update `PATH` with the toolbox bin. An example within Cygwin    #
# looks like this:                                                               #
# ```                                                                            #
# export VBOX_MSI_INSTALL_PATH="/cygdrive/c/Program Files/Oracle/VirtualBox/"    #
# export DOCKER_TOOLBOX_INSTALL_PATH="/cygdrive/c/Program Files/Docker Toolbox/" #
# export PATH="$PATH:$DOCKER_TOOLBOX_INSTALL_PATH"                               #
# ```                                                                            #
#                                                                                #
#                                                                                #
# [ Usage ]                                                                      #
#                                                                                #
# startDocker                                                                    #
#                                                                                #
##################################################################################

# includes =====================================================================

source $(dirname $0)/colors.sh

# functions ====================================================================

##
# Sets the global vars for Docker
function dockerSetEnvVars () {
  eval $(docker-machine env default --shell /bin/bash);
  echo -e " ${BGre}✓${RCol} Docker globals are now set.";
  echo "   You can test Docker by running \`docker run hello-world\`";
}

##
# Starts the `default` Docker container
function dockerStartDefaultContainer () {
  echo -e "   Starting default Docker (this'll take a few seconds).";
  echo;
  docker-machine start default;
  echo;
  echo -e " ${BGre}✓${RCol} Default Docker has started.";
  dockerSetEnvVars;
}

##
# Installs the `default` Docker container
function dockerInstallDefaultContainer () {
  echo -e "   Installing default Docker.";
  echo;
  
  local currDir=$(dirname $0);
  cd "$DOCKER_TOOLBOX_INSTALL_PATH";
  ./start.sh;
  cd "$currDir";
  startDocker;
}

##
# Starts the `default` Docker container
function startDocker () {
  # sanity check
  if [[ $(which docker-machine | grep "^/") == "" ]]; then
    echo;
    echo -e " ${BRed}✗ Error:${RCol} Tried to start Docker but couldn't find ${BRed}docker-machine${RCol}. Are you sure Docker is installed?";
    return;
  fi
  
  local defaultContainer=$(docker-machine ls -q --filter name=default);
  local isRunning=$(docker-machine ls -q --filter name=default --filter state=running);
  
  # check if `default` docker-machine exists and is up and running
  if [[ "$defaultContainer" != "" ]]; then
    echo;
    echo -e " ${BGre}✓${RCol} Default Docker is defined.";
    
    # isRunning will return the table headers if not running so check that it also
    # doesn't start with `NAME`.
    if [[ "$isRunning" != "" && "$isRunning" != NAME* ]]; then
      echo -e " ${BGre}✓${RCol} Default Docker is running.";
      dockerSetEnvVars;
    else
      echo -e " ${BYel}❗${RCol} Default Docker is not running.";
      dockerStartDefaultContainer;
    fi
  else
    echo;
    echo -e " ${BRed}✗ Error:${RCol} Default Docker is not defined.";
    dockerInstallDefaultContainer;
  fi
}
