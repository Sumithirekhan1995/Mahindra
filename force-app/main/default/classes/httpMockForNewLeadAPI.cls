@isTest
global class httpMockForNewLeadAPI implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status_code":200,"response":{"data":[{"success":{"id_bike_lead":2348775,"sfdc_lead_id":"00Q1s000001mNNZEA2"}}]}}');
        res.setStatusCode(200);
        return res;
    }

}