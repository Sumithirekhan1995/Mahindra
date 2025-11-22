public class InvocableClassForMakeAndModel {
    
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
        public String MakeModelSelection;       
    }
    
    
    @InvocableMethod(label='Initialize Values To Search Make and Model')
    Public static List<List<String>> setTranscriptValues(List<TranscriptInput> input)
    {
        String recordTypeValue;
        String dealerCity = input[0].City ;
        Long range1,range2;
        String CarTypeValue;
        Map<String,String>  MakeWithModelMap = new Map<String,String>();
        Set<String> dealerName = new Set<String>();
        String SelectedMakeModelValue = input[0].MakeModelSelection;
        String FuelValue;
        Map<String,Integer> ModelMap = new Map<String,Integer>();
        List<String> l1 =new List<String>();
        List<List<String>> TopThree = new List<List<String>>();
        Integer Counter = 0;
        String s1,s2;
        String closedWon = 'closed won';
        String QueryOpp = 'select id, name, product__r.name, product__r.expected_price__c,product__r.Kilometer__c ,product__r.Fuel__c, product__r.make__c, product__r.model__c, dealer__r.name, dealer__r.BillingCity, StageName from Opportunity  where StageName =: closedWon  AND Product__c != null AND RecordTypeId =:recordTypeValue AND dealer__r.BillingCity =: dealerCity ';
        if(input[0].BuyOrSellCarType == 'Buy a Used Car')
        {
            recordTypeValue = OpportunityConstants.buyerOppRecordTypeId;             
        }else if(input[0].BuyOrSellCarType == 'Sell a Used Car'){
            recordTypeValue = OpportunityConstants.sellerCarRecordTypeID;
        }
        
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
            QueryOpp += 'AND product__r.expected_price__c >=:  range1 AND product__r.expected_price__c <=: range2';
            
        } else if(input[0].TypesOfSelection == 'Fuel Type'){
            if(input[0].Values == 'Petrol'){
                FuelValue = 'Petrol';
            }else if(input[0].Values == 'Diesel'){
                FuelValue = 'Diesel';
            }
            QueryOpp += 'AND product__r.Fuel__c =:FuelValue';
            
        } else if(input[0].TypesOfSelection == 'KMs Driven'){
            
            if(input[0].Values == '10,000 to 50,000 Kms'){
                range1 = 10000;
                range2 = 50000;
            }else if(input[0].Values == '50,000 to 90,000 Kms'){
                range1 = 50000;
                range2 = 90000;
            }else if(input[0].Values == '90,000+ Kms'){
                range1 = 90000;
                range2 = 500000;
            }
            QueryOpp += ' AND product__r.Kilometer__c >=:  range1 AND product__r.Kilometer__c <=: range2';  
        }
        else if(input[0].TypesOfSelection == 'CarType'){
            
            if(input[0].values == 'Hatchback'){
                CarTypeValue = 'Hatchback';
                
            }else if(input[0].values == 'Sedan'){
                CarTypeValue = 'Sedan'; 
                
            }else if(input[0].values == 'XUV'){
                CarTypeValue = 'XUV';
            }
            QueryOpp += ' AND product__r.Body_Type__c =: CarTypeValue';
        }
        
        if(SelectedMakeModelValue != null){
            System.debug('********SelectedMakeModelValue******' + SelectedMakeModelValue); 
            s1 = SelectedMakeModelValue.substringBefore(',');
            s2 = SelectedMakeModelValue.substringAfter(',');
            QueryOpp += ' AND product__r.make__c =: s1 AND product__r.model__c =: s2 AND dealer__r.name != null'; 
            
        }
        
        QueryOpp += ' ORDER BY createddate DESC';
        System.debug('QueryOpp' + QueryOpp);
        
        List<Opportunity> l = database.query(QueryOpp);
        /* List<Opportunity> l = [select id, name, product__r.name, product__r.expected_price__c, product__r.make__c, product__r.model__c, dealer__r.name, dealer__r.BillingCity, StageName 
from Opportunity 
where StageName = 'closed won' AND Product__c != null AND RecordTypeId =:recordTypeValue AND dealer__r.BillingCity =: DealerCity
AND  product__r.expected_price__c >=: range1 AND product__r.expected_price__c <=: range2]; */
        if(SelectedMakeModelValue != null){
            for(Opportunity o : l){
             	 dealerName.add(o.dealer__r.name);
            }
            Integer count=0;
            if(!dealerName.isEmpty()){
                
                if(dealerName.size() <= 3){
                    l1.addAll(dealerName);
                }else
                {
                    List<String> l2 = new List<String>(dealerName);
                    for(Integer i=0; i<3; i++){
                        l1.add(l2[i]);
                    }
                }
            }
            l1.add('Other');
            TopThree.add(l1);
            return TopThree;
               
        }
        else if(SelectedMakeModelValue == null){
            for(Opportunity o : l){
                if(ModelMap.containsKey(o.product__r.model__c))
                {
                    Integer i =ModelMap.get(o.product__r.model__c) + 1; 
                    ModelMap.put(o.product__r.model__c,i);
                    i=0;
                }
                else
                {
                    ModelMap.put(o.product__r.model__c,1);
                    MakeWithModelMap.put(o.product__r.model__c,o.Product__r.make__c);
                }    
            }
            
            //Sort the MAP
            MakeAndModelWrapper[] ModelList = new MakeAndModelWrapper[0];
            for(String key: ModelMap.keyset()) {
                ModelList.add(new MakeAndModelWrapper(key, ModelMap.get(key)));
            }
            ModelList.sort();
            
            System.debug('ModelMap' + ModelMap + 'ModelMapSize' + ModelMap.size());
            System.debug('ModelList'+ ModelList+ 'ModelList SIze ' + ModelList.size()); 
            
            if(ModelList.size() >=3){
                for(Integer i=ModelList.size(); i> 0; i--)
                {
                    if(counter <3 )
                    {
                        l1.add(MakeWithModelMap.get(ModelList[i-1].Model) + ',' + ModelList[i-1].Model);
                        Counter++;
                    }
                }
            }else
            {
                for(Integer i=0;i<ModelList.size();i++){
                    l1.add(ModelList[i].Model);
                }
            }
            
            TopThree.add(l1);
            return TopThree; 
        }
        
       return TopThree;
       
    }
}