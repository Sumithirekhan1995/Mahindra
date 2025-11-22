@isTest
public class BatchClassForUpdationOfLeadTest {
    static testmethod void testing() {
        Lead l =new Lead();
        l.FirstName = 'Virat';
        l.LastName = 'Anushka';
        l.Phone = '9902244646';
        l.LeadSource = 'Advertisement';
        insert l;
        l.ExtrnId_Phone__c = null;
        update l;
        
        Test.startTest();
        BatchClassForUpdationOfLead b = new BatchClassForUpdationOfLead();
        Database.executeBatch(b);
        Test.stopTest();
     }

}