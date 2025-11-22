@isTest
public class SMSDisplayControllerTestClass {
    
    public static testmethod void getTemplateTest()
    {
        
        Map<Id,SMS_Log__c> mapSmsLog = new Map<Id,SMS_Log__c>();
        Set<Id> leadId = new Set<Id>();
        
        Lead l = new Lead();
        l.LastName = 'test';
        l.Phone = '8123565656';
        l.LeadSource = 'Other';
        insert l;
        leadId.add(l.Id);
            
        SMS_Template__c S = new SMS_Template__c();
        S.Name = 'Quote Creation';
        S.Module__c = 'Sell Used Car';
        S.SMS_Body__c = 'this is sms template {!lead.lastname}';
        S.Trigger_Object__c = 'Lead';
        S.IsActive__c = true;
        insert S;
        
        Set<Id> oppId = new Set<Id>();
        Opportunity op = new Opportunity();
        op.lead__c = l.Id;
        op.Name = l.LastName;
        op.Phone__c =  l.Phone;
        op.LeadSource = l.LeadSource;
        op.StageName = 'New';
        op.CloseDate = system.today();
        insert op;
        oppId.add(op.Id) ;
        
        Account acc = new Account();
        acc.LastName = 'test';
        acc.RecordTypeId = AccountConstants.customerAccountRecordTypeId;
        insert acc;
        
        Contact co = new Contact();
        co.LastName = l.LastName;
        co.Phone = l.Phone;
        co.AccountId = l.Customer__c;
        insert co;
        
        Rp_Dealer__c rp =  new Rp_Dealer__c();
        rp.Name = 'test';
        insert rp;
        
       SMS_Log__c smsLog = new SMS_Log__c();
        smsLog.SMS_Body__c = '{! Test, your purchase of CertiFirst for vehicle  is successful! Please click on the link to view the warranty booklet For any other queries, please reach us on 18004194800Mahindra First Choice';
        smsLog.SMS_Template__c = S.Id;
        smsLog.Dealer__c = acc.Id;
        smsLog.Rp_Dealer__c = rp.Id;
        insert smsLog; 
        mapSmsLog.put(smsLog.Id,smsLog);
        
        GupShup_Endpoints__c G = new GupShup_Endpoints__c();
        G.Name ='abc';
        G.Password__c = 'abc';
        G.UserId__c = '123';
        G.Single_Message_Api_Key__c = 'avcd';
        G.Single_Message_Endpoint__c ='https://enterprise.smsgupshup.com/GatewayAPI/rest';
        insert G; 
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new GupShupTestMock());
        SMSLogService.sendParametersToUser(mapSmsLog);
        SMSLogService.sendSMS('test123',smsLog.Id);
        
        LeadSelector.getAllLeadData(leadId);
        OpportunitySelector.getAllOpportunityData(oppId);
        SMSDisplayController.getTemplate(l.Id);
        SMSDisplayController.getTemplate(S.Id);
        SMSDisplayController.getTemplate(op.Id);
        SMSDisplayController.getContacts(op.Id);
        SMSDisplayController.getContacts(l.Id);
        SMSDisplayController.getContacts(co.Id);
        SMSDisplayController.createSMSLog(l.id, S.id,'test', '1234567890');
        SMSDisplayController.createSMSLog(op.id, S.id,'test', '1234567890');
        test.stopTest();
        
    }

}