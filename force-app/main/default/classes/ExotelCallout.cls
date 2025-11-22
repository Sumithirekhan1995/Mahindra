public class ExotelCallout {
    public Call call;
    
    //Wrapper class for response
    public Class Call {
        public String Sid;
        public String ParentCallSid;
        public String DateCreated;
        public String DateUpdated;
        public String AccountSid;
        public String To;
        public String PhoneNumberSid;
        public String Status;
        public String StartTime;
        public String EndTime;
        public String Duration;
        public String Price;
        public String Direction;
        public String AnsweredBy;
        public String ForwardedFrom;
        public String CallerName;
        public String Uri;
        public String RecordingUrl;
        
    }
 
    public static void sendExotelInfo(Set<Id> exotelIds){
        //Custom Setting for uname n pass.
        List<ExotelAuthDetails__c> eauth = ExotelAuthDetails__c.getAll().values();
        System.debug('eauth'+eauth);
        //Callout
        String endPoint;
        Exotel_Call_Summary__c ecs = [Select id, name,CallSid__c from Exotel_Call_Summary__c where Id IN :exotelIds LIMIT 1];
        system.debug('ecs'+ecs);
        if(ecs.CallSid__c != NULL){
            endPoint = 'https://api.exotel.com/v1/Accounts/mahindra7/Calls/'+ecs.CallSid__c+'.json';
        }
        
        //httpReq
        Http h = new Http();
        HttpRequest r = new HttpRequest();
        r.setEndpoint(endPoint);
        Blob headerValue = Blob.valueOf(eauth[0].username__c+ ':' + eauth[0].password__c);  
        
        system.debug('headerValue '+headerValue);
                     
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        r.setHeader('Authorization', authorizationHeader);
        r.setMethod('GET');
        r.setTimeout(120000);
        r.setHeader('Content-Type', 'application/json');
        r.setHeader('Accept', 'application/json');
        HTTPResponse resp = h.send(r);
        System.debug('response '+resp);
        System.debug('Response body '+resp.getBody());
        
        //Create api log record to store request and response body
        if(resp.getStatusCode() == 200){
            LogService.createApiLogs(endPoint, null, resp.getBody(), 'Success', 'ExotelCallout');
        }
        else{
            LogService.createApiLogs(endPoint, null, resp.getBody(), 'Failure', 'ExotelCallout');
        }
        
        //Parsing the Response
        Map<String,Object> responseObj = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
        call resCall = new call();
        String data = JSON.serialize(responseObj.get('Call'));
        resCall = (call)JSON.deserialize(data, call.class);
        
        //Mapping the response endtime with the endtime of obj
        List<Exotel_Call_Summary__c> exotelListToUpdate = new List<Exotel_Call_Summary__c>();
        if(resCall.Sid != NULL){
            Exotel_Call_Summary__c e = [Select name, EndTime__c, CallSid__c from Exotel_Call_Summary__c where CallSid__c = :resCall.Sid Limit 1];
            e.EndTime__c = resCall.EndTime;
            exotelListToUpdate.add(e);
        }
        
        //Updating the endtime of exotel rec
        System.debug('exotelListToUpdate '+exotelListToUpdate);
        if(!exotelListToUpdate.isEmpty()){
            update exotelListToUpdate;
        }
    }
}