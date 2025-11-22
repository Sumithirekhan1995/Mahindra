public class CnbwebsiteLinkInvocableClass {
    
      public class TranscriptInput {
          
          @InvocableVariable(required=true)
          public String TypeOfSelection;
          
          @InvocableVariable(required=true)
          public String Value;
          
          
        
    }
    
    @InvocableMethod(label='Fetch CNB Website Link')
    public static List<List<String>> sendWebsiteLink(List<TranscriptInput> input){
        
        String WebsiteLink = 'https://www.carandbike.com/used/';
        List<List<String>> WebsiteLinksToReturn = new List<List<String>>();
        List<String> links = new List<String>();
        
        
        if(input[0].TypeOfSelection == 'Budget'){
            
            if(input[0].value == 'Under 1 lakh'){
                WebsiteLink = WebsiteLink + 'cars-under-1-lakh';
            }else if(input[0].value == 'Under 2 lakh'){
                WebsiteLink = WebsiteLink + 'cars-under-2-lakh';
            }else if(input[0].value == '2 - 5 Lakhs'){
                WebsiteLink = WebsiteLink + 'cars-2-to-5-lakh';
            }else if(input[0].value == '5 - 8 Lakhs'){
                WebsiteLink = WebsiteLink + 'cars-5-to-8-lakh';
            }else if(input[0].value == '8 - 10 Lakhs'){
                WebsiteLink = WebsiteLink + 'cars-8-to-10-lakh';
            }
        }else if(input[0].TypeOfSelection == 'Car Type'){
            
            if(input[0].value == 'Hatchback'){
                WebsiteLink = WebsiteLink + 'hatchback-cars';
            }else if(input[0].value == 'Sedan'){
                WebsiteLink = WebsiteLink + 'sedan-cars';
            }else if(input[0].value == 'SUV'){
                WebsiteLink = WebsiteLink + 'suv-cars';
            }
        }else if(input[0].TypeOfSelection == 'Fuel Type'){
            
            if(input[0].value == 'Petrol'){
                WebsiteLink = WebsiteLink + 'petrol-cars';
            }else if(input[0].value == 'Diesel'){
                WebsiteLink = WebsiteLink + 'diesel-cars';
            }
        }
        

        links.add(WebsiteLink);
        WebsiteLinksToReturn.add(links);
        
        return WebsiteLinksToReturn;
    }

}