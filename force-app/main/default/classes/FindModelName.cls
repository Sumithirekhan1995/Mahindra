public class FindModelName {
	public class TranscriptInput {
        @InvocableVariable(required=true) 
        public String modelName;
    }
    
    @InvocableMethod(label='Find Model Name')
    public static List<String> findModelName(List<TranscriptInput> input){
        System.debug('input: '+input);
        if(input[0].modelName.length() >= 2){
            List<String> searchList = ChatbotUtility.findValues(input[0].modelName, 'Model');
            System.debug(searchList);
            return searchList;
        }
        else{
            return null;
        }
    }
}