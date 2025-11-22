@isTest
public class TestVFController {
    
    @isTest
    public static void testVF()
    {
        
        Lead l1=new Lead();
        l1.FirstName='test1';
        l1.LastName='test2';
        l1.Phone='9677867876';
        l1.HI_Serviceable__c='1';
        l1.CTIDuplicate__c = false;
        l1.LeadPushed__c = false;
        l1.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
        l1.LeadSource='Advertisement';
        insert l1;
        Test.startTest();
        PageReference pageRef=Page.InputStartEndTime;
        pageRef.getParameters().put('19/04/2022, 1:25 pm','26/04/2022, 1:25 pm');
        
        Test.setCurrentPage(pageRef);
        VFController ob=new VFController();
        ob.inputOne = '19/04/2022, 1:25 pm';
        ob.inputTwo = '26/04/2022, 1:25 pm';
        ob.submit();
        Test.stopTest();
        
        
        
    }

}