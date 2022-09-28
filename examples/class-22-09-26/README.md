# Getting used to the class's flow

## 1) sync regularly
```bash
# first time, or if you've really screwed up
git clone git@github.com:avinash-nonholonomy/olin-cafe-f22.git

# every time you start working
git pull

# for info:
git log # show you what changed, q to quit

# for details on what changed:
git diff ${commit_hash}

# to search:
git grep ${search_string}

```

## 2) look for READMEs
e.g., this document.


## 3) using make
We'll be using an old (but serviceable) tool called `make` to automate what we can in this class. The idea is to abstract away any oddities of the tools we are using so that we can work consistently. Everything starts with a `Makefile` document.

The big thing: it maps targets to actions:
```
target: dependency
  actions
```