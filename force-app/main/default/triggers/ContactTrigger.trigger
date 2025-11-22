//Added by Swetha
trigger ContactTrigger on Contact (before insert, before update, after insert, after update, before delete, after delete) {
    if(trigger.isBefore && trigger.isInsert){
        ContactTriggerHandler.mapAccountId();
    }
}