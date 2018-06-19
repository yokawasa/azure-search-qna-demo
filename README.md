# azure-search-qna-demo
Q and A Knowledge Base Search Application Demo using Azure Search

![azure search qna demo screenshot](https://github.com/yokawasa/azure-search-qna-demo/raw/master/img/screenshots.png)

## Index Schema
```
{
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
}
```
 
## Pre-requiste
- Create Azure Search Account (required)
- Create Cosmos DB Account (optional: only for the one who want to configure Cosmos DB indexer)

## Configuration for Data Ingestion
You want to create the Azure Search Index and uploading Sample QnA Data

### 1. Configure scripts/search.conf
```
AZURE_SEARCH_SERVICE_NAME='<Azure Search Service name>'
AZURE_SEARCH_API_VER='2016-09-01'
AZURE_SEARCH_ADMIN_KEY='<Azure Search API Admin Key>'
AZURE_SEARCH_INDEX_NAME='<Azure Search Index Name>'
AZURE_SEARCH_INDEXER_NAME='<Azure Search Indexer Name>'
AZURE_SEARCH_INDEXER_DATASOURCE_NAME='<Azure Search Indexer DataSource Name>'
```

### 2. Create Azure Search Index
```
cd scripts 
create-index.sh
```

### 3. Upload sample data into the index
You wan to upload Sample data, qna-data.json into the index that you just created

```
post-data.sh ../data/qna-data.json
```

## Configuration for Cosmos DB Indexer (Optional)

### 1. Configure scripts/docdb.conf
```
DOCDB_HOST='https://<DocumentDB_Account_Name>.documents.azure.com:443/'
DOCDB_DB='<DocumentDB Database Name>'
DOCDB_COLLECTION='<DocumentDB Collection Name>'
DOCDB_MASTER_KEY='<DocumentDB Master Key>'
```

### 2. Install python sdk for Cosmos DB
```
sudo pip install pydocumentdb
```

### 3. Configure Cosmos DB indexer
Simply run the following setup.sh script, which internaly kicks create-datasource.sh, create-docdb-init-dbcol.sh, create-indexer.sh scripts in order.
```
setup.sh
```

## Configuration for SPA

Open webapp/search.js with your editor and add your Azure Search Account and QueryKey info

```
var AzureSearchQueryApiKey = "<AzureSearchQueryKey>";
var AzureSearchServiceUrl = "https://<AzureSearchServiceName>.search.windows.net"
```


## Test Scripts
- [検索クエリー:GET,Simple,キーワード1](scripts/search-get-simple1.sh)
- [検索クエリー:GET,Simple,キーワード2](scripts/search-get-simple2.sh) 
- [検索クエリー:GET,Lucene,キーワード1](scripts/search-post-simple1.sh) 
- [検索クエリー:GET,Lucene,キーワード2](scripts/search-post-simple2.sh) 
- [検索クエリー:GET,Lucene,フィールドスコープ](scripts/search-post-full-field-scope.sh) 
- [検索クエリー:GET,Lucene,あいまい検索](scripts/search-post-full-fuzzy.sh) 
- [検索クエリー:GET,Lucene,近似検索](scripts/search-post-full-proximiy.sh)
- [検索クエリー:ファセット付き](scripts/search-with-facet.sh)
- [サジェストクエリー][scripts/suggest.sh]