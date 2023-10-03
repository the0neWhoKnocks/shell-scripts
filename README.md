# Shell Scripts

I keep my shell scripts within a `sh` directory within my User's home directory.

- [backup.sh](#backupsh)
- [git-editor.sh](#git-editorsh)
- [git-functions.sh](#git-functionssh)
- [override-cd.sh](#override-cdsh)
- [prev-dir.sh](#prev-dirsh)

---


## backup.sh

I use this on my work (OSX) system. It allows me to create backup archives of
specific files or folders.
In your `.*rc` file (`.zshrc`, `.bashrc`, etc), create an alias:
```sh
alias backupuserdata="$HOME/sh/backup.sh .atom .bash_history .bash_sessions .gitconfig .history .npmrc .oh-my-zsh .sh_history .ssh .tmux.conf .viminfo .vimrc .vscode .yarnrc .zsh-update .zsh_history .zshrc sh 'Library/Application Support/Google/Chrome/Default'"
```
In order to extract the password protected file:
```sh
7z x $HOME/Desktop/<FILE_NAME>.zip -o$HOME/Desktop/temp
```


## git-editor.sh

Right now this is set up for Windows, but could be adapted to any OS.

In your global `.gitconfig` file, set the editor entry so it matches what's below.

```sh
[core]
	...
	editor = ~/sh/git-editor.sh
```


## git-functions.sh

- A collection of shorthand functions/alias' that make working with GIT a little
easier.
- One thing that sets these functions apart from others is that it maintains
hierarchy knowledge. By that I mean, if you cut a branch called `child` from
`parent`, `child` knows to rebase from `parent` rather than pulling; and in turn,
`parent` knows to pull rather than rebase since it doesn't have a parent.


**Install**

In your `.*rc` file (`.zshrc`, `.bashrc`, etc), add this line near the top of 
the file.

```sh
source ~/sh/git-functions.sh
```


## override-cd.sh

Overrides the system's `cd` command with one that can execute custom functions once a User enters a directory.

**Install**

In your `.*rc` file (`.zshrc`, `.bashrc`, etc), add this line near the top of 
the file.

```sh
source ~/sh/override-cd.sh
```


## prev-dir.sh

When a Shell starts up, the User is given an option to open the previous directory.

**Install**

In your `.*rc` file (`.zshrc`, `.bashrc`, etc), add this line near the top of 
the file.

```sh
source ~/sh/prev-dir.sh
```
