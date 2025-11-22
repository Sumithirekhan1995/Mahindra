public class EcomCallout {
    
    public static boolean allowCallout = false;
    
    public class RequestWrapper{
        public String lead_status;
        public String sfdc_lead_id;
        public DateTime followup_date;
        public String followup_comments;
    }

    @future(callout = true)
    public static void ecomLeads(Set<Id> leadIds){
        System.debug('EcomCallout.ecomLeads::');
        String responseStr;
        String requestStr;
        String endPoint;
        Integer httpStatusCode;
        String sfId;
       
        HttpResponse res = new HttpResponse();
        try {
            List<Lead> lea = [Select id, Status__c, LastName,Follow_Up_Date_Time__c,FollowUp_Comments__c from lead where Id IN :leadIds];
            sfId = lea[0].Id;
            
            // creating request body
            RequestWrapper reqWrap = new RequestWrapper();
            reqWrap.lead_status = lea[0].Status__c;
            reqWrap.sfdc_lead_id = lea[0].Id;
            reqWrap.followup_date = lea[0].Follow_Up_Date_Time__c;
            reqWrap.followup_comments = lea[0].FollowUp_Comments__c;
            requestStr = JSON.serialize(reqWrap);
            
            // collecting credentails from 
            CnB_Endpoint__c cnbEndpoint = CnB_Endpoint__c.getAll().values();
            String username = cnbEndpoint.Username__c; 
            String password = cnbEndpoint.Password__c;
            endPoint = cnbEndpoint.BuyerToCnBEndpoint__c;
            // Add basic authentication to header
            // Create blob of user:pass
            Blob headerValue = Blob.valueOf(username + ':' + password);
            // Base 64 Encode the blob and prepend "Basic "
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            // Add the basic auth string to the Request Header
            HttpRequest req = new HttpRequest();
            // Configure standard headers
          
            // This tells the API that we are sending and receiving the data as a JSON object 
            // adding headers
            req.setHeader('Accept', '*/*');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-app-api-key', cnbEndpoint.x_app_api_key__c);
            req.setHeader('x-app-api-secret', cnbEndpoint.x_app_api_secret__c);
            req.setHeader('Authorization', authorizationHeader);
            
            req.setMethod('POST');
            req.setEndpoint(endPoint);
            req.setTimeout(120000);
            req.setBody(requestStr);
            
            http h = new http();
            res = h.send(req);
            httpStatusCode = res.getStatusCode();
            responseStr = res.getBody();
            
            System.debug('Request ' + requestStr);
            System.debug('Response ' + responseStr);
            
        } catch(Exception e) {
            httpStatusCode = 500;
            System.debug('Caught Exception: ' + e);
            String exceptionMsg;
            String statusMsg = 'Failed';
            if(e.getMessage().contains('Read timed out') && e.getTypeName().contains('System.CalloutException')) {
                exceptionMsg = 'SFDC waited for the response from CNB Server for 120 seconds and didn\'t  get the Response.'; 
            } else {
                exceptionMsg = 'EXCEPTION: Type: ' + e.getTypeName() + ', Message: ' +  e.getMessage() + ' at Line: ' + e.getLineNumber();
            }
            responseStr = exceptionMsg;
        } finally {
            List<Api_Log__c> apiLogs = new List<Api_Log__c>();
            String apiLogStatus = httpStatusCode == 200 ? 'Success' : 'Failed';
            apiLogs.add(LogService.createApiLogs(endPoint, requestStr, responseStr, apiLogStatus, 'EcomCnB', sfId, false));
            if(!apiLogs.isEmpty()){
                LogService.createApiLogs(apiLogs);
            }
            LeadTriggerHelper.apiFired = true;
        }
    }
}