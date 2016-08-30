#!/bin/sh
echo  "请输入描述信息：" 
read des
git add .
git commit -am $des
git push -u origin develop
hexo clean && hexo g && hexo d
