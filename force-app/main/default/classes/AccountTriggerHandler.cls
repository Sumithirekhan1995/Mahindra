public class AccountTriggerHandler{
    public static void onBeforeInsert(List<Account> newList){
        for(Account acc : newList){
            acc.ExtrnId_Phone__c = acc.Phone;
        }
    }
}