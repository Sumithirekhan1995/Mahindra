trigger SMSLogTrigger on SMS_Log__c (before insert, after insert) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            SMSLogTriggerHandler.onBeforeInsert(Trigger.new);
        }
    }
    else{
        if(Trigger.isInsert){
            SMSLogTriggerHandler.onAfterInsert(Trigger.newMap);
        }
    }
}