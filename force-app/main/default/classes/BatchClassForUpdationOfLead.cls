global class BatchClassForUpdationOfLead implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id,Phone, ExtrnId_Phone__c from Lead Where Phone != null AND ExtrnId_Phone__c = null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Lead> LeadList) {
        for(Lead leadUpdate : LeadList) {        
            leadUpdate.ExtrnId_Phone__c = leadUpdate.Phone;
        }
        try {
            update LeadList;
        } catch(Exception e) {
            System.debug(e);
        }
    } 
    
    global void finish(Database.BatchableContext BC) {
		System.debug('Executed Successfully');
        
    }

}