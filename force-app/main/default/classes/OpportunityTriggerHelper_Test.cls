@isTest
public class OpportunityTriggerHelper_Test {
    
    static{
        Account a1 = new Account();
        a1.Name = 'Dealer Test1';
        a1.Code__c = '12345355';
        a1.Active__c = true;
        a1.Dealer_Address_Map_Link__c = 'www.test.com';
        a1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        insert a1;
        
        Lead l = new Lead();
        l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Seller').getRecordTypeId();
        l.Phone = '6232123213';
        l.Status__c = 'Open';
        l.LeadSource = 'Advertisement';
        l.LastName = 'test';
        l.WhatsApp_consent__c = '1';
        insert l;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'M3Opp2';
        opp2.Phone__c = '7398123105';
        opp2.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('New_Car').getRecordTypeId();
        opp2.StageName = 'Qualification';
        opp2.CloseDate = System.today();
        opp2.Lead__c = l.Id;
        opp2.Dealer__c = a1.Id;
        opp2.Status__c = 'Hot';        
        opp2.HI_Serviceable__c = '1';
        opp2.Remarks__c = 'test';
        opp2.HI_Preference__c = 'Home';
        opp2.LeadSource = 'Advertisement';
        opp2.DealerName__c = 'Dealer_Test';
        opp2.Opp_Whatsapp_Consent__c = '0';
        insert opp2;
        
        SMS_Template__c stRec = new SMS_Template__c();
        stRec.Name = 'Hi FollowUp SMS';
        stRec.Module__c = 'Buy Used Car';
        stRec.SMS_Body__c = 'Test';
        stRec.isActive__c = true;    
        insert stRec;
        
        stRec = new SMS_Template__c();
        stRec.Name = 'HI FollowUp WIth Link';
        stRec.Module__c = 'Buy Used Car';
        stRec.SMS_Body__c = 'Test';
        stRec.isActive__c = true;    
        insert stRec;
        
        stRec = new SMS_Template__c();
        stRec.Name = 'HI_VTBA_FollowUp_Home';
        stRec.Module__c = 'Buy Used Car';
        stRec.SMS_Body__c = 'Test';
        stRec.isActive__c = true;    
        insert stRec;
        
        stRec = new SMS_Template__c();
        stRec.Name = 'HI_VBTA_FollowUp_Store';
        stRec.Module__c = 'Buy Used Car';
        stRec.SMS_Body__c = 'Test';
        stRec.isActive__c = true;    
        insert stRec;
    }
    
    public static testmethod void method3(){
    	Account a1 = [Select id from Account where Name = 'Dealer Test1'];
        
        Lead l = [Select id from Lead where Phone = '6232123213'];
        
        Opportunity opp2 = [Select id from Opportunity where name = 'M3Opp2'];

        test.startTest();
        //insert opp2;
        opp2.Opp_Whatsapp_Consent__c = '1';
        update opp2;
        test.stopTest();
    }
    
    public static testmethod void method4(){
    	Account a1 = [Select id from Account where Name = 'Dealer Test1'];
        
        Lead l = [Select id from Lead where Phone = '6232123213'];
        
        Opportunity opp2 = [Select id from Opportunity where name = 'M3Opp2'];

        test.startTest();
        opp2.Status__c = OpportunityConstants.Status_Rescheduled;
        opp2.HI_Preference__c = 'Home';
        update opp2;
        opp2.Status__c = 'Evaluated';
        opp2.HI_Serviceable__c = '1';
        update opp2;
        opp2.Status__c = 'Evaluated with report link';
        update opp2;
        opp2.Status__c = OpportunityConstants.Status_Rescheduled;
        opp2.HI_Preference__c = 'Store';
        update opp2;
        test.stopTest();
    }
    
