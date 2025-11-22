@isTest
public class BatchClassForUpdationOfAccountTest {
     static testmethod void test() {
        List<Account> accList = new List<Account>();
         Account acc = new Account();
         acc.Name = 'Brain Lara';
         acc.Phone = '8123565859';
         acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
         insert acc;
         acc.ExtrnId_Phone__c = null;
         update acc;

         Test.startTest();
         BatchClassForUpdationOfAccount b = new BatchClassForUpdationOfAccount();
         Database.executeBatch(b);
         Test.stopTest();
     }

}