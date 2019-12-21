#!/bin/bash

try() {
  touch tmp.txt
  expectCode="${1}"
  method="${2}"
  url="${3}"

  ./perl-client/httptalker.pl ${method} ${url} >tmp.txt

  actualCode="${?}"

  rm tmp.txt

  if [ ${actualCode} = ${expectCode} ]; then
    echo "OK : ${method} ${url}"
  else
    echo "ER : ${method} ${url}"
    echo "expect: ${expectCode}, but receive ${actualCode}."
    exit 1
  fi
}

try 0 -GET http://www.google.com/search?g=a
try 0 -GET http://www.google.com
try 0 -HEAD http://www.google.com
