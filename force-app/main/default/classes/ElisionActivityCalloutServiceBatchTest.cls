@isTest
public class ElisionActivityCalloutServiceBatchTest {
    @isTest
    public static void executeTest() {
        lead l = new lead();
        l.ACM_Name__c = 'test';
        l.Phone = '9876543220';
        l.LeadSource = 'Other';
        insert l;
        Opportunity o = new Opportunity();
            o.Name = 'test';
            o.StageName = 'Proposal';
            o.CloseDate = system.today();
            insert o;
        API_Log__c a = new API_Log__c();
        a.Status__c = 'Exception Occurred';
        insert a;
        
        Task tas = new task();
        tas.WhoId = l.Id;
       // tas.WhatId = o.Id;
        tas.API_Log__c = a.Id;
        insert tas;
        test.startTest();
        ElisionActivityCalloutServiceBatch obj = new ElisionActivityCalloutServiceBatch();
        //ElisionActivityCalloutServiceBatch.getNextScheduleTime();
        database.executeBatch(obj);

        
         test.stopTest();
    }

    @isTest
    public static void setSchedule() {
        Test.startTest();
          ElisionActivityCalloutServiceBatch testsche = new ElisionActivityCalloutServiceBatch();
		String sch = '0 0 15 * * ?';
		system.schedule('Test status Check', sch, testsche );
        
         test.stopTest();
    }

}