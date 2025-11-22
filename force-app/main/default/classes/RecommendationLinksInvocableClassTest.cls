@isTest
public class RecommendationLinksInvocableClassTest {

    public static testmethod void testmethod1(){
        Account acc = new Account();
        acc.Name = 'test';
        acc.Code__c = '123';
        acc.BillingCity = 'Banglaore';
        acc.RecordTypeId = AccountConstants.dealerAccountRecordTypeId;
        insert acc;
        
        Product2 pd = new Product2();
        pd.Name = 'test';
        pd.Dealer_Name__c = acc.Id;
        pd.Make__c = 'Maruti Suzuki';
        pd.Model__c = 'Dezire';
        pd.Stock_URL__c = 'ww.com';
        pd.IsActive = true;
        insert pd;
        
        RecommendationLinksInvocableClass.TranscriptInput i = new RecommendationLinksInvocableClass.TranscriptInput();
        i.City = 'Bangalore';
        i.MakeModelValue = 'Maruti Suzuki Dezire';
        
        List<RecommendationLinksInvocableClass.TranscriptInput> input = new List<RecommendationLinksInvocableClass.TranscriptInput>();
        input.add(i);
        
        test.startTest();
        List<List<String>> returnVal = RecommendationLinksInvocableClass.sendWebsiteLink(input);
        test.stopTest();
    }
}