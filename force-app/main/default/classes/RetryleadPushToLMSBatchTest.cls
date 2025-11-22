@isTest
public class RetryleadPushToLMSBatchTest {
 @isTest
    public static void testAll() {
        
        Lead l = new Lead();
        l.LastName = 'Test';
        l.LeadSource = 'cnB';
        l.Phone = '8989876789';
        l.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
        l.Company = 'Quadrafort';
         insert l;
        
        API_Log__c apiLog = new API_Log__c();
            apiLog.Lead__c = l.Id;
            apiLog.Status__c = 'AUTH_ENDPOINT_ERROR';
            apiLog.Tag__c = 'BUC LMS Lead Callout';
            apiLog.Failed_Retry_Count__c = null;
        
        insert apiLog;
        

        
        Test.startTest();
        RetryleadPushToLMSBatch batchJob = new RetryleadPushToLMSBatch();
        ID batchProcessId = Database.executeBatch(batchJob);
        Test.stopTest();
    }
    
    @isTest
    static void testScheduledTrigger() {
        // Schedule the job
        Test.startTest();
        Datetime currentTime = System.now();
        String cronExp = '0 1 * * * ?';
        System.schedule('TestRetryleadPushToLMSBatch', cronExp, new RetryleadPushToLMSBatch());
        Test.stopTest();

    }
 
}