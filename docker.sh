######################################################################
#                                                                    #
# [ Installation ]                                                   #
#                                                                    #
# I created a dir in my home dir called "sh" (for shell scripts).    #
# With that in mind, you can add the attached script in the sh dir,  #
# and add the below line to your .bashrc or .zshrc file.             #
#                                                                    #
# source ~/sh/docker.sh                                              #
#                                                                    #
# Important - Make sure Docker is installed before trying to         #
# source/run this file.                                              #
#                                                                    #
######################################################################

# includes =====================================================================

source $(dirname $0)/colors.sh

# vars =========================================================================

defaultContainer=$(docker-machine ls -q --filter name=default);
isRunning=$(docker-machine ls -q --filter name=default --filter state=running);

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


# logic ========================================================================

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
    echo -e " ${BRed}✗${RCol} Default Docker is not running.";
    dockerStartDefaultContainer;
  fi
else
  echo;
  echo -e " ${BRed}✗${RCol} Default Docker is not defined.";
  echo "   Try running <DOCKER_TOOLBOX>/start.sh to kick off the creation of the default container";
fi
