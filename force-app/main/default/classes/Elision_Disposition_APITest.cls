@isTest
public class Elision_Disposition_APITest {
    
    @isTest
    public static void testAll(){
        Id stExam = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Buyer Used Car').getRecordTypeId();
        
        Lead le=new Lead(RecordTypeId=stExam,Phone='7042125628',LeadSource='Advertisement', Buying_Time__c = 'Within 8 days');
        insert le;
        
        //StageName, CloseDate]: [StageName, CloseDate]
        Opportunity opp = New Opportunity();
        opp.name = 'test';
        opp.StageName = 'Qualified';
        opp.CloseDate = system.today();
        opp.status__c = 'No Response';
        opp.No_Response_Count__c = 3;
        
        insert opp;
        Task tRec = new Task();       
        tRec.WhatId = opp.Id;
        tRec.Subject = 'Elision BUC Call';
        insert tRec;
        
        Task tRec2 = new Task();       
        tRec2.WhoId = le.Id;
        tRec2.Subject = 'Elision BUC Call';
        insert tRec2;
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
        String jsondata='{"disposition": "","agent_id": "123","agent_FullName":"","list_id":"213","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"121212","campaign":"1212","all_lead_details":"","call_start_time":"121","call_end_time":"1212","hangup_reason":"1212","call_type":"","talktime":"1212","call_count":"1212","recordId":""}';
        req.requestURI='/services/apexrest/elision/disposition';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsondata);   
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Elision_Disposition_APITest.MockCallout());
        //Elision_Disposition_API.postHandler();   
        Elision_Disposition_API.postDisposition(req);             
        
        jsondata='{"disposition": "B","agent_id": "123","agent_FullName":"","list_id":"213","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"121212","campaign":"1212","all_lead_details":"","call_start_time":"121","call_end_time":"1212","hangup_reason":"1212","call_type":"","talktime":"1212","call_count":"1212","recordId":""}';
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "","agent_FullName":"","list_id":"213","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"121212","campaign":"1212","all_lead_details":"","call_start_time":"121","call_end_time":"1212","hangup_reason":"1212","call_type":"","talktime":"1212","call_count":"1212","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata);  
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "123","agent_FullName":"","list_id":"","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"121212","campaign":"1212","all_lead_details":"","call_start_time":"121","call_end_time":"1212","hangup_reason":"1212","call_type":"","talktime":"1212","call_count":"1212","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"","campaign":"1212","all_lead_details":"","call_start_time":"121","call_end_time":"1212","hangup_reason":"1212","call_type":"","talktime":"1212","call_count":"1212","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"","all_lead_details":"","call_start_time":"121","call_end_time":"1212","hangup_reason":"1212","call_type":"","talktime":"1212","call_count":"1212","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"","call_end_time":"1212","hangup_reason":"1212","call_type":"","talktime":"1212","call_count":"1212","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"","hangup_reason":"1212","call_type":"","talktime":"1212","call_count":"1212","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"2345","call_start_time":"121","call_end_time":"12345","hangup_reason":"","call_type":"456","talktime":"1212","call_count":"1212","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "BTT","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "CALLBK","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "LB","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "IB","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        
        jsondata='{"disposition": "RESD","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "BFRMFC","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "HT","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "WM","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "CLD","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "ABT","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        
        //ElisionDispositionService test starts
        jsondata='{"disposition": "ABT","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "","agent_FullName":"","list_id":"213","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"121212","campaign":"1212","all_lead_details":"","call_start_time":"121","call_end_time":"1212","hangup_reason":"1212","call_type":"","talktime":"1212","call_count":"1212","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata);  
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "123","agent_FullName":"","list_id":"","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"121212","campaign":"1212","all_lead_details":"","call_start_time":"121","call_end_time":"1212","hangup_reason":"1212","call_type":"","talktime":"1212","call_count":"1212","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"","campaign":"1212","all_lead_details":"","call_start_time":"121","call_end_time":"1212","hangup_reason":"1212","call_type":"","talktime":"1212","call_count":"1212","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"","all_lead_details":"","call_start_time":"121","call_end_time":"1212","hangup_reason":"1212","call_type":"","talktime":"1212","call_count":"1212","recordId":""}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"","call_end_time":"1212","hangup_reason":"1212","call_type":"","talktime":"1212","call_count":"1212","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"","hangup_reason":"1212","call_type":"","talktime":"1212","call_count":"1212","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"2345","call_start_time":"121","call_end_time":"12345","hangup_reason":"","call_type":"456","talktime":"1212","call_count":"1212","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "BTT","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "CALLBK","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "LB","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "Enquir","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "VENA","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "BoVeh","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "BV","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "IB","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        
        jsondata='{"disposition": "RESD","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "BFRMFC","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "HT","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "WM","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "CLD","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "ABT","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        
        jsondata='{"disposition": "","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+le.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "ABT","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"ABC123"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "ABT","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"'+opp.CloseDate+'","call_end_time":"'+opp.CloseDate+'","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "DROP","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"'+opp.CloseDate+'","call_end_time":"'+opp.CloseDate+'","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "B","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"'+opp.CloseDate+'","call_end_time":"'+opp.CloseDate+'","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "PAYI","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'","objName":"Opportunity"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        
        jsondata='{"disposition": "LNA","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'","objName":"Opportunity"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        
        jsondata='{"disposition": "BAV","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'","objName":"Opportunity"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "INTIR","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'","objName":"Opportunity"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "VEHBOO","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'","objName":"Opportunity"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "N","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'","objName":"Opportunity"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        
        jsondata='{"disposition": "NOTIN","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'","objName":"Opportunity"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "NBUSY","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'","objName":"Opportunity"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "PURCH","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'","objName":"Opportunity"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "SALE","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'","objName":"Opportunity"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "RS","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'","objName":"Opportunity"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "IB","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'","objName":"Opportunity"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "LB","objName":"Opportunity","noResponseCount":"0","dropCount":"0","stage":"Follow Up","status":"Language Issue","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'","objName":"Opportunity"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "N","objName":"Opportunity","noResponseCount":"2","dropCount":"0","stage":"Follow Up","status":"No response","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'","objName":"Opportunity"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "N","objName":"Opportunity","noResponseCount":"5","dropCount":"0","stage":"Follow Up","status":"No response","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'","objName":"Opportunity"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "TD","buyingTime":"Within 15 days","objName":"Opportunity","noResponseCount":"5","dropCount":"0","stage":"Follow Up","status":"No response","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"","all_lead_details":"","call_start_time":"121","call_end_time":"234","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+opp.Id+'","objName":"Opportunity"}';
        req.requestBody = Blob.valueOf(jsondata); 
        Elision_Disposition_API.postHandler();
        Elision_Disposition_API.postDisposition(req);
        
        jsondata='{"disposition": "NR","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"2020-01-16 16:12:54","call_end_time":"2020-01-16 16:12:54","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+tRec.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        RestContext.request = req;
        Elision_Disposition_API.postHandler();
        
        jsondata='{"disposition": "NR","agent_id": "123","agent_FullName":"123","list_id":"111","call_duration":"0","recording_link":"","vendor_lead_code":"","phone":"1234567890","campaign":"123","all_lead_details":"","call_start_time":"2020-01-16 16:12:54","call_end_time":"2020-01-16 16:12:54","hangup_reason":"1212","call_type":"3456","talktime":"1212","call_count":"77","recordId":"'+tRec2.Id+'"}';
        req.requestBody = Blob.valueOf(jsondata); 
        RestContext.request = req;
        Elision_Disposition_API.postHandler();
        Test.stopTest(); 
    }

    public class MockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            
            res.setStatusCode(200);
            res.setBody('{"success":[{"message":"lead Created","status_code":200,"id":"147310","leadsDispatch_id":"95365","sfdc_lead_id":"00Q1s0000011t3fEAA","target_id":"485","sfdc_lead_dispatch_id":"a0E1s000000UufCEAS"}]}');
            //res.setStatusCode(500);
            return res;
        }
    }
    
}