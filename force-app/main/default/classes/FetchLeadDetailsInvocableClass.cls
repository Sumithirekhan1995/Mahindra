public class FetchLeadDetailsInvocableClass {
    
    public class TranscriptInput {
        @InvocableVariable(required=true)
        public ID routableID;
        @InvocableVariable
        public String inputValue;
        @InvocableVariable(required=true)
        public String inputType;
        @InvocableVariable
        public Integer inputNumberValue;
        @InvocableVariable
        public DateTime inputDTValue;
        @InvocableVariable
        public Date dateValue;
        @InvocableVariable
        public Time timeValue;
        
    }
    
    @InvocableMethod(label = 'Capture Lead Details') 
    public static void saveLeadDetails(List<TranscriptInput> input){
        System.debug('****** Inside Method ******');
        Set<String> routableIdset = new Set<String>();
    //   Opportunity lstOpportunity ;
        String inputValue = '';
        String inputType = '';
        Integer inputNumberValue;
        DateTime inputDTValue;
        String searchVal = '';
        Time timeValue;
        for (TranscriptInput transcript : input) {
            
            routableIdset.add(transcript.routableID);  
            inputValue = transcript.inputValue;
            inputType = transcript.inputType;
            inputNumberValue = transcript.inputNumberValue;
            inputDTValue = transcript.inputDTValue;
            timeValue = transcript.timeValue;
        }
        
        System.debug('Input '+input);
        
        
        
        Map<String, Id> queueMap = new Map<String, Id>();
        for(Group grp : [Select Id,Name,type from Group where type = 'queue' and name LIKE 'Chat%']){
            queueMap.put(grp.Name, grp.Id);
        }
        
        List<LiveChatTranscript> transcriptRecord = [SELECT Id, First_Name__c,Last_Name__c,Phone__c,leadId,Opportunity__c FROM LiveChatTranscript WHERE Id IN :routableIdset LIMIT 1];
        system.debug('transcriptRecord'+transcriptRecord);
        if(transcriptRecord[0].leadId != NULL){
            Id leadId = transcriptRecord[0].leadId;
            Lead lea = new Lead();
            lea.Id = leadId;
            system.debug('transcriptRecord'+leadId);
           /* if(leadId != null){
                 lstOpportunity = [SELECT Lead__c FROM Opportunity WHERE Lead__c = :leadId Order By CreatedDate  DESC  limit 1];
            }*/
          //  lstOpportunity = [SELECT Lead__c FROM Opportunity WHERE Lead__c = :leadId Order By CreatedDate  DESC  limit 1];
         
            
            
            if(inputType == 'CITY'){
                lea.Area_City__c = inputValue;
                lea.Seller_City__c = inputValue;
                
            }
            else if(inputType == 'INSPECTED DATE'){
                if(inputValue == '10 AM - 11 AM'){
                    Time timeval = time.newInstance(10, 00, 00, 00);
                    date dateval = inputDTValue.date();
                    lea.inspected_date__c = Datetime.newInstance(dateval, timeval);
                }
                else if(inputValue == '11 AM - 12 PM'){
                    Time timeval = time.newInstance(11, 00, 00, 00);
                    date dateval = inputDTValue.date();
                    lea.inspected_date__c = Datetime.newInstance(dateval, timeval);
                }
                else if(inputValue == '12 PM - 1 PM'){
                    Time timeval = time.newInstance(12, 00, 00, 00);
                    date dateval = inputDTValue.date();
                    lea.inspected_date__c = Datetime.newInstance(dateval, timeval);
                }
                else if(inputValue == '2 PM - 3 PM'){
                    Time timeval = time.newInstance(14, 00, 00, 00);
                    date dateval = inputDTValue.date();
                    lea.inspected_date__c = Datetime.newInstance(dateval, timeval);
                }
                else if(inputValue == '3 PM - 4 PM'){
                    Time timeval = time.newInstance(15, 00, 00, 00);
                    date dateval = inputDTValue.date();
                    lea.inspected_date__c = Datetime.newInstance(dateval, timeval);
                }
                else if(inputValue == '4 PM - 5 PM'){
                    Time timeval = time.newInstance(16, 00, 00, 00);
                    date dateval = inputDTValue.date();
                    lea.inspected_date__c = Datetime.newInstance(dateval, timeval);
                }
                else if(inputValue == '5 PM - 6 PM'){
                    Time timeval = time.newInstance(17, 00, 00, 00);
                    date dateval = inputDTValue.date();
                    lea.inspected_date__c = Datetime.newInstance(dateval, timeval);
                }
                else if(inputValue == '6 PM - 7 PM'){
                    Time timeval = time.newInstance(18, 00, 00, 00);
                    date dateval = inputDTValue.date();
                    lea.inspected_date__c = Datetime.newInstance(dateval, timeval);
                }
            }
            else if(inputType == 'BUDGET'){
                lea.Budget__c = inputValue;
            }
            else if(inputType == 'CAR TYPE'){
                lea.CarType__c = inputValue;
            }
            else if(inputType == 'KMS'){
                lea.Kilometers__c = inputValue;
                if(inputValue == 'Less than 10,000 Kms')
                    lea.Kilometer__c = 10000;
                else if(inputValue == 'Less than 50,000 Kms')
                    lea.Kilometer__c = 30000;
                else if(inputValue == 'More than 50,000 Kms')
                    lea.Kilometer__c = 50000;
                //lea.Kilometer__c = Integer.valueOf(inputValue);
            }
            else if(inputType == 'MANUFACTURE YEAR'){
                lea.MFG_Year__c = String.valueOf(inputNumberValue);
                lea.Year__c = String.valueOf(inputNumberValue);
            }
            else if(inputType == 'MAKE'){
                lea.Primary_Make__c = inputValue;
                lea.Make__c = inputValue;
             //   lstOpportunity.Make__c = lea.Make__c;
                
            }
            else if(inputType == 'MODEL'){
                String[] splitStr = inputValue.split(',');
                System.debug('splitStr '+splitStr);
                if(splitStr.size() >= 2){
                    lea.Primary_Make__c = splitStr[0];
                    lea.Primary_Model__c = splitStr[1];
                }
                lea.Model__c = inputValue;
             //   lstOpportunity.Model__c = lea.Model__c;
            }
            
            else if(inputType == 'FUEL'){
                lea.Fuel__c = inputValue;
            }
            else if(inputType == 'DATE TIME'){
                lea.Follow_Up_Date_Time__c = inputDTValue;
            }
            else if(inputType == 'AGENT' && inputValue == 'true'){
                lea.Contact_Customer__c = true;
                if(lea.LeadSource == 'MFC'){
                    if(queueMap.containsKey('Chat_AgentsNotContacted')){
                        lea.OwnerId = queueMap.get('Chat_AgentsNotContacted');
                    }
                }
                else if(lea.LeadSource == 'CnB'){
                    if(queueMap.containsKey('Chat_CnB_AgentsNotContacted')){
                        lea.OwnerId = queueMap.get('Chat_CnB_AgentsNotContacted');
                    } 
                }
            }
            else if(inputType == 'TRANSFER AGENT' && inputValue == 'true'){
                lea.Transfer_to_Agent__c = true;
            //    lstOpportunity.Transfer_to_Agent__c = lea.Transfer_to_Agent__c;
                
                if(lea.LeadSource == 'MFC'){
                    if(queueMap.containsKey('Chat_AgentsContacted')){
                        lea.OwnerId = queueMap.get('Chat_AgentsContacted');
                    }
                }
                else if(lea.LeadSource == 'CnB'){
                    if(queueMap.containsKey('Chat_CnB_AgentsContacted')){
                        lea.OwnerId = queueMap.get('Chat_CnB_AgentsContacted');
                    }
                }
            }
            else if(inputType == 'STAGE ENTERED'){
                lea.Chat_Stages__c = 'Prechat Form Filled';
           //     lstOpportunity.Chat_stages__c = lea.Chat_Stages__c;                
                lea.OwnerId = queueMap.get('Chatbot_Lead');
                
            }
            else if(inputType == 'STARTED CONVERSATION'){
                lea.Chat_Stages__c = 'Started Conversation';
          //      lstOpportunity.Chat_stages__c = lea.Chat_Stages__c;
            }
            else if(inputType == 'ENDED CONVERSATION'){
                lea.Chat_Stages__c = 'Ended Conversation';
            //    lstOpportunity.Chat_stages__c = lea.Chat_Stages__c;
            }
            if((lea.Area_City__c != NULL || lea.Seller_City__c != NULL) && lea.Seller_State__c == NULL && lea.Area_State__c == NULL){
            /*    List<String> stateValue = new List<String>();
searchVal = lea.Area_City__c;
System.debug('Search Val '+searchVal);
List<List<sObject>> searchList = [FIND :searchVal IN ALL FIELDS 
RETURNING Chatbot_States__c(Name, Alternate_Values__c)];

Chatbot_States__c[] stateValues = searchList[0];
System.debug('stateValues '+stateValues);
for(Chatbot_States__c cs : stateValues){
stateValue.add(cs.name);
}
if(!stateValue.isEmpty() ){
lea.Area_State__c = stateValue[0];
lea.Seller_State__c = stateValue[0];
}*/
                
                String city = lea.Seller_City__c;
                Map<String, City_State__mdt> mapct = new Map<String, City_State__mdt>();
                for(City_State__mdt m:   [select MasterLabel,developerName, State__c from City_State__mdt where MasterLabel = :city]){
                    mapct.put(m.MasterLabel.toUpperCase(), m);
                }
                
                System.debug('Mapct '+Mapct);
                String city1 = lea.Seller_City__c.toUpperCase();
                System.debug('City1 '+city1);
                if(mapct.containsKey(city1)){
                    //System.debug('Mapct '+Mapct+'mapct.containsKey(l.registration_city__c '+mapct.containsKey(l.registration_city__c));
                    lea.Seller_State__c = mapct.get(city1).State__c;
                    lea.Area_State__c = lea.Seller_State__c;
                }
                system.debug('SellerState'+lea.Seller_State__c);
                
            }
            
            
            update lea;
          //  update lstOpportunity;
        }
        
        
    }
}