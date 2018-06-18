#!/bin/sh
#
# Create Index
# POST or PUT
#{  
#  "name": (optional on PUT; required on POST) "name_of_index",  
#  "fields": [  
#    {  
#      "name": "name_of_field",  
#      "type": "Edm.String | Collection(Edm.String) | Edm.Int32 | Edm.Int64 | Edm.Double | Edm.Boolean | Edm.DateTimeOffset | Edm.GeographyPoint",  
#      "searchable": true (default where applicable) | false (only Edm.String and Collection(Edm.String) fields can be searchable),  
#      "filterable": true (default) | false,  
#      "sortable": true (default where applicable) | false (Collection(Edm.String) fields cannot be sortable),  
#      "facetable": true (default where applicable) | false (Edm.GeographyPoint fields cannot be facetable),  
#      "key": true | false (default, only Edm.String fields can be keys),  
#      "retrievable": true (default) | false,  
#      "analyzer": "name of the analyzer used for search and indexing", (only if 'searchAnalyzer' and 'indexAnalyzer' are not set)
#      "searchAnalyzer": "name of the search analyzer", (only if 'indexAnalyzer' is set and 'analyzer' is not set)
#      "indexAnalyzer": "name of the indexing analyzer" (only if 'searchAnalyzer' is set and 'analyzer' is not set)
#    }  
# ...
#}

cwd=`dirname "$0"`
expr "$0" : "/.*" > /dev/null || cwd=`(cd "$cwd" && pwd)`
. $cwd/search.conf

curl -s\
 -H "Content-Type: application/json"\
 -H "api-key: $AZURE_SEARCH_ADMIN_KEY"\
 -XPOST "https://$AZURE_SEARCH_SERVICE_NAME.search.windows.net/indexes?api-version=$AZURE_SEARCH_API_VER" \
 -d'{
    "name": "qna",
    "fields": [
        { "name":"id", "type":"Edm.String", "key":true, "retrievable":true, "searchable":false, "filterable":false, "sortable":false, "facetable":false },
        { "name":"question", "type":"Edm.String", "retrievable":true, "searchable":true, "filterable":false, "sortable":false, "facetable":false,"analyzer":"ja.lucene"},
        { "name":"answer", "type":"Edm.String", "retrievable":true, "searchable":true, "filterable":false, "sortable":false, "facetable":false,"analyzer":"ja.lucene"},
        { "name":"category", "type":"Edm.String", "retrievable":true, "searchable":false, "filterable":true, "sortable":true, "facetable":true }
     ],
     "suggesters": [
        { "name":"questionsg", "searchMode":"analyzingInfixMatching", "sourceFields":["question"] }
     ],
     "scoringProfiles": [
         {
            "name": "weightedFields",
            "text": {
                "weights": {
                    "question": 9,
                    "answer": 1
                }
            }
        }
     ],
     "corsOptions": {
        "allowedOrigins": ["*"],
        "maxAgeInSeconds": 300
    }
}'
