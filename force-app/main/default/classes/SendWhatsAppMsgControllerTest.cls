@isTest
public class SendWhatsAppMsgControllerTest {
    
    @isTest
    public static void sendMessageAPITest()
    {    
        Test.setMock(HttpCalloutMock.class, new mockCalloutGet());
        Test.setMock(HttpCalloutMock.class, new mockCallout());
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.CloseDate = System.today();
        opp.StageName = 'Qualification';
        insert opp;
        
        Task tsk = new Task();
        tsk.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('Whatsapp').getRecordTypeId();
        tsk.WhatId = opp.Id;
        tsk.Subject = 'Whatsapp';
        tsk.Status = 'Completed';
        tsk.Phone__c = '1234567890';
        tsk.Description = 'Test';
        insert tsk;
        
        List<Task> tasks = new List<Task>();
        tasks.add(tsk);
        Test.setMock(HttpCalloutMock.class, new mockCalloutGet());
        Test.setMock(HttpCalloutMock.class, new mockCallout());
        SendWhatsAppMsgController.sendMessageCallout(tasks);
    }
    
    public class mockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            //System.assertEquals('POST', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success":[{"message":"Message Sent","status_code":200}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    public class mockCalloutGet implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            //System.assertEquals('Get', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success":[{"message":"Qualification","status_code":200}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
}