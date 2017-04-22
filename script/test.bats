#!/usr/bin/env bats

SITE=test/_site

@test "File exists: /index.html" {
  [ -f "$SITE/index.html" ]
}

@test "Level 1" {
  result=$(xmllint --xpath "string(//ul/li/ul/li/a)" "$SITE/index.html")
  [ "$result" = 'Level 1' ]
}

@test "Level 2" {
  result=$(xmllint --xpath "string(//ul/li/ul/li/ul/li/a)" "$SITE/index.html")
  [ "$result" = 'Level 2' ]
}

@test "Level 3" {
  result=$(xmllint --xpath "string(//ul/li/ul/li/ul/li/ul/li/a)" "$SITE/index.html")
  [ "$result" = 'Level 3' ]
}
