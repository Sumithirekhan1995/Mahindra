@isTest
public class RetryleadPushToLMSOppBatchTest {
    @isTest
    public static void testAll() {
        
        Opportunity o = new Opportunity();
        o.Name = 'test';
        o.StageName = 'Proposal';
        o.CloseDate = system.today();
        insert o;
        
        
        
        API_Log__c apiLog = new API_Log__c();
        apiLog.Opportunity__c = o.Id;
        apiLog.Status__c = 'AUTH_ENDPOINT_ERROR';
        apiLog.Tag__c = 'BUC LMS Opp Callout';
        apiLog.Failed_Retry_Count__c = null;
        
        insert apiLog;
        
        
        
        Test.startTest();
        RetryleadPushToLMSOppBatch batchJob = new RetryleadPushToLMSOppBatch();
        ID batchProcessId = Database.executeBatch(batchJob);
        Test.stopTest();
    }
    
    @isTest
    static void testScheduledTrigger() {
        // Schedule the job
        Test.startTest();
        Datetime currentTime = System.now();
        String cronExp = '0 1 * * * ?';
        System.schedule('TestRetryleadPushToLMSoppBatch', cronExp, new RetryleadPushToLMSOppBatch());
        Test.stopTest();

    }
 
}