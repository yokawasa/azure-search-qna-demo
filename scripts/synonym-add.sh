#!/bin/sh

cwd=`dirname "$0"`
expr "$0" : "/.*" > /dev/null || cwd=`(cd "$cwd" && pwd)`
. $cwd/search.conf

{
curl -s\
 -H "Content-Type: application/json"\
 -H "api-key: $AZURE_SEARCH_ADMIN_KEY"\
 -XPOST "https://$AZURE_SEARCH_SERVICE_NAME.search.windows.net/synonymmaps/?api-version=$AZURE_SEARCH_API_VER" \
 -d'{
   "name":"mysynonymmap",
   "format":"solr",
   "synonyms": "
      chair, armchair, rocker, recliner
      MS, MSKK, MSJAPAN, microsoft
      Washington, Wash., WA => WA
      pet => cat, dog, puppy, kitten, pet"
}'
} | python -mjson.tool| perl -Xpne 's/\\u([0-9a-fA-F]{4})/chr(hex($1))/eg'
