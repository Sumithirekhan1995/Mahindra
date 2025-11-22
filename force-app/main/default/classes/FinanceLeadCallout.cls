/*
Written By : Aravindan
*/

public class FinanceLeadCallout {

    
    // 11Oct2021:Sarthak:Start
    public static HttpResponse requestHandler(String requestType,String requestUrl, String requestBody,Integer timeOut){
        System.debug('FinanceLeadCallout.requestHandler ::');
        System.debug('requestType: ' + requestType);
        System.debug('requestUrl: ' + requestUrl);
        System.debug('requestBody: ' + requestBody);
        System.debug('timeOut: ' + timeOut);
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse response = new HttpResponse();
        try{
            req.setMethod(requestType);
            req.setEndpoint(requestUrl);
            req.setTimeout(timeOut);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            if(requestBody != null){
                req.setBody(requestBody);
            }
            if(timeOut!=null){
                req.setTimeout(timeOut);
            }
            response = h.send(req);           
        } catch(Exception e) {
            String exceptionMsg;
            String statusMsg = 'Failed';
            if(e.getMessage().contains('Read timed out') && e.getTypeName().contains('System.CalloutException')) {
                exceptionMsg = 'SFDC Failed at Endpoint[' + requestUrl + ']  for ' + (timeOut / 1000) + ' seconds and didn\'t  get the Response.'; 
            } else {
                exceptionMsg = 'EXCEPTION: Type: ' + e.getTypeName() + ', Message: ' +  e.getMessage() + ' at Line: ' + e.getLineNumber();
            }
            
            response.setStatusCode(500);
            response.setStatus(statusMsg);
            response.setBody(exceptionMsg);
        }
        System.debug('HttpResponse: ' + response);
        return response;
    } 
    // 11Oct2021:Sarthak:End
    
    //23Sep2021:Sarthak:Start added new notify function to send exception
    public static void notifyError(String functionName, String customMsg) {
        try {
            List<String> emailAddress = new List<String>();
            List<Email__c> emails = Email__c.getAll().values();
            for(Email__c e : emails){
                emailAddress.add(e.Person_Email__c);
            }
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = emailAddress;
            message.optOutPolicy = 'FILTER';
            message.subject = 'Function Failed ' + functionName;
            message.plainTextBody = 'The function has failed. Please check it ' + functionName + ' with message : ' + customMsg;
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
            
        } catch(System.EmailException e) {
            String exceptionMsg = 'EXCEPTION: Type: ' + e.getTypeName() + ', Message: ' +  e.getMessage();
            System.debug('Exception While Mailing: ' + exceptionMsg);
        }
        
    }
    //23Sep2021:Sarthak:End
  
}