// By Aravindan

@isTest
public class EntitySearchControllerTestClass {
    
    public static testmethod void EntitySearchTest() {
        		List<Id> AccountIds = new List<Id>();
        Account A = new Account();
        A.Name = 'Warp Test';
        A.Phone = '8892199321';
        A.RecordTypeId = AccountConstants.dealerAccountRecordTypeId;
        insert A;
        Account A1 = new Account();
        A1.Name = 'Warp Test';
        A1.Phone = '8892199322';
        A1.RecordTypeId = AccountConstants.dealerAccountRecordTypeId;
        insert A1;
        
        List<Id> ListofIds = new List<Id>();
        Lead lRec = new Lead();
        lRec.LastName = 'Test';
        lRec.Phone = '8400123412';
        lRec.Alternate_Mobile_Number__c = lRec.Phone;
        lRec.Source_Id__c = 'CreatedByMFCChatBot';
        lRec.Seller_State__c = 'Uttar Pradesh';
        lRec.Seller_City__c = 'Allahabad';
        lRec.Dealer_Code__c = '3936';
        lRec.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
        //lRec.Dealer__c = A1.Id;
        lRec.Bypass_validation__c = false;
        insert lRec;
        ListofIds.add(lRec.Id);

        
        Opportunity oRec = new Opportunity();
        oRec.Name = 'Test';
        oRec.Phone__c = lRec.Phone;
        oRec.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('Buyer_Used_Car').getRecordTypeId();
        oRec.StageName = 'Qualification';
        oRec.CloseDate = System.today();
        oRec.Lead__c = lRec.Id;
        oRec.Dealer__c = A1.Id;
        oRec.Status__c = 'Assigned';
        oRec.HI_Serviceable__c = '1';
        oRec.Remarks__c = 'test';
        oRec.HI_Preference__c = 'Home';
        oRec.Bypass_validation__c = false;
        oRec.LeadSource = 'Advertisement';
        insert oRec;
        
        AccountIds.add(A.Id);
        AccountIds.add(A1.Id);
        
        List<Id> productIds = new List<Id>();
        Product2 p = new Product2();
        p.Name = 'BMW';
        p.IsCertified__c = 'YES';
        insert p;
        productIds.add(p.Id);
        p.Id = null;
        p.Name = 'Test2';
        insert p;
        productIds.add(p.Id);
        String S = '{"spinner":true,"makeList":["ABC"],"modelList":["ABC"],"variantList":["ABC"],"bodyList":["ABC"],"fuelList":["ABC"],"TransmissionTypeList":["ABC"],"colorList":["ABC"],"modelYearList":["2018"],"modelMonthList":["1"],"certifiedList":["YES"],"dealerList":["ABC"],"cityList":["ABC"],"pincodeList":["560092"],"minKm":0,"maxKm":2000000,"minBudget":0,"maxBudget":100000000}';  
        String o = '{"spinner":true,"makeList":["ABC"],"modelList":["ABC"],"variantList":["ABC"],"bodyList":["ABC"],"fuelList":["ABC"],"TransmissionTypeList":["ABC"],"colorList":["ABC"],"modelYearList":["2018"],"modelMonthList":["1"],"certifiedList":["YES"],"dealerList":["ABC"],"cityList":["ABC"],"pincodeList":["560092"],"minKm":0,"maxKm":2000000,"minBudget":0,"maxBudget":100000000}';  
       
        EntitySearchController.getSearchResults(S,lRec.Id);
        EntitySearchController.getSearchResults(o,oRec.Id);
             
        
        
        String variant = 'HitchBack';
        EntitySearchController.fetchVariantValues(variant);
        EntitySearchController.getSearchDealerResults(S,lRec.Id);
        EntitySearchController.getSearchDealerResults(o,oRec.Id);
          

            
       
        
        LeadPushAPI__c LPA = new LeadPushAPI__c();
        LPA.Name = 'Lead Create';
        LPA.Endpoint__c = 'https://www.google.com';
        insert LPA;
		
        LeadPushAPI__c LPA1 = new LeadPushAPI__c();
        LPA1.Name = 'Lead Update';
        LPA1.Endpoint__c = 'https://www.facebook.com';
        insert LPA1;
        
        List<String> stringList = new List<String>();
        stringList.add('A');
        stringList.add('B');
        
        test.startTest();
   		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //EntitySearchController.createLeadDispatches(lRec.Id, productIds);
        EntitySearchController.getDependentMap(A,'Make__c', 'Model__c');
        //EntitySearchController.createDealerLeadDispatches(lRec.Id, AccountIds, 'Honda', 'City');
        //EntitySearchController.searchFilters instance1 = new EntitySearchController.searchFilters();
        //instance1.searchFilters(stringList,stringList,stringList,stringList,stringList,stringList,stringList,stringList,stringList,stringList,stringList,stringList,0,10000,0,100000);
        EntitySearchController.createOpportunity(lRec.Id, productIds);
        EntitySearchController.createOpportunity(oRec.Id, productIds);
        EntitySearchController.createDealerOpportunity(lRec.Id, AccountIds, 'Honda', 'City');
        EntitySearchController.createDealerOpportunity(oRec.Id, AccountIds, 'Honda', 'City');
        test.stopTest(); 
    }

}