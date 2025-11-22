@isTest
public class CnBCalloutServiceTest {

    public static testmethod void test1(){
        CnB_Endpoint__c cnb = new CnB_Endpoint__c();
        cnb.Name = 'cnb';
        cnb.LeadStatusChange__c = 'www.test.com';
        cnb.NewBike_LeadStatus__c = 'www.test.com';
        cnb.NewBike_NewLead__c = 'www.test.com';
        cnb.x_app_api_key__c = 'test';
        cnb.x_app_api_secret__c = 'test';
        cnb.Username__c = 'test';
        cnb.Password__c = 'test';
        cnb.CreateNewLead__c = 'www.test.com';
        insert cnb;
        
        Lead lea = new Lead();
        lea.FirstName = 'test';
        lea.LastName = 'test';
        lea.Phone = '9538017609';
        lea.Email = 'soumya@gmail.com';
        lea.Form_Type_Id__c = '4';
        lea.RecordTypeId = LeadConstants.CnBLeadRecordTypeId;
        lea.Car_Model_Id__c = '1517';
        lea.Status__c = '9';
        lea.Area_City__c = 'bglore';
        lea.Is_Verified__c = '1';
        lea.Source_Id__c = '1234';
        lea.Area_PinCode__c = '591080';
        insert lea;
        Set<Id> leadset = new Set<Id>();
        leadSet.add(lea.Id);
        lea.Status__c = '1';
        update lea;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new httpMockForStatusChange());
        Test.setMock(HttpCalloutMock.class, new httpMockForNewLeadAPI());
        CnBCallOutService.NewLead(leadSet);
        test.stopTest();
    }
    
   
    public static testmethod void test2(){
        CnB_Endpoint__c cnb = new CnB_Endpoint__c();
        cnb.Name = 'cnb';
        cnb.LeadStatusChange__c = 'www.test.com';
        cnb.NewBike_LeadStatus__c = 'www.test.com';
        cnb.NewBike_NewLead__c = 'www.test.com';
        cnb.x_app_api_key__c = 'test';
        cnb.x_app_api_secret__c = 'test';
        cnb.Username__c = 'test';
        cnb.Password__c = 'test';
        cnb.CreateNewLead__c = 'www.test.com';
        insert cnb;
        
        Lead lea = new Lead();
        lea.LastName = 'test';
        lea.Phone = '9538017609';
        lea.Email = 'soumya@gmail.com';
        lea.Form_Type_Id__c = '4';
        lea.RecordTypeId = LeadConstants.CnBBikeLeadRecordTypeId;
        lea.Bike_Model_Id__c = '1517';
        lea.Status__c = '9';
        lea.Area_City__c = 'bglore';
        insert lea;
        Set<Id> leadset = new Set<Id>();
        leadSet.add(lea.Id);
        lea.Status__c = '1';
        update lea;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new httpMockForBikeStatusChange());
        Test.setMock(HttpCalloutMock.class, new httpMockForNewLeadBike());
        CnBCallOutService.NewLead(leadSet);
        test.stopTest();
    }
}