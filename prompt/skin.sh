###########################################
#                                         #
#  [ Installation ]                       #
#                                         #
#  Add the below line to your .*rc file.  #
#                                         #
#  source ~/sh/prompt/conf.sh             #
#  source ~/sh/prompt/functions.sh        #
#  source ~/sh/prompt/skin.sh             #
#                                         #
###########################################

setopt extended_glob

# show GIT branch if inside GIT repo
source /etc/bash_completion.d/git
source ~/sh/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1

function precmd {
	userType='%#'
	userName='%n'
	currentDir='%1~'
	gitBranch=$(__git_ps1)
  gitBranchStart=''
  gitBranchEnd=''
  dateAndTime=' %w,%t '
  titlebar_xterm=$(print -Pn " %1~ ")
  currDirPath=$(print -Pn " %~ ")

  # extra logic to pretty up the titlebar. Will display the current dir first, then the full path if they're not the same.
  if [[ "$titlebar_xterm" != "$currDirPath" ]]; then
    currDirPath=" ${currDirPath##*'/cygdrive/'}"
    titlebar_xterm="$titlebar_xterm       [$currDirPath]"
  fi

  # add a branch character and the GIT branch name to the prompt
  if [ $gitBranch ]; then
    gitBranchStart="$CHAR_vertBar
$CHAR_rightVertBarBranch$CHAR_horzBar $SWITCH_TO_NORM_CHARS$COL_yellow"
    gitBranchEnd="
" 
  fi

  local TERMWIDTH
  (( TERMWIDTH = ${COLUMNS} - 1 ))


  ###
  # Truncate the path if it's too long.
  
  PR_FILLBAR=""
  PR_PWDLEN=""
  
  local promptsize=${#${(%):---( $userType $userName $currentDir )----($dateAndTime)-}}
  local pwdsize=${#${(%):-}}
  
  if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
      ((PR_PWDLEN=$TERMWIDTH - $promptsize))
  else
   PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..${CHAR_horzBar}.)}"
  fi


  ###
  # Get APM info.

  if which ibam > /dev/null; then
    PR_APM_RESULT=`ibam --percentbattery`
  elif which apm > /dev/null; then
    PR_APM_RESULT=`apm`
  fi
}

function preexec () {
  if [[ "$TERM" == "screen" ]]; then
    local CMD=${1[(wr)^(*=*|sudo|-*)]}
    echo -n "\ek$CMD\e\\"
  fi
}

