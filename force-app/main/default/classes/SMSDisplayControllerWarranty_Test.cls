@isTest
global class SMSDisplayControllerWarranty_Test {
    
    @isTest
    public static void getTemplateTest(){
        SMS_Template__c objSms = new SMS_Template__c();
        objSms.Name = 'Test Class';
        objSms.SMS_Body__c = 'Test Class';
        objSms.IsActive__c = True;
        objSms.Module__c = 'Buy Used Car Warranty';
        insert objSms;
        Test.startTest();
        SMSDisplayControllerWarranty.getTemplate(objSms.Id);
        Test.stopTest();
    } 
    
    @isTest
    public static void getContactsTest(){
        
        // test dealer
        Account a = new Account();
        a.Name = 'Dealer_Test';
        a.Code__c = '1234555';
        a.Active__c = true;
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        insert a;
        
        // test Lead
        Lead l = new Lead();
        l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Seller').getRecordTypeId();
        l.Phone = '9123456789';
        l.Status__c = 'Open';
        l.LeadSource = 'Advertisement';
        insert l;
        
        // insert opportunity Records
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
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
        insert opp;
        
        Warranty__c objWarranty = new Warranty__c();
        objWarranty.FollowUp_Lead__c = opp.Id;
        objWarranty.Customer_Phone__c = '9876543210';
        objWarranty.Customer_Name__c = 'Testing';
        objWarranty.Warranty_Type__c = 'CertiFirst';
        objWarranty.Status__c = 'Open';
        system.debug('Id+++ '+objWarranty);
        insert objWarranty;
        system.debug('Id+++ '+objWarranty);
        String warrantyId = objWarranty.Id;
        Test.startTest();
        SMSDisplayControllerWarranty.getContacts(warrantyId);
        Test.stopTest();
        
        
    }
    @isTest
    public static void createSMSLogTest() {
        
        Account a = new Account();
        a.Name = 'Dealer_Test';
        a.Code__c = '1234555';
        a.Active__c = true;
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        insert a;
        
        // test Lead
        Lead l = new Lead();
        l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Seller').getRecordTypeId();
        l.Phone = '9123456789';
        l.Status__c = 'Open';
        l.LeadSource = 'Advertisement';
        insert l;
        
        // insert opportunity Records
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
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
        insert opp;
        Warranty__c objWarranty = new Warranty__c();
        objWarranty.FollowUp_Lead__c = opp.Id;
        objWarranty.Customer_Name__c = 'Testing';
        objWarranty.Warranty_Type__c = 'CertiFirst';
        objWarranty.Status__c = 'Open';
        objWarranty.Customer_Phone__c = '9876543210';
        insert objWarranty;
        
        SMS_Template__c objSms = new SMS_Template__c();
        objSms.Name = 'Test Class';
        objSms.SMS_Body__c = 'Test Class';
        objSms.IsActive__c = True;
        objSms.Module__c = 'Buy Used Car Warranty';
        
        insert objSms;
        
        SMS_Log__c smsLog = new SMS_Log__c();
        smsLog.SMS_Template__c = objSms.Id;
        smsLog.Warranty__c = objWarranty.Id;
        smsLog.SMS_Body__c = 'TEsting';
        smsLog.Send_To__c= '6234567890';
        insert smsLog;
        
        test.startTest();
        SMSDisplayControllerWarranty.createSMSLog(objWarranty.Id, objSms.Id,smsLog.SMS_Body__c,smsLog.Send_To__c);
        test.stopTest();
    }
    
    @isTest
    public static void sendSMSTest() {
        Test.setMock(HttpCalloutMock.class, new MockClass());
        SMS_Template__c objSms = new SMS_Template__c();
        objSms.Name = 'Test Class';
        objSms.SMS_Body__c = 'Hi {!Warranty__c.Customer_Name__c}, your purchase of {!Warranty__c.Warranty_Type__c} for vehicle {!Warranty__c.Registration_Number__c} is successful! Please click on the link to view the warranty booklet {!Warranty__c.Generic_Booklet_URL__c}. For any other queries, please reach us on 18004194800-Mahindra First Choice';
        objSms.IsActive__c = True;
        objSms.Module__c = 'Buy Used Car Warranty';
        insert objSms;
        Account a = new Account();
        a.Name = 'Dealer_Test';
        a.Code__c = '1234555';
        a.Active__c = true;
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        insert a;
        
        Lead l = new Lead();
        l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Seller').getRecordTypeId();
        l.Phone = '9123456789';
        l.Status__c = 'Open';
        l.LeadSource = 'Advertisement';
        insert l;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
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
        insert opp;
        
        Warranty__c objWarranty = new Warranty__c();
        objWarranty.FollowUp_Lead__c = opp.Id;
        objWarranty.Customer_Name__c = 'Testing';
        objWarranty.Warranty_Type__c = 'CertiFirst';
        objWarranty.Status__c = 'Open';
        objWarranty.Customer_Phone__c = '9876543210';
        insert objWarranty;
        
        RP_Dealer__c objRpDealer = new RP_Dealer__c();
        objRpDealer.Name = 'Tester';
        insert objRpDealer;
        List<SMS_Log__c> lstLogs = new List<SMS_Log__c>();
        SMS_Log__c smsLog = new SMS_Log__c();
        smsLog.API_Request__c='strmsg';
        smslog.API_Response__c = 'fff';
        smslog.SMS_Body__c = 'Hi {!Warranty__c.Customer_Name__c}, your purchase of {!Warranty__c.Warranty_Type__c} for vehicle {!Warranty__c.Registration_Number__c} is successful! Please click on the link to view the warranty booklet {!Warranty__c.Generic_Booklet_URL__c}. For any other queries, please reach us on 18004194800-Mahindra First Choice';
        smslog.SMS_Template__c = objSms.Id;
        smslog.Lead__c = l.Id;
        smslog.Qualified_Lead__c = opp.Id;
        smslog.Dealer__c = a.Id;
        smslog.Warranty__c = objWarranty.Id;
        smslog.RP_Dealer__c = objRpDealer.Id;
        lstLogs.add(smslog);
        
        Set<Id> setIds = new Set<Id>();
        Set<Id> setId = new Set<Id>();
        //setIds.add(smslog.Id);
        setId.add(smslog.Id);
        insert smsLog;
        
        GupShup_Endpoints__c credentialObj = new GupShup_Endpoints__c();
        credentialObj.Single_Message_Endpoint__c = 'www.google.com';
        credentialObj.UserId__c = 'Arnav';
        credentialObj.Password__c = 'Passsword';
        credentialObj.Name = 'Mishal';
        setIds.add(credentialObj.Id);
        insert credentialObj;
        Map<Id,SMS_Log__c> mapLogs = new Map<Id,SMS_Log__c>();
        mapLogs.put(smslog.Id, smslog);
        test.startTest();
        SMSLogService.sendSMS('GET',smsLog.Id);
        SMSLogService.sendParametersToUser(mapLogs);
        Test.setMock(HttpCalloutMock.class, new MockClass());
        test.stopTest();
    }
    
    public class MockClass implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake responseg
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
}