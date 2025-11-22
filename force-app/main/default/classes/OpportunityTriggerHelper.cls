public class OpportunityTriggerHelper {
    
    //Added by Sumit
    //Purpose: To push the leads to LMS system through a future context
    public static void pushSingleOppToLMS(Set<Id> LmsOppPush){
        if(!CheckRecursiveTrigger.runOnceOppLMS()) {
            System.debug('Already Ran LMS Callout, EXITING_FUNCTION');
            return;
        }
        
        List<Id> OppIdList = new List<Id>();
        for(Id OppId : LmsOppPush){
            OppIdList.add(OppId);
        }
        makeLMSCallout(OppIdList);
    }
    
    // 07Dec2022:Sumit:Start
    @future(callout=true)
    public static void makeLMSCallout(List<Id> OppIdList) {
        LeadPushToLMS.pushLeadsToLms(OppIdList);
        // LeadPushToLMS.pushOpportunityToLms(OppIdList);
    }
    // 07Dec2022:Sumit:End
    
    public static void sendSMSToUser(String smsTempName, List<Opportunity> smsLeadList){
        List<SMS_Template__c> smsBodyList = [Select Id, name, SMS_Body__c from SMS_Template__c where name = :smsTempName and isActive__c = true];
        
        SMS_Log__c sms = new SMS_Log__c();
        sms.Lead__c = smsLeadList[0].Lead__c;
        sms.Qualified_Lead__c=smsLeadList[0].Id;
        sms.SMS_Template__c = smsBodyList[0].Id;
        sms.SMS_Body__c = smsBodyList[0].SMS_Body__c;
        sms.Send_To__c = smsLeadList[0].Lead__r.phone;
        if(smsLeadList[0].RP_Dealer__c != null)
            sms.rp_dealer__c = smsLeadList[0].RP_Dealer__c;
        if(smsLeadList[0].Dealer__c != null)
            sms.Dealer__c = smsLeadList[0].Dealer__c;
        
        insert sms;
    }
    
    public static void updateLead(Map<Id, List<Opportunity>> leadToOppArrMap) {
        if(leadToOppArrMap.isEmpty()) {
            return;
        }
        
        // Collecting Similiars Opps from SFDB
        for(Opportunity oRec : [SELECT Id, Lead__c, Status__c, Sub_Status__c, Loss_Reason__c FROM Opportunity WHERE Lead__c IN :leadToOppArrMap.keySet()]) {
            
            Boolean isAlreadyCounted = false;
            for(Opportunity oRecinMap : leadToOppArrMap.get(oRec.Lead__c)){
                if(oRecinMap.Id == oRec.Id) {
                    isAlreadyCounted = true;
                }
            }
            
            if(!isAlreadyCounted) {
                leadToOppArrMap.get(oRec.Lead__c).add(oRec);
            }
        }
        
        String status_Hot = 'Hot';
        String status_Warm = 'Warm';
        String status_Cold = 'Cold';
        String status_Lost = 'Lost';
        
        List<Lead> leadToUpdateArr = new List<Lead>();
        
        for(Id leadId : leadToOppArrMap.keySet()) {
            
            Boolean isAnyHot = false;
            Boolean isAnyWarm = false;
            Boolean isAnyCold = false;
            Boolean isAnyNotLost = null;
            String subStatus;
            
            for(Opportunity oRec : leadToOppArrMap.get(leadId)) {
                System.debug('oRec ' +oRec);
                // If there is any follow up lead with 'HOT' status => Fresh Lead status to be updated as 'HOT'
                if(oRec.status__c == status_Hot) {
                    isAnyHot = true;
                    if(subStatus == null) {
                        subStatus = oRec.Sub_Status__c;
                    }
                    continue;
                }
                
                // If there's any follow up lead with 'WARM' and no 'HOT' status => Fresh Lead status to be updated as 'WARM'
                if(oRec.status__c == status_Warm) {
                    isAnyWarm = true;
                    if(subStatus == null) {
                        subStatus = oRec.Sub_Status__c;
                    }
                    continue;
                }
                
                // If there is any follow up lead with 'COLD' and no 'HOT' or 'WARM' status => Fresh Lead status to be updated as 'COLD'
                if(oRec.status__c == status_Cold) {
                    isAnyCold = true;
                    if(subStatus == null) {
                        subStatus = oRec.Sub_Status__c;
                    }
                    continue;
                }
                
                // If all the follow up leads are 'LOST' => Fresh Lead status to be updated as 'LOST'
                if(oRec.status__c != status_Lost) {
                    isAnyNotLost = true;
                    continue;
                } else {
                    isAnyNotLost = false;
                    continue;
                }
            }
            
            Lead lRec = new Lead(
                Id = leadId
            );
            
            Boolean leadShouldUpdate = false;
            if(isAnyHot || isAnyWarm || isAnyCold) {
                if(isAnyHot) {
                    lRec.Status__c = status_Hot;  
                }
                
                if(isAnyWarm) {
                    lRec.Status__c = status_Warm;
                }
                
                if(isAnyCold) {
                    lRec.Status__c = status_Cold;
                }
                lRec.Sub_Status__c = subStatus;
                leadShouldUpdate = true;
            } else if(isAnyNotLost != null && !isAnyNotLost) {
                lRec.Status__c = status_Lost;
                // lRec.Lost_Reason__c = leadToOppArrMap.get(leadId)[0].Lost_Reason__c;
                lRec.Lost_Reason__c = 'Others';
                leadShouldUpdate = true;
            }
            
            if(leadShouldUpdate) {
                leadToUpdateArr.add(lRec);
            }
        }
        
        if(!leadToUpdateArr.isEmpty()) {
            update leadToUpdateArr;
        }
    }
    
    //Added as a part of CRM-1040 by Mishal
    @future(callout=true)
    public static void cnbCallout(Set<Id> setOfOpp){
        List<String> lstRequestString = new List<String>();
        List<opportunity> listOfOpp = new List<opportunity> ();
        String requestStr;
        Set<Id> oppIds = new Set<Id>();
        Map<Id,String> oppMap = new Map<Id,String>();
        List<String> lstString = new List<String>();
        
        List<Opportunity> oppLst = [select id, Lead__c, status__c,Lead__r.Id,Lead__r.Status__c,Lead__r.Follow_Up_Date_Time__c,Lead__r.FollowUp_Comments__c, Followup_Date_Time__c, FollowUp_Comments__c, Warranty_End_Date__c, Warranty_End_Kilometre__c, Warranty_Number__c, Warranty_Punched_Date__c, Warranty_Start_Date__c, Warranty_Start_Kilometre__c, Warranty_Type__c, Sold_Variant__c, Sold_Register_Year__c, Sold_Register_No__c, Sold_Register_Month__c, Sold_Register_City__c, Sold_Owner__c, Sold_Model__c, Sold_Mfg_Year__c, Sold_Mfg_Month__c, Sold_Make__c, Sold_Kms__c, Sold_Color__c from opportunity where Id IN: setOfOpp];
        Map<String,String> oppList = new Map<String,String>();
        
        List<Map<String,String>> mapOfOpp = new List<Map<String,String>>();
        Map<String,Object> mapOppLead = new Map<String,Object>();
        
        for(Opportunity opp : oppLst){
            string lead_followup_comments = '';
            string opp_followup_comments = '';
            string lead_Follow_Up_Date_Time = '';
            string opp_Follow_Up_Date_Time = '';
            if(opp.Lead__r.FollowUp_Comments__c != null){
                lead_followup_comments = opp.Lead__r.FollowUp_Comments__c;
            }
            if(opp.FollowUp_Comments__c != null){
                opp_followup_comments = opp.FollowUp_Comments__c;
            }
            if(opp.Lead__r.Follow_Up_Date_Time__c != null){
                lead_Follow_Up_Date_Time = string.valueOf(opp.Lead__r.Follow_Up_Date_Time__c);
            }
            if(opp.Followup_Date_Time__c != null){
                opp_Follow_Up_Date_Time = string.valueOf(opp.Followup_Date_Time__c);
            }
            requestStr = '{"sfdc_lead_id":"'+opp.Lead__r.Id+'","lead_status":"'+opp.Lead__r.Status__c+'","followup_date":"'+lead_Follow_Up_Date_Time+'","followup_comments":"'+lead_followup_comments+'","target":[{"sfdc_lead_dispatch_id":"'+opp.Id+'","status":"'+opp.status__c+'","followup_date":"'+opp_Follow_Up_Date_Time+'","followup_comments":"'+opp_followup_comments+'"}]}';
            oppMap.put(opp.Id, requestStr);
        }
        
        String responseStr;
        Integer httpStatusCode;
        HttpResponse res = new HttpResponse();
        
        // collecting credentails from 
        CnB_Endpoint__c cnbEndpoint = CnB_Endpoint__c.getAll().values();
        String username = cnbEndpoint.Username__c; 
        String password = cnbEndpoint.Password__c;
        String endPoint = cnbEndpoint.BuyerToCnBEndpoint__c;
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
        
        List<Api_Log__c> apiLogs = new List<Api_Log__c>();
        list<Id> Idss = new List<Id>(); // sumit CRM-1207
        String apiLogStatus = httpStatusCode == 200 ? 'Success' : 'Failed';
        for(String oppId : oppMap.keySet()) {
            // sumit start CRM-1207
            if(apiLogStatus == 'Success'){
                Idss.add(oppId);  
            } 
            apiLogs.add(LogService.createApiLogs(endPoint, oppMap.get(oppId), responseStr, apiLogStatus, 'CNB Reserve Opp Callout', oppId, false));
            // sumit end CRM-1207
        }
        // sumit start CRM-1207
        list<Opportunity> updatelst = new List<Opportunity>();
        for(Opportunity opplists: [select id,status__c,Reservation_Status__c from Opportunity where Id IN: Idss]){
           
            if(opplists.status__c == 'Cancelled'){
                opplists.Reservation_Status__c = false;
                updatelst.add(opplists);
            }
        }
        if(!updatelst.isEmpty()){
            update updatelst;   
        }
        
        // sumit end CRM-1207
        
        if(!apiLogs.isEmpty()){
            LogService.createApiLogs(apiLogs);
        }
        LeadTriggerHelper.apiFired = true;
    }
    
    /*CRM-1105 Pankaj Kumar 16-03-2023 Start*/
    /*CRM-1110 Pankaj Kumar 23-03-2023 Start*/
    public static void createWhatsappMsgTask(Map<Id, Opportunity> oppWhatsapMsgMap, String tempName, Map<Id,Account> dealerMap){
    /*CRM-1110 Pankaj Kumar 23-03-2023 End*/
        Map<Id,String> oppIdToMsgMap = new Map<Id,String>();
        List<Task> taskToInsert = new List<Task>();
        
        Datetime dt = System.now();
        String dtIST = dt.format('yyyy-MM-dd HH:mm:ss', 'IST');
        
        /*CRM-1110 Pankaj Kumar 23-03-2023 Start*/
        oppIdToMsgMap = WhatsappMessageTemplateHandler.getOppMsgMap(oppWhatsapMsgMap, tempName, dealerMap);
        /*CRM-1110 Pankaj Kumar 23-03-2023 End*/
        
        for(Id oppId : oppWhatsapMsgMap.keySet()){
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('Whatsapp').getRecordTypeId();
            tsk.WhatId = oppId;
            tsk.Subject = 'Whatsapp - '+tempName+' - '+dtIST;
            tsk.Status = 'Completed';
            tsk.Phone__c = oppWhatsapMsgMap.get(oppId).Customer_Phone__c;
            tsk.Description = oppIdToMsgMap.get(oppId);
            if(tempName == 'WalkinRegister_6567878'){
                tsk.Status = 'Open';
            }
            taskToInsert.add(tsk);
        }
        
        if(!taskToInsert.isEmpty()){
            insert taskToInsert;
        }
    }
    /*CRM-1105 Pankaj Kumar 16-03-2023 End*/
    /*CRM-1139 Pankaj Kumar 24-04-2023 Start*/
    public static boolean updateRelatedLeadRec(Map<Id,Opportunity> oldMap, List<Opportunity> newList, Boolean isUpdate){
        Set<Id> leadRecIdSet = new Set<Id>();
        List<Opportunity> updatedNewOppList = new List<Opportunity>();
        Map<Id,Lead> leadMap = new Map<Id,Lead>();
        Map<Id,Lead> leadsToBeUpdated = new Map<Id,Lead>();
        Map<Id,List<Opportunity>> leadToOppListMap = new Map<Id,List<Opportunity>>();
        
        for(Opportunity opp : newList){
            if((!isUpdate && opp.Opp_Whatsapp_Consent__c != null)||(isUpdate && opp.Opp_Whatsapp_Consent__c != null && opp.Opp_Whatsapp_Consent__c != oldMap.get(opp.Id).Opp_Whatsapp_Consent__c)){
                leadRecIdSet.add(opp.Lead__c);
                updatedNewOppList.add(opp);
            }
        }
        if(leadRecIdSet.isEmpty()){
            return false;
        }
        
        leadMap = new Map<Id,Lead>([Select id, WhatsApp_consent__c from Lead where id in :leadRecIdSet]);
        
        
        for(Opportunity opp : updatedNewOppList){
            if((!isUpdate && opp.Opp_Whatsapp_Consent__c != null && leadMap.containsKey(opp.Lead__c)) || 
               (isUpdate && opp.Opp_Whatsapp_Consent__c != null && opp.Opp_Whatsapp_Consent__c != oldMap.get(opp.Id).Opp_Whatsapp_Consent__c && leadMap.containsKey(opp.Lead__c) && ((String.isEmpty(leadMap.get(opp.Lead__c).WhatsApp_consent__c)) || (leadMap.get(opp.Lead__c).WhatsApp_consent__c != null && leadMap.get(opp.Lead__c).WhatsApp_consent__c != opp.Opp_Whatsapp_Consent__c)))){
                Lead leadRec = leadMap.get(opp.Lead__c);
                leadRec.WhatsApp_consent__c = opp.Opp_Whatsapp_Consent__c;
                leadsToBeUpdated.put(leadRec.Id,leadRec);
                List<Opportunity> oppList = new List<Opportunity>();
                if(leadToOppListMap.containsKey(leadRec.Id)){
                    oppList = leadToOppListMap.get(leadRec.Id);
                }
                oppList.add(opp);
                leadToOppListMap.put(leadRec.Id,oppList);
            }
        }
        if(leadsToBeUpdated.isEmpty()){
            return false; 
        }
        Database.SaveResult[] srList = Database.update(leadsToBeUpdated.values(),false);
        
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                for(Opportunity opp : leadToOppListMap.get(sr.getId())){
                    opp.addError((sr.getErrors())[0].getMessage() + ' on Lead');
                }
            }
        }
        return true;
    }
    /*CRM-1139 Pankaj Kumar 24-04-2023 End*/
    
    //19May2023:Sumit:Start:CRM-1147
    public static void ownerUpdateOnOpportunity(Map<Id, Id> oppOwnerUpdateDealerIdList,Set<String> DealerCodeSet){
                    
            List<Opportunity> UpdateListOfOpportunity = new list<Opportunity>();
            for(Opportunity o : [select Id,Opportunity_Owner__c,Lead__c,status__c,Dealer_Code__c from Opportunity where Lead__c IN :oppOwnerUpdateDealerIdList.keySet()  AND status__c != 'Lost' AND status__c != 'Sold' AND Dealer_Code__c IN: DealerCodeSet]) {
                o.Opportunity_Owner__c = oppOwnerUpdateDealerIdList.get(o.Lead__c);
                UpdateListOfOpportunity.add(o);
            } 
            update UpdateListOfOpportunity;         
    }
    
    public static void ownerInsertOnOpportunity(Map<Id, Id> oppOwnerUpdateDealerIdList,Set<Id> DealerCodeSet){
                    
            List<Opportunity> insertListOfOpportunity = new list<Opportunity>();
            for(Opportunity o : [select id,Opportunity_Owner__c,Lead__c,status__c,Dealer__c from Opportunity where Lead__c IN :oppOwnerUpdateDealerIdList.keySet()  AND status__c != 'Lost' AND status__c != 'Sold' AND Dealer__c IN: DealerCodeSet]) {
                o.Opportunity_Owner__c = oppOwnerUpdateDealerIdList.get(o.Lead__c);
                insertListOfOpportunity.add(o);
            } 
            update insertListOfOpportunity;        
    }
    public static void ownerChangeException(list<Opportunity> oplst){     
        update oplst;        
    }
     //19May2023:Sumit:End:CRM-1147 
     
       //26Oct2023::Amulya Start ::CRM-1200
       public static void updateOpportunity(list<Opportunity> oplst){     
        update oplst;        
    }
    //26Oct2023::Amulya End::CRM-1200
    
    //09Nov2022::Sumit Start::CRM-1207(Update Reservation Status False)
    public static void updateReservation(Set<Id> oppRec){    
        List<Opportunity> UpdateListOfOpportunity = new list<Opportunity>();
        for(Opportunity o : [select Id,Reservation_Status__c from Opportunity where Id IN :oppRec]) {
            o.Reservation_Status__c = false;
            UpdateListOfOpportunity.add(o);
        } 
        update UpdateListOfOpportunity;               
    }
    //09Nov2022::Sumit End::CRM-1207(Update Reservation Status False)
}