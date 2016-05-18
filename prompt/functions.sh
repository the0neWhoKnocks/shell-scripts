function clear {
	echo -e '\0033\0143'
}

# This is useful in changing the prompt title only while a command is running.
# For example if you're running some sort of daemon then you can see what
# process is running just by looking at the prompt's title.
function set-prompt-title {
	local title

	if [ "$1" != "" ]; then
		case $TERM in
		xterm*)
		    title=$'%{\e]0;%(!.-=*[ROOT]*=- | .)$1 \a%}'
		    ;;
		screen)
		    title=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)$1 \e\\%}'
		    ;;
		*)
		    title=''
		    ;;
	    esac

	    print -Pn "$title"
	else
		echo " usage: set-prompt-title \"prompt title\""
	fi
}

##
# This file echoes a bunch of color codes to the 
# terminal to demonstrate what's available.  Each 
# line is the color code of one forground color,
# out of 17 (default + 16 escapes), followed by a 
# test use of that color on all nine background 
# colors (default + 8 escapes).
function col-palette {
	local T='gYw'   # The test text

	echo -e "\n                 40m     41m     42m     43m\
		 44m     45m     46m     47m";

	for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
			   '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
			   '  36m' '1;36m' '  37m' '1;37m';
	  do FG=${FGs// /}
	  echo -en " $FGs \033[$FG  $T  "
	  for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
		do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
	  done
	  echo;
	done
	echo
}

# == SET alias' =================================================
alias gen-ssh='ssh-keygen -t rsa -C'
alias get-ssh='clip < ~/.ssh/id_rsa.pub'
alias open='explorer .'
