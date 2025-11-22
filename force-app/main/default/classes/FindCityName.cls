public class FindCityName {
	public class TranscriptInput {
        @InvocableVariable(required=true) 
        public String cityName;
    }
    
    @InvocableMethod(label='Find City Name')
    public static List<String> findCityName(List<TranscriptInput> input){
        System.debug('input: '+input);
        if(input[0].cityName.length() >= 2){
            List<String> searchList = ChatbotUtility.findValues(input[0].cityName, 'Customer City');
            System.debug(searchList);
            return searchList;
        }
        else{
            return null;
        }
    }
}