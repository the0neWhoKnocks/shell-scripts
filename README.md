###Installation

In your .*rc file (.zshrc, .bashrc, etc), add this line near the top of the file.

```
source ~/sh/git-functions.sh
```

I have my shell scripts within a `sh` directory within my user's home directory.

###Important

For `git-functions.sh`

* In order for `git-update` / `gu` to function propertly it expects a parent
branch to be specified. This is done automatically if you've used
`git-add-branch` / `gab`. If you want to start using the scripts with an existing
branch you can edit your `.git/config` file and add the parent listing to a branch
like so.

```
[branch "bugfix/branchName"]
  remote = origin
  merge = refs/heads/bugfix/branchName
  parent = release/branchName
```