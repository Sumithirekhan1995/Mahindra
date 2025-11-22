trigger TaskTrigger on Task (before insert, after insert, after Update, before delete) {

    System.debug('__TASK_TRIGGERED');
    if(Trigger.isInsert && Trigger.isBefore) {
        System.debug('__TASK_TRIGGERED __before insert');
        TaskTriggerHandler.onBeforeInsert(Trigger.New);
    }
    
    if(Trigger.isInsert && Trigger.isAfter){
        System.debug('__TASK_TRIGGERED __after insert');
        TaskTriggerHandler.UpdateLeadOwner(Trigger.New);
        TaskTriggerHandler.onAfterInsert(Trigger.New);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('__TASK_TRIGGERED __after update');
        TaskTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        for(Integer i = 0; i < Trigger.New.size(); i++) {
            SObject newObj = trigger.new[i];
            SObject oldObj = trigger.old[i]; 
            System.debug('__TaskId : ' + newObj.get('Id'));
            for(String fieldName : Schema.SObjectType.Task.fields.getMap().keySet()){ 
                if(newObj.get(fieldName) != oldObj.get(fieldName)){
                    System.debug('field: ' + fieldName + '[' + oldObj.get(fieldName) + ' => ' + newObj.get(fieldName) + ' ]');
                }  
            }
        }
        
        TaskTriggerHandler.updateCounter(Trigger.newMap, Trigger.oldMap);
    }
    
    if(Trigger.isDelete && Trigger.isBefore) {
        System.debug('__task deletion started');
        for(Task tRec : Trigger.Old) {
            //tRec.addError('Record can\'t be deleted');
            System.debug(tRec);
        }
    }
}