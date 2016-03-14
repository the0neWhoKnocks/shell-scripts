## Installation

I keep my shell scripts within a `sh` directory within my user's home directory.


**git-functions.sh**

In your `.*rc` file (`.zshrc`, `.bashrc`, etc), add this line near the top of 
the file.

```
source ~/sh/git-functions.sh
```

**git-editor.sh**

Right now this is set up for Windows, but could be adapted to any OS.

In your global `.gitconfig` file, set the editor entry so it matches what's below.

```
[core]
	...
	editor = ~/sh/git-editor.sh
```
