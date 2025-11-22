public class RecommendationLinksInvocableClass {
    
    public class TranscriptInput {
        
        @InvocableVariable(required=true)
        public String City;
        
        @InvocableVariable(required=true)
        public String MakeModelValue;
        
    }
    
    
    @InvocableMethod(label='Fetch Recommened Website Link')
    public static List<List<String>> sendWebsiteLink(List<TranscriptInput> input){
        List<List<String>> WebsiteLinksToReturn = new List<List<String>>();
        List<String> links = new List<String>();
        Set<String> UniqueData = new Set<String>();
        Boolean isActiveTrue = true;
        String dealerCity = input[0].City;
        String MakeAndModel =  input[0].MakeModelValue;
        String Make =  MakeAndModel.substringBefore(',');
        String Model =  MakeAndModel.substringAfter(','); 
        
        String QueryProduct = 'SELECT Id, MFC_Dealer_City__c, Make__c, Model__c,Stock_URL__c, IsActive FROM Product2 Where IsActive =:isActiveTrue AND MFC_Dealer_City__c =: dealerCity  AND Make__c =: Make AND Model__c =: Model AND Stock_URL__c != null';
        System.debug('**dealerCity**' + dealerCity + '**Make***' + Make + '**Model**' + Model);
        System.debug('**QueryProduct**' + QueryProduct);
        
        List<Product2>  ProductList = database.query(QueryProduct);
        System.debug('**ProductList**' + ProductList);
        
        if(!ProductList.isEmpty()){ 
            for(Product2 p: ProductList){
                UniqueData.add(p.Stock_URL__c);
                
            }
        }
        links.addAll(UniqueData);                                 
        links.add('Other');
        WebsiteLinksToReturn.add(links);
        return WebsiteLinksToReturn;
    }
    
}