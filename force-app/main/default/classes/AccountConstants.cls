/*
 * Class created by Deepali
 * Purpose: To keep all constants associated with Account in one class
*/
public class AccountConstants {
    
    //Added by Deepali
    //to get Account recordtypeId 
    public static Id customerAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
    public static Id dealerAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();

}