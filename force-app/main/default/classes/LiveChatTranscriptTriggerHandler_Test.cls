@isTest
public class LiveChatTranscriptTriggerHandler_Test {
    @isTest
    public static void LinkTranscriptToLead(){
     List<LiveChatTranscript> chat = new List<LiveChatTranscript>();
        
        
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        
       // List<LiveChatTranscript> chatScript = new  List<LiveChatTranscript>();
        LiveChatTranscript ch = new LiveChatTranscript();
        ch.First_Name__c = 'Test';
        ch.Phone__c = '9878789790';
        ch.Last_Name__c = 'Test';
    //    ch.Status = 'Completed';
        ch.LiveChatVisitorId = visitor.id;
        
        insert ch;
      
        LiveChatTranscript ch1 = new LiveChatTranscript();
        ch1.First_Name__c = 'Test';
        ch1.Phone__c = '9878789790';
        ch1.Last_Name__c = 'Test';
        ch1.Status = 'Dropped';
        ch1.LiveChatVisitorId = visitor.id;
        
        insert ch1;
        
        LiveChatTranscript ch2 = new LiveChatTranscript();
        ch2.First_Name__c = 'Test';
        ch2.Phone__c = '9878789790';
        ch2.Last_Name__c = 'Test';
        ch2.LiveChatVisitorId = visitor.id;     
        insert ch2;
        
        ch.First_Name__c = 'Test';
        ch.Phone__c = '9878789790';
        ch.Last_Name__c = 'Test';
        ch.Status = 'Missed';
      //  ch.LeadId = le.Id;
      //  ch.LiveChatVisitorId = visitor.id;      
        update ch; 
        
        LiveChatTranscript updatecr = [SELECT Id,Last_Name__c,Phone__c, First_Name__c,LeadId, Status FROM LiveChatTranscript WHERE Id = :ch.Id];

        updatecr.Status = 'Completed';
        
        lead le = new Lead();
        
        le.LastName = 'Test';
        le.Phone = '9876543210';
        le.LeadSource = 'MFC-Chat';
        insert le;

        Map<Id,LiveChatTranscript> liveChat = new Map<Id,LiveChatTranscript>();
        liveChat.put(ch.Id, ch);
        Test.startTest();
        LiveChatTranscriptTriggerHandler.updateLead(chat,liveChat);
        Test.stopTest();
        
    }
    
}