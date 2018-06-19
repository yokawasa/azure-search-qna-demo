#!/bin/sh

cwd=`dirname "$0"`
expr "$0" : "/.*" > /dev/null || cwd=`(cd "$cwd" && pwd)`
. $cwd/search.conf

KEYWORD="Azure"

{
curl -s\
 -H "Content-Type: application/json"\
 -H "api-key: $AZURE_SEARCH_ADMIN_KEY"\
 -XGET "https://$AZURE_SEARCH_SERVICE_NAME.search.windows.net/indexes/$AZURE_SEARCH_INDEX_NAME/docs/suggest?api-version=$AZURE_SEARCH_API_VER"\
"&suggesterName=questionsg"\
"&\$select=question"\
"&\$top=5"\
"&fuzzy=true"\
"&search=$KEYWORD"
} | python -mjson.tool| perl -Xpne 's/\\u([0-9a-fA-F]{4})/chr(hex($1))/eg'
