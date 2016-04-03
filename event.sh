#!/bin/bash
cmd="~/.rbenv/shims/ruby ~/Dropbox/workspace/mika4-heroku-operation/operation.rb -w $1 -a $2 -c $3"
eval ${cmd}
