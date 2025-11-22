@isTest
public class BatchToCaptureDateTimeTest {
	static testmethod void testing() {
        Account acc = new Account(name= 'ABC',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId());
        insert acc;
        lead l =new lead();
        l.lastname = 'D';
        l.Status = 'new';
        l.Phone = '9538017405';
        l.LeadSource = 'Advertisement';
        insert l;
        
    
        lead l1 =new lead();
        l1.id = l.Id;
        l1.lastname = 'D1';
        l1.Status = 'new';
        l1.Phone = '9538017405';
        l1.LeadSource = 'Advertisement';
        l1.CreatedDateTime__c = Null ;
        update l1;
        
        lead_dispatch__c ld = new Lead_dispatch__c();
        ld.dispatch_date__c ='06-03-2020 12:47';
        ld.Lead__c = l.id;
        insert ld;
        
        Opportunity opp =new Opportunity();
        opp.name = 'XYZ';
        opp.Dealer__c = acc.id;
        opp.Warranty_End_Date__c = '1/7/2019 12:00:00 AM';
        opp.Warranty_Start_Date__c = '1/7/2020 12:00:00 AM';
        opp.Warranty_Punched_Date__c = '1/7/2021 12:00:00 AM';
        opp.StageName = 'Qualification';
        opp.Lead_Dispatch__c = ld.id;
        opp.CloseDate = system.today()+5;
        insert opp;
        
        Opportunity opp1 =new Opportunity();
        opp1.name = 'XYZ';
        opp1.Dealer__c = acc.id;
        opp1.Warranty_End_Date__c = '1-7-2019';
        opp1.Warranty_Start_Date__c = '1-7-2020';
        opp1.Warranty_Punched_Date__c = '1-7-2021';
        opp1.StageName = 'Qualification';
        opp1.Lead_Dispatch__c = ld.id;
        opp1.CloseDate = system.today()+5;
        insert opp1;
        
        opp.Employee_Name__c = 'abc';
        opp.Lead__c = opp.Lead_Dispatch__r.lead__c;
        update opp;
        
        Test.startTest();
        BatchToCaptureLeadDateTime b1 = new BatchToCaptureLeadDateTime();
        Database.executeBatch(b1);
        Test.stopTest();
        
    }
}