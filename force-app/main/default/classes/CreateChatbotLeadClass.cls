public class CreateChatbotLeadClass {
    public static lead checkDuplicateMethodCall (String FirstName, String LastName, String Phone, String RecordTypeId){        
        List<Lead> leadRec = [SELECT Id
                              FROM Lead 
                              WHERE ExtrnId_Phone__c  =: Phone 
                              AND RecordTypeId =: RecordTypeId
                              LIMIT 1];
        if(!leadRec.isEmpty()){
            return leadRec[0];
        }else{
            return leadGeneration(FirstName,LastName,Phone);
        }
    }
    
    public static Lead leadGeneration(String FirstName, String LastName, String Phone){
        Lead ld = new Lead();
      	ld.LastName = LastName;
        ld.FirstName = FirstName;
        ld.Phone = Phone;            
        return ld;   
    }
}