function setprompt () {
  ###
  # Need this so the prompt will work.

  setopt prompt_subst


  ###
  # See if we can use colors.

  autoload colors zsh/terminfo
  if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
  fi
  for color in black red green yellow blue magenta cyan white; do
    eval COL_$color='%{$fg[${(L)color}]%}'
    (( count = $count + 1 ))
  done
  RESET_TEXT_FLAGS="%{$terminfo[sgr0]%}"
  SWITCH_TO_LIGHT_COLOR="%{$terminfo[bold]%}"


  ###
  # See if we can use extended characters to look nicer.
  
  typeset -A altchar
  set -A altchar ${(s..)terminfo[acsc]}
  SET_charset="%{$terminfo[enacs]%}"
  SWITCH_TO_EXT_CHARS="%{$terminfo[smacs]%}"
  SWITCH_TO_NORM_CHARS="%{$terminfo[rmacs]%}"
  CHAR_horzBar=${altchar[q]:--}
  CHAR_vertBar=${altchar[x]:--}
  CHAR_upperLeftCorner=${altchar[l]:--}
  CHAR_leftLeftCorner=${altchar[m]:--}
  CHAR_leftRightCorner=${altchar[j]:--}
  CHAR_upperRightCorner=${altchar[j]:--}
  CHAR_leftVertBarBranch=${altchar[u]:--}
  CHAR_rightVertBarBranch=${altchar[t]:--}
  CHAR_diamond=${altchar[\`]:--}
  charMap=${altchar[@]:--}
  extendedChars=$(echo -e $SWITCH_TO_EXT_CHARS$charMap; echo -e $SWITCH_TO_NORM_CHARS\n$charMap)

  
  ###
  # Decide if we need to set titlebar text.
  
  case $TERM in
    xterm*)
      SET_titleBar=$'%{\e]0;%(!.-=*[ROOT]*=- | .)$titlebar_xterm \a%}'
    ;;
    screen)
      SET_titleBar=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)$titlebar_xterm \e\\%}'
    ;;
    *)
      SET_titleBar=''
    ;;
  esac
  
  
  ###
  # Decide whether to set a screen title
  if [[ "$TERM" == "screen" ]]; then
    SET_screenTitle=$'%{\ekzsh\e\\%}'
  else
    SET_screenTitle=''
  fi
  
  
  ###
  # APM detection
  
  if which ibam > /dev/null; then
    PR_APM='$COL_red${${PR_APM_RESULT[(f)1]}[(w)-2]}%%(${${PR_APM_RESULT[(f)3]}[(w)-1]})$PR_LIGHT_BLUE:'
  elif which apm > /dev/null; then
    PR_APM='$COL_red${PR_APM_RESULT[(w)5,(w)6]/\% /%%}$PR_LIGHT_BLUE:'
  else
    PR_APM=''
  fi

  ###
  # Finally, the prompt.

  PROMPT='
$SET_charset$SET_screenTitle${(e)SET_titleBar}\
$SWITCH_TO_LIGHT_COLOR$COL_red$SWITCH_TO_EXT_CHARS$CHAR_upperLeftCorner$COL_red$CHAR_horzBar$CHAR_leftVertBarBranch$SWITCH_TO_NORM_CHARS $COL_green$userType $COL_cyan$userName $COL_black$currentDir$COL_red $SWITCH_TO_EXT_CHARS$CHAR_rightVertBarBranch$CHAR_horzBar$COL_red$CHAR_horzBar${(e)PR_FILLBAR}$COL_red$CHAR_horzBar$CHAR_horzBar$COL_red$CHAR_horzBar$SWITCH_TO_NORM_CHARS($COL_black$dateAndTime$COL_red)$SWITCH_TO_EXT_CHARS$CHAR_horzBar\
$gitBranchStart$SWITCH_TO_NORM_CHARS$gitBranch$gitBranchEnd\
$SWITCH_TO_EXT_CHARS$COL_red$CHAR_vertBar
$CHAR_leftLeftCorner$COL_red$CHAR_horzBar$CHAR_horzBar$CHAR_horzBar$CHAR_diamond$SWITCH_TO_NORM_CHARS$RESET_TEXT_FLAGS '

  RPROMPT=''
  #RPROMPT=' $COL_red$SWITCH_TO_EXT_CHARS$CHAR_horzBar$PR_BLUE$CHAR_horzBar$SWITCH_TO_NORM_CHARS($COL_yellow%D{%a,%b%d}$PR_BLUE)$SWITCH_TO_EXT_CHARS$CHAR_horzBar$COL_cyan$CHAR_leftRightCorner$SWITCH_TO_NORM_CHARS$RESET_TEXT_FLAGS'

  PS2='    $SWITCH_TO_LIGHT_COLOR$COL_red$SWITCH_TO_EXT_CHARS$CHAR_rightVertBarBranch$CHAR_horzBar$SWITCH_TO_NORM_CHARS %_ $SWITCH_TO_EXT_CHARS$CHAR_horzBar$CHAR_diamond$SWITCH_TO_NORM_CHARS$RESET_TEXT_FLAGS '
}

function showStartMessage {
  clear

  echo '       _____      ______    ______ ___      ___'
	echo '      / __  \   / ___   /\/ ___   /   A   /   /A'
	echo '     / /WWW /A / /WWW  /W/ /WWW  /    \YV    /W/'
	echo '    / ____  \W/ /WWW  /W/ /WWW  /           /W/'
	echo '   / /WWWWW  / /WWW  /W/ /WWW  /  /A   A   /W/'
	echo '  /_________/_______/W/______ /__/WWWWW/__/W/'
	echo '  \WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW^WW^WWWWW/    *  *'
	echo '                                              *  \/  *'
	echo '-------------------------------------------------  -- '
	echo '                                              *  /\  *'
	echo '                                                *  *'
	echo;
}

# init custom prompt
showStartMessage
setprompt
