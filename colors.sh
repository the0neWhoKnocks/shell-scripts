######################################################################
#                                                                    #
# [ Installation ]                                                   #
#                                                                    #
# I created a dir in my home dir called "sh" (for shell scripts).    #
# With that in mind, you can add the attached script in the sh dir,  #
# and add the below line to your .bashrc or .zshrc file.             #
#                                                                    #
# source ~/sh/colors.sh                                              #
#                                                                    #
# Usage:                                                             #
# echo -e "${BCya}Cyan Message${RCol} white text"                    #
#                                                                    #
######################################################################

# Text Reset
EscChar=$(printf '\033')
EscChar="${EscChar}["
RCol="${EscChar}0m"
BoldCol="${EscChar}1m"

# Regular                Bold                        Background                 Bold Backgrounds
Bla="${EscChar}30m";     BBla="${BoldCol}${Bla}";    On_Bla="${EscChar}40m";    On_IBla="${EscChar}100m";
Red="${EscChar}31m";     BRed="${BoldCol}${Red}";    On_Red="${EscChar}41m";    On_IRed="${EscChar}101m";
Gre="${EscChar}32m";     BGre="${BoldCol}${Gre}";    On_Gre="${EscChar}42m";    On_IGre="${EscChar}102m";
Yel="${EscChar}33m";     BYel="${BoldCol}${Yel}";    On_Yel="${EscChar}43m";    On_IYel="${EscChar}103m";
Blu="${EscChar}34m";     BBlu="${BoldCol}${Blu}";    On_Blu="${EscChar}44m";    On_IBlu="${EscChar}104m";
Pur="${EscChar}35m";     BPur="${BoldCol}${Pur}";    On_Pur="${EscChar}45m";    On_IPur="${EscChar}105m";
Cya="${EscChar}36m";     BCya="${BoldCol}${Cya}";    On_Cya="${EscChar}46m";    On_ICya="${EscChar}106m";
Whi="${EscChar}37m";     BWhi="${BoldCol}${Whi}";    On_Whi="${EscChar}47m";    On_IWhi="${EscChar}107m";
