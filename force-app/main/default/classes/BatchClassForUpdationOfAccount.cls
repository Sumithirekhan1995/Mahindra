global class BatchClassForUpdationOfAccount implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id,Phone, ExtrnId_Phone__c from Account Where Phone != null AND ExtrnId_Phone__c = null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accList) {
        for(Account acc : accList) {        
            acc.ExtrnId_Phone__c = acc.Phone;
        }
        try {
            update accList;
        } catch(Exception e) {
            System.debug(e);
        }
    } 
    
    global void finish(Database.BatchableContext BC) {
		System.debug('Executed Successfully');
        
    }

}