#! /bin/sh

if [ ! -d ./test/_plugins ]; then
  mkdir ./test/_plugins
fi
cp ./lib/jekyll-navigation-tree.rb ./test/_plugins/

cd test
bundle exec jekyll build
