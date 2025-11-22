@isTest
public class InvocableClassForChatBotTest {

    public static testmethod void testmethod1(){
        Lead l = new Lead();
        l.LastName = 'Test lead';
        l.Phone = '9876532560';
        l.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
        l.LeadSource = 'Advertisement';
        insert l;
        
        LiveChatVisitor liv = new LiveChatVisitor();
        insert liv;
        
        LiveChatTranscript livchat = new LiveChatTranscript();
        //livchat.Name = 'Test Demo';
        livchat.LeadId = l.Id;
        livchat.first_Name__c = 'Test';
        livchat.Last_Name__c = 'Demo';
        livchat.Phone__c = '9876532560';
        livchat.email__c = 'test@gmail.com';
        livchat.makeandmodel__c = 'honda';
        livchat.Budget__c = 'under 2 lakh';
        livchat.CarType__c = 'Sedan';
        livchat.ListingPage__c = 'test';
        livchat.LiveChatVisitorId = liv.Id;
        insert livchat;
        
        InvocableClassForChatBot.TranscriptInput i = new InvocableClassForChatBot.TranscriptInput();
        i.routableID = livchat.Id;
        
        List<InvocableClassForChatBot.TranscriptInput> input1 = new List<InvocableClassForChatBot.TranscriptInput>();
        input1.add(i);
        
        test.startTest();
        List<InvocableClassForChatBot.TranscriptOutput> returnVal = InvocableClassForChatBot.setTranscriptValues(input1);
        test.stopTest();
    }
}