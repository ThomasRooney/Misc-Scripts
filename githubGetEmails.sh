#!/usr/bin/env bash
(

if ! which -s jq
then
  echo "Please install jq"
  return
fi

listEmails() {
  usage()
  {
      if [ -n "$1" ]; then echo $1; fi
      echo "Usage: listEmails <github user>"
      return
  }

  if [[ $# -lt 1 ]]; then
    usage
    return
  fi

  GITHUB_USER_URL=https://api.github.com/users/$1/repos?per_page=1000

  # echo "Hitting $GITHUB_USER_URL"

  RESPONSE=$(cacheCurlGH $GITHUB_USER_URL)
  if [ $? -gt 0 ]; then echo "Failed to capture $URL: $RESPONSE"; return; fi

  REPOS=$(echo $RESPONSE| jq '.[] | .commits_url' | tr -d '"' | sed 's/{\/sha}//g')

  declare -A seen
  IFS=$'\n'

  printf '%s\n' "$REPOS" | while read -r line
  do
    # echo " -- Hitting $line"
    RESPONSE=$(cacheCurlGH $line)
    if [ $? -gt 0 ]; then echo "Failed to capture $URL: $RESPONSE"; return; fi
    list=$(echo $RESPONSE | jq '.[] | .commit.author | .name+" :: "+.email')
    for email in $list
    do
      if [ ! "${seen[$email]}" ]
      then
        seen[$email]=$email
        echo $email
      fi
    done
  done
}

cacheCurlGH() {
  usage()
  {
      if [ -n "$1" ]; then echo $1; fi
      echo "Usage: cacheCurl <URL>"
      return
  }

  if [[ $# -lt 1 ]]; then
      usage
      return
  fi

  local CACHE_DIR=/tmp/curlcache

  mkdir -p $CACHE_DIR

  local cacheFile=$(echo $* | sed -E 's/^((https?|ftp)):\/\///' | sed 's/\//__/g' | xargs -I {} echo $CACHE_DIR/{}.html)

  if [[ -f $cacheFile ]]; then
    cat $cacheFile
    return
  fi

  if [ -n ${GITHUB_USERNAME} ] || [ -n ${GITHUB_PERSONALACCESSTOKEN} ]; then
    curl -u $GITHUB_USERNAME:$GITHUB_PERSONALACCESSTOKEN $* -s > $cacheFile
  else
    curl $* -s > $cacheFile
  fi

  cat $cacheFile
}

listEmails $1
)
