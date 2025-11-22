public class TaskTriggerHandler {

    public static Id whatsappRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Whatsapp').getRecordTypeId();
    
    public static void onBeforeInsert(List<Task> newTaskArr) {
        System.debug('TaskTriggerHandler.onBeforeInsert ::');
        List<Id> leadIds = new List<Id>();
       
        // getting all lead Ids
        for(Task taskItem : newTaskArr) {
            leadIds.add(taskItem.WhoId);
        }
        System.debug('leadIds: ' + leadIds);
        
        // BUC leads Only
        if(!leadIds.isEmpty()) {
            List<Lead> bucLeads = [SELECT Id FROM Lead WHERE Id IN :leadIds AND RecordTypeId = :LeadConstants.buyerLeadRecordTypeId LIMIT 5000];
            leadIds.clear();
            for(Lead leadItem : bucLeads) {
                leadIds.add(leadItem.Id);
            }
            if(!leadIds.isEmpty()) {
                // getting all opportunity Ids
                Map<Id, Id> leadOpportunityIds = new Map<Id, Id>();
                List<Opportunity> allOpportunityDB = [SELECT Id, Lead__c FROM Opportunity WHERE Lead__c IN :leadIds ORDER BY CreatedDate DESC LIMIT 5000];
                for(Opportunity oppItem : allOpportunityDB) {
                    if(!leadOpportunityIds.containsKey(oppItem.Lead__c)) {
                        leadOpportunityIds.put(oppItem.Lead__c, oppItem.Id);
                    }
                }
                System.debug('leadOpportunityIds: ' + leadOpportunityIds);
                
                // mapping with opportunity Ids
                for(Task taskItem : newTaskArr) {
                    if(leadOpportunityIds.containsKey(taskItem.WhoId)) {
                        taskItem.whatId = leadOpportunityIds.get(taskItem.WhoId);
                        taskItem.WhoId = null;
                    }
                }
            }       
        }
    }
    
    public static void UpdateLeadOwner(List<Task> T){
        System.debug('TaskTriggerHandler.UpdateLeadOwner : ');
        try {
            Set<String> taskIds = new Set<String>();
            Set<String> LeadIds = new Set<String>();
            Map<String,String> leadIdWithTaskOwnerId = new Map<String,String>();
            list<Lead> LeadsToUpdate = new List<Lead>();
            
            for(Task t1 : T){
                taskIds.add(t1.Id);
                
            }
            System.debug('taskIds' + taskIds);
            List<Task> listOfTask = [select id,WhoId,owner.name, ownerId from Task where ID IN:taskIds];
        
            for(Task t2 : listOfTask){
                    if(t2.WhoId != null){
                        LeadIds.add(t2.WhoId);
                        leadIdWithTaskOwnerId.put(t2.WhoId,t2.OwnerId);
                    }
            }
            System.debug('LeadIds' + LeadIds);
            System.debug('leadIdWithTaskOwnerId' + leadIdWithTaskOwnerId);
            
            List<Lead> listOfLeads = [select id , ownerId, owner.name,RecordTypeId from Lead where Id In:LeadIds];
            
            for(lead l: listOfLeads){
                if(String.valueof(l.ownerId).startsWith('00G') && l.RecordTypeId == Leadconstants.financeLeadRecordTypeId)
                {
                    if(leadIdWithTaskOwnerId.containsKey(l.id))
                    {
                        lead l1 = new lead();
                        l1.id = l.id;
                        l1.OwnerId = leadIdWithTaskOwnerId.get(l.id);
                        LeadsToUpdate.add(l1);
                    }
                }
            }
            
            if(!LeadsToUpdate.isEmpty()) {
                Update LeadsToUpdate;
            }
        } catch(Exception e) {
            System.debug('Exception : ' + e);
        }
    }
    
    //Method to update the number of unconnected calls counter on lead.
    public static void updateCounter(Map<Id, Task> newMap, Map<Id, Task> oldMap){
        System.debug('TaskTriggerHandler.updateCounter : ');
        try {
            Set<Id> leadCounter = new Set<Id>();
            List<Lead> leadListToUpdate = new List<Lead>();

            for(Task t2 : newMap.values()){
                // 23Aug2022:Sarthak :: Commnented Disposition Null Check from Criteria
                if(t2.WhoId != Null && /*t2.CallDisposition != Null &&*/ t2.Call_Status__c != 'Success' &&
                (oldMap.get(t2.Id).CallDisposition != t2.CallDisposition || oldMap.get(t2.Id).Call_Status__c != t2.Call_Status__c)){
                    leadCounter.add(t2.WhoId);
                }       
            }
            
            List<Lead> leadlist = [select id, name, No_of_not_Connected_Calls__c from lead where Id IN :leadCounter];
            System.debug('Lead List Before Update'+leadlist);
            
            for(Lead lead1 : leadlist){
                if(lead1.No_of_not_Connected_Calls__c == NULL){
                    lead1.No_of_not_Connected_Calls__c = 1;
                }
                else if(lead1.No_of_not_Connected_Calls__c >= 1){
                    lead1.No_of_not_Connected_Calls__c += 1;
                }
                leadListToUpdate.add(lead1);
            }
            
            System.debug('Lead List to be updated'+leadListToUpdate);
            if(!leadListToUpdate.isEmpty()){
                update leadListToUpdate;
            } 
        } catch(Exception e) {
            System.debug('Exception : ' + e);
        }
    }
    
    public static void onAfterInsert(List<Task> newList) {
        Set<Id> tRecIdArr = new Set<Id>();
        List<Task> whatsappRecords = new List<Task>();
        Id buyerRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Elision').getRecordTypeId();
        
        for(Task tRec : newList) {
            if(tRec.RecordTypeId == buyerRecordTypeId) {
                tRecIdArr.add(tRec.Id);
            }
            if(tRec.RecordTypeId == whatsappRecordTypeId && tRec.Status == 'Completed'){
                whatsappRecords.add(tRec);
            }
        }
        
        //System.debug('tRecIDArr: '+tRecIdArr);
        
        // callout elision
        if(!tRecIdArr.isEmpty()) {
            ElisionActivityCalloutService.initFuture(tRecIdArr);
        }
        if(!whatsappRecords.isEmpty()){
            SendWhatsAppMsgController.sendMessageCallout(whatsappRecords);
        }
    }
    
    public static void onAfterUpdate(Map<Id, Task> newMap, Map<Id, Task> oldMap) {
        List<Task> triggerWhatsappMsg = new List<Task>();
        for(Task tRec : newMap.values()) {
            if(tRec.RecordTypeId == whatsappRecordTypeId && tRec.Status == 'Completed'){
                triggerWhatsappMsg.add(tRec);
            }
        }
        if(!triggerWhatsappMsg.isEmpty()){
            SendWhatsAppMsgController.sendMessageCallout(triggerWhatsappMsg);
        }
    }
}