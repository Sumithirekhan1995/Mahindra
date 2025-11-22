public class SMSLogSelector {

    public static List<SMS_Log__c> getSMSLogData(set<Id> smsLogIds){
        
        System.debug('smsLogIds' + smsLogIds);
        Map<String, Schema.SObjectField> fieldMap = SMS_Log__c.sObjectType.getDescribe().fields.getMap();
        System.debug('fieldMap' + fieldMap);
        List<String> fieldNames = new List<String>();
        for(String s : fieldMap.keySet()){
            fieldNames.add(s);
        }
        System.debug('fieldNames' + fieldNames);
		String soqlQuery = ' SELECT ' + string.join(fieldNames, ',') + ',Lead__r.Phone FROM  SMS_Log__c Where Id =: smsLogIds';
        System.debug('Query'+soqlQuery);
        return Database.query(soqlQuery);
    }
}