#!/bin/bash
git add .
git commit -m "update"
git pull origin doc --rebase
git push origin doc
hexo clean
hexo deploy --generate
