/*
* Class created by Deepali
* Purpose: To have a webservice class to pull lead info from LMS to SF and to update info from SF to LMS
*/
@RestResource(urlMapping='/leadupsert')
global class LeadPushToLMS { 
    
    //Added by Deepali
    @HttpPost
    global static void getLeadInfo(){
        OpportunityConstants.isFromAPI = true; // 7June2022:Asif :: flagging if from API
        RestRequest req;
        RestResponse res;
        //try{
        req = RestContext.request;
        res = RestContext.response; 
        
        LogService.requestedFrom = req.remoteAddress; // 10Mar2022:Asif :: For capturing remote Address
        
        res.statusCode = 200;           
        System.debug('req headers: '+req.headers);
        System.debug('req httpMethod: '+req.httpMethod); 
        System.debug('req remoteAddress: '+req.remoteAddress);
        System.debug('req requestBody: '+req.requestBody);
        System.debug('req requestURI: '+req.requestURI);
        System.debug('req resourcePath: '+req.resourcePath);
        System.debug('req params: '+req.params);
        System.debug('res: '+res);
        System.debug('res body: '+res.responseBody);
        System.debug('res status code: '+res.statusCode);
        
        String responseJsonStr = req.requestBody.toString();
        System.debug('responseJsonStr'+responseJsonStr);
        
        
        Map<String,Object> untypedObject = (Map<String,Object>)JSON.deserializeUntyped(responseJsonStr);
        System.debug('untypedObject'+untypedObject);        
        String jsob = JSON.serialize(untypedObject.get('data'));
        System.debug('jsob'+jsob);
        List<LeadDetailModel.LeadWrapper> leadsList = (List<LeadDetailModel.LeadWrapper>)JSON.deserialize(jsob, List<LeadDetailModel.LeadWrapper>.class);
        System.debug('leadsList'+leadsList);
        if(!leadsList.isEmpty()){
            upsertLeadFromLmsToSf(leadsList,res); 
            System.debug('res:'+res);
            System.debug('**res body**' + res.responseBody.toString());
        }  
        LogService.createApiLogs(req.requestURI, responseJsonStr, res.responseBody.toString(), NULL, 'Buyer Lead Upsert');
        
    }    
    
    //Added by Deepali
    //Purpose: to upsert lead records
    public static void upsertLeadFromLmsToSf(List<LeadDetailModel.LeadWrapper> leadObjectList, RestResponse res){
        System.debug('leadObjectList: ' + leadObjectList);
        System.debug('res: '+res);
        
        List<Lead> leadToUpsertList = new List<Lead>();
        List<Lead> leadToUpsertWithPhoneList = new List<Lead>();
        Map<String,List<Lead_Dispatch__c>> leadToDispatchListMap = new Map<String,List<Lead_Dispatch__c>>();
        List<Lead_Dispatch__c> targetList = new List<Lead_Dispatch__c>();
        List<Lead_Dispatch__c> targetWithPhoneList = new List<Lead_Dispatch__c>();
        List<Lead_Dispatch__c> targetWithPrivateIdList = new List<Lead_Dispatch__c>();
        Set<String> stockIdSet = new Set<String>(); 
        Set<String> PhoneSet = new Set<String>(); 
        Set<String> leadIdSets = new Set<String>(); // sumit
        Set<String> dealerIdSet = new Set<String>();
        List<Product2> stockList = new List<Product2>();
        List<Account> dealerList = new List<Account>();
        Map<String,Product2> stockIdtoProductMap = new Map<String,Product2>();
        Map<String,Account> dealerIdMap = new Map<String,Account>();
        List<Database.UpsertResult> leadResult = new List<Database.UpsertResult>();
        List<Database.SaveResult> leadResult2 = new List<Database.SaveResult>();
        List<Database.SaveResult> dispatchResult2 = new List<Database.SaveResult>();
        
        //Added by Soumya
        List<Database.SaveResult> leadUpdateResult = new List<Database.SaveResult>();
        List<Database.SaveResult> dispatchUpdateResult = new List<Database.SaveResult>();
        List<Database.UpsertResult> dispatchResult = new List<Database.UpsertResult>();
        List<Database.UpsertResult> dispatchResultWithPrivateLead = new List<Database.UpsertResult>();
        List<LeadDetailModel.ResponseLeadobj> resLeadWrapList = new List<LeadDetailModel.ResponseLeadobj>();
        List<LeadDetailModel.ResponseDispatchobj> resDispatchWrapList = new List<LeadDetailModel.ResponseDispatchobj>();
        Map<String,Id> leadIdMap = new Map<String,Id>();
        Map<String, Id> leadMapforDisp = new Map<String, Id>();
        
        //Added By Aravindan, Date : 1/9/2020
        List<Lead> leadToUpsertWithPrivateleadIdList = new List<Lead>();
        List<String> leadToUpsertListPrivateleadIdExternalId = new List<String>(); 
        List<Database.UpsertResult> leadResultWithPrivateIds = new List<Database.UpsertResult>();
        Map<String,Lead> LeadSfIdPrivateTrackMap = new Map<String,Lead>();
        
        //Added by Soumya -- 12/11/20
        List<Lead> procLeadSfId = new List<Lead>();
        
        //Added By Aravindan
        List<String> leadToUpsertListExternalId = new List<String>();     
        List<String> leadToUpsertWithPhoneListExternalId = new List<String>();
        Map<String,Lead> LeadSfIdTrackMap = new Map<String,Lead>();
        
        // 8Feb2022:Asif:Start ::adding dynamic Process status value
        Boolean isProcessFailed = false;
        // 8Feb2022:Asif:End
        
        //Added by Soumya 12/01/2021
        List<Lead> leadToUpdateWithSFId = new List<Lead>();
        List<Lead_Dispatch__c> leaddispToUpdateWithSfId = new List<Lead_Dispatch__c>();
        
        
        List<Id> sfIds = new List<Id>();
        List<Id> sfOppId = new List<Id>();
        Map<String, String> lmsMap = new Map<String, String>();
        
        Set<String> lmsIdSet = new Set<String>();
        Map<String, String> phoneLeadIdMap = new Map<String, String>();
        Map<String, String> LmsLeadIdMap = new Map<String, String>();
        Map<String, String> leadIdPhoneMap = new Map<String, String>();
        Map<Id, Lead> leadSourceIdMap = new Map<Id, Lead>();// Sumit::CRM-1085
        Map<string, Lead> leadSourcePhoneMap = new Map<string, Lead>();// Sumit::CRM-1085
        Map<Id, Opportunity> leadSourceOppMap = new Map<Id, Opportunity>();// Sumit::CRM-1085
        
        List<String> oppLMSArr = new List<String>();
        for(LeadDetailModel.LeadWrapper obj : leadObjectList){
            // stockIdSet.add(obj.stock_id);  because stock should come in the target only to insert into opp only
            if(!String.isEmpty(obj.sfdc_lead_id)) {
                sfIds.add(obj.sfdc_lead_id);
            }
            leadIdSets.add(obj.sfdc_lead_id);
            lmsIdSet.add(obj.customer_mobile);
            if(obj.customer_mobile != null) {
                phoneLeadIdMap.put(obj.customer_mobile, null);
                PhoneSet.add(obj.customer_mobile);
            }
            if(obj.sfdc_lead_id != null) {
                leadIdPhoneMap.put(obj.sfdc_lead_id, obj.customer_mobile);
               // newmap.put(obj.sfdc_lead_id,obj.customer_mobile);
            }
            
            // lms map
            if(!String.isEmpty(obj.lms_lead_id)) {
                CheckRecursiveTrigger.runOnceLMS(); // sumit::Stop LMS API callout if status update from LMS through /leadupsert
                CheckRecursiveTrigger.runOnceCNB(); // sumit::CRM-1053::Stop CNB API callout if status update for reserve lead is from CNB through /leadupsert
                LmsLeadIdMap.put(obj.sfdc_lead_id, obj.lms_lead_id);
            }
            
            if(obj.target != null){
                for(LeadDetailModel.Target targetObj : obj.target){
                    sfOppId.add(targetObj.sfdc_lead_dispatch_id);
                    oppLMSArr.add(targetObj.lms_dispatch_id);
                    if(targetObj.target_id != null){
                        dealerIdSet.add(targetObj.target_id);
                    }
                    if(targetObj.stock_id != null){
                        stockIdSet.add(targetObj.stock_id);
                    }else if(obj.stock_id != null){
                        stockIdSet.add(obj.stock_id);
                    }
                }
            }
        } 
        
        // sumit start
        Map<string,Id> opportunityMap = new Map<string,Id>(); 
        system.debug('stockIdSet '+stockIdSet);
        system.debug('dealerIdSet '+dealerIdSet);
        system.debug('sfIds '+sfIds);
        
        if(!sfIds.isEmpty()) {
            for(Lead lea : [Select id, Customer_Id__c,leadSource,Phone from lead where Id IN :sfIds]){
                lmsMap.put(lea.Id, lea.Customer_Id__c); // external Id 
                leadSourceIdMap.put(lea.Id,lea); // Sumit::CRM-1085
               //  System.debug('leadSourceMap'+leadSourceMap);
               
            }
           
        }
        
        // creating Map<Phone, LeadId>
        if(!phoneLeadIdMap.isEmpty()) {
            for(Lead l : [Select Id, Phone from lead where Phone IN :phoneLeadIdMap.keySet() AND RecordTypeId =:LeadConstants.buyerLeadRecordTypeId ORDER BY CreatedDate DESC]) {
                phoneLeadIdMap.put(l.Phone, l.Id);
               leadSourcePhoneMap.put(l.Phone,l);
            }
        }
        System.debug('phoneLeadIdMap ' + phoneLeadIdMap);
        
        // creating Map<SfdcLeadId, Phone>
        if(!leadIdPhoneMap.isEmpty()) {
            for(Lead l : [Select Id, Phone from lead where Id IN :leadIdPhoneMap.keySet() ORDER BY CreatedDate DESC]) {
                leadIdPhoneMap.put(l.Id, l.Phone);
                phoneLeadIdMap.put(l.Phone, l.Id);
              
            }
        }
        System.debug('phoneLeadIdMap ' + phoneLeadIdMap);
        
        
        // querying Opportunity
        List<Opportunity> oppList = [select Id, Product__r.Stock_ID__c, Dealer_Code__c, Lead__c,leadSource  from Opportunity  where (Product__r.Stock_ID__c IN :stockIdSet AND Dealer_Code__c IN :dealerIdSet AND lead__c IN :phoneLeadIdMap.values()) OR Id IN: sfOppId];
        for(Opportunity opp: oppList){
            System.debug('oppList.opp ' + opp);
            opportunityMap.put(opp.Product__r.Stock_ID__c + '-' + opp.Dealer_Code__c + '-' + opp.Lead__c, opp.Id);
            leadSourceOppMap.put(opp.Id,opp);
            
        }
      
        system.debug('leadSourceOppMap '+leadSourceOppMap);
        system.debug('opportunityMap '+opportunityMap);
        
        //sumit end
        if(!stockIdSet.isEmpty()) {
            stockList = [SELECT Id, Stock_ID__c, Expected_Price__c, MFC_Dealer_City__c, Dealer_Name__c,Fuel__c,Model_Year__c,Registration_City__c,make__c,Model__c,Variant__c,No_of_Owners__c FROM Product2 WHERE Stock_ID__c IN :stockIdSet];
            system.debug('stockList- sumit'+stockList);
        }
        if(!dealerIdSet.isEmpty()) {
            dealerList = [SELECT Id, Code__c FROM Account WHERE Code__c IN :dealerIdSet And RecordType.name = 'Dealer'];
        }
        
        System.debug('stockList ' + stockList);
        if(!stockList.isEmpty()){
            for(Product2 stock : stockList){
                stockIdtoProductMap.put(stock.Stock_ID__c, stock);
            }
        }
        
        System.debug('dealerIdSet: ' + dealerIdSet);
        if(!dealerList.isEmpty()){
            for(Account dealer : dealerList){
                dealerIdMap.put(dealer.Code__c, dealer);     //Code__c :- it is a external ID 
            }
        }
        
        System.debug('dealerIdMap: '+dealerIdMap);
        System.debug('stockIdtoProductMap: '+stockIdtoProductMap);
        
        
        System.debug('leadObjectList: '+leadObjectList);
        System.debug('leadObjectList sizw: '+leadObjectList.size());
        List<AssignmentRule> lstAssignmentRule = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Lead' AND Active = true LIMIT 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        if(!lstAssignmentRule.isEmpty()) {
            AssignmentRule objAssignmentRule = lstAssignmentRule[0];
            dmlOpts.assignmentRuleHeader.assignmentRuleId= objAssignmentRule.id;
        }
        
        Map<String, Lead> phoneLeadMap = new Map<String, Lead>();
        Map<String, Lead> LMSLeadMap = new Map<String, Lead>(); //LMS
        Map<String, Lead> phoneLeadMaps = new Map<String, Lead>(); // sumit
        Map<String, List<Opportunity>> phoneOppArrMap = new Map<String, List<Opportunity>>();
        
        for(LeadDetailModel.LeadWrapper obj : leadObjectList){
            Lead lea = new Lead();
            if(!String.isEmpty(obj.customer_mobile)) {
                // for updating the lead that are with same phone 
                if(phoneLeadIdMap.containsKey(obj.customer_mobile)) {
                    lea.Id = phoneLeadIdMap.get(obj.customer_mobile);
                }
                lea.Phone = obj.customer_mobile;
            }
            
            if(!String.isBlank(obj.sfdc_lead_id)) {
                lea.Id = obj.sfdc_lead_id;
                String phone =  leadIdPhoneMap.get(obj.sfdc_lead_id);
                if(!String.isEmpty(phone)) {
                    lea.Phone = phone;
                    obj.customer_mobile = phone;
                }
            } else {
                lea.setOptions(dmlOpts); // Assignment Rules
            }
            
            // If lms id in request body
            if(!String.isBlank(obj.lms_lead_id)){
                
                lea.Customer_Id__c = obj.lms_lead_id;
            }
            if(!String.isBlank(obj.customer_name)) {
                 lea.LastName = obj.customer_name; 
            }
            if(!String.isBlank(obj.customer_email))
                lea.Email = obj.customer_email;
            
            if(!String.isBlank(obj.rating))
                lea.Rating  = obj.rating; 
            
            if(!String.isBlank(obj.lead_title))
                lea.Lead_Title__c  = obj.lead_title;  // string
            if(!String.isBlank(obj.stock_type))
                lea.Stock_Type__c = obj.stock_type;  // string
            if(!String.isBlank(obj.area_city)){
                lea.Area_City__c = obj.area_city;   // string
                lea.Seller_City__c = obj.area_city;  // picklist
            }
            if(!String.isBlank(obj.area_state)){
                lea.Area_State__c = obj.area_state.toUpperCase();   // string
                lea.Seller_State__c = obj.area_state.toUpperCase();  // picklist
            }
            if(!String.isBlank(obj.area_pincode)){
                lea.Area_PinCode__c = obj.area_pincode;  // string
            }
            
            if(!String.isBlank(obj.client_ip)){
                lea.Client_IP__c = obj.client_ip;   // string
            }
            
            if(!String.isBlank(obj.comments)){
                lea.Comments__c = obj.comments;   // textarea
            }
            
            if(!String.isBlank(obj.customer_expected_price)){
                lea.Customer_Expected_Price__c = Decimal.valueOf(obj.customer_expected_price);   //currency
            }
            
            if(!String.isBlank(obj.funding_amount)){
                lea.Funding_Amount__c = Decimal.valueOf(obj.funding_amount); //currency
            }
            
            if(!String.isBlank(obj.is_otp_verfied)){
                lea.Is_Otp_Verified__c = obj.is_otp_verfied;  //// picklist
            }
            
            if(!String.isBlank(obj.whatsapp_consent)){
                lea.WhatsApp_consent__c = obj.whatsapp_consent; // picklist
            }
            
            if(!String.isBlank(obj.lead_category)){
                lea.Lead_Category__c = obj.lead_category;  // picklist
            }
            
            if(!String.isBlank(obj.lead_flag)){
                lea.Lead_Flag__c = obj.lead_flag;   // picklist
            }
            
            if(!String.isBlank(obj.lead_priority)){
                lea.Lead_Priority__c = obj.lead_priority;  // picklist
            }
            
            if(!String.isBlank(obj.lead_tags)){
                lea.Lead_Tags__c = obj.lead_tags;  // picklist
            }
            
            if(!String.isBlank(obj.lead_type) && obj.lead_type.toUpperCase().equals(LeadConstants.ProcurementConstant)){
                lea.Lead_Type__c = obj.lead_type;  // picklist
                lea.RecordTypeId = LeadConstants.SellerLeadRecordTypeId;   //RecordType
                lea.Lead_Created_From__c = 'LMS'; // string
                
                // 21Jan2022:Asif:Start :: Adding HI_Serviceable__c 
                if(!String.isBlank(String.valueOf(obj.hi_serviceable)))
                    lea.HI_Serviceable__c = String.valueOf(obj.hi_serviceable); //// picklist
                // 21Jan2022:Asif:End
                
            } else if(!String.isBlank(obj.lead_type)){
                lea.RecordTypeId =  LeadConstants.buyerLeadRecordTypeId;  //RecordType
            }
            if(!String.isBlank(obj.lead_flag)){
                lea.Lead_Flag__c = obj.lead_flag;   //// picklist
            }
            if(!String.isBlank(obj.marketing_campaign)){
                lea.Marketing_Campaign__c = obj.marketing_campaign;  //string
            }
            
            if(!String.isBlank(obj.marketing_content)){
                lea.Marketing_Content__c = obj.marketing_content; // textarea
            }
            if(!String.isBlank(obj.marketing_device)){
                lea.Marketing_Device__c = obj.marketing_device;   // string
            }
            if(!String.isBlank(obj.marketing_medium)){
                lea.Marketing_Medium__c = obj.marketing_medium;   // string
            }    
            if(!String.isBlank(obj.marketing_source)) {
                lea.Marketing_Source__c = obj.marketing_source;   // string  
            }
            if(!String.isBlank(obj.marketing_term)){
                lea.Marketing_Term__c = obj.marketing_term;  // string
            }
            // Sumit ::start- CRM-1085
            if(!String.isBlank(obj.lead_source)){ // Update case
                if(leadSourcePhoneMap.containsKey(obj.customer_mobile) || leadSourceIdMap.containsKey(lea.Id) ){
   
                } else { // insert case
                    lea.LeadSource = obj.lead_source; 
                }
                
            }
            // Sumit ::End- CRM-1085
            
            if(!String.isBlank(obj.lead_status))
                lea.Status__c = obj.lead_status; // picklist
            if(!String.isBlank(obj.lost_reason))
                lea.Lost_Reason__c = obj.lost_reason; // picklist
            if(String.isBlank(obj.stock_id)){  
                if(obj.target != null) {
                    for(LeadDetailModel.Target targetStockid : obj.target){
                        if(!String.isEmpty(targetStockid.stock_id)) {
                            lea.Stock_Id__c = targetStockid.stock_id;
                        }
                        
                    }
                }
            }
            if(!String.isBlank(obj.stock_id)){
                lea.Stock_Id__c = obj.stock_id;  // string
                if(stockIdtoProductMap.containsKey(obj.stock_id)){
                    
                    // 31Jan2022:Asif:Start :: mapping dealer with stock on Lead
                    lea.Dealer__c = stockIdtoProductMap.get(obj.stock_id).Dealer_Name__c;  // account
                    // 31Jan2022:Asif:End
                    
                    lea.Product__c =  stockIdtoProductMap.get(obj.stock_id).Id;   //    Product2
                    lea.Year__c = stockIdtoProductMap.get(obj.stock_id).Model_Year__c; // string
                    lea.City__c = stockIdtoProductMap.get(obj.stock_id).MFC_Dealer_City__c; // string
                    lea.Fuel__c = stockIdtoProductMap.get(obj.stock_id).Fuel__c; // string
                    lea.Dealer_Expected_Price__c = String.valueOf(stockIdtoProductMap.get(obj.stock_id).Expected_Price__c); // string
                }
                
                
                //Ankit(25 Aug)::CRM-971:Create product before adding lead for CNB Warranty Dealer leads
                else{
                    if(obj.target != null){
                        for(LeadDetailModel.Target targetObject : obj.target){
                            if(targetObject.target_id != null && targetObject.target_id == '4317'){
                                Product2 pro = new Product2();
                                pro.Stock_ID__c = obj.stock_id;
                                pro.Name = obj.primary_model + '-' +obj.stock_id; 
                                //item.Model+'-'+item.StockID;
                                pro.Make__c = obj.primary_make;
                                pro.Model__c = obj.primary_model;
                                pro.Variant__c = obj.primary_variant;
                                pro.Color__c = obj.color;
                                pro.Kilometer__c = Integer.valueOf(obj.kms);
                                pro.No_of_Owners__c = Integer.valueOf(obj.owner);
                                pro.Registration_Number__c = obj.register_no;
                                pro.Registration_City__c = obj.register_city;
                                //           pro.Expected_Price__c = Integer.valueOf(obj.stock_listed_price);  // sumit(10 oct)::CRM-998: comments this  code 
                                System.debug('OBJ.TARGET JSON DATA: '+obj);
                                System.debug('OBJ.TARGET JSON DATA: '+obj.target);                    
                                pro.Model_Year__c = obj.mfg_year;
                                pro.Model_Month__c = obj.mfg_month;                    
                                if(obj.target != null){
                                    for(LeadDetailModel.Target targetObj : obj.target){
                                        if(targetObj.target_id != null)
                                        {
                                            system.debug('Target ID: '+targetObj.target_id);
                                           list<Account> acc = [select Id from Account where Code__c =: targetObj.target_id limit 1];
                                            if(!acc.isEmpty()){
                                                 pro.Dealer_Name__c = acc[0].Id;
                                            }
                                           
                                            
                                            pro.MFC_Dealer_Code__c = targetObj.target_id;
                                        }
                                        if(targetObj.target_name != null)
                                            pro.Name_of_the_Dealer__c = targetObj.target_name;
                                    }
                                }
                                insert pro;
                                lea.Dealer__c = pro.Dealer_Name__c;    // account                
                                lea.Product__c = pro.Id;    // product2
                                lea.Subcity__c = '';     // picklist                   
                                lea.Year__c = pro.Model_Year__c; // string
                                lea.City__c = pro.MFC_Dealer_City__c; // string
                                lea.Fuel__c = pro.Fuel__c; // string
                                lea.Dealer_Expected_Price__c = String.valueOf(pro.Expected_Price__c); // string
                            }                     
                        }
                    }
                    //
                    
                }
                //Ankit(25 Aug)::CRM-971:Create product before adding lead for CNB Warranty Dealer leads
                
            }
            if(!String.isBlank(obj.primary_make)){
                lea.Primary_Make__c = obj.primary_make; // string
                lea.Make__c = obj.primary_make; // string
            }
            if(!String.isBlank(obj.primary_model)){
                lea.Primary_Model__c = obj.primary_model; // string
                lea.Model__c = obj.primary_model;   // picklist
            }
            if(!String.isBlank(obj.primary_variant)){
                lea.Primary_Variant__c  = obj.primary_variant; // string
                lea.Variant__c  = obj.primary_variant; // string
            }
            if(!String.isBlank(obj.mfg_year))
                lea.MFG_Year__c  = obj.mfg_year; // string
            if(!String.isBlank(obj.mfg_month))
                lea.MFG_Month__c   = obj.mfg_month; // string
            if(!String.isBlank(obj.register_month))
                lea.Register_Month__c  = obj.register_month; // string
            if(!String.isBlank(obj.register_year))
                lea.Register_Year__c   = obj.register_year; // string
            if(!String.isBlank(obj.color))
                lea.Color__c  = obj.color; // string
            if(!String.isBlank(obj.kms)){
                lea.Kilometers__c  = String.valueOf(obj.kms); // string
                lea.Kilometer__c = Decimal.valueOf(obj.kms);  // double
            }
            if(!String.isBlank(obj.owner))
                lea.Owner__c   = String.valueOf(obj.owner); // string
            if(!String.isBlank(obj.register_no))
                lea.Register_No__c   = obj.register_no; // string
            if(!String.isBlank(obj.register_city))
                lea.Register_City__c   = obj.register_city; // string
            if(!String.isBlank(obj.stock_listed_price))
                lea.Stock_Listed_Price__c   = String.valueOf(obj.stock_listed_price); // string
            //Added by soumya -12/11/20
            if(!String.isBlank(obj.td_client_id))
                lea.Td_Client_Id__c = obj.td_client_id; // string
            
            // 11April2022:Asif:Start :: mapping order Id
            if(!String.isBlank(obj.order_id)) {
                lea.Order_ID__c = obj.order_id;  // string
            } 
            // 11April2022:Asif:End 
            
            if(!String.isBlank(obj.lead_type) && obj.lead_type.toUpperCase().equals(LeadConstants.ProcurementConstant) 
               && !String.isBlank(obj.sfdc_lead_id)){
                   procLeadSfId.add(lea);
               } //end
            //Added By Aravindan
            if(!String.isBlank(obj.private_lead_id)){
                System.debug('***private_lead_id***' + obj.private_lead_id);
                //     lea.Private_lead_id__c = obj.private_lead_id;   // external id
            }
            
            // external Id user below
            if((lea.Customer_Id__c == NULL || lea.Customer_Id__c == '') && (lea.Private_lead_id__c == NULL || lea.Private_lead_id__c == '') && //// external Id
               obj.sfdc_lead_id == NULL){  
                   system.debug('corerect');
                   leadToUpsertWithPhoneList.add(lea);
               }else if(!String.isBlank(obj.customer_mobile) && String.isBlank(obj.sfdc_lead_id)){                
                   leadToUpsertList.add(lea);
               }else if(!String.isBlank(obj.private_lead_id) && String.isBlank(obj.sfdc_lead_id)){
                   leadToUpsertWithPrivateleadIdList.add(lea);
               }
            
            //Second condition added on 29/01/21
            if(!String.isBlank(obj.sfdc_lead_id) && !String.isBlank(obj.lead_type) && !obj.lead_type.toUpperCase().equals(LeadConstants.ProcurementConstant)){
                leadToUpdateWithSFId.add(lea);
            }
            
            if(lea.Phone != null) {
                phoneLeadMap.put(lea.Phone, lea);
            }
            
            if(lea.Customer_Id__c != null) {
                LMSLeadMap.put(lea.Customer_Id__c, lea);
            }
            
            if(!String.isBlank(obj.lead_type) && obj.lead_type.toUpperCase() != LeadConstants.ProcurementConstant && obj.target != null && !obj.target.isEmpty()){
                
                for(LeadDetailModel.Target trtwraps : obj.target){ 
                    
                    Opportunity opp = new Opportunity();
                    if(!String.isBlank(trtwraps.stock_id)){
                        String key = trtwraps.stock_id + '-' + trtwraps.target_id + '-' + phoneLeadIdMap.get(obj.customer_mobile);
                        system.debug('key:-'+key);
                        if(opportunityMap.containsKey(key)){
                            opp.Id = opportunityMap.get(key);
                        } 
                    } else {
                        if(!String.isBlank(obj.stock_id)){
                            String key = obj.stock_id + '-' + trtwraps.target_id + '-' + phoneLeadIdMap.get(obj.customer_mobile);
                            system.debug('key:-'+key);
                            if(opportunityMap.containsKey(key)){
                                opp.Id = opportunityMap.get(key);
                            } else {
                                //opp.Lead__r = new Lead(
                                //  Customer_Id__c = obj.customer_mobile
                                // );
                            }
                        }
                    }
                    // lms opp Id
                    if(!String.isBlank(trtwraps.lms_dispatch_id)){
                        CheckRecursiveTrigger.runOnceOppLMS();  //  sumit::Stop LMS API callout if status update from LMS through /leadupsert
                        CheckRecursiveTrigger.runOnceCNB();  // sumit::CRM-1053::Stop CNB API callout if status update for reserve lead is from CNB through /leadupsert
                        opp.LMS_Opp_Id__c = trtwraps.lms_dispatch_id;
                    }
                    
                    if(!String.isEmpty(trtwraps.sfdc_lead_dispatch_id)) {
                        opp.Id = trtwraps.sfdc_lead_dispatch_id;
                    }
                    if(!String.isEmpty(obj.customer_mobile)) {
                        opp.Phone__c = obj.customer_mobile;
                        opp.Customer_Phone__c = obj.customer_mobile;
                    }
                    
                    if(!String.isBlank(trtwraps.stock_id)) // StockId Map
                        opp.StockId__c = trtwraps.stock_id;
                    if(!String.isBlank(trtwraps.target_id)) // dealerCode Map
                        opp.Dealer_Code__c = trtwraps.target_id;
                    if(!String.isBlank(obj.customer_name)){
                        opp.Name = obj.customer_name;
                    }
                    if(opp.Id == null){
                      opp.StageName = 'New'; // Sumit::CRM-1062-Default Opportunity stage on creation should be "New" and not "Qualification" // CRM-1131-Do not set default opportunity stage in leadupsert API        
                    }
                     opp.CloseDate = System.today() + 10;  
                    
                    
                    // Sumit ::start- CRM-1085
                    if(!String.isBlank(obj.lead_source)){
                        if(leadSourceOppMap.containsKey(opp.Id)){  // update case
                           // if(leadSourceOppMap.get(opp.Id).LeadSource != null && opp.LeadSource != leadSourceOppMap.get(opp.Id).LeadSource){
                           //     opp.LeadSource = leadSourceOppMap.get(opp.Id).leadSource;
                          //  }
                            
                        } else { // insert case
                            opp.LeadSource = obj.lead_source; 
                        }
                        
                    }
                    // Sumit ::End- CRM-1085
                   
                    if(!String.isBlank(obj.rating))
                        opp.Rating__c  = obj.rating; 
                    
                    if(!String.isBlank(trtwraps.stock_id)){
                        opp.StockId__c = trtwraps.stock_id;
                        system.debug('opp.StockId__c'+opp.StockId__c);
                        opp.Product__c = stockIdtoProductMap.containsKey(trtwraps.stock_id) ? stockIdtoProductMap.get(trtwraps.stock_id).Id : NULL;  // product2
                        system.debug('opp.Product__c'+opp.Product__c);
                    }
                    else{
                        if(!String.isBlank(obj.stock_id)){
                            opp.StockId__c = obj.stock_id;
                            opp.Product__c = stockIdtoProductMap.containsKey(obj.stock_id) ? stockIdtoProductMap.get(obj.stock_id).Id : NULL;  // product2
                            system.debug('opp.Product__c'+opp.Product__c);
                        }
                    }
                    if(!String.isBlank(trtwraps.employee_id)){
                        opp.Employee_Id__c = trtwraps.employee_id;  // string
                    }
                    if(!String.isBlank(trtwraps.employee_name)){
                        opp.Employee_Name__c = trtwraps.employee_name; // string 
                    }
                    if(!String.isBlank(trtwraps.employee_type))
                        opp.Employee_Type__c = trtwraps.employee_type; // string
                    if(!String.isBlank(trtwraps.Ext_warranty_amount))
                        opp.Ext_warranty_amount__c = trtwraps.Ext_warranty_amount; // string
                    if(!String.isBlank(trtwraps.Ext_warranty_cancelled))
                        opp.Ext_warranty_cancelled__c = trtwraps.Ext_warranty_cancelled; // string
                    if(!String.isBlank(trtwraps.Ext_warranty_end_date))
                        opp.Ext_warranty_end_date__c = trtwraps.Ext_warranty_end_date; // string
                    if(!String.isBlank(trtwraps.Ext_warranty_end_kilometre))
                        opp.Ext_warranty_end_kilometre__c = trtwraps.Ext_warranty_end_kilometre; // string
                    if(!String.isBlank(trtwraps.Ext_warranty_number))
                        opp.Ext_warranty_number__c = trtwraps.Ext_warranty_number; // string
                    if(!String.isBlank(trtwraps.Ext_warranty_punched))
                        opp.Ext_warranty_punched__c = trtwraps.Ext_warranty_punched; // string
                    if(!String.isBlank(trtwraps.Ext_warranty_recommended))
                        opp.Ext_warranty_recommended__c = trtwraps.Ext_warranty_recommended; // string
                    if(!String.isBlank(trtwraps.Ext_warranty_sold_date))
                        opp.Ext_warranty_sold_date__c = trtwraps.Ext_warranty_sold_date; // string
                    if(!String.isBlank(trtwraps.Ext_warranty_start_date))
                        opp.Ext_warranty_start_date__c = trtwraps.Ext_warranty_start_date; // string
                    if(!String.isBlank(trtwraps.Ext_warranty_start_kilometre))
                        opp.Ext_warranty_start_kilometre__c = trtwraps.Ext_warranty_start_kilometre; // string  
                    //05 May  2023:Sumit:Start :: CRM-1143 :: If the field is more than 255 character then it takes only 255 character
                    if(!String.isBlank(trtwraps.followup_comments))
                        opp.Followup_Comments__c = trtwraps.followup_comments.length() > 255 ? trtwraps.followup_comments.substring(0,254) : trtwraps.followup_comments; // string
                    //05 May  2023:Sumit:End :: CRM-1143 :: If the field is more than 255 character then it takes only 255 character
                    if(!String.isBlank(trtwraps.followup_date))
                        opp.Followup_Date__c = trtwraps.followup_date; // string
                    if(!String.isBlank(trtwraps.lms_dispatch_id)) {
                        // opp.Lms_Dispatch_Id__c = trtwraps.lms_dispatch_id;
                    }
                    
                      // 18May2023:Shubham:Start-CRM-1148 
                    if(!String.isBlank(obj.marketing_campaign)) {
                         opp.Marketing_Campaign__c = obj.marketing_campaign;
                    }
                    if(!String.isBlank(obj.marketing_device)) {
                         opp.Marketing_Device__c = obj.marketing_device;
                    }
                    if(!String.isBlank(obj.marketing_medium)) {
                         opp.Marketing_Medium__c = obj.marketing_medium;
                    }
                     if(!String.isBlank(obj.marketing_term)) {
                         opp.Marketing_Term__c = obj.marketing_term;
                    }
                     if(!String.isBlank(obj.marketing_source)) {
                         opp.Marketing_Source__c = obj.marketing_source;
                    }
                     if(!String.isBlank(obj.lead_category)) {
                         opp.Lead_Category__c = obj.lead_category;
                    }
                    // 18May2023:Shubham:End-CRM-1148
                    
                    // 7Nov2023:Start::Sumit:CRM-1207::Resevation Flow
                    if(!String.isBlank(trtwraps.reservation_status)){
                        opp.Reservation_Status__c = Boolean.valueOf(trtwraps.reservation_status);
                    }
                    else{
                        if(!String.isBlank(obj.reservation_status)){
                            opp.Reservation_Status__c =  Boolean.valueOf(obj.reservation_status);
                        }
                    }
                    // 7Nov2023::End:Sumit:CRM-1207
                    
                    if(!String.isBlank(trtwraps.status))
                        opp.status__c = trtwraps.status; // picklist
                    if(!String.isBlank(obj.lost_reason)){
                        opp.Lost_Reason__c = obj.lost_reason;  // picklist
                    }
                    if(!String.isBlank(trtwraps.status_updated_by))
                        opp.Status_Updated_By__c = trtwraps.status_updated_by;  // string
                    if(!String.isBlank(trtwraps.target_id)){
                        // opp.Lead_Source_Dealer_Id__c = trtwraps.target_id;
                        opp.Dealer_Code__c = trtwraps.target_id; // string
                        opp.Dealer__c = dealerIdMap.containsKey(trtwraps.target_id) ? dealerIdMap.get(trtwraps.target_id).Id : NULL; // aacount
                        if(stockIdtoProductMap.containsKey(trtwraps.stock_id)){
                            Product2 proRec = stockIdtoProductMap.get(trtwraps.stock_id);
                            opp.Product__c =  proRec.Id; //product2
                            opp.Primary_Make__c = proRec.Make__c;    // string
                            opp.Primary_Model__c = proRec.Model__c;   // string
                            opp.Primary_Variant__c = proRec.Variant__c;  // string
                            opp.Owner__c = String.valueOf(proRec.No_of_Owners__c);  // string
                        }
                        else{ //Girish 15-01-2022 Start
                            if(!String.isBlank(obj.primary_make)){
                                opp.Primary_Make__c = obj.primary_make; // string
                                opp.Make__c = obj.primary_make; // string
                            }
                            if(!String.isBlank(obj.primary_model)){
                                opp.Primary_Model__c = obj.primary_model; // string
                                opp.Model__c = obj.primary_model;   // picklist
                            }
                            if(!String.isBlank(obj.primary_variant)){
                                opp.Primary_Variant__c  = obj.primary_variant; // string
                                opp.Variant__c  = obj.primary_variant; // string
                            }
                            if(!String.isBlank(obj.owner))
                                opp.Owner__c   = String.valueOf(obj.owner); // string
                        }//Girish 15-01-2022 End
                    }
                    
                    if(!String.isBlank(obj.register_no)){
                        opp.Register_No__c  = obj.register_no;
                    }
                    if(!String.isBlank(obj.register_city)){
                        opp.Register_City__c  = obj.register_city;
                    }

                    if(!String.isBlank(obj.area_state)){
                        opp.State__c = obj.area_state.toUpperCase();                    
                    }
                    
                    
                        
                    
                    if(!String.isBlank(trtwraps.target_source)){
                      //  opp.LeadSource = trtwraps.target_source;
                    }
                    if(!String.isBlank(trtwraps.Warranty))
                        opp.Warranty__c = trtwraps.Warranty;  // string
                    if(!String.isBlank(trtwraps.Warranty_Cancelled))
                        opp.Warranty_Cancelled__c = trtwraps.Warranty_Cancelled;  // string
                    if(!String.isBlank(trtwraps.Warranty_End_Date))
                        opp.Warranty_End_Date__c = trtwraps.Warranty_End_Date;  // string
                    if(!String.isBlank(trtwraps.Warranty_End_Kilometre))
                        opp.Warranty_End_Kilometre__c = trtwraps.Warranty_End_Kilometre;  // string
                    if(!String.isBlank(trtwraps.Warranty_Number))
                        opp.Warranty_Number__c = trtwraps.Warranty_Number;  // string
                    if(!String.isBlank(trtwraps.Warranty_Punched_Date))
                        opp.Warranty_Punched_Date__c = trtwraps.Warranty_Punched_Date;  // string
                    if(!String.isBlank(trtwraps.Warranty_Start_Date))
                        opp.Warranty_Start_Date__c = trtwraps.Warranty_Start_Date;  // string
                    if(!String.isBlank(trtwraps.Warranty_Start_Kilometre))
                        opp.Warranty_Start_Kilometre__c = trtwraps.Warranty_Start_Kilometre;  // string
                    if(!String.isBlank(trtwraps.Warranty_Type))
                        opp.Warranty_Type__c = trtwraps.Warranty_Type;  // string
                    if(!String.isBlank(obj.customer_mobile)) {
                         opp.Customer_Phone__c = obj.customer_mobile;  
                    }
                    if(!String.isBlank(trtwraps.sold_stock_type))
                        opp.Sold_Stock_Type__c = trtwraps.sold_stock_type;  // string
                    if(!String.isBlank(trtwraps.sold_make))
                        opp.Sold_Make__c  = trtwraps.sold_make;  // string
                    if(!String.isBlank(trtwraps.sold_model))
                        opp.Sold_Model__c  = trtwraps.sold_model;  // string
                    if(!String.isBlank(trtwraps.sold_variant))
                        opp.Sold_Variant__c  = trtwraps.sold_variant;  // string
                    if(!String.isBlank(trtwraps.sold_mfg_year))
                        opp.Sold_Mfg_Year__c  = trtwraps.sold_mfg_year;  // string
                    if(!String.isBlank(trtwraps.sold_mfg_month))
                        opp.Sold_Mfg_Month__c  = trtwraps.sold_mfg_month;  // string
                    if(!String.isBlank(trtwraps.sold_register_month))
                        opp.Sold_Register_Month__c  = trtwraps.sold_register_month;  // string
                    if(!String.isBlank(trtwraps.sold_register_year))
                        opp.Sold_Register_Year__c  = trtwraps.sold_register_year;  // string
                    if(!String.isBlank(trtwraps.sold_color))
                        opp.Sold_Color__c  = trtwraps.sold_color;  // string
                    if(!String.isBlank(trtwraps.sold_kms))
                        opp.Sold_Kms__c  = trtwraps.sold_kms;  // string
                    if(!String.isBlank(trtwraps.sold_owner))
                        opp.Sold_Owner__c  = trtwraps.sold_owner;  // string
                   
                    if(!String.isBlank(trtwraps.sold_register_no)){
                        opp.Sold_Register_No__c  = trtwraps.sold_register_no;
                    }
                    if(!String.isBlank(trtwraps.testdrive_datetime)){
                        opp.Test_Drive_DateTime__c  = datetime.valueof(trtwraps.testdrive_datetime); 
                        system.debug(' opp.Test_Drive_DateTime__c'+ opp.Test_Drive_DateTime__c);
                    }
                    
                    // 11Jan2023:Sumit:Start :: (CRM - 1013/1014)
                    if(!String.isBlank(obj.is_autofin_lead)){
                        if(obj.is_autofin_lead.containsIgnoreCase('Yes'))
                        opp.Is_Autofin_Lead__c =  true;
                        else if(obj.is_autofin_lead.containsIgnoreCase('No'))  
                        opp.Is_Autofin_Lead__c = false;
                    }
                    //11Jan2023:Sumit:End :: (CRM - 1013/1014)
                    
                    // Girish 14-Dec 2022 start
                    if(!String.isBlank(obj.lead_flag)){
                        opp.Lead_Flag__c = obj.lead_flag;   
                        if((obj.lead_flag).toLowerCase()=='reserve')
                            opp.Reserved__c  = true;
                        if((obj.lead_flag).toLowerCase()=='inspection report')
                            opp.Inspection_Report__c  = true;
                    }
                    // Girish 14-Dec 2022 end
                    
                    if(!String.isBlank(trtwraps.sold_register_city))
                        opp.Sold_Register_City__c = trtwraps.sold_register_city;  // string              
                    system.debug('Adding opp into the list');
                    system.debug('opp.Phone__c'+opp.Phone__c);
                    
                    if(!String.isEmpty(opp.Phone__c)) {
                        if(phoneOppArrMap.containsKey(opp.Phone__c)) {
                            phoneOppArrMap.get(opp.Phone__c).add(opp);
                        } else {
                            phoneOppArrMap.put(opp.Phone__c,new List <Opportunity> {opp});
                        }
                    }                    
                 }
                
            }
        }        
        System.debug('phoneOppArrMap ' + phoneOppArrMap.keySet());
        
        
        // first lead upsert
        List<Database.UpsertResult> leadUpsertResultArr = new List<Database.UpsertResult>();
        if(!phoneLeadMap.isEmpty()) {
            leadUpsertResultArr = Database.upsert(phoneLeadMap.values(), false);
        }
        
        
        // then collect all leadId and fill the  Map (phone => LeadId)
        
        // upsert lead and process result with UpsertResult
        Integer index = 0;
        List<String> phoneArr = new List<String>(phoneLeadMap.keySet());
        List<String> LMSArr = new List<String>(LMSLeadMap.keySet()); //LMS
        List<String> leadLmsArr = new List<String>(phoneLeadMap.keySet());
        system.debug('phoneLeadMap.keySet()'+phoneLeadMap.keySet());
        for(Database.UpsertResult result: leadUpsertResultArr) {
            LeadDetailModel.ResponseLeadobj resLeadWrap = new LeadDetailModel.ResponseLeadobj();
            
            resLeadWrap.status = result.success == TRUE ? 'Success' : 'Failed';
            resLeadWrap.sf_lead_id = result.success == TRUE ? result.Id : null;
            resLeadWrap.customer_mobile = '';
            resLeadWrap.private_lead_id = '';
            // Girish 15-Dec 2022
            if(!LMSArr.isEmpty())
            { 
            resLeadWrap.lms_lead_id = LMSArr[index];
            }
            resLeadWrap.phone = phoneArr[index];
            
            String successMsg = result.isCreated() ? 'Inserted' : 'Updated';
            String dbError = '';
            for(Database.Error err : result.getErrors()) {
                dbError += '[' + err.getMessage() + ']';
            }
            resLeadWrap.message = result.success == TRUE? successMsg + ' successfully!': dbError;
            resLeadWrapList.add(resLeadWrap);
            
            if(result.success == TRUE) {
                phoneLeadIdMap.put(phoneArr[index], result.Id);
            }
            index++;
        }
        system.debug('phoneLeadIdMap'+phoneLeadIdMap);
        // then add leadIds to opp Maps
        List<Opportunity> oppToUpsertArr = new List<Opportunity>();
        for(String customerMobile : phoneOppArrMap.keySet()) {
            String leadId = phoneLeadIdMap.get(customerMobile);
            if(leadId == null)  continue;
            
            for(Opportunity opp : phoneOppArrMap.get(customerMobile)) {
                opp.Lead__c = leadId;
                oppToUpsertArr.add(opp);
                system.debug('oppToUpsertArr'+oppToUpsertArr);
            }
        }
        // then upsert opps
        List<Database.UpsertResult> oppUpsertResultArr = new List<Database.UpsertResult>();
        if(!oppToUpsertArr.isEmpty()) {
            oppUpsertResultArr  = Database.upsert(oppToUpsertArr, false);
        }
        index = 0;
        for(Database.UpsertResult result: oppUpsertResultArr) {
            LeadDetailModel.ResponseDispatchobj resDispaWrap = new LeadDetailModel.ResponseDispatchobj();
            //Girish 15-Dec 2022
            if(!oppLMSArr.isEmpty())
            { 
            resDispaWrap.lms_dispatch_id = oppLMSArr[index];
            }
            resDispaWrap.sf_lead_dispatch_id = result.success == TRUE ?  result.Id : NULL;
            resDispaWrap.status = result.success == TRUE ? 'Success' : 'Failed';
            String successMsg = result.isCreated() ? 'Inserted' : 'Updated';
            String dbError = '';
            for(Database.Error err : result.getErrors()) {
                dbError += '[' + err.getMessage() + ']';
            }
            resDispaWrap.message = result.success == TRUE? successMsg + ' successfully!': dbError;
            resDispatchWrapList.add(resDispaWrap);
            index++;
        }
        
        System.debug('leadToDispatchListMap' + leadToDispatchListMap);
        System.debug('****leadToUpsertList****' + leadToUpsertList);
        System.debug('****leadToUpsertWithPhoneList****' + leadToUpsertWithPhoneList);
        System.debug('targetList' + targetList);
        System.debug('targetWithPhoneList' + targetWithPhoneList);
        System.debug('targetWithPrivateIdList ' + targetWithPrivateIdList);
        System.debug('****leadToUpsertWithPrivateleadIdList****' + leadToUpsertWithPrivateleadIdList);
        System.debug('Leads with Sf Id ' + leadToUpdateWithSFId);
        System.debug('Lead dispatch with Sf Id ' + leaddispToUpdateWithSfId);
        
        
        
       // ********** LMS Callout starts from here. **********
        
        LeadDetailModel.ResponseMessage resWrap = new LeadDetailModel.ResponseMessage();
        
        // 8Feb2022:Asif:Start :: adding whole Process Status Dynamically 
        resWrap.status = !isProcessFailed ? 'Success' : 'Failed';
        // 8Feb2022:Asif:End
        
        resWrap.lead_result = resLeadWrapList;
        resWrap.lead_dispatch_result = resDispatchWrapList;        
        String responseJson = System.JSON.serializePretty(resWrap);
        String requestJson = System.JSON.serializePretty(leadObjectList);
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(responseJson);
    }
    
    //Added by Deepali
    //Purpose: To accept a set of Ids to be used to push data using http callout service
    
    global static void pushLeadsToLms(List<Id> leadIdSet){
        System.debug('__LeadPushToLMS.pushLeadsToLms::');
        System.debug('leadIdSet ' + leadIdSet);
        // 21 April  2023:Sumit:Start :: LeadPushToLMS exception error on production(CRM-1138) 
        if(leadIdSet == null || leadIdSet.isEmpty()) {
            System.debug('leadIdSet is Empty');
            return;
        }
		// 21 April  2023:Sumit:End :: LeadPushToLMS exception error on production(CRM-1138) 
        if(UserInfo.getUserId() == System.label.Callout_Block_User) {  
            System.debug('__blocked Callout for User: ' + System.label.Callout_Block_User);
            //  return;
        }       
        
        List<API_Log__c> apiLogArr = new List<API_Log__c>();
        List<Opportunity> updateOppList = new List<Opportunity>();
        CalloutHelper cHObj = new CalloutHelper();
        List<Lead> updateLeadList = new List<Lead>();
        Map<Id, String> leadIdLMSIdMap = new Map<Id, String>();
        // to Make opp callout together
        List<Id> leadIdForOppCalloutArr = new List<Id>();
        if(String.valueof(leadIdSet[0]).startsWith('00Q')) {
            List<Lead> leadList = [SELECT Id,Name,Status__c,Area_City__c,Td_Client_Id__c,Lead_Title__c,Primary_Make__c , Primary_Model__c ,Area_PinCode__c,Area_State__c,Client_IP__c,Customer_Id__c,Status,Comments__c,
                                   Funding_Amount__c,Is_Otp_Verified__c,WhatsApp_consent__c ,Lead_Category__c,Lead_Flag__c,Lead_Priority__c,Lead_Source_Ref_ID__c,Lead_Stage__c,
                                   Lead_Tags__c,Lead_Type__c,Lost_Reason__c,Marketing_Campaign__c,Marketing_Device__c,Marketing_Medium__c,Marketing_Content__c,
                                   Marketing_Source__c,Email,Phone,LastName,FirstName,CreatedDate,LeadSource,Dealer__r.Name,Customer_Expected_Price__c,
                                   Product__c,Product__r.Stock_ID__c,Product__r.Registration_City__c,Product__r.Registration_Number__c,Product__r.Kilometer__c,
                                   Product__r.Color__c,Product__r.Model_Year__c,Product__r.Model_Month__c,Product__r.Variant__c, Product__r.Model__c,Product__r.Make__c,
                                   Product__r.Body_Type__c FROM Lead WHERE Id IN :leadIdSet];
            
            String apiLogTag = 'BUC LMS Lead Callout';
            String accessTokenEndpoint, insertLeadEndpoint, updateLeadEndpoint;
            String responseString;
            Map<String,LeadDetailModel.LeadWrapper> sfIdWithJson = new Map<String,LeadDetailModel.LeadWrapper>();
            try {
                
                // create JSON body
                List<LeadDetailModel.LeadWrapper> leadWrapperList = new List<LeadDetailModel.LeadWrapper>();
                Map<String,String> leadIdCustomerIDMap = new Map<String, String> (); 
                if(!leadList.isEmpty()){
                    for(Lead lea : leadList){ 
                        leadIdCustomerIDMap.put(lea.id, lea.Customer_Id__c); // external Id  
                        leadIdLMSIdMap.put(lea.id, lea.Customer_Id__c);
                        List<LeadDetailModel.Target> targetList = new List<LeadDetailModel.Target>();
                        LeadDetailModel.LeadWrapper leadwrap = new LeadDetailModel.LeadWrapper();
                        leadwrap.sfdc_lead_id = lea.Id;
                        leadwrap.area_city = lea.Area_City__c;
                        leadwrap.area_pincode = lea.Area_PinCode__c;
                        leadwrap.area_state = lea.Area_State__c;
                        leadwrap.client_ip = '';
                        // leadwrap.color = lea.Product__r.Color__c;
                        leadwrap.comments = lea.Comments__c;
                        leadwrap.customer_email = lea.Email;
                        if(lea.Phone != null){
                            leadwrap.customer_mobile = (lea.Phone).right(10);
                        }                    
                        leadwrap.customer_name = lea.Name;
                        leadwrap.funding_amount = String.valueOf(lea.Funding_Amount__c);
                        leadwrap.is_otp_verfied = lea.Is_Otp_Verified__c;
                        leadwrap.whatsapp_consent = lea.WhatsApp_consent__c;
                        // leadwrap.kms = String.valueOf(lea.Product__r.Kilometer__c);
                        leadwrap.lead_category = lea.Lead_Category__c;
                        leadwrap.lead_flag = lea.Lead_Flag__c;
                        leadwrap.lms_lead_id = lea.Customer_Id__c; // external Id 
                        if(lea.Td_Client_Id__c != NULL) {
                            leadwrap.td_client_id = lea.Td_Client_Id__c;
                        }
                        leadwrap.lead_source = lea.LeadSource != null ? lea.LeadSource : 'MFC-CRM';
                        leadwrap.lead_tags = lea.Lead_Tags__c;
                        leadwrap.lead_title = lea.Lead_Title__c;
                        leadwrap.lead_type = lea.Lead_Type__c;
                        leadwrap.leadsource_dealer_id = lea.Lead_Source_Ref_ID__c;
                        //leadwrap.LMS_leadid = lea.Customer_Id__c;
                        leadwrap.marketing_campaign = lea.Marketing_Campaign__c;
                        leadwrap.marketing_content = lea.Marketing_Content__c;
                        leadwrap.marketing_device = lea.Marketing_Device__c;
                        leadwrap.marketing_medium = lea.Marketing_Medium__c;
                        leadwrap.marketing_source = lea.Marketing_Source__c;
                        leadwrap.lead_priority = lea.Lead_Priority__c; 
                        leadwrap.lead_stage = lea.Lead_Stage__c;
                        leadwrap.lead_status = lea.Status__c;
                        leadwrap.customer_expected_price = String.valueOf(lea.Customer_Expected_Price__c);
                        leadwrap.customer_address = '';
                        leadwrap.created_date = '';
                        leadwrap.lms_lead_id = lea.Customer_Id__c; // external Id 
                        for(Opportunity  Opp : lea.Opportunities__r){
                            LeadDetailModel.Target trtwrap = new LeadDetailModel.Target();
                            trtwrap.stock_id = Opp.Product__r.Stock_ID__c;
                            trtwrap.employee_id = Opp.Employee_Id__c;
                            trtwrap.employee_name = Opp.Employee_Name__c;
                            trtwrap.employee_type = Opp.Employee_Type__c;
                            trtwrap.followup_comments = Opp.Followup_Comments__c;
                            trtwrap.followup_date = Opp.Followup_Date__c;
                            trtwrap.lms_dispatch_id = Opp.Lms_Dispatch_Id__c;
                            trtwrap.sfdc_lead_dispatch_id = Opp.Id;
                            trtwrap.status = Opp.status__c;
                            trtwrap.status_updated_by = Opp.Status_Updated_By__c;
                            trtwrap.target_id = Opp.Dealer__r.Code__c;
                            trtwrap.target_name = Opp.Dealer__r.Name;
                            trtwrap.target_source = 'MFC';
                            targetList.add(trtwrap);                    
                        }
                        leadwrap.target = targetList;
                        leadWrapperList.add(leadwrap);  
                        sfIdWithJson.put(lea.id, leadwrap);
                    }
                }
                
                // getting endpoints 
                List<LeadPushAPI__c> endpointList = LeadPushAPI__c.getAll().values();
                if(!endpointList.isEmpty()){
                    for(LeadPushAPI__c endpnt : endpointList){
                        if(endpnt.Name =='Get Token'){
                            accessTokenEndpoint = endpnt.Endpoint__c;
                        } else if(endpnt.Name =='Lead Create'){
                            insertLeadEndpoint = endpnt.Endpoint__c;
                        } else if(endpnt.Name =='Lead Update'){
                            updateLeadEndpoint = endpnt.Endpoint__c;
                        }
                    }
                }
                
                // getting Access Token
                String accessToken;
                String jsonToGetAccessToken = '{"username":"crmsfdc@lms.com","password":"p@ssword","tag":"android"}';
                System.debug('__making Auth Call');
                
                HttpResponse authResponse = cHObj.sendAsPOST(accessTokenEndpoint, jsonToGetAccessToken, null);
                System.debug('Response: ' + authResponse);
                if(authResponse.getStatusCode() == 200) {
                    String resStr = authResponse.getBody();
                    System.debug('resStr: ' + resStr);
                    Map<String,Object> authResponseObj = (Map<String,Object>)JSON.deserializeUntyped(resStr);
                    if(authResponseObj.get('status_code') == 200){
                        accessToken = (String)authResponseObj.get('access_token');
                    } 
                    System.debug('accessToken: ' + accessToken);
                } else {
                    responseString = authResponse.getBody();
                    throw new CalloutException('AUTH_ENDPOINT_ERROR');
                }
                
                // wrapper JSON
                LeadDetailModel.MainWrapperClass mainWrapper = new LeadDetailModel.MainWrapperClass();
                mainWrapper.data = leadWrapperList;
                mainWrapper.access_token = accessToken;
                mainWrapper.tag = 'MFC-CRM';
                String JsonLeadStr = System.JSON.serialize(mainWrapper).replace('null','\"\"');
                System.debug('JsonLeadStr: ' + JsonLeadStr);
                
                // Insert API CallOut
                // Added By Aravindan A
                System.debug('__making insert Call');
                HttpResponse leadRes = cHObj.sendAsPOST(insertLeadEndpoint, JsonLeadStr, null);
                System.debug('Response: ' + leadRes);
                
                // handling Response
                Map<String,Object> responseObj = new Map<String,Object>();
                if(leadRes.getStatusCode() == 200) {
                    responseObj = (Map<String,Object>)JSON.deserializeUntyped(leadRes.getBody());
                    System.debug('responseObj: ' + responseObj);
                } else {
                    responseString = leadRes.getBody();
                    throw new CalloutException('INSERT_ENDPOINT_ERROR');
                }
                String jsonSuccess = JSON.serialize(responseObj.get('success'));
                String jsonError = JSON.serialize(responseObj.get('error'));
                System.debug('jsonError: ' + jsonError);
                System.debug('jsonSuccess: ' + jsonSuccess);
                Map<String,LeadDetailModel.ResponseWrapperClass> sfIdWithResponse = new Map<String,LeadDetailModel.ResponseWrapperClass>(); 
                
                // Success
                if(jsonSuccess != null) {
                    List<LeadDetailModel.ResponseWrapperClass> successResponseList = (List<LeadDetailModel.ResponseWrapperClass>)JSON.deserialize(jsonSuccess, List<LeadDetailModel.ResponseWrapperClass>.class);
                    System.debug('successResponseList: ' + successResponseList);
                    Map<String,String> sfIdWithCustomerId = new Map<String,String>();
                    Map<String,String> sfDispactchIdWithDispatchId = new Map<String,String>();
                    if(successResponseList != null)  {
                        for(LeadDetailModel.ResponseWrapperClass resObj : successResponseList){
                            system.debug('resObj'+resObj);
                            sfIdWithResponse.put(resObj.sfdc_lead_id, resObj);
                            sfIdWithCustomerId.put(resObj.sfdc_lead_id, resObj.id);
                            system.debug('sfIdWithCustomerId'+sfIdWithCustomerId);
                            if(resObj.sfdc_lead_dispatch_id != null && !String.isBlank(resObj.sfdc_lead_dispatch_id)) {
                                sfDispactchIdWithDispatchId.put(resObj.sfdc_lead_dispatch_id, resObj.leadsDispatch_id);
                            }
                        }
                    }
                    
                    System.debug('sfIdWithCustomerId');
                    if(!sfIdWithCustomerId.isEmpty()) {
                        for(String key : sfIdWithCustomerId.keySet()) {
                            System.debug('responseKey ' + key);
                            lead l = new lead();
                            l.Id = key;
                            l.Customer_Id__c = sfIdWithCustomerId.get(key); // external Id
                            if(leadIdCustomerIDMap.containsKey(key) && leadIdCustomerIDMap.get(key) == null){ 
                                updateLeadList.add(l);
                                leadIdLMSIdMap.put(l.Id, l.Customer_Id__c);
                                leadIdForOppCalloutArr.add(key); // leads that are making callout on insert only
                            }
                            apiLogArr.add(LogService.createApiLogs(insertLeadEndpoint, JSON.serialize(sfIdWithJson.get(key)), JSON.serialize(sfIdWithResponse.get(key)), sfIdWithResponse.get(key).status_code, apiLogTag, key,false));
                        }
                    }
                }
                
                // failure
                if(jsonError != null) {
                    List<LeadDetailModel.ResponseWrapperClass> failureResponseList = (List<LeadDetailModel.ResponseWrapperClass>)JSON.deserialize(jsonError, List<LeadDetailModel.ResponseWrapperClass>.class);
                    System.debug('failureResponseList: ' + failureResponseList);
                    Map<String,String> FailureMap = new Map<String,String>();
                    if(failureResponseList != null) {
                        for(LeadDetailModel.ResponseWrapperClass resObj : failureResponseList){
                            sfIdWithResponse.put(resObj.sfdc_lead_id, resObj);
                            FailureMap.put(resObj.sfdc_lead_id, resObj.message);  
                        }
                    }
                    if(!FailureMap.isEmpty()){
                        Map<String, Id> queueMap = new Map<String, Id>();
                        for(Group grp : [Select Id,Name,type from Group where type = 'queue']){
                            queueMap.put(grp.Name, grp.Id);
                        }
                        for(String key2 : FailureMap.keySet()) {
                            lead l = new lead();
                            l.id = key2;
                            System.debug('responseKey2 ' + key2);
                            l.Upload_Message__c = FailureMap.get(key2);
                            if(FailureMap.get(key2).contains('Duplicate')){
                                
                                l.OwnerId = queueMap.get('BUC_Duplicate');
                                l.IsDuplicate__c = true; 
                                l.Status__c = 'Duplicate';
                            }
                            updateLeadList.add(l);
                            apiLogArr.add(LogService.createApiLogs(insertLeadEndpoint, JSON.serialize(sfIdWithJson.get(key2)), JSON.serialize(sfIdWithResponse.get(key2)), sfIdWithResponse.get(key2).status_code, apiLogTag, key2,false));
                        }
                    }
                }
                
            } catch(Exception e) {
                System.debug('EXCEPTION_CAUGHT: ' + e);
                String exMsg = e.getMessage();
                String exceptionStr;
                String endPoint;
                if(exMsg == 'AUTH_ENDPOINT_ERROR') {
                    endPoint = accessTokenEndpoint;
                } else if(exMsg == 'INSERT_ENDPOINT_ERROR') {
                    endPoint = insertLeadEndpoint;
                } else {
                    exceptionStr = 'Exception: Type: ' + e.getTypeName() + ', Message: ' +  e.getMessage() + ' at Line: ' + e.getLineNumber();  
                    responseString = exceptionStr;
                    exMsg = 'Failed';
                }
                String reqBody;
                for(Id leadId : leadIdSet) {
                    reqBody = JSON.serialize(sfIdWithJson.get(leadId));
                    apiLogArr.add(LogService.createApiLogs(endPoint, reqBody, responseString, exMsg, apiLogTag, leadId, false));
                }
            } 
        }
        
        // making Opp Callout if Opp is getting inserted with lead as well
        // new Lead record that has no customer Id, but going to have customerId from above callout, 
        // emphasizes to insert callout and insert callout should have opp callout as well.
        Boolean isInsertCallout = false;
        if(!leadIdForOppCalloutArr.isEmpty()) { 
            List<Opportunity> newOppArr = [SELECT Id FROM Opportunity WHERE Lead__c IN :leadIdForOppCalloutArr AND LMS_Opp_Id__c = null AND Lead__r.Customer_Id__c = null];
            if(!newOppArr.isEmpty()) {
                System.debug('newOppArr ' + newOppArr);
                leadIdSet.clear();
                isInsertCallout = true;
                for(Opportunity opp : newOppArr) {
                    leadIdSet.add(opp.Id);
                } 
            }
        }
        System.debug('__leadIdSet ' + leadIdSet);
        
        if(String.valueof(leadIdSet[0]).startsWith('006')) {
            String queryPartial = ' AND lead__r.Customer_Id__c != null';
            if(isInsertCallout) {
                queryPartial = '';
            }
            List<Opportunity> oppList = Database.query('SELECT Id,Name,Employee_Id__c,Area_City__c,Employee_Name__c,Employee_Type__c,Ext_warranty_amount__c,Ext_warranty_cancelled__c,lead__r.Id,'
                                                       +'Product__r.Variant__c, Product__r.Make__c, Product__r.Model__c,Lead_Flag__c,Reservation_Status__c,'
                                                        + 'Ext_warranty_end_date__c,Ext_warranty_end_kilometre__c,Ext_warranty_number__c,Ext_warranty_punched__c,Ext_warranty_recommended__c,Stock_ID__c,'
                                                       + 'Ext_warranty_sold_date__c,Ext_warranty_start_date__c,Ext_warranty_start_kilometre__c,Followup_Comments__c,Followup_Date__c,Lms_Dispatch_Id__c,'
                                                       + 'Warrant_Amount__c,Warranty__c,Warranty_Cancelled__c,Warranty_End_Date__c,Warranty_End_Kilometre__c,Warranty_Number__c,Warranty_Punched_Date__c,'
                                                       + 'Warranty_Start_Date__c,Warranty_Start_Kilometre__c,status__c,Status_Updated_By__c,Warranty_Type__c, Area_PinCode__c,Area_State__c,lead__r.Product__r.Color__c,'
                                                       + 'lead__r.Comments__c,lead__r.Email,lead__r.Phone,lead__r.Name,lead__r.Funding_Amount__c,lead__r.Is_Otp_Verified__c,'
                                                       + 'lead__r.WhatsApp_consent__c,lead__r.Product__r.Kilometer__c,lead__r.Lead_Category__c,lead__r.Lead_Flag__c,lead__r.Customer_Id__c,lead__r.Td_Client_Id__c'
                                                       + ',lead__r.LeadSource,lead__r.Area_State__c, lead__r.Lead_Tags__c,lead__r.Lead_Title__c,lead__r.Lead_Source_Ref_ID__c,lead__r.Marketing_Campaign__c,lead__r.Marketing_Content__c'
                                                       + ',lead__r.Marketing_Device__c,lead__r.Marketing_Medium__c,lead__r.Marketing_Source__c,lead__r.Product__r.Model_Month__c,lead__r.Product__r.Model_Year__c'
                                                       + ',lead__r.Product__r.Make__c,lead__r.Product__r.Model__c,lead__r.Product__r.Variant__c,lead__r.Product__r.Registration_City__c,lead__r.Product__r.Registration_Number__c,'                       
                                                       + 'lead__r.Product__r.Stock_ID__c,lead__r.Product__r.Body_Type__c,lead__r.Primary_Make__c,lead__r.Primary_Model__c,lead__r.Lead_Priority__c,lead__r.Lead_Stage__c,'
                                                       + 'lead__r.Status__c,lead__r.Customer_Expected_Price__c,Dealer__r.Code__c,Dealer__r.Name,LMS_Opp_Id__c,lead__r.Lead_Type__c,Product__r.Stock_ID__c FROM Opportunity WHERE Id IN :leadIdSet' + queryPartial);
            
            System.debug('oppList ' + oppList);
            if(!oppList.isEmpty()) {
                String apiLogTag = 'BUC LMS Opp Callout';
                String accessTokenEndpoint, insertLeadEndpoint, updateLeadEndpoint;
                String responseString;
                Map<String,LeadDetailModel.LeadWrapper> sfIdWithJson = new Map<String,LeadDetailModel.LeadWrapper>();
                try {
                    
                    // create JSON body
                    List<LeadDetailModel.LeadWrapper> leadWrapperList = new List<LeadDetailModel.LeadWrapper>();
                    Map<String,String> leadIdCustomerIDMap = new Map<String, String> ();
                    
                    for(Opportunity opp : oppList){ 
                        leadIdCustomerIDMap.put(opp.lead__r.Id, opp.lead__r.Customer_Id__c);
                        List<LeadDetailModel.Target> targetList = new List<LeadDetailModel.Target>();
                        LeadDetailModel.LeadWrapper leadwrap = new LeadDetailModel.LeadWrapper();
                        leadwrap.sfdc_lead_id = opp.lead__r.Id;
                        leadwrap.area_city = opp.Area_City__c;
                        leadwrap.area_pincode = opp.Area_PinCode__c;
                        leadwrap.area_state = opp.lead__r.Area_State__c;
                        leadwrap.client_ip = '';  
                        leadwrap.comments = opp.lead__r.Comments__c;
                        leadwrap.customer_email = opp.lead__r.Email;
                        if(opp.lead__r.Phone != null){
                            leadwrap.customer_mobile = (opp.lead__r.Phone).right(10);
                        }                    
                        leadwrap.customer_name = opp.lead__r.Name;
                        leadwrap.funding_amount = String.valueOf(opp.lead__r.Funding_Amount__c);
                        leadwrap.is_otp_verfied = opp.lead__r.Is_Otp_Verified__c;
                        leadwrap.whatsapp_consent = opp.lead__r.WhatsApp_consent__c;
                        leadwrap.lead_category = opp.lead__r.Lead_Category__c;
                        leadwrap.lead_flag = opp.lead__r.Lead_Flag__c;
                        leadwrap.lms_lead_id = opp.lead__r.Customer_Id__c; // external Id 
                        if(opp.lead__r.Td_Client_Id__c != NULL) {
                            leadwrap.td_client_id = opp.lead__r.Td_Client_Id__c;
                        }
                        leadwrap.lead_source =  opp.lead__r.LeadSource != null ? opp.lead__r.LeadSource :  'MFC-CRM';                      
                        leadwrap.lead_tags = opp.lead__r.Lead_Tags__c;
                        leadwrap.lead_title = opp.lead__r.Lead_Title__c;
                        leadwrap.lead_type = opp.lead__r.Lead_Type__c;
                        leadwrap.leadsource_dealer_id = opp.lead__r.Lead_Source_Ref_ID__c;
                        leadwrap.marketing_campaign = opp.lead__r.Marketing_Campaign__c;
                        leadwrap.marketing_content = opp.lead__r.Marketing_Content__c;
                        leadwrap.marketing_device = opp.lead__r.Marketing_Device__c;
                        leadwrap.marketing_medium = opp.lead__r.Marketing_Medium__c;
                        leadwrap.marketing_source = opp.lead__r.Marketing_Source__c;
                        if(opp.lead__r.Product__c == null){
                            leadwrap.primary_make = opp.lead__r.Primary_Make__c;
                            leadwrap.primary_model = opp.lead__r.Primary_Model__c;
                        }
                        leadwrap.stock_listed_price = '';
                        leadwrap.owner = '';
                        leadwrap.register_year = '';
                        leadwrap.register_month = '';
                        leadwrap.secondary_variant = '';
                        leadwrap.secondary_model = '';
                        leadwrap.secondary_make = '';
                        leadwrap.secondary_variant = '';
                        leadwrap.lead_priority = opp.lead__r.Lead_Priority__c; 
                        leadwrap.lead_stage = opp.lead__r.Lead_Stage__c;
                        leadwrap.lead_status = opp.lead__r.Status__c;
                        leadwrap.customer_expected_price = String.valueOf(opp.lead__r.Customer_Expected_Price__c);
                        leadwrap.customer_address = '';
                        leadwrap.created_date = '';
                        leadwrap.lms_lead_id = opp.lead__r.Customer_Id__c; // external Id 
                        if(String.isEmpty(leadwrap.lms_lead_id)) {
                            leadwrap.lms_lead_id = leadIdLMSIdMap.get(opp.lead__c);
                        }
                        for(Opportunity  OppT : oppList){
                            LeadDetailModel.Target trtwrap = new LeadDetailModel.Target();
                            trtwrap.employee_id = OppT.Employee_Id__c;
                            trtwrap.employee_name = OppT.Employee_Name__c;
                            trtwrap.employee_type = OppT.Employee_Type__c;
                            trtwrap.followup_comments = OppT.Followup_Comments__c;
                            trtwrap.followup_date = OppT.Followup_Date__c;
                            trtwrap.lms_dispatch_id = OppT.LMS_Opp_Id__c;
                            trtwrap.sfdc_lead_dispatch_id = OppT.Id;
                            trtwrap.status = OppT.status__c;
                            trtwrap.status_updated_by = OppT.status__c;
                            trtwrap.target_id = OppT.Dealer__r.Code__c;
                            trtwrap.target_name = OppT.Dealer__r.Name;
                            trtwrap.target_source = 'MFC';
                            system.debug('test reservation status :- '+String.valueOf(OppT.Reservation_Status__c));
                            
                            if(OppT.status__c == 'Cancelled'){
                                trtwrap.reservation_status = 'false';   // CRM-1207
                            }else{
                                trtwrap.reservation_status = String.valueOf(OppT.Reservation_Status__c);   // CRM-1207
                            } 
                            
                            // Girish 14-Dec 2022 start
                            trtwrap.stock_id=OppT.Product__r.Stock_ID__c;
                            leadwrap.primary_make = OppT.Product__r.Make__c;
                            leadwrap.primary_model = OppT.Product__r.Model__c;
                            leadwrap.primary_variant = OppT.Product__r.Variant__c;
                            leadwrap.stock_id = OppT.Product__r.Stock_ID__c;
                            leadwrap.lead_flag = OppT.Lead_Flag__c;

                            //Girish 14-Dec 2022 end
                            targetList.add(trtwrap);  
                        }
                        leadwrap.target = targetList;
                        leadWrapperList.add(leadwrap);  
                        sfIdWithJson.put(opp.Id, leadwrap);
                    }
                    
                    // getting endpoints 
                    List<LeadPushAPI__c> endpointList = LeadPushAPI__c.getAll().values();
                    if(!endpointList.isEmpty()){
                        for(LeadPushAPI__c endpnt : endpointList){
                            if(endpnt.Name =='Get Token'){
                                accessTokenEndpoint = endpnt.Endpoint__c;
                            } else if(endpnt.Name =='Lead Create'){
                                insertLeadEndpoint = endpnt.Endpoint__c;
                            }else if(endpnt.Name =='Lead Update'){
                                updateLeadEndpoint = endpnt.Endpoint__c;
                            }
                        }
                    }
                    
                    // getting Access Token
                    String accessToken;
                    String jsonToGetAccessToken = '{"username":"crmsfdc@lms.com","password":"p@ssword","tag":"android"}';
                    System.debug('__making Auth Call');
                     
                    HttpResponse authResponse = cHObj.sendAsPOST(accessTokenEndpoint, jsonToGetAccessToken, null);
                    System.debug('Response: ' + authResponse);
                    if(authResponse.getStatusCode() == 200) {
                        String resStr = authResponse.getBody();
                        System.debug('resStr: ' + resStr);
                        Map<String,Object> authResponseObj = (Map<String,Object>)JSON.deserializeUntyped(resStr);
                        if(authResponseObj.get('status_code') == 200){
                            accessToken = (String)authResponseObj.get('access_token');
                        } 
                        System.debug('accessToken: ' + accessToken);
                    } else {
                        responseString = authResponse.getBody();
                        throw new CalloutException('AUTH_ENDPOINT_ERROR');
                    }
                    
                    // wrapper JSON
                    LeadDetailModel.MainWrapperClass mainWrapper = new LeadDetailModel.MainWrapperClass();
                    mainWrapper.data = leadWrapperList;
                    mainWrapper.access_token = accessToken;
                    mainWrapper.tag = 'MFC-CRM';
                    String JsonLeadStr = System.JSON.serialize(mainWrapper).replace('null','\"\"');
                    System.debug('JsonLeadStr: ' + JsonLeadStr);
                    
                    // Insert API CallOut
                    System.debug('__making insert Call');
                    
                    HttpResponse leadRes = cHObj.sendAsPOST(insertLeadEndpoint, JsonLeadStr, null);
                    System.debug('Response: ' + leadRes);
                    
                    // handling Response
                    Map<String,Object> responseObj = new Map<String,Object>();
                    if(leadRes.getStatusCode() == 200) {
                        responseObj = (Map<String,Object>)JSON.deserializeUntyped(leadRes.getBody());
                        System.debug('responseObj: ' + responseObj);
                    } else {
                        responseString = leadRes.getBody();
                        throw new CalloutException('INSERT_ENDPOINT_ERROR');
                    }
                    String jsonSuccess = JSON.serialize(responseObj.get('success'));
                    String jsonError = JSON.serialize(responseObj.get('error'));
                    System.debug('jsonError: ' + jsonError);
                    System.debug('jsonSuccess: ' + jsonSuccess);
                    Map<String,LeadDetailModel.ResponseWrapperClass> sfIdWithResponse = new Map<String,LeadDetailModel.ResponseWrapperClass>(); 
                    
                    // Success
                    if(jsonSuccess != null) {
                        List<LeadDetailModel.ResponseWrapperClass> successResponseList = (List<LeadDetailModel.ResponseWrapperClass>)JSON.deserialize(jsonSuccess, List<LeadDetailModel.ResponseWrapperClass>.class);
                        System.debug('successResponseList: ' + successResponseList);
                        Map<String,String> sfIdWithCustomerId = new Map<String,String>();
                        Map<String,String> sfDispactchIdWithDispatchId = new Map<String,String>();
                        if(successResponseList != null)  {
                            for(LeadDetailModel.ResponseWrapperClass resObj : successResponseList){
                                system.debug('resObj'+resObj);
                                sfIdWithResponse.put(resObj.sfdc_lead_dispatch_id, resObj);
                                system.debug('sfIdWithResponse'+sfIdWithResponse);
                                sfIdWithCustomerId.put(resObj.sfdc_lead_dispatch_id, resObj.leadsDispatch_id);
                                system.debug('sfIdWithCustomerId'+sfIdWithCustomerId);
                                if(resObj.sfdc_lead_dispatch_id != null && !String.isBlank(resObj.sfdc_lead_dispatch_id)) {
                                    sfDispactchIdWithDispatchId.put(resObj.sfdc_lead_dispatch_id, resObj.leadsDispatch_id);
                                }
                            }
                        }
                        if(!sfIdWithCustomerId.isEmpty()) {
                            for(String key : sfIdWithCustomerId.keySet()) {
                                System.debug('responseKey ' + key);
                                Opportunity l = new Opportunity();
                                l.Id = key;
                                l.LMS_Opp_Id__c = sfIdWithCustomerId.get(key); // external Id 
                                if(leadIdCustomerIDMap.containsKey(key) && leadIdCustomerIDMap.get(key) == null){ // 10 Augast  2022:Ankit:Start :: Leads hitting Elision on updating followup lead(CRM-962) 
                                    updateOppList.add(l);
                                }
                                apiLogArr.add(LogService.createApiLogs(insertLeadEndpoint, JSON.serialize(sfIdWithJson.get(key)), JSON.serialize(sfIdWithResponse.get(key)), sfIdWithResponse.get(key).status_code, apiLogTag, key,false));
                            }
                            System.debug('apiLogArr ' + apiLogArr);
                        }
                        system.debug('sfDispactchIdWithDispatchId');
                        if(!sfDispactchIdWithDispatchId.isEmpty()){
                            for(String key1 : sfDispactchIdWithDispatchId.keySet()){
                                Opportunity OD = new Opportunity();
                                OD.Id = key1;
                                OD.LMS_Opp_Id__c = sfDispactchIdWithDispatchId.get(key1);
                                updateOppList.add(OD);
                            }
                        }
                    }
                    
                    // failure
                    if(jsonError != null) {
                        List<LeadDetailModel.ResponseWrapperClass> failureResponseList = (List<LeadDetailModel.ResponseWrapperClass>)JSON.deserialize(jsonError, List<LeadDetailModel.ResponseWrapperClass>.class);
                        System.debug('failureResponseList: ' + failureResponseList);
                        Map<String,String> FailureMap = new Map<String,String>();
                        if(failureResponseList != null) {
                            for(LeadDetailModel.ResponseWrapperClass resObj : failureResponseList){
                                sfIdWithResponse.put(resObj.sfdc_lead_dispatch_id, resObj);
                                FailureMap.put(resObj.sfdc_lead_dispatch_id, resObj.message);  
                            }
                        }
                        if(!FailureMap.isEmpty()){
                            Map<String, Id> queueMap = new Map<String, Id>();
                            for(Group grp : [Select Id,Name,type from Group where type = 'queue']){
                                queueMap.put(grp.Name, grp.Id);
                            }
                            for(String key2 : FailureMap.keySet()) {
                                System.debug('responseKey2 ' + key2);
                                Opportunity l = new Opportunity();
                                l.Id = key2;
                                l.Message__c = FailureMap.get(key2);
                                updateOppList.add(l);
                                apiLogArr.add(LogService.createApiLogs(insertLeadEndpoint, JSON.serialize(sfIdWithJson.get(key2)), JSON.serialize(sfIdWithResponse.get(key2)), sfIdWithResponse.get(key2).status_code, apiLogTag, key2,false));
                            }
                        }
                    }
                } catch(Exception e) {
                    System.debug('EXCEPTION_CAUGHT: ' + e + ' line ' + e.getLineNumber());
                    String exMsg = e.getMessage();
                    String exceptionStr;
                    String endPoint;
                    if(exMsg == 'AUTH_ENDPOINT_ERROR') {
                        endPoint = accessTokenEndpoint;
                    } else if(exMsg == 'INSERT_ENDPOINT_ERROR') {
                        endPoint = insertLeadEndpoint;
                    } else {
                        exceptionStr = 'Exception: Type: ' + e.getTypeName() + ', Message: ' +  e.getMessage() + ' at Line: ' + e.getLineNumber();  
                        responseString = exceptionStr;
                        exMsg = 'Failed';
                    }
                    String reqBody;
                    for(Id leadId : leadIdSet) {
                        reqBody = JSON.serialize(sfIdWithJson.get(leadId));
                        apiLogArr.add(LogService.createApiLogs(endPoint, reqBody, responseString, exMsg, apiLogTag, leadId, false));
                    }
                } 
            }
        }
        
        System.debug('__updateLeadList ' + updateLeadList);
        if(!updateLeadList.isEmpty()){
            Database.update(updateLeadList, false);
        }
        
        System.debug('__updateOppList ' + updateOppList);
        if(!updateOppList.isEmpty() && !Test.isRunningTest()){
            Database.update(updateOppList, false);
        }
        
        System.debug('__apiLogArr ' + apiLogArr);
        LogService.createApiLogs(apiLogArr);
    }
    
   // @InvocableMethod(label='Invoking Opp Push')
  /*  global static void pushOpportunityToLms(List<Id> leadIdSet){
        System.debug('LeadPushToLMS.pushLeadsToLms::');
        System.debug('leadIdSet ' + leadIdSet);
        
        if(UserInfo.getUserId() == System.label.Callout_Block_User) {  
            System.debug('__blocked Callout for User: ' + System.label.Callout_Block_User);
            //  return; //sumit
        }       
        
        
        //  String leadLmsId;
        List<API_Log__c> apiLogCaptureList = new List<API_Log__c>();
        List<Opportunity> updateoppList = new List<Opportunity>();
        List<Lead> updateLeadList = new List<Lead>();
        List<API_Log__c> errorLogs = new List<API_Log__c>();
        if(string.valueof(leadIdSet[0]).startsWith('006')) {
            //leadLmsId = string.valueof(leadIdSet);
            system.debug('Opportunity Id :-'+leadIdSet);
            List<Opportunity> oppList = [SELECT Id,Name,Employee_Id__c,Area_City__c,Employee_Name__c,Employee_Type__c,Ext_warranty_amount__c,Ext_warranty_cancelled__c,lead__r.Id,
                                            Product__r.Variant__c, Product__r.Make__c, Product__r.Model__c,Lead_Flag__c,
                                         Ext_warranty_end_date__c,Ext_warranty_end_kilometre__c,Ext_warranty_number__c,Ext_warranty_punched__c,Ext_warranty_recommended__c,Stock_ID__c,
                                         Ext_warranty_sold_date__c,Ext_warranty_start_date__c,Ext_warranty_start_kilometre__c,Followup_Comments__c,Followup_Date__c,Lms_Dispatch_Id__c,
                                         Warrant_Amount__c,Warranty__c,Warranty_Cancelled__c,Warranty_End_Date__c,Warranty_End_Kilometre__c,Warranty_Number__c,Warranty_Punched_Date__c,
                                         Warranty_Start_Date__c,Warranty_Start_Kilometre__c,status__c,Status_Updated_By__c,Warranty_Type__c, Area_PinCode__c,Area_State__c,lead__r.Product__r.Color__c,lead__r.Comments__c,lead__r.Email,lead__r.Phone,lead__r.Name,lead__r.Funding_Amount__c,lead__r.Is_Otp_Verified__c,
                                         lead__r.WhatsApp_consent__c,lead__r.Product__r.Kilometer__c,lead__r.Lead_Category__c,lead__r.Lead_Flag__c,lead__r.Customer_Id__c,lead__r.Td_Client_Id__c  
                                         ,lead__r.LeadSource,lead__r.Area_State__c, lead__r.Lead_Tags__c,lead__r.Lead_Title__c,lead__r.Lead_Source_Ref_ID__c,lead__r.Marketing_Campaign__c,lead__r.Marketing_Content__c
                                         ,lead__r.Marketing_Device__c,lead__r.Marketing_Medium__c,lead__r.Marketing_Source__c,lead__r.Product__r.Model_Month__c,lead__r.Product__r.Model_Year__c
                                         ,lead__r.Product__r.Make__c,lead__r.Product__r.Model__c,lead__r.Product__r.Variant__c,lead__r.Product__r.Registration_City__c,lead__r.Product__r.Registration_Number__c,                       
                                         lead__r.Product__r.Stock_ID__c,lead__r.Product__r.Body_Type__c,lead__r.Primary_Make__c,lead__r.Primary_Model__c,lead__r.Lead_Priority__c,lead__r.Lead_Stage__c,
                                         lead__r.Status__c,lead__r.Customer_Expected_Price__c,Dealer__r.Code__c,Dealer__r.Name,LMS_Opp_Id__c,lead__r.Lead_Type__c FROM Opportunity WHERE Id IN :leadIdSet and lead__r.Customer_Id__c != null ];
            
            if(oppList.size() == 0){
                return;        
            }
            String apiLogTag = 'BUC LMS Opp Callout';
            String accessTokenEndpoint, insertLeadEndpoint, updateLeadEndpoint;
            String responseString;
            Map<String,LeadDetailModel.LeadWrapper> sfIdWithJson = new Map<String,LeadDetailModel.LeadWrapper>();
            try {
                
                // create JSON body
                List<LeadDetailModel.LeadWrapper> leadWrapperList = new List<LeadDetailModel.LeadWrapper>();
                Map<String,String> leadIdCustomerIDMap = new Map<String, String> (); // 10 Augast  2022:Ankit:Start :: Leads hitting Elision on updating followup lead(CRM-962)
                if(!oppList.isEmpty()){
                    system.debug('oppList'+oppList);
                    for(Opportunity opp : oppList){ 
                        
                        leadIdCustomerIDMap.put(opp.lead__r.Id, opp.lead__r.Customer_Id__c);// external Id  // 10 Augast  2022:Ankit:Start :: Leads hitting Elision on updating followup lead(CRM-962) 
                        
                        List<LeadDetailModel.Target> targetList = new List<LeadDetailModel.Target>();
                        LeadDetailModel.LeadWrapper leadwrap = new LeadDetailModel.LeadWrapper();
                        leadwrap.sfdc_lead_id = opp.lead__r.Id;
                        leadwrap.area_city = opp.Area_City__c;
                        leadwrap.area_pincode = opp.Area_PinCode__c;
                        leadwrap.area_state = opp.lead__r.Area_State__c;
                        leadwrap.client_ip = '';//Auth.SessionManagement.getCurrentSession().get('SourceIp');  
                        //    leadwrap.color = opp.lead__r.Product__r.Color__c;
                        leadwrap.comments = opp.lead__r.Comments__c;
                        leadwrap.customer_email = opp.lead__r.Email;
                        if(opp.lead__r.Phone != null){
                            leadwrap.customer_mobile = (opp.lead__r.Phone).right(10);
                        }                    
                        leadwrap.customer_name = opp.lead__r.Name;
                        leadwrap.funding_amount = String.valueOf(opp.lead__r.Funding_Amount__c);
                        leadwrap.is_otp_verfied = opp.lead__r.Is_Otp_Verified__c;
                        leadwrap.whatsapp_consent = opp.lead__r.WhatsApp_consent__c;
                        //        leadwrap.kms = String.valueOf(opp.lead__r.Product__r.Kilometer__c);
                        leadwrap.lead_category = opp.lead__r.Lead_Category__c;
                        leadwrap.lead_flag = opp.lead__r.Lead_Flag__c;
                        //newly added for checking
                        leadwrap.lms_lead_id = opp.lead__r.Customer_Id__c; // external Id 
                        if(opp.lead__r.Td_Client_Id__c != NULL)
                            leadwrap.td_client_id = opp.lead__r.Td_Client_Id__c;
                        if(opp.lead__r.LeadSource != null){
                            leadwrap.lead_source = opp.lead__r.LeadSource;
                        }else{
                            leadwrap.lead_source = 'MFC-CRM';
                        }                           
                        leadwrap.lead_tags = opp.lead__r.Lead_Tags__c;
                        leadwrap.lead_title = opp.lead__r.Lead_Title__c;
                        leadwrap.lead_type = opp.lead__r.Lead_Type__c;
                        leadwrap.leadsource_dealer_id = opp.lead__r.Lead_Source_Ref_ID__c;
                        //leadwrap.LMS_leadid = lea.Customer_Id__c;
                        leadwrap.marketing_campaign = opp.lead__r.Marketing_Campaign__c;
                        leadwrap.marketing_content = opp.lead__r.Marketing_Content__c;
                        leadwrap.marketing_device = opp.lead__r.Marketing_Device__c;
                        leadwrap.marketing_medium = opp.lead__r.Marketing_Medium__c;
                        leadwrap.marketing_source = opp.lead__r.Marketing_Source__c;
                        if(opp.lead__r.Product__c != null){
                            /*   leadwrap.mfg_month = opp.lead__r.Product__r.Model_Month__c;
leadwrap.mfg_year = opp.lead__r.Product__r.Model_Year__c;
leadwrap.primary_make = opp.lead__r.Product__r.Make__c;
leadwrap.primary_model = opp.lead__r.Product__r.Model__c;
leadwrap.primary_variant = opp.lead__r.Product__r.Variant__c;
leadwrap.register_city = opp.lead__r.Product__r.Registration_City__c;
leadwrap.register_no = opp.lead__r.Product__r.Registration_Number__c;
leadwrap.stock_id = opp.lead__r.Product__r.Stock_ID__c;
leadwrap.stock_type = opp.lead__r.Product__r.Body_Type__c; 
                        } else{
                            leadwrap.primary_make = opp.lead__r.Primary_Make__c;
                            leadwrap.primary_model = opp.lead__r.Primary_Model__c;
                        }
                        leadwrap.stock_listed_price = '';
                        leadwrap.owner = '';
                        leadwrap.register_year = '';
                        leadwrap.register_month = '';
                        leadwrap.secondary_variant = '';
                        leadwrap.secondary_model = '';
                        leadwrap.secondary_make = '';
                        leadwrap.secondary_variant = '';
                        leadwrap.lead_priority = opp.lead__r.Lead_Priority__c; 
                        leadwrap.lead_stage = opp.lead__r.Lead_Stage__c;
                        leadwrap.lead_status = opp.lead__r.Status__c;
                        leadwrap.customer_expected_price = String.valueOf(opp.lead__r.Customer_Expected_Price__c);
                        leadwrap.customer_address = '';
                        leadwrap.created_date = '';
                        leadwrap.lms_lead_id = opp.lead__r.Customer_Id__c; // external Id 
                        
                        for(Opportunity  OppT : oppList){
                            LeadDetailModel.Target trtwrap = new LeadDetailModel.Target();
                            //    trtwrap.stock_id = OppT.Product__r.Stock_ID__c;
                            trtwrap.employee_id = OppT.Employee_Id__c;
                            trtwrap.employee_name = OppT.Employee_Name__c;
                            trtwrap.employee_type = OppT.Employee_Type__c;
                            trtwrap.followup_comments = OppT.Followup_Comments__c;
                            trtwrap.followup_date = OppT.Followup_Date__c;
                            trtwrap.lms_dispatch_id = OppT.LMS_Opp_Id__c;
                            trtwrap.sfdc_lead_dispatch_id = OppT.Id;
                            trtwrap.status = OppT.status__c;
                            trtwrap.status_updated_by = OppT.status__c;
                            trtwrap.target_id = OppT.Dealer__r.Code__c;
                            trtwrap.target_name = OppT.Dealer__r.Name;
                            trtwrap.target_source = 'MFC';
                            // Girish 14-Dec 2022 start
                            trtwrap.stock_id=OppT.Stock_ID__c;
                            leadwrap.primary_make = OppT.Product__r.Make__c;
                            leadwrap.primary_model = OppT.Product__r.Model__c;
                            leadwrap.primary_variant = OppT.Product__r.Variant__c;
                            leadwrap.stock_id = OppT.Stock_ID__c;
                            leadwrap.lead_flag = OppT.Lead_Flag__c;

                            //Girish 14-Dec 2022 end
                            targetList.add(trtwrap);  
                            system.debug('targetList'+targetList);
                        }
                        leadwrap.target = targetList;
                        leadWrapperList.add(leadwrap);  
                        system.debug('leadWrapperList'+leadWrapperList);
                        
                        sfIdWithJson.put(opp.Id, leadwrap);
                        
                        // system.debug('sfIdWithJson'+sfIdWithJson);
                        
                        
                        
                    }
                }
                
                // getting endpoints 
                List<LeadPushAPI__c> endpointList = LeadPushAPI__c.getAll().values();
                if(!endpointList.isEmpty()){
                    for(LeadPushAPI__c endpnt : endpointList){
                        if(endpnt.Name =='Get Token'){
                            accessTokenEndpoint = endpnt.Endpoint__c;
                        } else if(endpnt.Name =='Lead Create'){
                            insertLeadEndpoint = endpnt.Endpoint__c;
                        }else if(endpnt.Name =='Lead Update'){
                            updateLeadEndpoint = endpnt.Endpoint__c;
                        }
                    }
                }
                
                // getting Access Token
                String accessToken;
                String jsonToGetAccessToken = '{"username":"crmsfdc@lms.com","password":"p@ssword","tag":"android"}';
                
                System.debug('__making Auth Call');
                HttpResponse authResponse = FinanceLeadCallout.requestHandler('POST', accessTokenEndpoint, jsonToGetAccessToken, 120000);
                System.debug('Response: ' + authResponse);
                if(authResponse.getStatusCode() == 200) {
                    String resStr = authResponse.getBody();
                    System.debug('resStr: ' + resStr);
                    
                    Map<String,Object> authResponseObj = (Map<String,Object>)JSON.deserializeUntyped(resStr);
                    if(authResponseObj.get('status_code') == 200){
                        accessToken = (String)authResponseObj.get('access_token');
                    } 
                    System.debug('accessToken: ' + accessToken);
                } else {
                    responseString = authResponse.getBody();
                    throw new CalloutException('AUTH_ENDPOINT_ERROR');
                }
                
                // wrapper JSON
                LeadDetailModel.MainWrapperClass mainWrapper = new LeadDetailModel.MainWrapperClass();
                mainWrapper.data = leadWrapperList;
                mainWrapper.access_token = accessToken;
                mainWrapper.tag = 'MFC-CRM';
                
                String JsonLeadStr = System.JSON.serialize(mainWrapper).replace('null','\"\"');
                System.debug('JsonLeadStr: ' + JsonLeadStr);
                
                // Insert API CallOut
                // Added By Aravindan A
                System.debug('__making insert Call');
                HttpResponse leadRes = FinanceLeadCallout.requestHandler('POST', insertLeadEndpoint, JsonLeadStr, 120000);
                System.debug('Response: ' + leadRes);
                
                // handling Response
                Map<String,Object> responseObj = new Map<String,Object>();
                if(leadRes.getStatusCode() == 200) {
                    responseObj = (Map<String,Object>)JSON.deserializeUntyped(leadRes.getBody());
                    System.debug('responseObj: ' + responseObj);
                } else {
                    responseString = leadRes.getBody();
                    throw new CalloutException('INSERT_ENDPOINT_ERROR');
                }
                String jsonSuccess = JSON.serialize(responseObj.get('success'));
                String jsonError = JSON.serialize(responseObj.get('error'));
                System.debug('jsonError: ' + jsonError);
                System.debug('jsonSuccess: ' + jsonSuccess);
                
                
                //     List<API_Log__c> apiLogCaptureList = new List<API_Log__c>();
                
                Map<String,LeadDetailModel.ResponseWrapperClass> sfIdWithResponse = new Map<String,LeadDetailModel.ResponseWrapperClass>(); 
                
                // Success
                if(jsonSuccess != null) {
                    List<LeadDetailModel.ResponseWrapperClass> successResponseList = (List<LeadDetailModel.ResponseWrapperClass>)JSON.deserialize(jsonSuccess, List<LeadDetailModel.ResponseWrapperClass>.class);
                    System.debug('successResponseList: ' + successResponseList);
                    Map<String,String> sfIdWithCustomerId = new Map<String,String>();
                    Map<String,String> sfDispactchIdWithDispatchId = new Map<String,String>();
                    if(successResponseList != null)  {
                        for(LeadDetailModel.ResponseWrapperClass resObj : successResponseList){
                            system.debug('resObj'+resObj);
                            sfIdWithResponse.put(resObj.sfdc_lead_dispatch_id, resObj);
                            system.debug('sfIdWithResponse'+sfIdWithResponse);
                            sfIdWithCustomerId.put(resObj.sfdc_lead_dispatch_id, resObj.leadsDispatch_id);
                            system.debug('sfIdWithCustomerId'+sfIdWithCustomerId);
                            if(resObj.sfdc_lead_dispatch_id != null && !String.isBlank(resObj.sfdc_lead_dispatch_id)) {
                                sfDispactchIdWithDispatchId.put(resObj.sfdc_lead_dispatch_id, resObj.leadsDispatch_id);
                            }
                        }
                        
                    }
                    
                    system.debug('sfIdWithResponse.get(key)'+sfIdWithResponse.get('sfdc_lead_id'));
                    
                    if(!sfIdWithCustomerId.isEmpty()) {
                        for(String key : sfIdWithCustomerId.keySet()) {
                            system.debug('key'+key);
                            Opportunity l = new Opportunity();
                            l.id = key;
                            l.LMS_Opp_Id__c = sfIdWithCustomerId.get(key); // external Id 
                            
                            
                            if(leadIdCustomerIDMap.containsKey(key) && leadIdCustomerIDMap.get(key) == null){ // 10 Augast  2022:Ankit:Start :: Leads hitting Elision on updating followup lead(CRM-962) 
                                updateoppList.add(l);
                            }
                            
                            
                            System.debug('Added To list' + updateoppList);
                            
                            apiLogCaptureList.add(LogService.createApiLogs(insertLeadEndpoint, JSON.serialize(sfIdWithJson.get(key)), JSON.serialize(sfIdWithResponse.get(key)), sfIdWithResponse.get(key).status_code, apiLogTag, key,false));
                            system.debug('apiLogCaptureList' +apiLogCaptureList);
                            //LogService.createApiLogs(insertLeadEndpoint, JSON.serialize(sfIdWithJson.get(key)), JSON.serialize(sfIdWithResponse.get(key)), sfIdWithResponse.get(key).status_code, 'Buyer Lead Callout',key);   
                        }
                    }
                    system.debug('sfDispactchIdWithDispatchId');
                    if(!sfDispactchIdWithDispatchId.isEmpty()){
                        for(String key1 : sfDispactchIdWithDispatchId.keySet()){
                            Opportunity OD = new Opportunity();
                            OD.Id = key1;
                            OD.LMS_Opp_Id__c = sfDispactchIdWithDispatchId.get(key1);
                            updateoppList.add(OD);
                        }
                    }
                    
                }
                
                // failure
                if(jsonError != null) {
                    List<LeadDetailModel.ResponseWrapperClass> failureResponseList = (List<LeadDetailModel.ResponseWrapperClass>)JSON.deserialize(jsonError, List<LeadDetailModel.ResponseWrapperClass>.class);
                    System.debug('failureResponseList: ' + failureResponseList);
                    Map<String,String> FailureMap = new Map<String,String>();
                    if(failureResponseList != null) {
                        for(LeadDetailModel.ResponseWrapperClass resObj : failureResponseList){
                            sfIdWithResponse.put(resObj.sfdc_lead_dispatch_id, resObj);
                            FailureMap.put(resObj.sfdc_lead_dispatch_id, resObj.message);  
                        }
                    }
                    
                    if(!FailureMap.isEmpty()){
                        Map<String, Id> queueMap = new Map<String, Id>();
                        for(Group grp : [Select Id,Name,type from Group where type = 'queue']){
                            queueMap.put(grp.Name, grp.Id);
                        }
                        for(String key2 : FailureMap.keySet()) {
                            Opportunity l = new Opportunity();
                            l.id = key2;
                            l.Message__c = FailureMap.get(key2);
                            /*  if(FailureMap.get(key2).contains('Duplicate')){
l.OwnerId = queueMap.get('BUC_Duplicate');
l.IsDuplicate__c = true; 
l.status__c='Duplicate'; // 26 august 2022: Rohit ::  Mark Duplicate leads in SF with status duplicate on fresh and followup(CRM-960)
} 
                            updateoppList.add(l);
                            apiLogCaptureList.add(LogService.createApiLogs(insertLeadEndpoint, JSON.serialize(sfIdWithJson.get(key2)), JSON.serialize(sfIdWithResponse.get(key2)), sfIdWithResponse.get(key2).status_code, apiLogTag, key2,false));
                            // LogService.createApiLogs(insertLeadEndpoint, JSON.serialize(sfIdWithJson.get(key2)), JSON.serialize(sfIdWithResponse.get(key2)), sfIdWithResponse.get(key2).status_code, 'Buyer Lead Callout',key2);   
                        }
                    }
                }
                
                // updating SFDC
                System.debug('updateoppList: ' + updateoppList.size());
                System.debug('apiLogs: ' + apiLogCaptureList.size());
                System.debug('Updating lead: ' + updateoppList);
                
                
                
                
            } catch(Exception e) {
                System.debug('EXCEPTION_CAUGHT: ' + e);
                String exMsg = e.getMessage();
                String exceptionStr;
                String endPoint;
                if(exMsg == 'AUTH_ENDPOINT_ERROR') {
                    endPoint = accessTokenEndpoint;
                } else if(exMsg == 'INSERT_ENDPOINT_ERROR') {
                    endPoint = insertLeadEndpoint;
                } else {
                    exceptionStr = 'Exception: Type: ' + e.getTypeName() + ', Message: ' +  e.getMessage() + ' at Line: ' + e.getLineNumber();  
                    responseString = exceptionStr;
                    exMsg = 'Failed';
                }
                
                String reqBody;
                //      List<API_Log__c> errorLogs = new List<API_Log__c>();
                for(Id leadId : leadIdSet) {
                    system.debug('Record Id :- '+leadId);
                    reqBody = JSON.serialize(sfIdWithJson.get(leadId));
                    errorLogs.add(LogService.createApiLogs(endPoint, reqBody, responseString, exMsg, apiLogTag, leadId, false));
                }
                
                
            } finally {
                LeadConstants.fireLMSApiFromLead = FALSE;
            }
        }
        system.debug('updateLeadList'+updateLeadList);
        
        if(!updateLeadList.isEmpty()){
            database.update(updateLeadList,False);
            
        }
        if(!updateoppList.isEmpty()){
            database.update(updateoppList,False);
            
        }
        if(!apiLogCaptureList.isEmpty()){
            LogService.createApiLogs(apiLogCaptureList);
        }
        
        if(!errorLogs.isEmpty()){
            LogService.createApiLogs(errorLogs);
        }   
    } */
}