trigger AccountTrigger on Account (before insert) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            AccountTriggerHandler.onBeforeInsert(Trigger.new);
        }
    }
}