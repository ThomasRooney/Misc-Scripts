find . | grep "\.mp3" | sed -e "s:./:\":g" | sed -e "s/$/\"/g" | unsort | cat | xargs -n 1 mpg123
