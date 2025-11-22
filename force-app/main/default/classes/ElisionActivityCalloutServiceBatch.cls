global class ElisionActivityCalloutServiceBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Schedulable{

    global void execute(SchedulableContext ctx){
        ElisionActivityCalloutServiceBatch eobj = new ElisionActivityCalloutServiceBatch();
        Database.executeBatch(eobj, 50);   
    } 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([SELECT Id, WhatId, WhoId,API_log__r.status__c,API_log__r.Failed_Retry_Count__c,API_log__r.tag__c,API_log__c FROM TASK Where API_log__r.status__c = 'Exception Occurred' AND API_log__r.tag__c = 'ElisionActivityCallout' AND ((API_log__r.Failed_Retry_Count__c = Null) OR (API_log__r.Failed_Retry_Count__c <= 5)) AND CreatedDate = LAST_N_DAYS:1]);
    }
    
    global void execute(Database.BatchableContext BC, List<Task> newList) {
        Set<Id> taskId = new Set<Id>();
        List<API_Log__c> apList = new List<API_Log__c>();
        for(Task tas : newList) {            
            
            taskId.add(tas.Id);                                
        }
        System.debug('taskId -->'+taskId);
        
        ElisionActivityCalloutService.init(taskId);
        
      /*  for(Task t1 : [SELECT Id, API_log__r.status__c,API_log__r.Failed_Retry_Count__c,API_log__r.tag__c,API_log__c FROM TASK Where id =:taskId]) {
            System.debug('T1--> '+t1);
            Integer num = 1;
            
            API_log__c ap = new API_log__c();
            ap.Id =  t1.API_Log__c;
            system.debug('t1.API_Log__r.Failed_Retry_Count__c ' + t1.API_Log__r.Failed_Retry_Count__c);
            if(t1.API_Log__r.Failed_Retry_Count__c == Null || t1.API_Log__r.Failed_Retry_Count__c <= 5){
            ap.Failed_Retry_Count__c = t1.API_Log__r.Failed_Retry_Count__c + num; 
                
            }
            apList.add(ap);
        }*/
        System.debug('apList :-'+apList);
        // update apList;
        
    }
        
    global void finish(Database.BatchableContext BC) {
        
    }
     
}