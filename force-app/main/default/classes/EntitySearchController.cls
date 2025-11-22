public without sharing class EntitySearchController {
    
    
    public class wrapper{
        @AuraEnabled
        public List<Product2> listOfProducts;
        @AuraEnabled
        public boolean check;
    }
    @auraEnabled
    
    public static List<Product2> getSearchResults(String filterList,String recordId){
        System.debug('EntitySearchController.getSearchResults::');
        System.debug('filterList ' + filterList);
        searchFilters filters = (searchFilters)JSON.deserialize(filterList,searchFilters.class);   
        System.debug(filters);
        List<String> makeList = filters.makeList;
        List<String> modelList = filters.modelList;
        List<String> variantList = filters.variantList;
        List<String> bodyList = filters.bodyList;
        List<String> fuelList = filters.fuelList;
        //6Mar2023:Shubham:Start
     //   List<String> TransmissionTypeList = filters.TransmissionTypeList;
        //6Mar2023:Shubham:End
        List<String> colorList = filters.colorList;
        List<String> modelYearList = filters.modelYearList;
        List<String> modelMonthList = filters.modelMonthList;
        List<String> certifiedList = filters.certifiedList;
        List<String> dealerList = filters.dealerList;
        List<String> cityList = filters.cityList;
        //26Sep2021:Sarthak:Start
        List<String> stateList = filters.stateList;
        //26Sep2021:Sarthak:End
        List<String> pincodeList = filters.pincodeList;
        
        Decimal minKm = filters.minKm;
        Decimal maxKm = filters.maxKm;
        Decimal minBudget = filters.minBudget;
        Decimal maxBudget = filters.maxBudget;
        String query = 'select id, Make__c, Model__c,No_of_Owners__c,Variant__c,Vehicle_Category__c, Body_Type__c, Fuel__c,TransmissionType__c, Color__c, Model_Year__c,'+ 
            'Model_Month__c, IsCertified__c,Dealer_Name__c, Dealer_Name__r.Name, MFC_Dealer_City__c, MFC_Dealer_State__c, Warranty_Recommended__c, MFC_Dealer_PinCode__c,'+
            'Kilometer__c,Registration_Number__c, Expected_Price__c,Dealer_Name__r.Active__c,IsActive from Product2 where IsActive= true AND Dealer_Name__r.Active__c = true AND Vehicle_Category__c= \'Private\' AND (Kilometer__c >=: minKm AND Kilometer__c <=: maxKm ) AND '+
            '(Expected_Price__c >=: minBudget AND Expected_Price__c <=: maxBudget)';
        if(makeList.size()>0){
            query += ' AND Make__c in: makeList';
        }
        if(modelList.size()>0){
            query += ' AND Model__c in: modelList';
        }
        if(variantList.size()>0){
            query += ' AND Variant__c in: variantList';
        } 
        if(bodyList.size()>0){
            query += ' AND Body_Type__c in: bodyList';
        }
        if(fuelList.size()>0 && fuelList[0] != ''){
            System.debug('fuelList: '+fuelList);
            query += ' AND Fuel__c in: fuelList';
        }
        //6Mar2023:Shubham:Start
     /*  if(TransmissionTypeList.size()>0){
            query += ' AND TransmissionType__c in: TransmissionTypeList';
        }*/
        //6Mar2023:Shubham:End
        if(colorList.size()>0){
            query += ' AND Color__c in: colorList';
        }
        if(modelYearList.size()>0 && modelYearList[0] != ''){
            query += ' AND Model_Year__c in: modelYearList';
        }
        if(modelMonthList.size()>0 && modelMonthList[0] != ''){
            query += ' AND Model_Month__c in: modelMonthList';
        }
        if(certifiedList.size()>0 && certifiedList[0] != ''){
            query += ' AND IsCertified__c in: certifiedList';
        }
        if(dealerList.size()>0){
            query += ' AND Dealer_Name__r.Name in: dealerList';
        }
        if(cityList.size()>0){
            query += ' AND MFC_Dealer_City__c in: cityList';
        }
        //26Sep2021:Sarthak:Start
        if(stateList != null && stateList.size() > 0){
            query += ' AND MFC_Dealer_State__c in: stateList';
        }
        //26Sep2021:Sarthak:End
        if(pincodeList.size()>0){
            query += ' AND MFC_Dealer_PinCode__c in: pincodeList';
        }
        //23feb2023:Shubham:Start
        query += ' Order By Make__c,Model__c ASC';
        //23feb2023:Shubham:End
               System.debug('Stock query ' + query);
        
        List<Product2> productList = Database.query(query);
        /*List<Product2> productList = [select id, Make__c, Model__c, Variant__c, Body_Type__c, Fuel__c, Color__c, Model_Year__c, 
Model_Month__c, IsCertified__c, Dealer_Name__c, Dealer_Name__r.Name, MFC_Dealer_City__c,Registration_Number__c, MFC_Dealer_PinCode__c,
Kilometer__c, Expected_Price__c from Product2 where 
Make__c in: makeList OR Model__c in: modelList OR Variant__c in: variantList OR 
Body_Type__c in: bodyList OR Fuel__c in: fuelList OR Color__c in: colorList OR 
Model_Year__c in: modelYearList OR Model_Month__c in: modelMonthList OR 
IsCertified__c in: certifiedList OR Dealer_Name__r.Name in: dealerList OR 
MFC_Dealer_City__c in: cityList OR MFC_Dealer_PinCode__c in: pincodeList OR 
(Kilometer__c >=: minKm AND Kilometer__c <=: maxKm ) OR 
(Expected_Price__c >=: minBudget AND Expected_Price__c <=: maxBudget)];*/
         System.debug('productList' + productList.size());
        
        list<Id> alreadyCreatedProductId = new list<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        
        if(recordId.startsWith('00Q')) {
             oppList = [select id, lead__c, Product__c from Opportunity where lead__c =: recordId];
        } else {
            if(recordId.startsWith('006')) {
                recordId = [select Id, lead__c from Opportunity where Id =: recordId limit 1].Lead__c;
               
                oppList = [select id, lead__c, Product__c from Opportunity where lead__c =:recordId];   
            }
        }
        
        
        for(Opportunity o: oppList){
            alreadyCreatedProductId.add(o.Product__c);
        }
        for(Product2 pro: productList){
            if(alreadyCreatedProductId.contains(pro.Id)){
                pro.IsActive = False;
            }
        }
        return productList;
    }

    @auraEnabled 
    public static List<String> fetchVariantValues(String modelValueString){
        System.debug('EntitySearchController.fetchVariantValues::');
        System.debug('ModelName ' + modelValueString);
        
        
        Set<String> variantValue = new Set<String>();
        //String VariantQuery = 'select id,Variant__c from Product2 where Model__c =:'+ModelName;
        List<Product2> Variants = [select id,Variant__c from Product2 where Model__c=: modelValueString];
        for(Product2 p : Variants)
        {
            variantValue.add(p.Variant__c);
        }
        System.debug('Variant Successfull' +  variantValue);
        List<String> VariantPicklistValue = new List<String>(variantValue);
        System.debug('VariantPicklistValue' + VariantPicklistValue); 
        return VariantPicklistValue;
        
    }
    
    @auraEnabled
    public static List<Account> getSearchDealerResults(String filterList, String recordId){
        System.debug('EntitySearchController.getSearchDealerResults::');
        System.debug('filterList: ' + filterList);
        searchFilters filters = (searchFilters)JSON.deserialize(filterList,searchFilters.class);   
        System.debug('SearchFilters ' + filters);
        List<String> dealerList = filters.dealerList;
        List<String> cityList = filters.cityList;
        List<String> stateList = filters.stateList;
        List<String> pincodeList = filters.pincodeList;
        String query = 'select id, Code__c,Name,BillingAddress,BillingStreet,BillingCity,BillingState,BillingPostalCode,Active__c,Phone,'+
            'Dealer_Email__c,Dealer_Sales_Email__c from Account where Active__c = true AND RecordType.Name = \'Dealer\'';
        if(dealerList.size()>0 && cityList.size()>0 && pincodeList.size()>0){
            query += ' AND (Name in: dealerList AND BillingCity in: cityList AND BillingPostalCode in: pincodeList)';
        }
        else if(dealerList.size()>0 && cityList.size()>0){
            query += ' AND (Name in: dealerList AND BillingCity in: cityList)';
        }
        else if(cityList.size()>0 && pincodeList.size()>0){
            query += ' AND (BillingCity in: cityList AND BillingPostalCode in: pincodeList)';
        }
        else if(dealerList.size()>0 && pincodeList.size()>0){
            query += ' AND (Name in: dealerList AND BillingPostalCode in: pincodeList)';
        }
        else if(dealerList.size()>0){
            query += ' AND Name in: dealerList';
        }
        else if(cityList.size()>0){
            query += ' AND BillingCity in: cityList';
        }
        //26Sep2021:Sarthak:Start
        else if(stateList != null && stateList.size() > 0){
            query += ' AND BillingState in: stateList';
        }
        //26Sep2021:Sarthak:End
        else if(cityList.size()>0){
            query += ' AND BillingCity in: cityList';
        }
        else if(pincodeList.size()>0){
            query += ' AND BillingPostalCode in: pincodeList';
        }
        System.debug('Dealer query-- ' + query);
        List<Account> accountList = database.query(query);
        /*List<Account> accountList = [select id, Code__c,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,Phone,
Dealer_Email__c,Dealer_Sales_Email__c from Account where 
RecordType.Name = 'Dealer' AND (Name in: dealerList OR BillingCity in: cityList
OR BillingPostalCode in: pincodeList)];*/
        list<Id> alreadyCreatedAccountId = new list<Id>();
        List<Opportunity> oppList1 = new List<Opportunity>();
        
        if(recordId.startsWith('00Q')) {
             oppList1 = [select id, lead__c, AccountId from Opportunity where lead__c =: recordId];
            system.debug('oppList1 '+ oppList1);
        } else {
            if(recordId.startsWith('006')) {
                recordId = [select Id, lead__c from Opportunity where Id =: recordId limit 1].Lead__c;
                system.debug('recordId ' + recordId);
               
                oppList1 = [select id, lead__c, AccountId from Opportunity where lead__c =:recordId];   
            }
        }
        
        for(Opportunity op: oppList1){
            alreadyCreatedAccountId.add(op.AccountId);
        }
        for(Account acc: accountList){
            if(alreadyCreatedAccountId.contains(acc.Id)){
                acc.Active__c = False;
            }
        }
        
        return accountList;
    }
    
    @auraEnabled
    public static void createOpportunity(Id LeadId, List<Id> productIds){
        if(String.valueOf(LeadId).startsWith('00Q')){
            
            System.debug('EntitySearchController.createOpportunity::');
            System.debug('LeadId' + LeadId + 'productIds' + productIds);
            //      List<Lead_Dispatch__c> leadDispatchList = new List<Lead_Dispatch__c>(); 
            List<Opportunity> opportunityList = new List<Opportunity>();    //Added by shubham
            List<Lead> leadsToUpdate = new List<Lead>();
            List<Lead> leadsToInsert = new List<Lead>();
            
            Map<Id,Product2> prodMap = new Map<Id,Product2>();
            Set<Id> leadIds = new Set<Id>();
            for(Product2 prod : [Select Id, Dealer_Name__c,Variant__c,Registration_City__c,Registration_Number__c, Make__c, Model__c, Stock_Id__c from Product2 Where Id =: productIds]){
                prodMap.put(prod.Id,prod);
            }
            Map<String, Schema.SObjectField> fieldMap = Lead.sObjectType.getDescribe().fields.getMap();
            List<String> fieldNames = new List<String>();
            for(String s : fieldMap.keySet()){
                fieldNames.add(s);
            }
            String soqlQuery = ' SELECT ' + string.join(fieldNames, ',') + ' FROM  Lead Where Id =: LeadId';
            Lead leadRecord = Database.query(soqlQuery);
            for(integer i=0;i<productIds.size();i++){
                
                /*  7April2022:Asif :: creating new lead for multiple product.
if(i == 0){
System.debug('productIds[i]: '+productIds[i]);
System.debug('prodMap.get(productIds[i]).Make__c: '+prodMap.get(productIds[i]).Make__c);
System.debug('prodMap.get(productIds[i]).Model__c '+prodMap.get(productIds[i]).Model__c);
System.debug('prodMap.get(productIds[i]).Dealer_Name__c '+prodMap.get(productIds[i]).Dealer_Name__c);
leadRecord.Product__c = productIds[i];
leadRecord.Primary_Make__c = prodMap.get(productIds[i]).Make__c;
leadRecord.Primary_Model__c = prodMap.get(productIds[i]).Model__c;
leadRecord.Dealer__c = prodMap.get(productIds[i]).Dealer_Name__c;

// 3Feb2022:Asif:Start :: field mapping for products
leadRecord.Stock_Id__c = prodMap.get(productIds[i]).Stock_Id__c;
// 3Feb2022:Asif:End
leadRecord.Bypass_validation__c = false;
leadRecord.Status = 'Dealer/Stock Assigned';
leadRecord.Followup_Lead_Created__c = true;
//leadRecord.Status__c = 'Hot';
leadsToUpdate.add(leadRecord);
}
else{
Lead leadClone = leadRecord.clone(false);
System.debug('clone productIds[i]: '+productIds[i]);
System.debug('clone prodMap.get(productIds[i]).Make__c: '+prodMap.get(productIds[i]).Make__c);
System.debug('clone prodMap.get(productIds[i]).Model__c '+prodMap.get(productIds[i]).Model__c);
System.debug('cloneprodMap.get(productIds[i]).Dealer_Name__c '+prodMap.get(productIds[i]).Dealer_Name__c);
leadClone.Product__c = productIds[i];
leadClone.Bypass_validation__c = false;
leadClone.Status = 'Dealer/Stock Assigned';
leadClone.Customer_Id__c = null;
leadClone.Primary_Make__c = prodMap.get(productIds[i]).Make__c;
leadClone.Primary_Model__c = prodMap.get(productIds[i]).Model__c;
leadClone.Dealer__c = prodMap.get(productIds[i]).Dealer_Name__c;
leadClone.Followup_Lead_Created__c = true;
//leadClone.Status__c = 'Hot';
leadsToInsert.add(leadClone);
}
*/
                // 7April2022:Asif:Start ::Lead update and creating dispatch on same lead
                // updating with dealer/Stock
                leadRecord.Product__c = productIds[i];
                leadRecord.Primary_Make__c = prodMap.get(productIds[i]).Make__c;
                leadRecord.Primary_Model__c = prodMap.get(productIds[i]).Model__c;
                leadRecord.Primary_Variant__c = prodMap.get(productIds[i]).Variant__c;
                leadRecord.Register_City__c = prodMap.get(productIds[i]).Registration_City__c;
                leadRecord.Register_No__c = prodMap.get(productIds[i]).Registration_Number__c;
                //     leadRecord.Dealer__c = prodMap.get(productIds[i]).Dealer_Name__c;    //Shubh
                leadRecord.Stock_Id__c = prodMap.get(productIds[i]).Stock_Id__c;
                leadRecord.Bypass_validation__c = false;
                leadRecord.Status = 'Dealer/Stock Assigned';
                leadRecord.Followup_Lead_Created__c = true;
                
                // creating new Dispatch for new FollowUplead
                //    Lead_Dispatch__c ld = new Lead_Dispatch__c();   
                Date date1 = System.today()+1;
                Time mtTime = Time.newInstance(4, 30, 0, 0);
                DateTime dt = DateTime.newInstanceGMT(date1, mtTime);
                system.debug(dt);   
                
                Opportunity ld = new Opportunity();      //Added by shubham
                ld.Lead__c = leadRecord.Id;
                ld.Customer_Phone__c = leadRecord.Phone;
                ld.State__c = leadRecord.Area_State__c;
                ld.Product__c = productIds[i];
                ld.Dealer__c = prodMap.get(leadRecord.Product__c).Dealer_Name__c;
                ld.Primary_Make__c = prodMap.get(leadRecord.Product__c).Make__c;
                ld.Primary_Model__c = prodMap.get(leadRecord.Product__c).Model__c;
                ld.Primary_Variant__c = prodMap.get(leadRecord.Product__c).Variant__c;
                ld.Register_City__c = prodMap.get(leadRecord.Product__c).Registration_City__c;
                ld.Register_No__c = prodMap.get(leadRecord.Product__c).Registration_Number__c;
                ld.Status__c = 'New';
                ld.OwnerId = UserInfo.getUserId();
                ld.Name = leadRecord.LastName;
                ld.CloseDate = System.today() + 10;
                ld.StageName = 'New';  
                ld.Rating__c = 'New';
                ld.LeadSource = 'Call Centre';
                ld.Followup_Date_Time__c = dt;
                //      leadDispatchList.add(ld);                 shubh
                opportunityList.add(ld);              //   shubham
                // 7April2022:Asif:End
            }
            
            
            /* 7April2022:Asif :: creating new lead for multiple product.
System.debug(leadsToInsert);
if(leadsToInsert.size()> 0){
insert leadsToInsert;
}


for(Lead l : leadsToUpdate){
Lead_Dispatch__c ld = new Lead_Dispatch__c();
ld.Lead__c = l.Id;
ld.Dealer__c = prodMap.get(l.Product__c).Dealer_Name__c;
ld.Product__c = l.Product__c;

// 8Mar2022:Asif:Start mapping more fields of product
ld.Primary_Make__c = prodMap.get(l.Product__c).Make__c;
ld.Primary_Model__c = prodMap.get(l.Product__c).Model__c;
// 8Mar2022:Asif:End

// ld.status__c = 'Hot';
ld.Status__c = l.Status__c;  // 9Mar2022:Asif ::Mapped Status with Lead
ld.OwnerId = UserInfo.getUserId();
leadDispatchList.add(ld);

}
*/
            System.debug('opportunityList'+opportunityList);
            System.debug('opportunityList size'+opportunityList.size());
           
            if(opportunityList.size()>0){                                        
                //    insert leadDispatchList;  
                                         
                insert opportunityList;  
                //Added by Shubham
                for(Opportunity ld : opportunityList){                 
                    leadIds.add(ld.Lead__c);
                }
                LeadConstants.fireLMSApiFromLead = TRUE;
                //LeadTriggerHelper.pushSingleLeadsToLMS(leadIds);
                
            }
            if(!Test.isRunningTest())
                update leadRecord;
            
        } 
        //19Nov2022 : Shubham Start
        else if(String.valueOf(LeadId).startsWith('006')){
           //  LeadConstants.isFromAura = true; // sumit for android
            leadId = [Select id , Lead__c from Opportunity Where Id =:LeadId limit 1].Lead__c;
            List<Opportunity> opportunityList1 = new List<Opportunity>();    
            List<Lead> leadsToUpdate1 = new List<Lead>();
            List<Lead> leadsToInsert1 = new List<Lead>();
            Map<Id,Product2> prodMap1 = new Map<Id,Product2>();
            Set<Id> leadIds1 = new Set<Id>();
            for(Product2 prod1 : [Select Id, Dealer_Name__c,Variant__c,Registration_City__c,Registration_Number__c, Make__c, Model__c, Stock_Id__c from Product2 Where Id =: productIds]){
                prodMap1.put(prod1.Id,prod1);
            }
            Map<String, Schema.SObjectField> fieldMap = Lead.sObjectType.getDescribe().fields.getMap();
            List<String> fieldNames = new List<String>();
            for(String s : fieldMap.keySet()){
                fieldNames.add(s);
            }
            String soqlQuery = ' SELECT ' + string.join(fieldNames, ',') + ' FROM  Lead Where Id =: LeadId';
            Lead leadRecord1 = Database.query(soqlQuery);
            for(integer i=0;i<productIds.size();i++){
                
                leadRecord1.Product__c = productIds[i];
                leadRecord1.Primary_Make__c = prodMap1.get(productIds[i]).Make__c;
                leadRecord1.Primary_Model__c = prodMap1.get(productIds[i]).Model__c;
                leadRecord1.Stock_Id__c = prodMap1.get(productIds[i]).Stock_Id__c;
                leadRecord1.Primary_Variant__c = prodMap1.get(productIds[i]).Variant__c;
                leadRecord1.Register_City__c = prodMap1.get(productIds[i]).Registration_City__c;
                leadRecord1.Register_No__c = prodMap1.get(productIds[i]).Registration_Number__c; 
                leadRecord1.Bypass_validation__c = false;
                leadRecord1.Status = 'Dealer/Stock Assigned';
                leadRecord1.Followup_Lead_Created__c = true;
                
                 Date date1 = System.today()+1;
                Time mtTime = Time.newInstance(4, 30, 0, 0);
                DateTime dt1 = DateTime.newInstanceGMT(date1, mtTime);
                system.debug(dt1);  
                
                Opportunity lD = new Opportunity();      
                lD.Lead__c = leadRecord1.Id;
                lD.Customer_Phone__c = leadRecord1.Phone;
                lD.State__c = leadRecord1.Area_State__c;
                lD.Product__c = productIds[i];
                lD.Dealer__c = prodMap1.get(leadRecord1.Product__c).Dealer_Name__c;
                lD.Primary_Make__c = prodMap1.get(leadRecord1.Product__c).Make__c;
                lD.Primary_Model__c = prodMap1.get(leadRecord1.Product__c).Model__c;
                lD.Primary_Variant__c = prodMap1.get(leadRecord1.Product__c).Variant__c;
                lD.Register_City__c = prodMap1.get(leadRecord1.Product__c).Registration_City__c;
                lD.Register_No__c = prodMap1.get(leadRecord1.Product__c).Registration_Number__c;
                lD.Status__c = 'New';
                lD.OwnerId = UserInfo.getUserId();
                lD.Name = leadRecord1.LastName;
                lD.CloseDate = System.today() + 10;
                lD.StageName = 'New';
                lD.Rating__c = 'New';
                lD.LeadSource = 'Call Centre';
                lD.Followup_Date_Time__c = dt1;
                opportunityList1.add(lD); 
            }
            System.debug('opportunityList1'+opportunityList1);
            System.debug('opportunityList1 size'+opportunityList1.size());
           
            if(opportunityList1.size()>0 && !Test.isRunningTest()){  
                insert opportunityList1;
                
                for(Opportunity ld : opportunityList1){                     
                    leadIds1.add(ld.Lead__c);
                }
                LeadConstants.fireLMSApiFromLead = TRUE;
            }
            if(!Test.isRunningTest())
                update leadRecord1;
        }
        
    }
    //Shubham End
    @auraEnabled
    public static void createDealerOpportunity(Id LeadId, List<Id> dealerIds, String selectedMake, String selectedModel){
        if(String.valueOf(LeadId).startsWith('00Q')){                                         //Added by Shubham
            System.debug('EntitySearchController.createDealerOpportunity::');
            System.debug('selectedMake: '+selectedMake);
            System.debug('selectedModel: '+selectedModel);
            //     List<Lead_Dispatch__c> leadDispatchList = new List<Lead_Dispatch__c>();
            List<Opportunity> opportunityList = new List<Opportunity>();
            Map<String, String> leadDealerMap = new Map<String, String>();
            List<Lead> leadArr = [SELECT Id,Phone, Status__c,LastName,customer__c FROM Lead WHERE Id = :LeadId LIMIT 1];
            
            for(Id dealerId : dealerIds){
                Opportunity ld = new Opportunity();
                ld.Lead__c = LeadId;
                ld.Customer_Phone__c = leadArr[0].Phone;
                ld.Dealer__c = dealerId;
                if(!leadDealerMap.containsKey(LeadId)) {
                    leadDealerMap.put(LeadId, dealerId);
                }
                Date date1 = System.today()+1;
                Time mtTime = Time.newInstance(4, 30, 0, 0);
                DateTime dt = DateTime.newInstanceGMT(date1, mtTime);
                system.debug(dt);  
                // ld.status__c = 'Open';
                ld.status__c = 'New'; // 9Mar2022:Asif ::Mapped Status with Lead
                ld.Name = leadArr[0].LastName;
                ld.CloseDate = System.today() + 10;
                ld.StageName = 'New'; 
                ld.Rating__c = 'New';
                ld.LeadSource = 'Call Centre';
                ld.AccountId = leadArr[0].customer__c;
                ld.Followup_Date_Time__c = dt;
                opportunityList.add(ld);
            }
            System.debug('opportunityList'+opportunityList);
            if(opportunityList.size() > 0){
                Lead newLead = new Lead();
                newLead.Id = LeadId;
                newLead.Bypass_validation__c = false;
                newLead.Status = 'Dealer/Stock Assigned';
                //   newLead.Dealer__c = leadDealerMap.get(LeadId);      //shubh
                //newLead.Status__c = 'Hot';
                newLead.Primary_Make__c = selectedMake;
                newLead.Primary_Model__c = selectedModel;
                if(!Test.isRunningTest())
                    update newLead;
               
                if(!Test.isRunningTest()){
                    insert opportunityList;                
                }
                Set<Id> leadIds = new Set<Id>();
                leadIds.add(LeadId);
                LeadConstants.fireLMSApiFromLead = TRUE;
                //LeadTriggerHelper.pushSingleLeadsToLMS(leadIds);
            }
        }
        //21-Nov-22 : Shubham Start 
        else if(String.valueOf(LeadId).startsWith('006')){
            leadId = [Select id , Lead__c from Opportunity Where Id =:LeadId limit 1].Lead__c;
            List<Opportunity> opportunityList2 = new List<Opportunity>();
            Map<String, String> leadDealerMap2 = new Map<String, String>();
            List<Lead> leadArr2 = [SELECT Id,Phone, Status__c,LastName,customer__c FROM Lead WHERE Id = :LeadId LIMIT 1];
            
            for(Id dealerId2 : dealerIds){
                Opportunity lD = new Opportunity();
                lD.Lead__c = LeadId;
                lD.Customer_Phone__c = leadArr2[0].Phone;
                lD.Dealer__c = dealerId2;
                if(!leadDealerMap2.containsKey(LeadId)) {
                    leadDealerMap2.put(LeadId, dealerId2);
                }
                Date date1 = System.today()+1;
                Time mtTime = Time.newInstance(4, 30, 0, 0);
                DateTime dt1 = DateTime.newInstanceGMT(date1, mtTime);
                system.debug(dt1); 
                lD.status__c = 'New';  
                lD.Name = leadArr2[0].LastName;
                lD.CloseDate = System.today() + 10;
                lD.StageName = 'New'; 
                lD.Rating__c = 'New';
                lD.LeadSource = 'Call Centre';
                lD.Followup_Date_Time__c = dt1;
             //   lD.AccountId = leadArr2[0].customer__c; // sumit
                
                opportunityList2.add(lD);
            }
            System.debug('opportunityList2'+opportunityList2);
            if(opportunityList2.size() > 0){
                Lead newLead2 = new Lead();
                newLead2.Id = LeadId;
                newLead2.Bypass_validation__c = false;
                newLead2.Status = 'Dealer/Stock Assigned';
                newLead2.Primary_Make__c = selectedMake;
                newLead2.Primary_Model__c = selectedModel;
                if(!Test.isRunningTest())
                    update newLead2;
                if(!Test.isRunningTest()){
                    insert opportunityList2;
                }
                Set<Id> leadIds2 = new Set<Id>();
                leadIds2.add(LeadId);
                LeadConstants.fireLMSApiFromLead = TRUE;
                
            }
        }
    }
    //Shubham End     
    public class searchFilters{
        @auraEnabled
        Public List<String> makeList;
        @auraEnabled
        Public List<String> modelList;
        @auraEnabled
        Public List<String> variantList;
        @auraEnabled
        Public List<String> bodyList;
        @auraEnabled
        Public List<String> fuelList;
     //   @auraEnabled
     //   Public List<String> TransmissionTypeList;
        @auraEnabled
        Public List<String> colorList;
        @auraEnabled
        Public List<String> modelYearList;
        @auraEnabled
        Public List<String> modelMonthList;
        @auraEnabled
        Public List<String> certifiedList; 
        @auraEnabled
        Public List<String> dealerList;
        @auraEnabled
        Public List<String> cityList;
        @auraEnabled
        Public List<String> stateList;
        @auraEnabled
        Public List<String> pincodeList;
        @auraEnabled
        Public Decimal minKm;
        @auraEnabled
        Public Decimal maxKm;
        @auraEnabled
        Public Decimal minBudget;
        @auraEnabled
        Public Decimal maxBudget;
        
        public void searchFilters(List<String> makeList,List<String> modelList,List<String> variantList,List<String> bodyList,
                                  List<String> fuelList,/*List<String> TransmissionTypeList,*/List<String> colorList,List<String> modelYearList,List<String> modelMonthList,
                                  List<String> certifiedList,List<String> dealerList,List<String> cityList,List<String> pincodeList,
                                  Decimal minKm,Decimal maxKm,Decimal minBudget,Decimal maxBudget, List<String> stateList)
        {
            this.makeList = makeList;
            this.modelList = modelList;
            this.variantList = variantList;
            this.bodyList = bodyList;
            this.fuelList = fuelList;
        //    this.TransmissionTypeList = TransmissionTypeList;
            this.colorList = colorList;
            this.modelYearList = modelYearList;
            this.modelMonthList = modelMonthList;
            this.certifiedList = certifiedList;
            this.dealerList = dealerList;
            this.stateList = stateList;
            this.cityList = cityList;
            this.pincodeList = pincodeList;
            this.minKm = minKm;
            this.maxKm = maxKm;
            this.minBudget = minBudget;
            this.maxBudget = maxBudget;
        }
    }
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        System.debug('EntitySearchController.getDependentMap::');
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        System.debug('controllingField' + controllingField + 'dependentField' + dependentField + 'objDetail' + objDetail);
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
}