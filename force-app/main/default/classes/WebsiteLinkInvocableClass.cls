public class WebsiteLinkInvocableClass {
    
    
    public class TranscriptInput {
        
        @InvocableVariable(required=true)
        public String City;
        
    }
    
    @InvocableMethod(label='Fetch Website Link')
    public static List<List<String>> sendWebsiteLink(List<TranscriptInput> input){
        
        String WebsiteLink = 'https://www.mahindrafirstchoice.com/buy/used-cars/';
        List<List<String>> WebsiteLinksToReturn = new List<List<String>>();
        List<String> links = new List<String>();
        
        WebsiteLink  = WebsiteLink + input[0].City;
        links.add(WebsiteLink);
        links.add('Other');
        WebsiteLinksToReturn.add(links);
        
        return WebsiteLinksToReturn;
    }
    
}