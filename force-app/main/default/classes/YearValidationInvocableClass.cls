public class YearValidationInvocableClass {

    public class TranscriptInput {
        
        @InvocableVariable(required=true)
        public Integer Year;
            
    }
    
    @InvocableMethod(label='Year validation')
    public static List<String> sendMakeAndModel(List<TranscriptInput> input){
        
        List<String> l1 =new List<String>();
        Integer CurrentYear = Date.Today().Year();
        if(input[0].Year >= 1990 && input[0].Year <= CurrentYear)
        {
          l1.add('Valid');  
        }else{
            l1.add('Invalid');  
        }
        return l1;
    }

}