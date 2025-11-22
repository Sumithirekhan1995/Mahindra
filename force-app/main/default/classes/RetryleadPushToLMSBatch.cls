global class RetryleadPushToLMSBatch implements database.Batchable<sObject>, Database.AllowsCallouts,Schedulable{
    
    global void execute(SchedulableContext ctx){
        RetryleadPushToLMSBatch eobj = new RetryleadPushToLMSBatch();
        Database.executeBatch(eobj, 50);   
    } 
    
    global Database.QueryLocator Start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([Select id,Lead__c, Status__c, Tag__c,Failed_Retry_Count__c from API_Log__c Where Status__c IN ('AUTH_ENDPOINT_ERROR','INSERT_ENDPOINT_ERROR') AND Lead__c != null AND Tag__c = 'BUC LMS Lead Callout' AND Failed_Retry_Count__c = null AND CreatedDate = LAST_N_DAYS:2 LIMIT 1]);
    }
    
    
    global void execute(Database.BatchableContext BC, List<API_Log__c> newList){
        
        List<API_Log__c> apList = new List<API_Log__c>();
        
        List<Id> leadId = new List<Id>();
        List<Id> oppId = new List<Id>();
        
        for(API_Log__c apiLog : newList) {   
            
            
            if(apiLog.Lead__c != null){
                
                leadId.add(apiLog.Lead__c);
            }
            
            
        }
        System.debug('listLeadId -->'+leadId);
        
        if(!leadId.isEmpty()){
            LeadPushToLMS.pushLeadsToLms(new List<Id>(leadId));
        }
       
        
        // api log update
        for (API_Log__c api : [Select id,Lead__c,Failed_Retry_Count__c from API_Log__c Where Lead__c  =:leadId] ){
            //system.debug('__finish___');
            
            API_log__c ap = new API_log__c();
            ap.Id =  api.id;
            system.debug('Failed_Retry_Count__c ::::' +api.Failed_Retry_Count__c);
            If(api.Failed_Retry_Count__c == null ){
                ap.Failed_Retry_Count__c = 1; 
            }
            
            apList.add(ap);
            
        }
        system.debug('apList::::' +apList);
        update apList;
        
        
    }
    
    
    global void finish(Database.BatchableContext BC){
        
        
    }
    
}