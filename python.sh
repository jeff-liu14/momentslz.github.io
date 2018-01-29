#!/bin/sh
git add .
git commit -am "Update pages."
git push -u origin develop
hexo clean && hexo g && hexo d
