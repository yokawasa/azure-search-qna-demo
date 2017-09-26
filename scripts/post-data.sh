#!/bin/sh

if [ $# -ne 1 ]
then
    echo "Usage: $0 <json.file>"
    exit 1;
fi

cwd=`dirname "$0"`
expr "$0" : "/.*" > /dev/null || cwd=`(cd "$cwd" && pwd)`
. $cwd/azure.conf

curl -H "Content-Type: application/json" \
     -H "api-key: $AZURE_SEARCH_ADMIN_KEY" \
     -XPOST "https://$AZURE_SEARCH_SERVICE_NAME.search.windows.net/indexes/qna/docs/index?api-version=2016-09-01" \
     -d "`cat $1`"
