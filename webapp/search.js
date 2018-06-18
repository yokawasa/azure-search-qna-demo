var AzureSearchQueryApiKey = "<AzureSearchQueryKey>";
var AzureSearchServiceUrl = "https://<AzureSearchServiceName>.search.windows.net"

// Instantiate the Bloodhound suggestion engine
var sessions = new Bloodhound({
    datumTokenizer: function (datum) {
        return Bloodhound.tokenizers.whitespace(datum.value);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
        url: AzureSearchServiceUrl
          + "/indexes/qna/docs/suggest?api-version=2017-11-11"
          + "&suggesterName=questionsg&$select=question&$top=10&fuzzy=true&search=%q",
        filter: function (qnas) {
            // Map the remote source JSON array to a JavaScript object array
            return $.map(qnas.value, function (qna) {
                return {
                    value: qna.question
                };
            });
        },
        prepare: function(query, settings) {
            settings.contentType = 'application/json; charset=UTF-8';
            settings.headers = {
                "api-key": AzureSearchQueryApiKey
            };
            settings.url = settings.url.replace('%q', query);
            return settings;
        }
    }
});

// Initialize the Bloodhound suggestion engine
sessions.initialize();
// Instantiate the Typeahead UI
$('.input-group .form-control').typeahead({
    hint: false,
    highlight: true,
    minLength: 1
}, {
    displayKey: 'value',
    source: sessions.ttAdapter(),
    limit : 9,
});


function execSearch(category_name)
{
	var searchAPI = AzureSearchServiceUrl
                 + "/indexes/qna/docs?api-version=2017-11-11"
                 + "&$top=50&$select=id,question,answer,category&$count=true&highlight=question,answer"
                 + "&facet=category,count:10"
                 + "&searchMode=any&queryType=full"
                 + "&search=" + encodeURIComponent($("#q").val() + '~1' );
    if ( typeof category_name !== "undefined" ) {
        searchAPI += "&$filter=" + encodeURIComponent("category eq '" + category_name + "'");
    }
    $.ajax({
        url: searchAPI,
        beforeSend: function (request) {
            request.setRequestHeader("api-key", AzureSearchQueryApiKey);
            request.setRequestHeader("Content-Type", "application/json");
            request.setRequestHeader("Accept", "application/json");
        },
        type: "GET",
        success: function (data) {

            $( "#category" ).html('');
            $( "#category" ).append('Categories');
            
            // Render facets
            $( "#facetContainer" ).html('');
            $( "#facetContainer" ).append('<ul class="list-group">');
            var facets = data['@search.facets'].category;
            for (var item in facets) 
            {
                
                var catcount = facets[item].count;   
                var catname= facets[item].value;   
                $( "#facetContainer" ).append(
                        '<li class="list-group-item"><a href="javascript:void(0)" onclick="execSearch(\'' + catname + '\');">'
                          + catname + '</a> (<font color=blue>' + catcount + '</font>)</li>');
            }
            $( "#facetContainer" ).append('</ul>');
            // Render search result hits #
            $( "#resulthits" ).html('');
            $( "#resulthits" ).append( 'Search Results ( hits: ' + data['@odata.count'] + ' )');
            // Render search result items
            $( "#qnaItemsContainer" ).html('');
            $( "#qnaItemsContainer" ).append('<ul class="list-group">');
            for (var item in data.value)
            {
                var id = data.value[item].id;
                var queryType = ''
                question = data.value[item]['@search.highlights'].question;
                if (typeof question === "undefined") {
                    question = data.value[item].question;
                }
                var answer = ''
                answer = data.value[item]['@search.highlights'].answer;
                if (typeof answer === "undefined") {
                    answer = data.value[item].answer;
                }
                var score = data.value[item]['@search.score'];
                $( "#qnaItemsContainer" ).append(
                        '<li class="list-group-item">'
                        + '<b><h4>' +  question + '</h4></b></br>'
                        + answer
                        + '</br>(Score: <font color=red>'+ score +'</font>)</li>' );
            }
            $( "#qnaItemsContainer" ).append('</ul>');
        }
    });
}



