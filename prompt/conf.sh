# == setup history sharing between prompts ==========================
# Where it gets saved
HISTFILE=~/.history
# Remember about a years worth of history (AWESOME)
SAVEHIST=10000
HISTSIZE=10000
# Don't overwrite, append!
setopt APPEND_HISTORY
# Killer: share history between multiple shells
setopt SHARE_HISTORY
# If I type cd and then cd again, only save the last one
setopt HIST_IGNORE_DUPS
# Even if there are commands inbetween commands that are the same, still only save the last one
setopt HIST_IGNORE_ALL_DUPS
# Use this locking method to prevent errors on initial start
setopt HIST_FCNTL_LOCK
# Pretty    Obvious.  Right?
setopt HIST_REDUCE_BLANKS

# https://cygwin.com/cygwin-ug-net/using-cygwinenv.html
# each option is separated by a space
export CYGWIN="nodosfilewarning winsymlinks:nativestrict"
