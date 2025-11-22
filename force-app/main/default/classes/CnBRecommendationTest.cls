@isTest
public class CnBRecommendationTest {

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
        lea.LastName = 'test';
        lea.Phone = '9538017609';
        lea.Email = 'soumya@gmail.com';
        lea.Form_Type_Id__c = '4';
        lea.RecordTypeId = LeadConstants.CnBLeadRecordTypeId;
        lea.Car_Model_Id__c = '1517';
        lea.Status__c = '9';
        lea.Area_City__c = 'bglore';
        insert lea;
        
        String S = '[{"check":true,"id_car_model":"1562","manufacturer_name":"Tata","max_mileage":"24.00","max_price":"669990","min_mileage":"24.00","min_price":"669990","model_name":"Tiago JTP","rating":"7.5","status":"1"}]';
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new httpMockForReccommendation());
        CnBLeadWrapperClass.CnBResponseData rec = CnBRecommendationController.getCarRecommendations(lea.id);
        CnBRecommendationController.createLead(s, lea.Id, 'cross-sell');
        Lead lead1 = CnBRecommendationController.returnLead(lea.Id);
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
        lea.RecordTypeId = LeadConstants.CnBLeadRecordTypeId;
        lea.Car_Model_Id__c = '1517';
        lea.Status__c = '9';
        lea.Area_City__c = 'bglore';
        insert lea;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new httpMockForCarSearch());
        List<CnBLeadWrapperClass.CnBCalloutResponseData> search =  CnBRecommendationController.searchRecommendations('maruti', lea.Id);
        test.stopTest();
    }
}