    public static testmethod void method2(){
        
        Account a1 = [Select id from Account where Name = 'Dealer Test1'];
        
        Account a2 = new Account();
        a2.Name = 'Dealer Test2';
        a2.Code__c = '12355';
        a2.Active__c = true;
        a2.Dealer_Address_Map_Link__c = 'www.test.com';
        a2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        insert a2;
        
        Test.setMock(HttpCalloutMock.class, new MockAll());
        
        Lead l = new Lead();
        l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Seller').getRecordTypeId();
        l.Phone = '9123456789';
        l.Status__c = 'Open';
        l.LeadSource = 'Advertisement';
        l.LastName = 'test';
        l.WhatsApp_consent__c = '1';
        insert l;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test21';
        opp2.Phone__c = '7398123105';
        opp2.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('New_Car').getRecordTypeId();
        opp2.StageName = 'Qualification';
        opp2.CloseDate = System.today();
        opp2.Lead__c = l.Id;
        opp2.Dealer__c = a1.Id;
        opp2.Status__c = 'Hot';        
        opp2.HI_Serviceable__c = '1';
        opp2.Remarks__c = 'test';
        opp2.HI_Preference__c = 'Home';
        opp2.LeadSource = 'Advertisement';
        opp2.DealerName__c = 'Dealer_Test';
        insert opp2;
        
        Opportunity opp3 = new Opportunity();
        opp3.Name = 'Test211';
        opp3.Phone__c = '7398423905';
        opp3.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('Buyer_Used_Car').getRecordTypeId();
        opp3.CloseDate = System.today();
        opp3.Lead__c = l.Id;
        opp3.Dealer__c = a2.Id;
        opp3.Status__c = 'Hot';        
        opp3.HI_Serviceable__c = '1';
        opp3.Remarks__c = 'test';
        opp3.HI_Preference__c = 'Home';
        opp3.LeadSource = 'Advertisement';
        opp3.StageName = 'New';
        opp3.DealerName__c = 'Dealer_Test';
        insert opp3;
        
        List<Opportunity> lOpp = new List<Opportunity> ();
        lOpp.add(opp3);
        
        Map <Id,List<Opportunity> > mOpp = new Map<Id,List<Opportunity>>();
        mOpp.put(l.Id, lOpp);
        
        test.startTest();
        
        OpportunityTriggerHelper.updateLead(mOpp);
        Map<Id, Account> dealerIdToAddressLinkMap = new Map<Id, Account>();
        dealerIdToAddressLinkMap.put(opp3.Dealer__c, a2);
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        oppMap.put(opp3.Id, opp3);
        WhatsappMessageTemplateHandler.getOppMsgMap(oppMap, 'Walkin_Alert_6646765', dealerIdToAddressLinkMap);
        test.stopTest();
    }
    
