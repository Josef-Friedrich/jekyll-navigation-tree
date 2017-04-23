#!/usr/bin/env bats

SITE=test/_site

_test() {
  result=$(xmllint --xpath "$1" "$SITE/$2")
}

@test "File exists: /index.html" {
  [ -f "$SITE/index.html" ]
}

@test "Link text: Folder with an index file" {
  _test 'string(//ul/li[1]/a)' index.html
  [ "$result" = 'Folder with an index file' ]
}

@test "Link text: Deep nested folders" {
  _test 'string(//ul/li[2]/a)' index.html
  [ "$result" = 'Deep nested folders' ]
}

@test "Link text: Level 1" {
  _test 'string(//ul/li/ul/li/a)' index.html
  [ "$result" = 'Level 1' ]
}

@test "Link text: Level 2" {
  _test 'string(//ul/li/ul/li/ul/li/a)' index.html
  [ "$result" = 'Level 2' ]
}

@test "Link text: Level 3" {
  _test 'string(//ul/li/ul/li/ul/li/ul/li/a)' index.html
  [ "$result" = 'Level 3' ]
}

@test "Link text: folder-without-index" {
  _test 'string(//ul/li[3]/div)' index.html
  [ "$result" = 'folder-without-index' ]
}
