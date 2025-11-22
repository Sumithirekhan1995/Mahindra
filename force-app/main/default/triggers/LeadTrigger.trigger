/*
* Trigger created by Deepali
* Purpose: To handle trigger events in Lead objects
*/
trigger LeadTrigger on Lead (before insert, after insert, before update, after update) {
    
    System.debug('__LEAD_TRIGGERED');
    Boolean triggerShouldRun = true;
    
    // 12Aug2021:Sarthak:Start ::
    // for verifying changed fields values.
    if(Trigger.isUpdate) {
        System.debug('Checking Changed Values');
        SObject newObj = trigger.new[0];
        SObject oldObj = trigger.old[0]; 
        for(String fieldName : Schema.SObjectType.Lead.fields.getMap().keySet()){ 
            if(newObj.get(fieldName) != oldObj.get(fieldName)){
                System.debug('field: ' + fieldName + '[' + oldObj.get(fieldName) + ' => ' + newObj.get(fieldName) + ' ]');
            }  
        }
    }
    // 12Aug2021:Sarthak:End
    
    
    //Added by Deepali
    if(Trigger.isBefore && Trigger.isInsert){
        System.debug('__LEAD_TRIGGERED: BEFORE_INSERT');
        LeadTriggerHandler.onBeforeInsert(Trigger.new);        
    } 
    
    //Added by Deepali
    if(Trigger.isAfter && Trigger.isInsert){
        System.debug('__LEAD_TRIGGERED: AFTER_INSERT');
        LeadTriggerHandler.onAfterInsert(Trigger.new, Trigger.newMap, Trigger.oldMap);  
        
        // 3Feb2022:Shivam:Start ::Elision Call Handler trigger
       // LeadElisionCTI_Handler.leadAfterInsert(Trigger.new, Trigger.newMap);  
        // 3Feb2022:Shivam:End
        
    } 
    
    //Added by Deepali
    if(Trigger.isAfter && Trigger.isUpdate){
        
        // 3Feb2022:Shivam:Start ::Elision Call Handler trigger
        // LeadElisionCTI_Handler.leadAfterUpdate(Trigger.new, Trigger.newMap); 
         //SendWhatsappNotification.sendMessageAPIHiLead(Trigger.New[0]);  
        // 3Feb2022:Shivam:End
        
        System.debug('__LEAD_TRIGGERED: AFTER_UPDATE');
        LeadTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap, Trigger.new);

        
        
    } 
    
    if(Trigger.isBefore && Trigger.isUpdate){
        System.debug('__LEAD_TRIGGERED: BEFORE_UPDATE');
        LeadTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);  
    }
    
}