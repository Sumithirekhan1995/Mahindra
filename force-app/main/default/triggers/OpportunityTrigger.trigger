trigger OpportunityTrigger on Opportunity (before insert, after insert, after update, before update) {
    
    if(Trigger.isbefore) { 
        if(Trigger.isInsert) {
            OpportunityTriggerHandler.beforeinsert(Trigger.new);
        } else if(Trigger.isUpdate) {
            OpportunityTriggerHandler.beforeUpdate(Trigger.newMap, trigger.OldMap);
        }
    } else if(Trigger.isAfter) {  
        if(Trigger.isInsert) {
            OpportunityTriggerHandler.onAfterInsert(Trigger.New, trigger.OldMap);
            // ElisionOpportunityService.initFuture(Trigger.newMap.keySet());
    
            List<Opportunity> oppToUpdate = new List<Opportunity>();
            for(Opportunity o : Trigger.New) {
                if(!o.Bypass_validation__c) {
                    oppToUpdate.add(new Opportunity(
                        Id = o.Id,
                        Bypass_validation__c = true
                    ));
                }
            }
            
            if(!oppToUpdate.isEmpty()) {
                update oppToUpdate;
            }
        } else if(Trigger.isUpdate) {
            OpportunityTriggerHandler.afterUpdate(Trigger.newMap, trigger.OldMap, Trigger.New);
        }
    }
}