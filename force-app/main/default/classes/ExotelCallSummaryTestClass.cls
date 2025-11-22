@isTest
public class ExotelCallSummaryTestClass {
    @isTest
    public static void ExotelTest()
    {
        String exotelOutGoingPhone = '8888777766';
        Id buyerLeadRecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Buyer_Used_Car').getRecordTypeId();
        String dealerRTId = AccountConstants.dealerAccountRecordTypeId;
        Account acc = new Account();
        acc.Name = 'test';
        acc.Exotel_Landing_Number__c = exotelOutGoingPhone;
        acc.BillingState = 'test';
        acc.RecordTypeId = dealerRTId;
        insert acc;

        Test.setMock(HttpCalloutMock.class, new MockHttpGenerator());
        List<Exotel_Call_Summary__c> Elist = new List<Exotel_Call_Summary__c>();
        List<Exotel_Call_Summary__c> Elist2 = new List<Exotel_Call_Summary__c>();
        Map<Id,Exotel_Call_Summary__c> mapExotel = new Map<Id,Exotel_Call_Summary__c>();
        Set<Id> exotelId = new Set<Id>();
        List<Id> lstId = new List<Id>();
        Exotel_Call_Summary__c E = new Exotel_Call_Summary__c();
        Exotel_Call_Summary__c E1 = new Exotel_Call_Summary__c();
        
        E.CallFrom__c = '9538017400';
        E.CallSid__c  = '6149bc6e965454f07c958465484a16ab';
        E.CallType__c = 'completed';
        E.CallTo__c = '9999999990';
        E.From__c = '9538017400';
        E.To__c = '8888777766';
        E.OutgoingPhoneNumber__c = exotelOutGoingPhone;
        E.Tenant_Id__c = '16184';
        E.Legs_0_Number__c = '02250111909';
        Elist.add(E);
        insert Elist;
        lstId.add(Elist[0].Id);
        exotelId.add(Elist[0].Id);
        mapExotel.put(Elist[0].Id,E);
        
        
      /*  E1.CallFrom__c = '9538017400';
        E1.CallSid__c  = '1234';
        E1.CallType__c = 'Exotel Missed';
        E1.CallTo__c = '9999999990';
        E1.From__c = '9538017400';
        E1.To__c = '8888777766';
        E1.OutgoingPhoneNumber__c = '8888777766';
        E1.Tenant_Id__c = '16184';
        E1.Legs_0_Number__c = '02250111909';
        Elist2.add(E1);
        insert Elist2;*/

        /*Exotel_Call_Summary__c E1 = new Exotel_Call_Summary__c();
        E1.CallFrom__c = '9538017406';
        E1.CallSid__c  = '12345';
        E1.CallType__c = 'completed';
        E1.CallTo__c = '9999999997';
        E1.From__c = '8123565656';
        E1.DialWhomNumber__c = '09930037047';
        E.To__c = '8888777766';
        insert E1; */
        
        
        
        Lead l = new Lead();
        l.LastName = 'test';
        l.Phone = Elist[0].CallFrom__c;
        l.LeadSource = 'Exotel';
        l.Exotel_Repeat__c = false;
        l.State = 'test';
        l.Status__c = 'test';
        l.Status = 'test';
        l.RecordTypeId = buyerLeadRecordTypeId;
        insert l;
        
       
        
       
        List<Opportunity> lstOpp = new List<Opportunity>();
        opportunity opp = new Opportunity();
        opp.name = 'test OPP';
        opp.Dealer_Phone__c = exotelOutGoingPhone;
        opp.Exotel_Call__c = Elist[0].Id;
        opp.LeadSource = 'Exotel';
        opp.Dealer__c = acc.Id;
        opp.Status__c = 'New';
        opp.Exotel_Repeat__c = false;
        opp.Customer_Phone__c = Elist[0].From__c;
        opp.Lead__c = l.id;
        opp.StageName = 'New';
        opp.CloseDate = date.today();
        lstOpp.add(opp);
        insert opp;
        
        ExotelAuthDetails__c objExotelAuth = new ExotelAuthDetails__c();
        objExotelAuth.username__c = 'Test123';
        objExotelAuth.password__c = 'testg123';
        objExotelAuth.Name = 'teszt123';
        insert objExotelAuth;
        
        List<Exotel_Call_Summary__c> Elist1 = [SELECT OutgoingPhoneNumber__c,From__c,CallFrom__c,Tenant_Id__c FROM Exotel_Call_Summary__c WHERE CallFrom__c ='9538017400'];
        for(Exotel_Call_Summary__c objExotel:Elist1) {
            objExotel.OutgoingPhoneNumber__c = '8888777767';
        }
        update Elist1;
		test.startTest();
        ExotelCallSummaryTriggerHelper.createLeadRecord(Elist);
        ExotelCallSummaryTriggerHelper.callExotelCallout(exotelId);
        ExotelCallSummaryTriggerHandler.callHelper(lstId);
        ExotelCallSummaryTriggerHandler.onAfterUpdate(Elist,mapExotel);
        
		test.stopTest();        
        
       //Opportunity opp2 = [select id,name,Dealer_Phone__c, Exotel_Call__c,dealer__r.Exotel_Landing_Number__c, Status__c,Dealer__c, Exotel_Repeat__c,Customer_Phone__c,Lead__c from Opportunity where Dealer__c IN :Acc.Id AND Status__c != 'Sold' AND Status__c != 'Lost' AND dealer__r.Exotel_Landing_Number__c != NULL AND dealer__r.Exotel_Landing_Number__c IN :E.OutgoingPhoneNumber__c AND Customer_Phone__c =:E.From__c];
        //    system.debug('opp2: '+opp2);
        //Elist.add(E);
        // Elist.add(E1);      
        /*      
    for(Opportunity o : [
        select id,name,Dealer_Phone__c, Exotel_Call__c,dealer__r.Exotel_Landing_Number__c, 
        Status__c,Dealer__c, Exotel_Repeat__c,Customer_Phone__c,Lead__c 
        from Opportunity 
        where Dealer__c IN :AccId 
        AND Status__c != 'Sold' 
        AND Status__c != 'Lost' 
        AND dealer__r.Exotel_Landing_Number__c != NULL 
        AND dealer__r.Exotel_Landing_Number__c IN :dealerPhones 
        AND Customer_Phone__c != null 
        AND Customer_Phone__c IN :customerPhones]){*/
        
        
    }
    


public class MockHttpGenerator implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Call":{"Sid":"6149bc6e965454f07c958465484a16ab","ParentCallSid":"","DateCreated":"2022-10-11 09:56:20","DateUpdated":"2022-10-11 10:00:11","AccountSid":"mahindra7","To":"02250111909","From":"07588425495","PhoneNumberSid":"09513881992","Status":"completed","StartTime":"2022-10-11 09:56:20","EndTime":"2022-10-11 09:58:47","Duration":"147","Price":"2.050000","Direction":"inbound","AnsweredBy":"human","ForwardedFrom":"","CallerName":"","Uri":"v1Accountsmahindra7Calls6149bc6e965454f07c958465484a16ab","RecordingUrl":"https:s3-ap-southeast-1.amazonaws.comexotelrecordingsmahindra76149bc6e965454f07c958465484a16ab.mp3"}}');
        res.setStatusCode(200);
        return res;
    }
}
}