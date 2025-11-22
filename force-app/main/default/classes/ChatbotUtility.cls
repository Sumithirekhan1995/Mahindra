public class ChatbotUtility {
	public static List<String> findValues(String searchValue, String recordTypeName){
        Set<String> uniqueValues = new Set<String>();
        List<String> valueList = new List<String>();
        List<List<sObject>> searchList = [FIND :searchValue IN ALL FIELDS 
                           RETURNING Chatbot_Entity__c(Name, Alternate_Values__c WHERE RecordType.Name = :recordTypeName order by name ASC) ];
        Chatbot_Entity__c[] searchValues = (Chatbot_Entity__c[])searchList[0];
        System.debug('searchValues: '+searchValues);
        for (Chatbot_Entity__c m : searchValues) {
            System.debug('m.Alternate_Values__c: '+m.Alternate_Values__c);
            //Set<String> alternateValues = new Set<String>(m.Alternate_Values__c.split(','));
            //System.debug('alternateValues: '+alternateValues);
            
            /*for(String altValue : alternateValues){
                System.debug(searchValue+' '+altValue);
                if(searchValue == altValue){
                    System.debug('true');
                    uniqueValues.add(m.Name);
                }else{
                    System.debug('false');
                }
            }*/
            System.debug(m.Name);
            uniqueValues.add(m.Name);
        }
        System.debug('uniqueValues: '+uniqueValues);
        valueList.addAll(uniqueValues);
        return valueList;
    }
}