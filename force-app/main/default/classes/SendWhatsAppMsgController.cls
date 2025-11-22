public class SendWhatsAppMsgController {    
    
    public Static void getConsent(String phone){
        
        WhatsAppAPI__mdt optInData = WhatsAppAPI__mdt.getInstance('OPT_IN');
        String url;
        if(optInData != null){
            url = optInData.API_Link__c+'?method='+optInData.Method__c+'&format='+optInData.Format__c+'&userid='+optInData.UserId__c+'&password='+optInData.Password__c+'&phone_number='+phone+'&v='+optInData.Version__c+'&auth_scheme='+optInData.Auth_Scheme__c+'&channel='+optInData.Channel__c;
            System.debug('Url=: '+url);
        }else{
            url = 'Test';
        }
        
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        httpReq.setTimeout(20);
        httpReq.setEndpoint(url); 
        httpReq.setMethod('GET');
        httpReq.setHeader('Accept','*/*');
        httpReq.setHeader('Accept-Encoding', 'gzip, deflate, br');
        httpReq.setHeader('Connection', 'keep-alive');
        httpReq.setTimeout(20000);
        try{
            HttpResponse httpRes = http.send( httpReq );
            System.debug('httpReq=: '+httpReq);
            if(httpRes.getStatusCode() == 200) {
                System.debug('Status Code: '+httpRes.getBody());
                
            } else {
                System.debug('The status code returned was not expected: ' + httpRes.getStatusCode() + '===== ' + httpRes.getStatus()+' === '+httpRes);
            } 
            
        } catch (Exception e) {
            
            System.debug('ERROR ===  :: '+e.getMessage()+' :: cause '+e.getStackTraceString());
        }
    }
    
    public static void sendMessageCallout(List<Task> tasks) {
        if(!CheckRecursiveTrigger.runOnceWhatsappMsg()) {
            System.debug('Aleardy made Whatsapp Callout ');
            return;
        }
        
        for(Task task : tasks){
            String phone = task.Phone__c;
            if(String.isEmpty(phone) || phone.length() < 10){
                continue;                
            } else {
                phone = phone.right(10);
            }
            sendMessage(task.Description,phone,task.Id);
        }
    }
    
    @future (callout=true)
    public static void sendMessage(String msg, String phoneNo, Id taskId)
    {
        WhatsAppAPI__mdt messaging = WhatsAppAPI__mdt.getInstance('Messaging');
        /*CRM-1124 Pankaj Kumar 23-03-2023 Start*/
        Boolean flag = false;
        if(msg.contains('We could just play it cool, but that wouldn’t be honest. Truth is, we are THRILLED you chose us while purchasing your dream car.') || 
        	msg.contains('Store. Did you enjoy your experience at the store?')){
            flag = true;
        }
        /*CRM-1124 Pankaj Kumar 23-03-2023 End*/
		String message = EncodingUtil.urlEncode(msg,'UTF-8').replace('+', '%20');
        /*CRM-1124 Pankaj Kumar 23-03-2023 Start*/
        if(flag){
            message += '&isTemplate=true&footer=Type%20STOP%20to%20Opt-Out';
        }
        /*CRM-1124 Pankaj Kumar 23-03-2023 End*/
        String phone = '91'+phoneNo;
        
        getConsent(phone);
        String URL;
        If(messaging != null){
			URL = messaging.API_Link__c+'?userid='+messaging.UserId__c+'&password='+messaging.Password__c+'&method='+messaging.Method__c+'&auth_scheme='+messaging.Auth_Scheme__c+'&v='+messaging.Version__c+'&format='+messaging.Format__c+'&msg_type='+messaging.Msg_Type__c+'&send_to='+phone+'&msg='+message;
		} else {
			URL = 'Test';
            messaging = new WhatsAppAPI__mdt();
            messaging.API_Link__c = 'test';
		}
                
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(URL);
        request.setMethod('POST');    
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
       
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            //System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            API_Log__c log = LogService.createApiLogs(messaging.API_Link__c , messaging.API_Link__c, String.valueOf(response.getBody()), String.valueOf(response.getStatusCode()), 'Gupshup_Callout', taskId, true);
            Task task = new Task(Id=taskId,API_Log__c = log.Id );
            update task;
        } else {
            API_Log__c log = LogService.createApiLogs(messaging.API_Link__c , messaging.API_Link__c, String.valueOf(response.getBody()), String.valueOf(response.getStatusCode()), 'Gupshup_Callout', taskId, true);
            Task task = new Task(Id=taskId,API_Log__c = log.Id );
            update task;
            //System.debug(response.getBody());
        }
        
    }
}