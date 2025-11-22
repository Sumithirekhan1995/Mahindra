global class BatchToCaptureLeadDateTime implements Database.Batchable<sObject> {
   
        
	global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id, Lead_Created_Date__c , Created_Date__c   from Lead where CreatedDateTime__c = null';
        return Database.getQueryLocator(query);
    } 

    global void execute(Database.BatchableContext BC, List<Lead> leadList) {
        for(Lead l : leadList) {        
          l.CreatedDateTime__c = DateTime.valueOf(l.Created_Date__c );
        }
        try {
            list<Database.SaveResult> dr = Database.update(leadList, false);
           
        } catch(Exception e) {
            System.debug(e);
        }
    } 
    
    global void finish(Database.BatchableContext BC) {
		System.debug('Executed Successfully');
        BatchToCaptureOpportunityDateTime b = new BatchToCaptureOpportunityDateTime();
        Database.executeBatch(b, 2000);
        
    }
}