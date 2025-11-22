//Added by Swetha
public class ContactTriggerHandler {
    public static void mapAccountId(){
        Set<String> dealerCodes = new Set<String>();
        Map<String,Id> dealerMap = new Map<String,Id>();
        String dealerRtId = AccountConstants.dealerAccountRecordTypeId;
        for(Contact c : (List<Contact>)trigger.new){
            dealerCodes.add(c.Dealer_Code__c);
        }
        for(Account acc : [select id, Code__c  from Account where Code__c in:dealerCodes And RecordTypeId =: dealerRtId]){
            dealerMap.put(acc.Code__c, acc.Id);
        }
        for(Contact c : (List<Contact>)trigger.new){
            c.AccountId = dealerMap.get(c.Dealer_Code__c)!=null?dealerMap.get(c.Dealer_Code__c):null;
        }
    }
}