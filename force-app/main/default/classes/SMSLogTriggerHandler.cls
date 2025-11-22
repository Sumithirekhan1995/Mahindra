public class SMSLogTriggerHandler {
    public static void onBeforeInsert(List<SMS_Log__c> newList){
        SMSLogService.generateSMSContent(newList);
    }
    public static void onAfterInsert(Map<Id,SMS_Log__c> newMap){
        SMSLogService.sendParametersToUser(newMap);

    }
}