public class CalloutHelper {

    public HttpResponse send(String reqMethod, String reqURL, String reqBody, Map<String, String> reqHeaderMap) {
        HttpResponse response = new HttpResponse();
        try{
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod(reqMethod);
            req.setEndpoint(reqURL);

            req.setTimeout(120000);
            if(reqMethod != 'GET' && reqBody != null) {
                req.setBody(reqBody);
            }

            // Request Header
            if(reqHeaderMap != null) {
                for(String headerKey : reqHeaderMap.keySet()) {
                    req.setHeader(headerKey, reqHeaderMap.get(headerKey));
                }
            }

            response = h.send(req);

        } catch(Exception e) {
            Map<String, Object> exceptionMap = new Map<String, Object>();
            exceptionMap.put('cause', e.getCause());
            exceptionMap.put('lineNumber', e.getLineNumber());
            exceptionMap.put('type', e.getTypeName());
            exceptionMap.put('message', e.getMessage());

            response.setStatusCode(500);
            response.setStatus('ApexException');
            response.setBody(JSON.serialize(exceptionMap));
        }
        System.debug('HttpResponse: ' + response);
        return response;
    }

    private HttpResponse sendJSONRequest(String reqMethod, String reqURL, String reqBody, Map<String, String> reqHeaderMap) {
        if(reqHeaderMap == null) {
            reqHeaderMap = new Map<String, String>();
        } 
        reqHeaderMap.put('Content-Type', 'application/json');
        reqHeaderMap.put('Accept', 'application/json');
        return send(reqMethod, reqURL, reqBody, reqHeaderMap);
    }

    public HttpResponse sendAsGET(String reqURL, Map<String, String> reqHeaderMap) {
        return sendJSONRequest('GET', reqURL, null, reqHeaderMap);
    }

    public HttpResponse sendAsPOST(String reqURL, String reqBody, Map<String, String> reqHeaderMap) {
        return sendJSONRequest('POST', reqURL, reqBody, reqHeaderMap);
    }
}