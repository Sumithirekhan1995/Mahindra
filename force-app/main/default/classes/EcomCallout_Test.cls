@isTest


public class EcomCallout_Test {
    
    public static testmethod void getEcomCallOutInfoTest()
    {
        Test.setMock(HttpCalloutMock.class, new EcomCalloutMock());
        Test.setMock(HttpCalloutMock.class, new LeadPushtoLMSMock());
        
        Set<Id> leaIds = new Set<Id>();
        
        CnB_Endpoint__c cnb = new CnB_Endpoint__c();
        cnb.BuyerToCnBEndpoint__c = 'test';
        cnb.Name = 'test';
        cnb.Password__c = 'test pass';
        cnb.Username__c = 'test uname';
        cnb.x_app_api_key__c = '123';
        cnb.x_app_api_secret__c = 'test';
        insert cnb;
        
        Lead lea = new Lead();
        Lea.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
        lea.LastName = 'Test lead';
        lea.Phone = '9538017402';
        lea.Lead_Flag__c = 'Reserve';
        lea.Status__c = 'Cold';
        lea.Follow_Up_Date_Time__c = System.now()+1;
        lea.FollowUp_Comments__c = 'test';
        lea.LeadSource = 'Advertisement';
        insert lea;
        
        lea.Status__c = 'Test Drive';
        //update lea;
        
        leaIds.add(lea.Id);
        
        
         test.startTest();
       	 EcomCallout.ecomLeads(leaIds);
         test.stopTest(); 
        
    }
    

}