public class LiveChatTranscriptTriggerHandler {
    public static Boolean runOnce = false;
    public static void updateLead( List<LiveChatTranscript>  newChat, Map<Id, LiveChatTranscript> Oldchat){
        
        if(runOnce) return;
        runOnce = true;
        
        Set<String> phone = new Set<String>();
        List<Lead> leadList = new List<Lead>();
        Map<String, Id> queueMap = new Map<String, Id>();
        
        List<LiveChatTranscript> transcriptToUpdate = new List<LiveChatTranscript>();
        
        for(Group grp : [Select Id,Name,type from Group where type = 'queue' and name = 'Chatbot_Lead' limit 1]){
            queueMap.put(grp.Name, grp.Id);
        }
        
        List<LiveChatTranscript> transcriptRecord = [SELECT Id,LeadId 
                                                     FROM LiveChatTranscript 
                                                     ORDER BY 
                                                     CreatedDate DESC 
                                                     LIMIT 1];   
        
        for(LiveChatTranscript CT : newChat){ 
            if(CT.Status != Oldchat.get(CT.Id).Status && (CT.Status == 'Completed') || (CT.Status =='Missed') || (CT.Status =='Dropped')){
                phone.add(CT.Phone__c);    
                if(CT.LeadId == null){      
                    
                    if(phone.size() > 0){
                        
                        List<lead> leads = [SELECT Id, Phone ,Lead_Type__c
                                            from Lead
                                            WHERE ExtrnId_Phone__c IN:phone 
                                            AND Lead_Type__c= :LeadConstants.BuyerConstant
                                            ORDER BY
                                            createdDate DESC LIMIT 1 ];
                        
                        Map<String, Lead> Lea = new Map<String, Lead>();
                        
                        for(Lead ld : leads){
                            Lea.put(ld.Phone, ld);   
                        }
                        
                        Lead lD = Lea.get(CT.Phone__c);
                        
                        if(lD  != null){
                            
                            transcriptToUpdate.add( new LiveChatTranscript(
                                Id =  CT.Id,
                                LeadId =  lD.Id,
                                Phone__c = lD.Phone
                                
                            ));  
                            
                        }
                        else {
                            
                            Lead le = new Lead();
                            
                            le.Phone = CT.Phone__c;
                            le.LastName = CT.Last_Name__c;
                            le.FirstName = CT.First_Name__c;
                            le.RecordTypeId = LeadConstants.buyerLeadRecordTypeId ;
                            le.LeadSource = 'MFC-Chat';
                            le.OwnerId = queueMap.get('Chatbot_Lead');
                            
                            leadList.add(le);
                            
                            if(!leadList.isEmpty()){
                                insert leadList;
                                transcriptRecord[0].LeadId = leadList[0].Id;
                                
                                update transcriptRecord[0];
                            }     
                            
                        } 
                    }
                    
                    if(transcriptToUpdate.size() > 0 ){
                        update transcriptToUpdate;
                        
                    }
                    
                } 
                
            }
        }   
    }
}