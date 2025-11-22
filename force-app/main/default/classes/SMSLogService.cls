public class SMSLogService {
    public class objectInfo{
        public String ObjectName;
        public String fieldApiName;
        public String mergeName;
    }
    public static void generateSMSContent(List<SMS_Log__c> smsLogs){
        System.debug('Entered into a method');
        
        Map<String,String> mapOfObjectApiNames=new Map<String,String>();
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<String, objectInfo> mapofObjectToObjectInfo=new Map<String, objectInfo>();
        Map<Id, Account> dealerMap = new Map<Id, Account>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Map<Id, SMS_Template__c> smsTemplateMap = new Map<Id, SMS_Template__c>();
        Map<Id, RP_Dealer__c> rpDealerMap = new Map<Id, RP_Dealer__c>();
        Set<Id> dealerIds = new Set<Id>();
        Set<Id> leadIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> smsTemplateIds = new Set<Id>();
        Set<Id> rpDealerIds = new Set<Id>();
        Set<String> setOfAllMergeFields = new Set<String>();
        mapOfObjectApiNames = UtilityClass.getMapOfObjectApiNameAndLabel();
        for(SMS_Log__c log : smsLogs){
            
            if(log.Lead__c != null){
                leadIds.add(log.Lead__c);
            }
            if(log.Qualified_Lead__c != null){
                oppIds.add(log.Qualified_Lead__c);
            }
            if(log.Sms_Template__c != null){
                smsTemplateIds.add(log.Sms_Template__c);
            }
            if(log.Dealer__c != null){
                dealerIds.add(log.dealer__c);
            }
            if(log.lead__c != null){
                leadIds.add(log.lead__c);
            }
             if(log.Rp_Dealer__c != NULL){
                rpDealerIds.add(log.rp_dealer__c);
            }
        }
        
        
        
        if(oppIds.size() > 0){
            for(Opportunity opp : OpportunitySelector.getAllOpportunityData(oppIds)){
                oppMap.put(opp.Id, opp);
                
            }
        }
        
        if(leadIds.size() > 0){
            for(Lead lea : LeadSelector.getAllLeadData(leadIds)){
                leadMap.put(lea.Id, lea);
            }
        }
        
        if(smsTemplateIds.size() > 0){
            for(SMS_Template__c template : [Select Id,SMS_Body__c from SMS_Template__c Where Id =: smsTemplateIds]){
                smsTemplateMap.put(template.Id, template);
            }
        }
        
        if(dealerIds.size() > 0){
            for(Account acc : AccountSelector.getAllAccountData(dealerIds)){
                dealerMap.put(acc.Id, acc);
            }
        }
        
        if(rpDealerIds.size() > 0){
            for(RP_Dealer__c rp : [Select id, name, Address__c from RP_Dealer__c where Id IN :rpDealerIds]){
                rpDealerMap.put(rp.Id, rp);
            }
        }
        
        System.debug('dealerMap: '+dealerMap);
        System.debug('oppMap: '+oppMap);
        System.debug('leadMap: '+leadMap); 
        
        for(SMS_Log__c log : smsLogs){
            System.debug('body: '+log.SMS_Body__c);
            System.debug('body: '+smsTemplateMap.get(log.SMS_Template__c).SMS_Body__c);
            String smsContent = log.SMS_Body__c;
            System.debug('smsContent: '+smsContent);
            for(Integer i=0 ;i<smsContent.length();i++){
                String eachMerge='';
                String objName='';
                Boolean hasDot = false;
                String fieldApiNme='';
                objectInfo obinfo=new objectInfo();
                if(String.fromCharArray(new List<Integer>{smsContent.charAt(i)}) == '{' && String.fromCharArray(new List<Integer>{smsContent.charAt(i+1)})=='!'){
                    eachMerge = eachMerge + String.fromCharArray(new List<Integer>{smsContent.charAt(i)}) + String.fromCharArray(new List<Integer>{smsContent.charAt(i+1)});
                    for(Integer j=i+2; j<smsContent.length();j++){
                        if(String.fromCharArray(new List<Integer>{smsContent.charAt(j)}) == '.' && !hasDot){
                            hasDot = true;
                        }
                        if(!hasDot){
                            objName = objName + String.fromCharArray(new List<Integer>{smsContent.charAt(j)});
                        }else if(hasDot && String.fromCharArray(new List<Integer>{smsContent.charAt(j)}) != '.' && String.fromCharArray(new List<Integer>{smsContent.charAt(j)}) !='}') {
                            fieldApiNme = fieldApiNme + String.fromCharArray(new List<Integer>{smsContent.charAt(j)});
                        }
                        eachMerge = eachMerge + String.fromCharArray(new List<Integer>{smsContent.charAt(j)});
                        
                        if(String.fromCharArray(new List<Integer>{smsContent.charAt(j)}) == '}'){
                            i = j;
                            break;
                        }
                    }
                    obinfo.ObjectName = objName;
                    obinfo.mergeName = eachMerge;
                    obinfo.fieldApiName = fieldApiNme;
                    mapofObjectToObjectInfo.put(eachMerge, obinfo);
                    setOfAllMergeFields.add(eachMerge);
                }
            }
            System.debug('mapofObjectToObjectInfo: '+mapofObjectToObjectInfo);
            System.debug('setOfAllMergeFields: '+setOfAllMergeFields);
            for(String eachMerge: setOfAllMergeFields){
                System.debug('---Eachmerge'+eachMerge);
                //System.debug('mapofObjectToObjectInfo.get(eachMerge).fieldApiName'+mapofObjectToObjectInfo.get(eachMerge).fieldApiName);
                //System.debug('leadMap.get(log.lead__c).get(mapofObjectToObjectInfo.get(eachMerge).fieldApiName)'+leadMap.get(log.lead__c).get(mapofObjectToObjectInfo.get(eachMerge).fieldApiName));
                if(smsContent.contains(eachMerge)){
                    if(mapofObjectToObjectInfo.containsKey(eachMerge) 
                       && mapofObjectToObjectInfo.get(eachMerge).ObjectName != null 
                       && mapofObjectToObjectInfo.get(eachMerge).ObjectName == 'Lead' 
                       && mapofObjectToObjectInfo.containsKey(eachMerge)
                       && mapofObjectToObjectInfo.get(eachMerge).fieldApiName !=null
                       && leadMap.get(log.lead__c).get(mapofObjectToObjectInfo.get(eachMerge).fieldApiName) !=null){ 
                           smsContent = smsContent.replace(eachMerge, String.valueOf(leadMap.get(log.lead__c).get(mapofObjectToObjectInfo.get(eachMerge).fieldApiName)));
                       }
                    if(mapofObjectToObjectInfo.containsKey(eachMerge)
                       && mapofObjectToObjectInfo.get(eachMerge).ObjectName == 'Qualified_Lead'
                       && mapofObjectToObjectInfo.get(eachMerge).ObjectName != null 
                       && mapofObjectToObjectInfo.containsKey(eachMerge)
                       && mapofObjectToObjectInfo.get(eachMerge).fieldApiName !=null
                       && oppMap.get(log.Qualified_Lead__c).get(mapofObjectToObjectInfo.get(eachMerge).fieldApiName) !=null){
                           smsContent = smsContent.replace(eachMerge, String.valueOf(oppMap.get(log.Qualified_Lead__c).get(mapofObjectToObjectInfo.get(eachMerge).fieldApiName)));
                       }
                    System.debug('log.dealer__c: '+log.dealer__c);
                    System.debug('dealerMap.cont(log.dealer__c): '+dealerMap.containsKey(log.dealer__c));
                    if(mapofObjectToObjectInfo.containsKey(eachMerge)
                       && mapofObjectToObjectInfo.get(eachMerge).ObjectName == 'Dealer'
                       && mapofObjectToObjectInfo.get(eachMerge).ObjectName != null 
                       && mapofObjectToObjectInfo.containsKey(eachMerge)
                       && mapofObjectToObjectInfo.get(eachMerge).fieldApiName !=null
                       && dealerMap.get(log.dealer__c).get(mapofObjectToObjectInfo.get(eachMerge).fieldApiName) !=null){ 
                           smsContent = smsContent.replace(eachMerge, String.valueOf(dealerMap.get(log.dealer__c).get(mapofObjectToObjectInfo.get(eachMerge).fieldApiName)));
                       }
                }
                
                if(mapofObjectToObjectInfo.containsKey(eachMerge)
                       && mapofObjectToObjectInfo.get(eachMerge).ObjectName == 'Rp_Dealer'
                       && mapofObjectToObjectInfo.get(eachMerge).ObjectName != null 
                       && mapofObjectToObjectInfo.containsKey(eachMerge)
                       && mapofObjectToObjectInfo.get(eachMerge).fieldApiName !=null
                       && rpDealerMap.get(log.RP_Dealer__c).get(mapofObjectToObjectInfo.get(eachMerge).fieldApiName) !=null){ 
                           smsContent = smsContent.replace(eachMerge, String.valueOf(rpDealerMap.get(log.RP_Dealer__c).get(mapofObjectToObjectInfo.get(eachMerge).fieldApiName)));
                       }
                
            }
            log.SMS_Body__c = smsContent;
            
        }
        
    }
    
    public static void sendParametersToUser(Map<Id,SMS_Log__c> newMap){
        System.debug('SMSLogService.sendParametersToUser ::');
               
        // 21Jan2022:Asif:Start :: Bulkifying
        Set<Id> logIds = new Set<Id>();
        for(String logId : newMap.keySet()) {
            logIds.add(logId);
        }
       
        sendSMSBulk(logIds);
        // 21Jan2022:Asif:End
    }
    
    // 21Jan2022:Asif:Start :: Bulkifying SMSs
    @future(callout=true)
    public static void sendSMSBulk(Set<Id> logIds) {
        /*if(System.isBatch() || System.isFuture()) {
            return;
        }*/
        
        // getting SMS logs
        List<SMS_Log__c>  listOfSMSLogs = SMSLogSelector.getSMSLogData(logIds);
        if(listOfSMSLogs.isEmpty()) {
            return;
        }
        
        // getting endpoints and credentials
        List<GupShup_Endpoints__c> gupshupEndpoints = GupShup_Endpoints__c.getall().values();
        if(gupshupEndpoints.isEmpty()) {
            return;
        }
        GupShup_Endpoints__c credentialObj = gupshupEndpoints[0];
        String endpoint = credentialObj.Single_Message_Endpoint__c;
        String userId = credentialObj.UserId__c;
        String password = credentialObj.Password__c;
        

        List<SMS_Log__c> logToUpdate = new List<SMS_Log__c>();
        // looping through logs and making SMS calls
        for(SMS_Log__c smsLog : listOfSMSLogs) {
            String encodedMsg = EncodingUtil.urlEncode(smsLog.SMS_Body__c, 'UTF-8');
            
            String subURL = 'method=sendMessage&&msg_type=Unicode_text&mask=EMFCWL&auth_scheme=plain&v=1.1&format=text';
            subURL += '&userid=' + userId;
            subURL += '&password=' + password;
            subURL += '&send_to=' + smsLog.Lead__r.phone;
            subURL += '&msg=' + encodedMsg;
            
            String smsURL = endpoint + '?' + subURL;            
            System.debug('smsURL: ' + smsURL);
            
            // making SMS callout
            CalloutHelper cHObj = new CalloutHelper();
            HttpResponse res = cHObj.sendAsGET(smsURL, null);
           
            System.debug('SMS Response ' + res);
            
            logToUpdate.add(new SMS_Log__c(
                Id = smsLog.Id,
                API_Request__c = smsURL,
                API_Response__c = res + ' : ' + res.getBody()
            ));
        }
        
        // updating logs with Response
        update logToUpdate;
    }    
    // 21Jan2022:Asif:End
    
    @future(callout=true)
    public static void sendSMS(String strMsg, String recId){
        CalloutHelper cHObj = new CalloutHelper();
        HttpResponse res = cHObj.sendAsGET(strMsg, null);
        System.debug('res'+res);
        System.debug('resbody'+res.getBody());
        SMS_Log__c smsLog = new SMS_Log__c();
        smsLog.Id = recId;
        smsLog.API_Request__c = strMsg;
        smsLog.API_Response__c = res+' : '+res.getBody();
        update smsLog;
    }
    
    
}