public class FetchNameInvocableClass {
    
    public class TranscriptInput {
        @InvocableVariable(required=true)
        public ID routableID;
        @InvocableVariable(required=true)
        public String leadFlow;
        @InvocableVariable(required=true)
        public String chatbotFlow;
        
    }
    
    public class TranscriptOutput {
        @InvocableVariable(required=true)
        public String FirstName;
        
        @InvocableVariable(required=true)
        public String Phone;
        
        
    }
    
    @InvocableMethod(label='Fetch Name and Phone')
    Public static List<TranscriptOutput> setTranscriptValues(List<TranscriptInput> input)
    {
        System.debug('input 26 -- '+input);
        System.debug('****** Inside Method ******');
        List<TranscriptOutput> outputList = new List<TranscriptOutput>();
        
        Set<String> routableIdset = new Set<String>();
        
        String leadFlow = '';
        String chatbotFlow = '';
        for (TranscriptInput transcript : input) {
            routableIdset.add(transcript.routableID);  
            leadFlow = transcript.leadFlow;
            chatbotFlow = transcript.chatbotFlow;
        }
        system.debug('input ' + input);
        
        Map<String, Id> queueMap = new Map<String, Id>();
        
        for(Group grp : [Select Id,Name,type from Group where type = 'queue' and name = 'Chatbot_Lead' limit 1]){
            queueMap.put(grp.Name, grp.Id);
        }
        System.debug('queueMap '+queueMap);
        List<LiveChatTranscript> transcriptRecord = [SELECT Id, First_Name__c,Last_Name__c,Phone__c,leadId FROM LiveChatTranscript WHERE Id IN :routableIdset LIMIT 1];
        System.debug('**transcriptRecord**' + transcriptRecord);
        System.debug('leadId '+transcriptRecord[0].leadId);
        
        
        for(LiveChatTranscript t : transcriptRecord){
            TranscriptOutput output = new TranscriptOutput();
            output.FirstName = t.First_Name__c;
            output.Phone = t.Phone__c;
            outputList.add(output);
            
        }
        
        
        /*if(transcriptRecord[0].leadId != NULL){
Id leadId = transcriptRecord[0].leadId; 
Lead lead1 = new Lead();
lead1.Id = leadId;

*/      Lead lead1 = new Lead();      
        System.debug('leadFlow == '+leadFlow);
        if(leadFlow == 'Buy a Used Car'){
            lead1 = CreateChatbotLeadClass.checkDuplicateMethodCall(transcriptRecord[0].First_Name__c,transcriptRecord[0].Last_Name__c, transcriptRecord[0].Phone__c,LeadConstants.buyerLeadRecordTypeId);
            system.debug('lead1 ' + lead1);
            lead1.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
            lead1.Lead_Type__c = 'USEDCARSALES';
        } else if(leadFlow == 'Sell a Used Car'){
            lead1 = CreateChatbotLeadClass.leadGeneration(transcriptRecord[0].First_Name__c,transcriptRecord[0].Last_Name__c, transcriptRecord[0].Phone__c);
            lead1.RecordTypeId = LeadConstants.SellerLeadRecordTypeId;
            lead1.Lead_Type__c = 'PROCUREMENT';
        } else if(leadFlow == 'Finance Options'){
            lead1 = CreateChatbotLeadClass.leadGeneration(transcriptRecord[0].First_Name__c,transcriptRecord[0].Last_Name__c, transcriptRecord[0].Phone__c);
            lead1.RecordTypeId = LeadConstants.FinanceChatRecordTypeId;
            lead1.Lead_Type__c = 'FINANCE';
        } else if(leadFlow == 'Buy a New Car'){
            lead1.RecordTypeId = LeadConstants.CnBLeadRecordTypeId;
            lead1.Lead_Type__c = 'CnB';
        } else if(leadFlow == 'Buy a New Bike'){
            lead1.RecordTypeId = LeadConstants.CnBBikeLeadRecordTypeId;
            lead1.Lead_Type__c = 'CnB';
        } else{
            lead1 = CreateChatbotLeadClass.checkDuplicateMethodCall(transcriptRecord[0].First_Name__c,transcriptRecord[0].Last_Name__c, transcriptRecord[0].Phone__c,LeadConstants.buyerLeadRecordTypeId);
            lead1.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
            lead1.Lead_Type__c = 'OTHERS';
        }  
        if(chatbotFlow == 'MFC'){
            lead1.Chatbot_Flow__c = 'MFC';
            lead1.LeadSource = 'MFC-Chat';
            //lead1.OwnerId = queueMap.get('Chatbot_Lead');
            
        } else if(chatbotFlow == 'CNB'){ 
            lead1.Chatbot_Flow__c = 'CNB';
            lead1.LeadSource = 'CnB-Chat';
            //lead1.OwnerId = queueMap.get('Chatbot_Lead');
            
        }
        System.debug('102 == '+lead1);
        upsert lead1;     
        System.debug('104 == '+lead1);
        System.debug('105 == '+transcriptRecord[0].leadId);
        transcriptRecord[0].leadId = lead1.Id;
     //   transcriptRecord[0].RecordType__c = lead1.Lead_Type__c;
        System.debug('107 == '+transcriptRecord[0].leadId);
        update transcriptRecord[0];
        //}
        return outputList;
    }
}