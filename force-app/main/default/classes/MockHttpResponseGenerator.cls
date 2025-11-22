@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
      //  System.assertEquals('http://example.com/example/test', req.getEndpoint());
     	System.assertEquals('POST', req.getMethod());
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":[{"message":"lead Created","status_code":200,"id":"147310","leadsDispatch_id":"95365","sfdc_lead_id":"00Q1s0000011t3fEAA","target_id":"485","sfdc_lead_dispatch_id":"a0E1s000000UufCEAS"}]}');
        //res.setBody('{"status":"success","status_code":200,"access_token":"Rpivk1iD6NVfHi1bmFZsI3r0CAogx1nzAvTzyHj","expires_at":"2020-05-28 20:30:43"}');
        res.setStatusCode(200);
        return res;
    }
}