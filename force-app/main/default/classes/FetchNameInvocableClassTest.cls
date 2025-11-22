@isTest
public class FetchNameInvocableClassTest {

    public static testmethod void fetchinvocable(){
        Lead l = new Lead();
        l.LastName = 'Test lead';
        l.Phone = '9876532561';
        l.LeadSource = 'MFC-Chat';
        l.Lead_Type__c = 'USEDCARSALES';
        l.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
        insert l;
        
        Lead l1 = new Lead();
        l1.LastName = 'Test lead';
        l1.Phone = '9876532561';
        l1.LeadSource = 'MFC-Chat';
        l1.Lead_Type__c = 'OTHERS';
        l1.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
        insert l1;

        
        LiveChatVisitor liv = new LiveChatVisitor();
        insert liv;
        
        LiveChatTranscript livchat = new LiveChatTranscript();
      //  livchat.Name = 'Test Demo';
        livchat.LeadId = l.Id;
        livchat.first_Name__c = 'Test';
        livchat.Last_Name__c = 'Demo';
        livchat.Phone__c = '9876532560';
        livchat.LiveChatVisitorId = liv.Id;        
        insert livchat;
       
     // livchat.Name = 'Test Demo';
        livchat.LeadId = l.Id;
        livchat.first_Name__c = 'Test';
        livchat.Last_Name__c = 'Demo';
        livchat.Phone__c = '9876532560';
     //   livchat.LiveChatVisitorId = liv.Id;
        update livchat;
        
        FetchNameInvocableClass.TranscriptInput i1 = new FetchNameInvocableClass.TranscriptInput();
        i1.routableID = livchat.Id;
        i1.chatbotflow = 'MFC';
        i1.leadFlow = 'Buy a Used Car';
       
        FetchNameInvocableClass.TranscriptInput i2 = new FetchNameInvocableClass.TranscriptInput();
        i2.routableID = livchat.Id;
        i2.chatbotflow = 'MFC';
        i2.leadFlow = 'Sell a Used Car';
        
         FetchNameInvocableClass.TranscriptInput i3 = new FetchNameInvocableClass.TranscriptInput();
        i3.routableID = livchat.Id;
        i3.chatbotflow = 'MFC';
        i3.leadFlow = 'Finance Options';
        
        FetchNameInvocableClass.TranscriptInput i4 = new FetchNameInvocableClass.TranscriptInput();
        i4.routableID = livchat.Id;
        i4.chatbotflow = 'CNB';
        i4.leadFlow = 'Buy a New Car';
       
        
        FetchNameInvocableClass.TranscriptInput i5 = new FetchNameInvocableClass.TranscriptInput();
        i5.routableID = livchat.Id;
        i5.chatbotflow = 'CNB';
        i5.leadFlow = 'Buy a New Bike';
        
        FetchNameInvocableClass.TranscriptInput i6 = new FetchNameInvocableClass.TranscriptInput();
        i6.routableID = livchat.Id;
        i6.chatbotflow = Null;
        i6.leadFlow = Null;
        
 
        /*FetchNameInvocableClass.TranscriptInput i2 = new FetchNameInvocableClass.TranscriptInput();
        i2.routableID = livchat.Id;
        i2.chatbotflow = 'CnB'; */        
        
        List<FetchNameInvocableClass.TranscriptInput> input1 = new List<FetchNameInvocableClass.TranscriptInput>();
        input1.add(i1);           
        List<FetchNameInvocableClass.TranscriptInput> input2 = new List<FetchNameInvocableClass.TranscriptInput>();
        input2.add(i2);          
        List<FetchNameInvocableClass.TranscriptInput> input3 = new List<FetchNameInvocableClass.TranscriptInput>();
        input3.add(i3);   
        List<FetchNameInvocableClass.TranscriptInput> input4 = new List<FetchNameInvocableClass.TranscriptInput>();
        input4.add(i4);   
        List<FetchNameInvocableClass.TranscriptInput> input5 = new List<FetchNameInvocableClass.TranscriptInput>();
        input5.add(i5);
         List<FetchNameInvocableClass.TranscriptInput> input6 = new List<FetchNameInvocableClass.TranscriptInput>();
        input6.add(i6);

        test.startTest();
        FetchNameInvocableClass.setTranscriptValues(input1);
        FetchNameInvocableClass.setTranscriptValues(input2);
        FetchNameInvocableClass.setTranscriptValues(input3);
        FetchNameInvocableClass.setTranscriptValues(input6);
     // FetchNameInvocableClass.setTranscriptValues(input5);  

        test.stopTest();
    }
}