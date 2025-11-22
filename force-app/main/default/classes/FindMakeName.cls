public class FindMakeName {
	public class TranscriptInput {
        @InvocableVariable(required=true) 
        public String makeName;
    }
    
    @InvocableMethod(label='Find Make Name')
    public static List<String> findMakeName(List<TranscriptInput> input){
        System.debug('input: '+input);
        List<String> searchList = ChatbotUtility.findValues(input[0].makeName, 'Make');
        System.debug(searchList);
        return searchList;
    }
    
    
}