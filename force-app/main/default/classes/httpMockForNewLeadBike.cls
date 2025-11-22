@isTest
global class httpMockForNewLeadBike implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status_code":200,"response":{"data":[{"success":{"id_bike_lead":2348799,"sfdc_lead_id":"00Q1s000001mNe8EAE"}}]}}');
        res.setStatusCode(200);
        return res;
    }

}