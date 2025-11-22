//Added by Aravindan

@isTest
public class LogServiceTestClass {
    
    public static testmethod void LogTest(){
        List<Api_Log__c> lstapi = new List<Api_Log__c>();
        Api_Log__c api = new Api_Log__c();
        api.Response_Body__c = 'failedRec';
        api.Status__c = 'Failed';
        api.Tag__c = 'tag';
        lstapi.add(api);
        insert lstapi;
        
        Lead objLead = new Lead();
        objLead.Status = 'Open';
        objLead.LeadSource = 'Exotel';
        objLead.LastName = 'Exotel - 9876543210';
        objLead.Phone = '9876543210';
        insert objLead;
        
        DmlException d = new DmlException();
        LogService.insertGenericErrorLog(d, 'SFDC', 'Arithmetic'); 
        LogService.insertGenericErrorLog(d, 'Salesforce', 'NullPointer', 'errorRecords');
        LogService.createApiLogs('www.google.com', 'GET', 'Name', 'Success', 'true');
        LogService.createApiLogs('www.google.com', 'Success', 'true');
        LogService.createApiLogs(lstapi);
        Logservice.createApiLogs('www.google.com', 'Salesforce', 'Arithmetic', 'Success', 'true', objLead.Id, true);
    }

}