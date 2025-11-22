@isTest
global class httpMockForStatusChange implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "marketing_status" : 1, "id_car_lead": 13255, "sfdc_lead_id": "00Q1s000001RtqNEAS", "leads": [ { "id_car_model": 1113, "marketing_status": 2, "sfdc_lead_id": "00Q1s000001RqPSNew" }, { "id_car_model": 1117, "marketing_status": 2, "sfdc_lead_id": "00Q1s000001RqPNew1" } ] }');
        res.setStatusCode(200);
        return res;
    }

}