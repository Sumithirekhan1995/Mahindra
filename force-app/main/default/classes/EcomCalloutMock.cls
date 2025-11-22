@isTest

public class EcomCalloutMock implements HttpCalloutMock {
    
    public HttpResponse respond(HttpRequest req) {
        String json = '{"success": [{"message": "lead Created","status_code": 200,"id": "147948","leadsDispatch_id": "95945","sfdc_lead_id": "1003","target_id": "1","sfdc_lead_dispatch_id": "12348"}],"error": [{"message": "lead Created","status_code": 200,"id": "147948","leadsDispatch_id": "95945","sfdc_lead_id": "103","target_id": "1","sfdc_lead_dispatch_id": "12348"}]}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Token', 'value');
        res.setBody(json);
        res.setStatusCode(200);
        return res;    
    } 
}