    public static testmethod void OpportunityTriggerHelper(){
        
        // test dealer
        Account a = new Account();
        a.Name = 'Dealer_Test';
        a.Code__c = '1234555';
        a.Active__c = true;
        a.Dealer_Address_Map_Link__c = 'www.test.com';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        insert a;
                
        // SMSs endpoints
        GupShup_Endpoints__c endpoints = new GupShup_Endpoints__c();
        endpoints.Name = 'Test';
        endpoints.Single_Message_Endpoint__c = 'Test';
        endpoints.UserId__c = 'test';
        endpoints.Password__c = 'test';
        insert endpoints;
        
        // mock SMS
        Test.setMock(HttpCalloutMock.class, new MockAll());
        
        // SMS Template
        SMS_Template__c template = new SMS_Template__c();
        template.isActive__c = true;
        template.Name = 'HI_VTBA_FollowUp_Home';
        template.SMS_Body__c = 'Test_body {!Lead.Name} {!Dealer.Name}';
        template.Module__c = 'Finance';
        insert template;
        
        // test Lead
        Lead l = new Lead();
        l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Seller').getRecordTypeId();
        l.Phone = '9123456789';
        l.Status__c = 'Open';
        l.LeadSource = 'Advertisement';
        l.LastName = 'test';
        l.WhatsApp_consent__c = '1';
        insert l;
        
        // insert opportunity Records
        set<Id> cnbIdset = new set<Id>();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test1';
        opp.Phone__c = l.Phone;
        opp.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('Seller_Car').getRecordTypeId();
        opp.StageName = 'Qualification';
        opp.CloseDate = System.today();
        opp.Lead__c = l.Id;
        opp.Dealer__c = a.Id;
        opp.Status__c = 'Assigned';
        opp.HI_Serviceable__c = '1';
        opp.Remarks__c = 'test';
        opp.HI_Preference__c = 'Home';
        opp.Bypass_validation__c = false;
        opp.LeadSource = 'Advertisement';
        opp.DealerName__c = 'Dealer_Test';
        insert opp;
        cnbIdset.add(opp.Id); 
        
        Product2 prod = new Product2();
        prod.Dealer_Name__c = a.Id;
        prod.Name = 'Honda';
        prod.Body_Type__c ='Shield';
        prod.Color__c = 'Black';
        prod.Stock_ID__c = '12345';
        insert prod;
        
        Opportunity oppMsg = new Opportunity();
        oppMsg.Name = 'Test1';
        oppMsg.Phone__c = l.Phone;
        oppMsg.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('Buyer_Used_Car').getRecordTypeId();
        oppMsg.StageName = 'Qualification';
        oppMsg.CloseDate = System.today();
        oppMsg.Lead__c = l.Id;
        oppMsg.Dealer__c = a.Id;
        oppMsg.Status__c = 'Assigned';
        oppMsg.HI_Serviceable__c = '1';
        oppMsg.Remarks__c = 'test';
        oppMsg.HI_Preference__c = 'Home';
        oppMsg.Bypass_validation__c = false;
        oppMsg.LeadSource = 'Advertisement';
        oppMsg.Lead_Flag__c = 'getseller';
        oppMsg.Product__c = prod.Id;
        oppMsg.DealerName__c = 'Dealer_Test';
        insert oppMsg;
        
        oppMsg.status__c = 'No response';
        oppMsg.No_Response_Count__c = 3;
        update oppMsg;
                
        CnB_Endpoint__c obj = new CnB_Endpoint__c();
        obj.Name = 'ssss';
        obj.x_app_api_key__c = 'test';
        obj.x_app_api_secret__c = 'test';
        obj.Username__c = 'Username';
        obj.Password__c = '12333221';
        obj.BuyerToCnBEndpoint__c = 'sjjkdk';
        insert obj;
        
        opp.Lead__c = l.Id;
        opp.Remarks__c = 'test1';
        opp.Status__c = 'Sold';        
        opp.RecordTypeId = OpportunityConstants.buyerOppRecordTypeId;
        opp.Bypass_validation__c = false;
        opp.Warranty_Status__c = 'Verified';
      //  update opp;
        
        
        test.startTest();
        
        OpportunityTriggerHelper.cnbCallout(cnbIdset);
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        oppMap.put(oppMsg.Id, oppMsg);
        Map<Id, Account> dealerIdToAddressLinkMap = new Map<Id, Account>();
        dealerIdToAddressLinkMap.put(oppMsg.Dealer__c, a);
        WhatsappMessageTemplateHandler.getOppMsgMap(oppMap, 'TDScheduled_6646756', null);
        WhatsappMessageTemplateHandler.getOppMsgMap(oppMap, 'Walkin_Alert_6646765', dealerIdToAddressLinkMap);
        
        test.stopTest();
    }
    
    @isTest
    public static void ownerUpdateOnOpportunityTest() {
        Map<Id, Id> oppMap = new Map<Id, Id>();
        Set<String> newlist = new Set<String>();
        Test.startTest();
        OpportunityTriggerHelper.ownerUpdateOnOpportunity(oppMap, newList);
        Test.stopTest();
    }
    
      @isTest
    public static void ownerInsertOnOpportunityTest() {
        Map<Id, Id> oppMap = new Map<Id, Id>();
        Set<Id> newlist = new Set<Id>();
        Test.startTest();
        OpportunityTriggerHelper.ownerInsertOnOpportunity(oppMap, newList);
        Test.stopTest();
    }
    
    @isTest
    public static void ownerChangeExceptionTest() {
        List<Opportunity> opList = new List<Opportunity>();
        Opportunity o = new Opportunity();
        
    OpportunityTriggerHelper.ownerChangeException(opList);
        }
    public class MockAll implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertNotEquals(null, req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            if(req.getEndpoint().contains('ibbAuthSuccess')) {
                res.setBody('{"status":"success","status_code":200,"access_token":"nY5cGouW507wH2DvqUMWBMo5aFgq8TbAnr8ulSu","expires_at":"2020-09-12 18:08:50"}');
            } 
            return res;
            
        }
    }
}