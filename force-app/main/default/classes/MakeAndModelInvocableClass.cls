public class MakeAndModelInvocableClass {
    
    public class MakeAndModelWrapper implements Comparable {
        public String Model;
        public Integer counter;
        public MakeAndModelWrapper(String Model, Integer counter) {
            this.Model = Model;
            this.counter = counter;
        }
        public Integer compareTo(Object other) {
            return counter-((MakeAndModelWrapper)other).counter;
        }
    }
    
    public class TranscriptInput {
        
        @InvocableVariable(required=true)
        public String BuyOrSellCarType;
        
        @InvocableVariable(required=true)
        public String City;
        
        @InvocableVariable(required=true)
        public String TypesOfSelection;
        
        @InvocableVariable(required=true)
        public String Values;
        
        @InvocableVariable(required=false)
        public String FuelType;
        
        
    }
    
    @InvocableMethod(label='Fetch Make and Model')
    public static List<List<String>> sendMakeAndModel(List<TranscriptInput> input){
        String recordTypeValue;
        String dealerCity = input[0].City;
        Long range1,range2;
        String FuelValue;
        String CarTypeValue;
        Boolean isActiveTrue = true;
        Map<String,Integer> ModelMap = new Map<String,Integer>();
        Map<String,String> MakeWithModelMap = new Map<String,String>();
        List<String> l1 =new List<String>();
        List<List<String>> TopFour = new List<List<String>>();
        Integer Counter = 0;
        
        System.debug('**dealerCity**' + dealerCity);
        if(input[0].BuyOrSellCarType == 'Buy a Used Car')
        {
            recordTypeValue = OpportunityConstants.buyerOppRecordTypeId;             
        }else if(input[0].BuyOrSellCarType == 'Sell a Used Car'){
            recordTypeValue = OpportunityConstants.sellerCarRecordTypeID;
        }
        String QueryProduct = 'SELECT Id, Body_Type__c, MFC_Dealer_City__c, Make__c, Model__c, Expected_Price__c, Fuel__c, Kilometer__c, IsActive FROM Product2 Where IsActive =:isActiveTrue AND MFC_Dealer_City__c =: dealerCity';
        
        
        if(input[0].TypesOfSelection == 'Budget'){
            
            if(input[0].Values == '2 - 4 Lakhs'){
                range1 = 200000;
                range2 = 400000;
            }else if(input[0].Values == '4 - 6 Lakhs'){
                range1 = 400000;
                range2 = 600000; 
            }else if(input[0].Values == '6 - 8 Lakhs')
            {
                range1 = 600000;
                range2 = 800000;  
            }else if(input[0].Values == '8 - 10 Lakhs')
            {
                range1 = 800000;
                range2 = 1000000;  
            }else if(input[0].Values == '10+ Lakhs'){
                range1 = 1000000;
                range2 = 10000000;
            }
            System.debug('**range values**' + range1 + ' ' + range2);
            QueryProduct += ' AND expected_price__c >=:  range1 AND expected_price__c <=: range2';
            
        }  else if(input[0].TypesOfSelection == 'CarType'){
            
            if(input[0].values == 'Hatchback'){
                CarTypeValue = 'Hatchback';
                
            }else if(input[0].values == 'Sedan'){
                CarTypeValue = 'Sedan'; 
                
            }else if(input[0].values == 'SUV'){
                CarTypeValue = 'SUV';
            }
            
            QueryProduct += ' AND Body_Type__c =: CarTypeValue';
        }
        
        if(input[0].FuelType != null){
            if(input[0].FuelType == 'Petrol'){
                FuelValue = 'Petrol';
            }else if(input[0].FuelType == 'Diesel'){
                FuelValue = 'Diesel';
            }
            QueryProduct += ' AND Fuel__c =:FuelValue';
            
        }
        
        System.debug('****QueryProduct****' + QueryProduct);
        List<Product2>  ProductList = database.query(QueryProduct);
        System.debug('****ProductList****' + ProductList);
        if(!ProductList.isEmpty()){ 
            for(Product2 p: ProductList){
                if(ModelMap.containsKey(p.model__c))
                {
                    Integer i =ModelMap.get(p.model__c) + 1; 
                    ModelMap.put(p.model__c,i);
                    i=0;
                }
                else
                {
                    ModelMap.put(p.model__c,1);
                    MakeWithModelMap.put(p.model__c,p.make__c);
                }
            }
        }
        
        MakeAndModelWrapper[] ModelList = new MakeAndModelWrapper[0];
        for(String key: ModelMap.keyset()) {
            ModelList.add(new MakeAndModelWrapper(key, ModelMap.get(key)));
        }
        ModelList.sort();
        
        System.debug('ModelMap' + ModelMap + 'ModelMapSize' + ModelMap.size());
        System.debug('ModelList'+ ModelList+ 'ModelList SIze ' + ModelList.size()); 
        
        if(ModelList.size() >=4){
            for(Integer i=ModelList.size(); i> 0; i--)
            {
                if(counter <= 4 )
                {
                    l1.add(MakeWithModelMap.get(ModelList[i-1].Model) + ',' + ModelList[i-1].Model);
                    Counter++;
                }else
                {
                    l1.add('Other');
                    break;
                }
            }
        }else 
        {
            if(ModelList.size() > 0){
                for(Integer i=0;i<ModelList.size();i++){
                    l1.add(MakeWithModelMap.get(ModelList[i].Model) + ',' + ModelList[i].Model);
                }
                l1.add('Other');
            }
           
            
        }
        
        TopFour.add(l1);
        return TopFour;
    }
    
}