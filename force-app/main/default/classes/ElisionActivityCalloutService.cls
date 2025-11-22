public class ElisionActivityCalloutService {
    
    private List<Task> tRecArr;
    private Map<Id, Opportunity> oRecMap;
    private Map<Id, Lead> lRecMap;
    private Map<Id, TaskWrap> tRecIdWrapMap;
    private Map<Id, Id> tRecIdApiLogIdMap;
    
    // constructor : get records
    public ElisionActivityCalloutService(Set<Id> tRecIdArr) {
        tRecArr = new List<Task>();
        oRecMap = new Map<Id, Opportunity>();
        lRecMap = new Map<Id, Lead>();
        tRecIdWrapMap = new Map<Id, TaskWrap>();
        tRecIdApiLogIdMap = new Map<Id, Id>();
        
        // querying Task records
        List<Task> tRecArr = Database.query('SELECT Id, WhatId, WhoId, Campaign_Id__c, CallBack_Time__c, Elison_CallBack_Time__c FROM Task WHERE Id IN :tRecIdArr');
        if(!tRecArr.isEmpty()) {
            this.tRecArr = tRecArr;
            
            // Opportunity Id Arr
            Set<Id> oRecIdArr = new Set<Id>();
            Set<Id> lRecIdArr = new Set<Id>();
            for(Task tRec : tRecArr) {
                if(tRec.WhatId != null && String.valueOf(tRec.WhatId).startsWith('006')) {
                    oRecIdArr.add(tRec.WhatId);
                }
                else if(tRec.WhoId != null && String.valueOf(tRec.whoId).startsWith('00Q')) {
                    lRecIdArr.add(tRec.WhoId);
                }
            }
            
            // querying Opportunity Records
            if(!oRecIdArr.isEmpty()) {
                for(Opportunity oRec : Database.query('SELECT Id, Name, Customer_Phone__c  FROM Opportunity WHERE Id IN :oRecIdArr')){
                    this.oRecMap.put(oRec.Id, oRec);
                }
            }

            if(!lRecIdArr.isEmpty()) {
                for(Lead lRec : Database.query('SELECT Id, FirstName, LastName, Phone  FROM Lead WHERE Id IN :lRecIdArr')){
                    this.lRecMap.put(lRec.Id, lrec);
                }
            }
        }
    }
    
    // without future
    public static void init(Set<Id> tRecIdArr) {
        ElisionActivityCalloutService eACSObj = new ElisionActivityCalloutService(tRecIdArr);
        eACSObj.start();
    }  
    
    // with future 
    public static void initFuture(Set<Id> tRecIdArr) {
        if(System.isFuture() || System.isBatch()) {
            return;
        }
        
        //Make chunks of 60-80 
        Set<Id> chunksIdArr = new Set<Id>();
        Integer LIMIT_CHUNK = 50;
        for(ID recId : tRecIdArr) {
            chunksIdArr.add(recId);
            if(chunksIdArr.size() >= LIMIT_CHUNK) {
                startFuture(new Set<Id>(chunksIdArr));
                chunksIdArr.clear();
            }
        }
        if(!chunksIdArr.isEmpty()) {
            startFuture(new Set<Id>(chunksIdArr));
            chunksIdArr.clear();
        }
        
    }
    // future method
    @future(Callout=true)
    private static void startFuture(Set<Id> tRecIdArr) {
        ElisionActivityCalloutService eACSObj = new ElisionActivityCalloutService(tRecIdArr);
        eACSObj.start();
    }
    
    // start method
    private void start() {
        // if no records found
        if(tRecArr.isEmpty()) {
            System.debug('No Task Records found');
            return;
        }
        if(oRecMap.isEmpty() && lRecMap.isEmpty() ) {
            System.debug('No Records found');
            return;
        }
        
        // prepare request body
        constructRequestBody();
        if(tRecIdWrapMap.isEmpty()) {
            System.debug('No Request Body Wraps');
            return;
        }
        
        //Shubham: Start: CRM-1174
        //Retry mechanism for Elision callout
        
        Map<Id, Api_Log__c> apiLogMap = new Map<Id, Api_Log__c>();
        
        List<Task> tas = [Select Id, API_log__c, API_log__r.Failed_Retry_Count__c from Task Where Id =: tRecIdWrapMap.keySet()];
        
        Map<String , Integer> countMap = new Map<String , Integer>();
        for(Task t : tas) {
            Integer count;
            if(t.API_Log__c == null) continue;
            
            if(t.API_log__r.Failed_Retry_Count__c == null) {
                count = 0;
            } else {
                count = Integer.valueOf(t.API_log__r.Failed_Retry_Count__c);
            }
            countMap.put(t.Id, count);
        }
        
        // make Callout
        for(String recId : tRecIdWrapMap.keySet()) {
            Integer newCount;
            if(countMap.containsKey(recId)) {
                newCount = countMap.get(recId) + 1; 
            } else {
                newCount = 0;
            }
            
            Api_Log__c apiLog = makeCallout(JSON.serialize(new List<TaskWrap>{tRecIdWrapMap.get(recId)}));
            apiLog.Failed_Retry_Count__c = newCount;
            
            apiLogMap.put(recId, apiLog);
        }
        
        //Shubham: End: CRM-1174
        
        // API Log
        if(apiLogMap.isEmpty()) {
            return;
        }
        insert apiLogMap.values();
        // Task update
        List<Task> tRecToUpdateArr = new List<Task>();
        
        for(Id tRecId : apiLogMap.keySet()) {
            tRecIdApiLogIdMap.put(tRecId, apiLogMap.get(tRecId).Id);
            Task tRecNew = new Task(
                Id = tRecId
            );
            tRecNew.API_Log__c = apiLogMap.get(tRecId).Id;
            
            
            tRecToUpdateArr.add(tRecNew);
        }
        
        if(!tRecToUpdateArr.isEmpty()) {
            Database.update(tRecToUpdateArr, false);
        }
    }
    
    // prepare request body
    private void constructRequestBody() {
        tRecIdWrapMap = new Map<Id, TaskWrap>();
        for(Task tRec : tRecArr) {
            Opportunity oRec;
            Lead lRec;
            TaskWrap tWrapObj;
            if(oRecMap.containsKey(tRec.WhatId))
            {
                oRec = oRecMap.get(tRec.WhatId);
                tWrapObj = new TaskWrap(oRec.Name, oRec.Name, oRec.Customer_Phone__c, tRec.Campaign_Id__c, tRec.Id, tRec.CallBack_Time__c,String.valueOf(tRec.Elison_CallBack_Time__c));
            }
            if(lRecMap.containsKey(tRec.WhoId))
            {
                lRec = lRecMap.get(tRec.WhoId);
                tWrapObj = new TaskWrap(lRec.FirstName, lRec.LastName, lRec.Phone, tRec.Campaign_Id__c, tRec.Id, tRec.CallBack_Time__c,String.valueOf(tRec.Elison_CallBack_Time__c));
            }
             
             
            
            tRecIdWrapMap.put(tRec.Id, tWrapObj);
        }
    }
    
    // make callout
    private Api_Log__c makeCallout(String reqBody) { 
        System.debug('reqBody : ' + reqBody);
        
        String encodedBody = EncodingUtil.urlEncode(reqBody, 'UTF-8');
        String baseURL1 = 'https://mum1.dialers.xbaud.com/';
        String baseURL2 = 'https://mum2.dialers.xbaud.com/';
        String subURL = 'elision-dialer/elision-api/main.php?action=add_multi_lead&source=12&multi_leads=' + encodedBody;
        
        Boolean isSuccess = false;
        // Callout 1
        String reqEndpoint = baseURL1 + subURL;
        String apiLogTag;
        String resBody;
        String resStatus;
        
        HttpResponse response = calloutHelper(reqEndpoint);
        
        // Api Log for 1st Call
        apiLogTag = 'ElisionActivityCallout';
        resStatus = response.getStatus();
        resBody = response.getBody();
        system.debug('resBody: '+resBody);
        resBody.contains('"success":"true"');
        return genAPILog(reqEndpoint, reqBody, resBody, resStatus, apiLogTag);
    }
    
    // callout helper
    private HttpResponse calloutHelper(String requestURL) {
        HttpResponse response = new HttpResponse();
        Integer timeOut = 120000;
        try{
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(requestURL);
            if(timeOut != null){
                req.setTimeout(timeOut);
            }
            String instanceURL = System.URL.getSalesforceBaseURL().getHost();
            /*if(instanceURL.contains('')){
                response.setStatusCode(200);
                response.setStatus('Success');
                response.setBody('{"success":"true"}');
            } else {*/
                response = h.send(req);
            /*}*/
        } catch(Exception e) {
            String statusMsg = 'Exception Occurred';
            String exceptionMsg = '{"type": "' + e.getTypeName() + '", "message": "' +  e.getMessage() + '", "line": "' + e.getLineNumber() + '"}';
            
            response.setStatusCode(500);
            response.setStatus(statusMsg);
            response.setBody(exceptionMsg);
        }
        System.debug('HttpResponse: ' + response);
        return response;
    }
    
    // Task request body wrap
    private class TaskWrap {
        String first_name, last_name, list_id, phone_number, province, recordId, objectIdentifier, callback_datetime;
        
        public TaskWrap(String firstName, String lastName, String customerPhone, String compaignId, String recordId, String callback_datetime, String Elison_CallbackTime) {
            this.first_name = firstName;
            this.last_name = lastName;
            if(customerPhone != null){
                this.phone_number = customerPhone.right(10);  
            }
            
            this.province = 'mrnnumber';
            this.list_id = compaignId;
            this.recordId = recordId;
            this.objectIdentifier = 'Activity';
            this.callback_datetime = callback_datetime == null ? Elison_CallbackTime : callback_datetime == ''? Elison_CallbackTime : callback_datetime;
        }
    }
    
    // Api Log Generator
    private Api_Log__c genAPILog(String url, String reqBody, String resBody, String statusMsg, String tag) {
        Api_Log__c apiLogRec = new Api_Log__c();
        try {
            apiLogRec.Endpoint__c = url;
            apiLogRec.Response_Body__c = resBody;
            apiLogRec.Tag__c = tag;
            apiLogRec.Status__c = statusMsg;
            apiLogRec.Request_Body__c = reqBody;
        } catch(Exception e) {
            System.debug('EXCEPTION: Type: ' + e.getTypeName() + ', Message: ' +  e.getMessage() + ' at Line: ' + e.getLineNumber());
        } 
        return apiLogRec;
    }
}