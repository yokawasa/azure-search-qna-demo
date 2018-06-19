#!/bin/sh

cwd=`dirname "$0"`
expr "$0" : "/.*" > /dev/null || cwd=`(cd "$cwd" && pwd)`
. $cwd/search.conf

{
curl -s\
 -H "Content-Type: application/json"\
 -H "api-key: $AZURE_SEARCH_ADMIN_KEY"\
 -XGET "https://$AZURE_SEARCH_SERVICE_NAME.search.windows.net/synonymmaps?api-version=$AZURE_SEARCH_API_VER"
} | python -mjson.tool| perl -Xpne 's/\\u([0-9a-fA-F]{4})/chr(hex($1))/eg'
