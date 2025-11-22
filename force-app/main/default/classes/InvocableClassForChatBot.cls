public class InvocableClassForChatBot {
    public class TranscriptInput {
        @InvocableVariable(required=true)
        public ID routableID;
    
    }
    public class TranscriptOutput {
        @InvocableVariable(required=true)
        public String Page;
        
        @InvocableVariable(required=true)
        public String Website;
        
        @InvocableVariable(required=true)
        public String FirstName;
        
         @InvocableVariable(required=true)
        public String Phone;
        
        @InvocableVariable(required=true)
        public String MakeAndModel;
        
         @InvocableVariable(required=true)
        public String Budget;
        
         @InvocableVariable(required=true)
        public String CarType;
        
        @InvocableVariable(required=true)
        public String ListingPage;
        
    }
    
    
    @InvocableMethod(label='Initialize Values To Transcript')
    Public static List<TranscriptOutput> setTranscriptValues(List<TranscriptInput> input)
    {
        List<TranscriptOutput> outputList = new List<TranscriptOutput>();
        for (TranscriptInput transcript : input) {
            
            // Query for the transcript record based on the ID
            LiveChatTranscript transcriptRecord = [SELECT Website__c,Page__c, First_Name__c,Last_Name__c, Email__c, Phone__c,MakeAndModel__c,Budget__c,CarType__c,ListingPage__c
                                                   FROM LiveChatTranscript 
                                                   WHERE Id = :transcript.routableID 
                                                   LIMIT 1];
            system.debug('transcriptRecord****'+transcriptRecord.First_Name__c);
            system.debug('transcriptRecord****'+transcriptRecord.Last_Name__c);
            system.debug('transcriptRecord****'+transcriptRecord.Email__c);
            TranscriptOutput output = new TranscriptOutput();
            
            // Store the FirstName field in an output variable
            output.Website = transcriptRecord.Website__c;
            // Store the OrderNumber field in an output variable
            output.Page = transcriptRecord.Page__c;
            output.FirstName = transcriptRecord.First_Name__c;
            output.Phone = transcriptRecord.Phone__c;
            output.ListingPage = transcriptRecord.ListingPage__c;
            output.MakeAndModel = transcriptRecord.MakeAndModel__c;  
            output.Budget = transcriptRecord.Budget__c;   
            output.CarType = transcriptRecord.CarType__c;
            
            
            
            
            System.debug('transcriptRecord.MakeAndModel__c;' + transcriptRecord.MakeAndModel__c);
            
            // Add the values to the list of outputs
            outputList.add(output);
        }
        return outputList;
        
    }
}