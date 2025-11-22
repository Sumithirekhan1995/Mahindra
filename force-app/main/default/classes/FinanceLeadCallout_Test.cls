@isTest
public class FinanceLeadCallout_Test {
    
    @isTest 
    public static void getFinanceLeadInfoTest() {
		
        
        
		Email__c mail = new Email__c();
        mail.Name = 'test Email';
		mail.Person_Email__c = 'test@test.co';
        insert mail;
        
        Finance_Auth_Details__c fin = new Finance_Auth_Details__c();
        fin.Username__c = 'test';
        fin.Password__c = 'test';
        fin.Name = 'test';
        fin.Endpoint__c = 'ibbAuth';
        fin.NonQualified_R2W_Endpoint__c = 'nonQualify';
        fin.EndPoint_for_Finance_Lead_Data__c = 'ibb';
        insert fin;
        
        // mmfsl
        Fin_MMFSL__c f = new Fin_MMFSL__c();
        f.Name = 'test Fin_MMFSL__c';
        f.endpoint__c = 'mmfsl';
        f.client_id__c = 'test client Id';
        f.subscriber_code__c = 'test subscriber code';
        insert f;
        
        Branch__c b = new Branch__c();
        b.Name = 'Bangalore Branch';
        b.Branch_Code__c = '0907';
        insert b;
        
        
        Executive__c e = new Executive__c();
        e.Branch__c = b.id;
        e.Name = 'Sam';
        e.Executive_Id__c = '12765';
        insert e;
        
        Set<Id> leadIds = new Set<Id>();
        
        lead l = new lead();
        l.Branch_Related__c = b.id;
        l.Executive_Related__c = e.Id;
        l.firstName = 'Test';
        l.LastName = 'Purnima';
        l.Phone = '8989878788';
        l.MFCW_Id__c = '123987';
        l.Status__c = 'More Info';
        l.RecordTypeId = LeadConstants.financeLeadRecordTypeId;
        l.LeadSource = 'R2W';
        l.Lead_For__c = 'BLM';
        l.Exe_Id__c = '234123';
        l.Seller_State__c = 'Karnataka';
        l.Given_For__c = 'Refinance';
        l.cc_remarks__c = 'Test test';
        l.First_Contacted_Date__c = System.now();
        insert l;
        
        List<Lead> leads = new List<Lead>();
        leads.add(l);
        leadIds.add(l.Id);
        
        l.Status__c = 'Hot';
        update l;
        
        leads.add(l);
        
      //  Test.setMock(HttpCalloutMock.class, new Test_FinHTTPMock.mockAll());
                
        List<Lead> leadList = new List<Lead>();
        leadList.add(l);
        test.startTest();
        
        //FinanceLeadCallout.requestHandler('GET', ';', '',2000);
        
        //FinanceLeadCallout.pushNonQualifiedR2WLeads(leadIds);
        FinanceLeadCallout.notifyError('functionName', 'customMsg');
        
        //FinanceLeadCallout.getMMFSLLeadDetails(leadList);
        
        f.endpoint__c = 'mmfslFail';
        update f;
        
        
        
        fin.EndPoint_for_Finance_Lead_Data__c = 'ibbFail';
        update fin;
        
        l.Status__c = 'Cold';
		CheckRecursiveTrigger.callMMFSL = true;
        CheckRecursiveTrigger.callIBB = true;
        update l;
        
        FinanceLeadCallout.requestHandler('test123','test123','test123',10);
        //FinanceLeadCallout.getMMFSLLeadDetails(leadList);
        
        test.stopTest();  
    }
}