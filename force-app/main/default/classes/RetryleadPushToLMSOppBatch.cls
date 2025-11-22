global class RetryleadPushToLMSOppBatch implements database.Batchable<sObject>, Database.AllowsCallouts,Schedulable{
    
    global void execute(SchedulableContext ctx){
        RetryleadPushToLMSOppBatch eobj = new RetryleadPushToLMSOppBatch();
        Database.executeBatch(eobj, 50);   
    } 
    
    global Database.QueryLocator Start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([Select id,Opportunity__c, Status__c, Tag__c,Failed_Retry_Count__c from API_Log__c Where Status__c IN ('AUTH_ENDPOINT_ERROR','Failed','INSERT_ENDPOINT_ERROR') AND Tag__c = 'BUC LMS Opp Callout' AND Opportunity__c != null  AND Failed_Retry_Count__c = null AND CreatedDate = LAST_N_DAYS:2 LIMIT 1]);
    }
    
    
    global void execute(Database.BatchableContext BC, List<API_Log__c> newList){
        
        List<API_Log__c> apList = new List<API_Log__c>();
        
        List<Id> leadId = new List<Id>();
       
        
        for(API_Log__c apiLog : newList) {   
            
            if(apilog.Opportunity__c != null){
                
                 leadId.add(apilog.Opportunity__c);
                
            }          
               
            
        }
        System.debug('listLeadId -->'+leadId);
        
            LeadPushToLMS.pushLeadsToLms(new List<Id>(leadId));
      
        
        // api log update
        for (API_Log__c api : [Select id,Opportunity__c,Failed_Retry_Count__c from API_Log__c Where Opportunity__c =:leadId] ){
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