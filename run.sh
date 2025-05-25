#! /bin/sh
emacs --batch --eval "(require 'org)" --eval "(org-babel-tangle-file \"Install.org\")" && sh install.sh
