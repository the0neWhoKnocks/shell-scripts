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

## What These Files Do

**git-functions.sh**

- A collection of shorthand functions/alias' that make working with GIT a little
easier.
- One thing that sets these functions apart from others is that it maintains
hierarchy knowledge. By that I mean, if you cut a branch called `child` from
`parent`, `child` knows to rebase from `parent` rather than pulling; and in turn,
`parent` knows to pull rather than rebase since it doesn't have a parent.
