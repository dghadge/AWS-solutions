#!/bin/bash

## Adjust the parameters below to suite your local environment ##

export PYTHONUSERBASE=$HOME/.python
export PATH=$PATH:$HOME/.python/bin
export PROJ_BASE=`pwd`
sudo pip install --editable app/.
