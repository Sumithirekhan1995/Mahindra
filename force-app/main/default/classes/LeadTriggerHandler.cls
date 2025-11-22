/*
* Class created by Deepali
* Purpose: To filter out records from LeadTrigger and send to LeadTriggerHelper
*/
public class LeadTriggerHandler {
    
    public static boolean isLeadInsert = false;
    public static boolean createFinOpp = true;
    public static List<AggregateResult> results;
    
    //Added by Deepali
    public static void onBeforeInsert(List<Lead> newList){
        
        isLeadInsert = true;
        List<Lead> buyerLeadWithPhoneList = new List<Lead>();
        List<Lead> checkforDuplicates = new List<Lead>();
        List<Lead> checkforSellerDuplicates = new List<Lead>();
        List<Lead> checkforCnBDuplicates = new List<Lead>();
        List<Lead> checkForBSEDuplicates = new List<Lead>();
        List<Lead> checkForCnBBikeDuplicates = new List<Lead>();
        List<Lead> leadwithoutStates = new List<Lead>();
        List<Lead> chatbotDuplicateLeads = new List<Lead>();
        Set<String> servicableCity = new Set<String>();
        
        Set<Id> leadIds = new Set<Id>();
        
        Map<Id,Profile> userProfileMap = new Map<Id,Profile>([SELECT id FROM Profile where name in ('BUC and HI CRE Agent','Seller HI CRE','Seller HI Lead CRE')]);
        
        for(Serviceable_City__c scCustomSetting :Serviceable_City__c.getAll().values() ){
            servicableCity.add(scCustomSetting.City_Name__c.toLowerCase());
        }
        Map<String,Integer> HiservicableCityMap = new Map<String,Integer>(); // sumit
        for(HiServiceableCity__c hCity : HiServiceableCity__c.getAll().values()) {
           // HiservicableCity.add(hCity.City__c);
            HiservicableCityMap.put((String)hCity.City__c,(Integer)hCity.Count__c);
        }
        Map<String,Integer> slotMap = new Map<String,Integer>();
        Set<Date> setDate = new Set<Date>();
        
        // Girish 27-08-2023
         for(Lead lDate : newlist) {
          if(lDate.Valuator_Assigned_Visit_Date__c!=null)
            setDate.add(lDate.Valuator_Assigned_Visit_Date__c);
        }
        
        if(results == null && !setDate.isEmpty()) {
            results = [SELECT COUNT(Valuator_Assigned_Visit_Date__c) recordCount, Valuation_Schedule_Time_Slot__c,Seller_City__c  FROM Lead WHERE Valuator_Assigned_Visit_Date__c =: setDate AND RecordTypeId =: LeadConstants.SellerLeadRecordTypeId GROUP BY Valuation_Schedule_Time_Slot__c,Seller_City__c];
        }
        if(results!=null)
        {
        for (AggregateResult result : results) {
             string Key = result.get('Valuation_Schedule_Time_Slot__c') + '-' +  result.get('Seller_City__c');
            slotMap.put(Key,(Integer)result.get('recordCount'));
            system.debug('slotMap'+slotMap);
        }
        }
        // increasing count for the same slot for new updated records that are in trigger and not queried
        for(Lead lDate : newList){
            if(lDate.Valuation_Schedule_Time_Slot__c != null && runOnceCount) {
                Integer count = 0;
                if(slotMap.containsKey(lDate.Valuation_Schedule_Time_Slot__c + '-' + lDate.Seller_City__c)) {
                    count = slotMap.get(lDate.Valuation_Schedule_Time_Slot__c + '-' + lDate.Seller_City__c);
                    
                    count++;
                }  else {
                    count = 1;
                }
                slotMap.put(lDate.Valuation_Schedule_Time_Slot__c + '-' + lDate.Seller_City__c, count);
                
                 runOnceCount = false;
            }
        }
        
       List<Lead> leadArrwithLessData = new List<Lead>();
         
        
        for(Lead lea : newList){
            
            // 6April2022:Asif:Start ::mapping LeadSource 
            if(lea.Source_Id__c == 'CreatedByMFCChatBot') {
                lea.LeadSource = 'MFC-Chat';
                lea.Source_Id__c = null;
                lea.Status__c = 'New';
            }
            // 6April2022:Asif:End
            
             if(lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && 
                   slotmap.get(lea.Valuation_Schedule_Time_Slot__c + '-' + lea.Seller_City__c) > HiservicableCityMap.get(lea.Seller_City__c) && 
                   lea.Status__c == LeadConstants.LeadStatus && 
                   lea.HI_Serviceable__c == '1' &&
                   UserInfo.getUserId() != System.Label.Integration_User &&
                   userProfileMap.keySet().contains(UserInfo.getProfileId())
                  ) 
               {
                   lea.Valuation_Schedule_Time_Slot__c.addError((slotmap.get(lea.Valuation_Schedule_Time_Slot__c + '-' + lea.Seller_City__c) - 1) +' bookings already assigned for this inspection date time and slot. Please choose another slot ' );  
                    }
            
            lea.ExtrnId_Phone__c = lea.Phone;
            if(lea.LastName == NULL){
                lea.LastName = lea.Phone;
            }  
            if(lea.Area_State__c != null && lea.Seller_State__c == null){
                lea.Seller_State__c = lea.Area_State__c;
            }
            if(lea.Seller_State__c != null && lea.Area_State__c == null){
                lea.Area_State__c = lea.Seller_State__c;
            }
            if(lea.Area_City__c != null && lea.Seller_City__c == null){
                lea.Seller_City__c = lea.Area_City__c;
            }
            if(lea.Seller_City__c != null && lea.Area_City__c == null){
                lea.Area_City__c = lea.Seller_City__c;
            }
            
            //To check if city is in list of serviceable cities and mark the field as true
            if(lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && lea.Seller_City__c != NULL && servicableCity.contains(lea.Seller_City__c.toLowerCase()) 
               && lea.HI_Serviceable__c == '0'){
                   lea.Serviceable_City__c = true;
               }
            
            //added by Deepali
            //to filter out Buyer Leads with Phone number and without Account
            if(lea.Phone != NULL && lea.Customer__c == NULL){
                buyerLeadWithPhoneList.add(lea);
            }  
            
            if(lea.RecordTypeId == LeadConstants.buyerLeadRecordTypeId) {
                leadArrwithLessData.add(lea);
            }
            
            //added by Deepali
            //to filter out Buyer Leads with Product and Dealer value
            if(lea.RecordTypeId == LeadConstants.buyerLeadRecordTypeId && lea.Dealer__c  != NULL /*&& lea.Product__c != NULL*/){
                lea.Bypass_validation__c = false;
                lea.Status = LeadConstants.leadStatus_Qualified;
            } 
            
            //To filter if leadtype = USEDCAR and update recordtype as buyer used car
            if(lea.Lead_Type__c != NULL && lea.Lead_Type__c == LeadConstants.BuyerConstant){
                lea.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
            }
            
            //To Filter if lead type = Procurement and update recordtype as seller car
            if(lea.Lead_Type__c != NULL && lea.Lead_Type__c == LeadConstants.ProcurementConstant){
                if(lea.LeadSource == 'ELV' || lea.LeadSource == 'PI'){
                    lea.RecordTypeId = LeadConstants.ElvLeadRecordTypeId; // CRM-1311
                }else{
                    lea.RecordTypeId = LeadConstants.SellerLeadRecordTypeId;
                }
            }
            // To assign Seller_ELV Queue :: Sumit ::Start:: CRM-1311
            if(lea.RecordTypeId == LeadConstants.ElvLeadRecordTypeId && lea.LeadSource != NULL  &&  lea.LeadSource == 'ELV'){
                lea.OwnerId = LeadConstants.SellerElvQueueId;
            }
             if(lea.RecordTypeId == LeadConstants.ElvLeadRecordTypeId && lea.LeadSource != NULL  &&  lea.LeadSource == 'PI'){
                lea.OwnerId = LeadConstants.SellerPiQueueId;
            }
            // Sumit ::End:: CRM-1311
           
            //To filter the statuses and assign stage as qualified
            if(lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && lea.Status__c != NULL  &&  
               (lea.Status__c == LeadConstants.LeadStatus || lea.status__c == 'Evaluated' || lea.Status__c == 'Assigned')  && lea.Followup_Lead_Created__c == false){
                   lea.Bypass_validation__c = false;
                   lea.Status = LeadConstants.LEAD_STATUS_QUALIFIED;
               }
            
            //To check if state is null and populate state based on city
            if(lea.Seller_State__c == null && lea.Seller_City__c != null){
                leadwithoutStates.add(lea);
            }            
            
            //duplicate Records
            if(lea.Phone != null && lea.Lead_Type__c == LeadConstants.BuyerConstant && lea.LeadSource != NULL && !lea.LeadSource.contains('Exotel')){  
                checkforDuplicates.add(lea);
            }
            
            if(lea.Phone != null && lea.Lead_Type__c == LeadConstants.ProcurementConstant){
                checkforSellerDuplicates.add(lea);
            }
            
            if(lea.Phone != NULL && lea.Lead_Type__c == LeadConstants.LEAD_TYPE_CNB){
                checkforCnBDuplicates.add(lea);
            }
            
            if(lea.Phone != NULL && lea.Lead_Type__c == LeadConstants.LEAD_TYPE_BSE){
                checkForBSEDuplicates.add(lea);
            }
            
            if(lea.Phone != NULL && lea.Lead_Type__c == LeadConstants.LEAD_TYPE_CNB_BIKE){
                checkForCnBBikeDuplicates.add(lea);
            }
            
            if(lea.Phone != null){
                chatbotDuplicateLeads.add(lea);
            }
            
            if(!leadArrwithLessData.isEmpty()) {
                LeadTriggerHelper.fillLeadDetails(leadArrwithLessData);
            }
            
            // 12April2022:Shivam:Start :: duplicating Elision CTI Leads
            if(!lea.CTIDuplicate__c  &&  (lea.RecordTypeId == LeadConstants.buyerLeadRecordTypeId || (lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && lea.HI_Serviceable__c == '1'))) {
                DateTime dt = (DateTime)System.today();
                dt = dt.addSeconds(19800);
                List<Lead> leadDBArr = [SELECT Id FROM Lead WHERE Phone = :lea.Phone AND (NOT Status__c Like 'Exotel%') AND  (RecordTypeId = :LeadConstants.buyerLeadRecordTypeId OR (RecordTypeId = :LeadConstants.SellerLeadRecordTypeId AND HI_Serviceable__c = '1')) AND CreatedDate >= :dt  LIMIT 1];
                if(!leadDBArr.isEmpty()) {
                    lea.CTIDuplicate__c = true;
                } else {
                    List<String> phone = new List<String>();
                    for(Lead lead1 : newList) {
                        if(lea.Phone == lead1.phone && lead1.Status__c != null && !lead1.Status__c.contains('Exotel')) {
                            if(phone.size() == 0) {
                                phone.add(lea.Phone);
                            } else {
                                lead1.CTIDuplicate__c= true;
                            }
                        }
                    }
                }
            }
            // 12April2022:Shivam:End
            
        }
        
        
        //Added by Deepali
        System.debug('buyerLeadWithPhoneList'+buyerLeadWithPhoneList);
        if(!buyerLeadWithPhoneList.isEmpty()){
            LeadTriggerHelper.tagCustomerAccountToLead(buyerLeadWithPhoneList);
        }
        
        //To call method that populates state
        system.debug('leadwithoutStates'+leadwithoutStates);
        if(!leadwithoutStates.isEmpty()){
            LeadTriggerHelper.populateState(leadwithoutStates);
        }
        
        //Added by Swetha checkforLeadDuplicates
        if(!checkforDuplicates.isEmpty()){
            LeadTriggerHelper.checkDuplicates(checkforDuplicates, LeadConstants.BuyerConstant);
        }
        if(!checkforSellerDuplicates.isEmpty()){
            LeadTriggerHelper.checkDuplicates(checkforSellerDuplicates, LeadConstants.ProcurementConstant);
        }
        
        if(!checkforCnBDuplicates.isEmpty()){
            LeadTriggerHelper.checkDuplicates(checkforCnBDuplicates, LeadConstants.LEAD_TYPE_CNB);
        }
        
        if(!checkForBSEDuplicates.isEmpty()){
            LeadTriggerHelper.checkDuplicates(checkForBSEDuplicates,LeadConstants.LEAD_TYPE_BSE);
        }
        if(!checkForCnBBikeDuplicates.isEmpty()){
            LeadTriggerHelper.checkDuplicates(checkForCnBBikeDuplicates, LeadConstants.LEAD_TYPE_CNB_BIKE);
        }
        if(!chatbotDuplicateLeads.isEmpty()){
            // LeadTriggerHelper.checkChatbotDuplicates(chatbotDuplicateLeads);
        }
        
    }  
    
    //Added by Deepali
    public static void onAfterInsert(List<Lead> newList, Map<Id,Lead> newMap, Map<Id,Lead> oldMap){
        List<Lead> qualifiedBuyerList = new List<Lead>();
        List<Lead> listOfLeadToCPT = new List<Lead>();
        List<Id> sellerLeadIdtoLock = new List<Id>();
        List<lead> qualifiedsellerleads = new List<lead>();
        Set<String> servicableCity = new Set<String>();
        List<Lead> BulkUploadList = new List<Lead>();
        Set<id> r2wLeadIdsPushToLostAPI = new Set<id>();
        List<Id> finlostLeadsToLock = new List<Id>();
        
         Map<String,Integer> HiservicableCityMap = new Map<String,Integer>(); // sumit
         Map<String,Integer> slotMap = new Map<String,Integer>();//sumit
        
        
        
        // 03/08/22:Ankit:Start  CRM-947-Seller HI lead created with status VTA to hit IBB 
        List<Lead> sellerHIList = new List<Lead>();
        system.debug('Created List for SellerHiList');
        // 03/08/22:Ankit:End  CRM-947-Seller HI lead created with status VTA to hit IBB
        
        //ForCnb
        Set<Id> leadsToNewLeadAPI = new Set<Id>();
        List<Lead> leadListToCallCnBOpp = new List<Lead>();
        List<Id> cnbIdsToLock = new List<Id>();
        
        //List for Automatic SMS triggering 
        List<Lead> newLeadsCreatedList = new List<Lead>();
        
        //For Ecom
        Set<Id> ecomLeads = new Set<Id>();
        Set<Id> bucLeads = new Set<Id>();
        Set<Id> leadIds = new Set<Id>();
        //List<Lead> leadlistinServiceableCity = new List<Lead>();
        
        for(Serviceable_City__c scCustomSetting :Serviceable_City__c.getAll().values() ){
            servicableCity.add(scCustomSetting.City_Name__c.toLowerCase());
        }
        
        // 28feb2022:Asif:Start Autofin Lead Coversion
        List<Lead> autoFinConvertedLeads = new List<Lead>();
        // 28feb2022:Asif:End
        List<Lead> lstChatbotLead = new List<Lead>();
        
        //10Jan2022:Shivam:Start
        
        List<Lead> hiLeadArr = new List<Lead>();
        Map<Id, Lead> hiLeadMap = new Map<Id, Lead>();
        for(Lead lRec : newList)
        {
            System.debug('lRec 1: '+lRec.RecordTypeId);
            if(lRec.RecordTypeId == LeadConstants.SellerLeadRecordTypeId || lRec.RecordTypeId == LeadConstants.ElvLeadRecordTypeId ) { //CRM-1312
                hiLeadArr.add(lRec);
                if(oldMap != null && oldMap.containsKey(lRec.Id)) {
                    hiLeadMap.put(lRec.Id, oldMap.get(lRec.Id));
                }   
                
            }
        }
        
          if(!hiLeadArr.isEmpty()) {
            ElisonLeadActivityService.init(hiLeadArr, hiLeadMap);
        }
        
        //10Jan2022:Shivam:End
        for(Lead lea : newList){  
            //added by Mishal as a part of 995
            if(lea.LeadSource == 'MFC-Chat') {
                lstChatbotLead.add(lea);
                
            }
            
            //added by Deepali
            //to filter out qualified Buyer Leads
            //(lea.LeadSource != 'Exotel Missed Call' || lea.LeadSource != 'Exotel Call' || lea.LeadSource != 'Exotel')
            if( lea.Exotel_Call_Summary__c == null && lea.RecordTypeId == LeadConstants.buyerLeadRecordTypeId && lea.Status != null && lea.Status == LeadConstants.leadStatus_Qualified ){
                System.debug('*****Getting Inside Lead Trigger******' + lea.leadSource);
                qualifiedBuyerList.add(lea);
            } 
            
            if(lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && lea.Status__c != NULL  && lea.Status__c == LeadConstants.LeadStatus && lea.Seller_City__c  != null && 
               servicableCity.contains(lea.Seller_City__c.toLowerCase()) && lea.Bulk_Uploaded__c == false && lea.HI_Serviceable__c == '0'){
                   listOfLeadToCPT.add(lea);   
               }
            //To filter qualified Seller leads
             if(lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && 
                   slotmap.get(lea.Valuation_Schedule_Time_Slot__c) > HiservicableCityMap.get(lea.Seller_City__c) && 
                   lea.Status__c == LeadConstants.LeadStatus && 
                   //lea.LeadSource == LeadConstants.CptConstants && 
                   lea.HI_Serviceable__c == '1' &&
                    UserInfo.getUserId() != System.Label.Integration_User
                  ) 
               {
                        
                   }          
          else if(lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && lea.Status__c != NULL  &&  (lea.Status__c == LeadConstants.LeadStatus || lea.status__c == 'Evaluated' || lea.Status__c == 'Assigned')  && lea.Followup_Lead_Created__c == false){
                qualifiedsellerleads.add(lea);
            }
            
            //To take ids so as to lock record
            if(lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && lea.Status__c != NULL 
               && (lea.Status__c == LeadConstants.LeadStatus || lea.Status__c == LeadConstants.Lead_Status_del || lea.Status__c == LeadConstants.Lead_Status_Evaluated 
                   || lea.Status__c == LeadConstants.Lead_Status_Assigned || lea.Status == 'Lost') ){
                       sellerLeadIdtoLock.add(lea.Id);    
                   }
            
            // 03/08/22:Ankit:Start  CRM-947-Seller HI lead created with status VTA to hit IBB            
            if(lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && lea.Status__c == 'Valuator to be Assigned'){//&& lea.HI_Serviceable__c == '1' && lea.HI_Preference__c != NULL ){                  
                sellerHIList.add(lea);
            }
            // 03/08/22:Ankit:Ends  CRM-947-Seller HI lead created with status VTA to hit IBB
            
            //for Cnb
            if((lea.RecordTypeId == leadConstants.CnBLeadRecordTypeId || lea.RecordTypeId == leadConstants.CnBBikeLeadRecordTypeId) && lea.CnB_API_Fire__c == false &&
               UserInfo.getUserId() != System.Label.Integration_User){
                   leadsToNewLeadAPI.add(lea.id);
               }
            if((lea.RecordTypeId == leadConstants.CnBLeadRecordTypeId || lea.RecordTypeId == leadConstants.CnBBikeLeadRecordTypeId) && (lea.Status__c == '1' || lea.Status__c == '8' || lea.Status__c == '9') &&
               lea.Status__c != NULL && lea.Form_Type_Id__c != NULL){
                   leadListToCallCnBOpp.add(lea);
               }
            if((lea.RecordTypeId == leadConstants.CnBLeadRecordTypeId || lea.RecordTypeId == leadConstants.CnBBikeLeadRecordTypeId) && lea.Followup_Lead_Created__c == true){
                cnbIdsToLock.add(lea.Id);
            }
            
            //For Automated SMS Triggering
            if(lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && lea.HI_Serviceable__c == '1'){
                newLeadsCreatedList.add(lea);
                System.debug('LEad creation SMS triggering ');
            }
            
            //To send buyer data to Ecom CnB
            if(lea.RecordTypeId == LeadConstants.buyerLeadRecordTypeId && lea.Lead_Flag__c == 'Reserve' &&
               (lea.External_LMS_Lead_Id__c == NULL || lea.Private_lead_id__c == NULL) ){
                   ecomLeads.add(lea.Id);
                   system.debug('ecomLeads'+ecomLeads);
               }
            
            if(lea.RecordTypeId == LeadConstants.buyerLeadRecordTypeId && lea.Customer_Id__c == NULL ){
                bucLeads.add(lea.Id);
                system.debug('i am in bucLeads');
            }
            
            // 28Feb2022:Asif:Start AutoFin Lead Conversion
            if(lea.recordTypeId == LeadConstants.AutofinRecordtyeId && lea.Status__c == LeadConstants.StatusInProcess) {
                autoFinConvertedLeads.add(lea);
            }
            // 28Feb2022:Asif:End
            
        } 
        if(!lstChatbotLead.isEmpty()) {
            System.debug('lstChatbotLead'+lstChatbotLead);
            LeadTriggerhelper.checkChatbotDuplicates(lstChatbotLead);
        }
        
        system.debug('listOfLeadToCPT'+listOfLeadToCPT);
        if(!listOfLeadToCPT.isEmpty()){
            LeadTriggerHelper.sendLeadDataToCPT(listOfLeadToCPT);
        }
        
        system.debug('qualifiedsellerleads'+qualifiedsellerleads);
        if(!qualifiedsellerleads.isEmpty()){
            LeadTriggerHelper.createSellerOpportunity(qualifiedsellerleads);
        }
        
        // 03/08/22:Ankit:Start  CRM-947-Seller HI lead created with status VTA to hit IBB
        //For Seller HI
        if(!sellerHIList.isEmpty()){
            LeadTriggerHelper.createSellerOpportunity(sellerHIList);
            LeadPushCPT.setDataforHICallout(sellerHIList);
        } 
        // 03/08/22:Ankit:End  CRM-947-Seller HI lead created with status VTA to hit IBB
        
        //ForCnB
        System.debug('leadsToNewLeadAPI '+leadsToNewLeadAPI);
        if(!leadsToNewLeadAPI.isEmpty()){
            //   LeadTriggerHelper.callNewLeadAPI(leadsToNewLeadAPI);
        } 
        if(!leadListToCallCnBOpp.isEmpty()){
            LeadTriggerHelper.cnbLeadOpportunity(leadListToCallCnBOpp);
        }     
        if(!cnbIdsToLock.isEmpty()){
            UtilityClass.lockRecords(cnbIdsToLock);
        }
        if(sellerLeadIdtoLock.size() > 0){
            UtilityClass.lockRecords(sellerLeadIdtoLock);
        }
        
        //For Automated SMS triggering
        System.debug('SMS Trigger on new Lead '+newLeadsCreatedList);
        if(!newLeadsCreatedList.isEmpty()){
            LeadTriggerHelper.sendSMSToUser('SELL_Leadcreate', newLeadsCreatedList);
        }
        
        //To Call ecom callout class in helper
        if(!ecomLeads.isEmpty() && !Test.isRunningTest()){
            System.debug('__making LMS Callout from LeadTriggerHandler.onAfterUpdate pushLeadToLmsfuture ecomLeads');
            //LeadTriggerHelper.pushLeadToLmsfuture(ecomLeads);
        }
        if(!bucLeads.isEmpty() && !Test.isRunningTest()){
            System.debug('__making LMS Callout from LeadTriggerHandler.onAfterUpdate pushLeadToLmsfuture bucLeads');
            LeadTriggerHelper.pushLeadToLmsfuture(bucLeads);
        }

        
        
        // 28Feb2022:Asif:Start AutoFin Lead Conversion
        if(!autoFinConvertedLeads.isEmpty()) {
            LeadTriggerhelper.onAfterConverted(autoFinConvertedLeads);
        }
        
        // 28Feb2022:Sarthak:End
        System.debug('CAlling ChatBot Dup');
        
    }  

    static Boolean runOnceCount = true;    
    public static void onBeforeUpdate(List<Lead> newList, Map<Id, Lead> oldMap){
        List<AssignmentRule> lstAssignmentRule = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Lead' AND Active = true LIMIT 1];
        AssignmentRule objAssignmentRule = new AssignmentRule();
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        List<String> servicableCity = new List<String>();
       // List<String> HiservicableCity = new List<String>(); // sumit added 29JUNE2023 CRM-1163
        Map<String,Integer> HiservicableCityMap = new Map<String,Integer>(); // sumit
         List<Lead> sellerHIList = new List<Lead>();//sumit
        
        Map<Id,Profile> userProfileMap = new Map<Id,Profile>([SELECT id FROM Profile where name in ('BUC and HI CRE Agent','Seller HI CRE','Seller HI Lead CRE')]);
        
        if(lstAssignmentRule.size() > 0)
        {
            objAssignmentRule = lstAssignmentRule[0];
            dmlOpts.assignmentRuleHeader.assignmentRuleId= objAssignmentRule.id;
        }
        Id lookupId = null;
        
        for(Serviceable_City__c scCustomSetting :Serviceable_City__c.getAll().values() ){
            servicableCity.add(scCustomSetting.City_Name__c.toLowerCase());
            
        }
        
        // sumit start 29JUNE2023  CRM-1163
        for(HiServiceableCity__c hCity : HiServiceableCity__c.getAll().values()) {
            HiservicableCityMap.put((String)hCity.City__c,(Integer)hCity.Count__c);
        }
        System.debug(' HiservicableCityMap :' +HiservicableCityMap); 
         
        List<Lead> changedLeads = new List<Lead>();
        Map<String,Integer> slotMap = new Map<String,Integer>();
        Set<Date> setDate = new Set<Date>();  // 05July2023 Sumit Start  CRM-1163   
        // 29June2023 Sumit Start  CRM-1163   
        
        //Girish 27-08-2023
        for(Lead lDate : newlist) {
            if(lDate.Valuator_Assigned_Visit_Date__c!=null)
            setDate.add(lDate.Valuator_Assigned_Visit_Date__c);
        }
        if(results == null && !setDate.isEmpty()) {
            results = [SELECT COUNT(Valuator_Assigned_Visit_Date__c) recordCount, Valuation_Schedule_Time_Slot__c,Seller_City__c  FROM Lead WHERE Valuator_Assigned_Visit_Date__c =: setDate AND RecordTypeId =: LeadConstants.SellerLeadRecordTypeId GROUP BY Valuation_Schedule_Time_Slot__c,Seller_City__c];
        }
        if(results!=null)
        {
        for (AggregateResult result : results) {
            string Key = result.get('Valuation_Schedule_Time_Slot__c') + '-' +  result.get('Seller_City__c');
            slotMap.put(Key,(Integer)result.get('recordCount'));
            system.debug('slotMap'+slotMap);
        }
        }
        // increasing count for the same slot for new updated records that are in trigger and not queried
        for(Lead lDate : newList){
            if(lDate.Valuation_Schedule_Time_Slot__c != null && runOnceCount) {
                System.debug('curre ' + lDate.Valuation_Schedule_Time_Slot__c);
                Integer count = 0;
                if(slotMap.containsKey(lDate.Valuation_Schedule_Time_Slot__c + '-' + lDate.Seller_City__c)) {
                    count = slotMap.get(lDate.Valuation_Schedule_Time_Slot__c + '-' + lDate.Seller_City__c);
                    count++;
                    System.debug('slotMap.get(lDate.Valuation_Schedule_Time_Slot__c) ' + slotMap.get(lDate.Valuation_Schedule_Time_Slot__c));
                }  else {
                    count = 1;
                }
                System.debug('count ' + count);
                slotMap.put(lDate.Valuation_Schedule_Time_Slot__c + '-' + lDate.Seller_City__c, count);
                runOnceCount = false;
            }
        }
        system.debug('slotMap ' + slotMap);
        for(Lead l : newList ) {
            system.debug(' slotmap_----------' +  slotmap.get(l.Valuation_Schedule_Time_Slot__c + '-' + l.Seller_City__c));
            system.debug('HiservicableCityMap ===' + HiservicableCityMap.get(l.Seller_City__c));
            if(l.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && 
               slotmap.get(l.Valuation_Schedule_Time_Slot__c + '-' + l.Seller_City__c) > HiservicableCityMap.get(l.Seller_City__c) && 
               l.Status__c == LeadConstants.LeadStatus && 
               l.HI_Serviceable__c == '1' &&
               (l.Valuation_Schedule_Time_Slot__c != oldMap.get(l.Id).Valuation_Schedule_Time_Slot__c) &&
               UserInfo.getUserId() != System.Label.Integration_User  &&
               userProfileMap.keySet().contains(UserInfo.getProfileId())
              ) 
                
            {
                System.debug('Error Occured');
                l.Valuation_Schedule_Time_Slot__c.addError((slotmap.get(l.Valuation_Schedule_Time_Slot__c + '-' + l.Seller_City__c) - 1) +' bookings already assigned for this inspection date time and slot. Please choose another slot ' );  
                
                  }
            
            // CRM-1311 :: Sumit :: Start - Assign Seller_ELV Queue based on status changes
            if(l.RecordTypeId == LeadConstants.ElvLeadRecordTypeId && l.Status__c != NULL && l.Status__c != oldMap.get(l.Id).Status__c && 
               l.Status__c == 'Whatsapp Msg Sent' && l.LeadSource == 'ELV'){
                   l.Status = LeadConstants.LEAD_STATUS_QUALIFIED;
               }
            // CRM-1313 :: STart
            if(l.RecordTypeId == LeadConstants.ElvLeadRecordTypeId && l.Status__c != NULL && l.Status__c != oldMap.get(l.Id).Status__c && 
               (l.Status__c == 'Appointment Booked' || l.Status__c == 'Still planning to buy but no vehicle finalised yet') && l.LeadSource == 'PI'){
                   l.Status = LeadConstants.LEAD_STATUS_QUALIFIED;
               }
            
             if(l.RecordTypeId == LeadConstants.ElvLeadRecordTypeId && l.Status__c != NULL && l.Status__c != oldMap.get(l.Id).Status__c && l.LeadSource == 'PI' && 
               (l.Status__c == LeadConstants.LEAD_STATUS_LOST || l.Status__c == LeadConstants.LEAD_STATUS_INVALIED_LEAD || l.Status__c == 'Duplicate Lead')){
                    l.Status = LeadConstants.LEAD_STATUS_LOST;
                   system.debug('Lead Rejected');
               }
            
            if(l.RecordTypeId == LeadConstants.ElvLeadRecordTypeId && l.Status__c != NULL && l.Status__c != oldMap.get(l.Id).Status__c && l.LeadSource == 'PI' && 
               (l.Status__c == 'Call Back' || l.Status__c == 'Not answering' || l.Status__c == 'No Response- Switch off' || l.Status__c == 'No Response- Not Reachable' ||l.Status__c == 'No Response- Call drop' ||l.Status__c == 'Language Issue')){
                   l.Status = 'Follow up';
               }
            
            // CRM-1313 :: End
            if(l.RecordTypeId == LeadConstants.ElvLeadRecordTypeId && l.Status__c != NULL && l.Status__c != oldMap.get(l.Id).Status__c && l.LeadSource == 'ELV' && 
               (l.Status__c == LeadConstants.LEAD_STATUS_LOST || l.Status__c == LeadConstants.LEAD_STATUS_INVALIED_LEAD || l.Status__c == LeadConstants.LEAD_STATUS_NOT_INTERESTED)){
                    l.Status = LeadConstants.LEAD_STATUS_LOST;
                   system.debug('Lead Rejected');
               }
            // CRM-1311 :: Sumit :: End
                        
            }
        

        // Sumit End 29June 2023  CRM-1163
        
        for(Lead lea : newList){ 
            

            // 16Mar2022:Asif:Start LeadSource mandatory
          //  if(lea.RecordTypeId == LeadConstants.buyerLeadRecordTypeId && lea.LeadSource != oldMap.get(lea.Id).LeadSource && oldMap.get(lea.Id).LeadSource != null) {
              //  if(!Test.isRunningTest()) lea.addError('LeadSource cannot be changed on update');
          //  }
            // 16Mar2022:Asif:End
            
            // 07Feb2023:Sumit:Start::CRM-1085
         //   if(lea.LeadSource != null && lea.LeadSource != oldMap.get(lea.Id).LeadSource){
         //       lea.LeadSource = oldMap.get(lea.Id).LeadSource;                
         //   }
            // 07Feb2023:Sumit:End::CRM-1085
            
            // override Lead assignment
            System.debug('OwnerId: ' + lea.OwnerId);
            if(lea.OwnerId == '0052v00000hONhxAAG') {
                lea.setOptions(dmlOpts);
            }
            
            //To check if city is in list of serviceable cities and mark the field as true
            if(lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && lea.Seller_City__c != NULL && servicableCity.contains(lea.Seller_City__c.toLowerCase()) 
               && lea.Seller_City__c != oldMap.get(lea.Id).Seller_City__c){
                   lea.Serviceable_City__c = true;
               }
            
            //To run lead assignment when hi_serviceable changes
            if(oldMap.get(lea.Id).HI_Serviceable__c != lea.HI_Serviceable__c && lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && 
               lea.HI_Serviceable__c == '1' && lea.Seller_State__c != NULL){
                   lea.setOptions(dmlOpts);
               }
            
            
            //Added by Soumya for Seller Date - 24/05/2021 --Start
            Date tempDate = System.today()+14;
            if(lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && lea.Valuator_Assigned_Visit_Date__c > tempDate){
                lea.addError('Choose the date within 2 weeks');
            }
            
            DateTime tempDT = System.now();
            Date tempDate1 = tempDT.date();
            time tempTime1 = tempDt.time();
            Time tempTime2 = Time.newInstance(12, 00, 00, 00);
            if((lea.Valuation_Schedule_Time_Slot__c != OldMap.get(lea.Id).Valuation_Schedule_Time_Slot__c || lea.Valuator_Assigned_Visit_Date__c != oldMap.get(lea.Id).Valuator_Assigned_Visit_Date__c || 
                (lea.Status__c != oldMap.get(lea.Id).Status__c && lea.Status__c == LeadConstants.LeadStatus) /* 31March2022:Asif :: Added Status change to VTA. */
               ) && tempTime2 > tempTime1 && (lea.Valuation_Schedule_Time_Slot__c == '10 AM - 12 PM' || lea.Valuation_Schedule_Time_Slot__c == '12 PM - 2 PM') &&
               lea.Valuator_Assigned_Visit_Date__c == tempDate1){
                   lea.addError('You can choose slot 2 PM - 4 PM and 4PM - 6 PM only');
               }
            else if((lea.Valuation_Schedule_Time_Slot__c != OldMap.get(lea.Id).Valuation_Schedule_Time_Slot__c || lea.Valuator_Assigned_Visit_Date__c != oldMap.get(lea.Id).Valuator_Assigned_Visit_Date__c || 
                     (lea.Status__c != oldMap.get(lea.Id).Status__c && lea.Status__c == LeadConstants.LeadStatus) /* 31March2022:Asif :: Added Status change to VTA. */
                    ) && tempTime2 < tempTime1 && lea.Valuator_Assigned_Visit_Date__c == tempDate1
                    && (lea.Valuation_Schedule_Time_Slot__c == '2 PM - 4 PM' || lea.Valuation_Schedule_Time_Slot__c == '12 PM - 2 PM' ||  lea.Valuation_Schedule_Time_Slot__c == '4 PM - 6 PM' ||
                        lea.Valuation_Schedule_Time_Slot__c == '10 AM - 12 PM')){
                            lea.addError('It cant be scheduled today');
                        }
            
            if(lea.HI_Serviceable__c == '1' && lea.Assign_Type__c != OldMap.get(lea.Id).Assign_Type__c){
                lea.addError('Assign Type cant be edited when HI Serviceable is yes');
            }
            if(lea.HI_Serviceable__c == '1' && lea.Autoinspekt__c != OldMap.get(lea.Id).Autoinspekt__c){
                lea.addError('AutoInspekt Cannot be edited when HI Serviceable is yes');
            }
            
            if(lea.Valuator_Assigned_Visit_Date__c != NULL && lea.Valuator_Assigned_Visit_Date__c != oldMap.get(lea.id).Valuator_Assigned_Visit_Date__c){
                lea.Inspect_Schedule_Date_2__c = String.valueOf(lea.Valuator_Assigned_Visit_Date__c).removeEnd(' 00:00:00');
            }
            System.debug('Inspect_Schedule_Date_2__c '+lea.Inspect_Schedule_Date_2__c);
            //End
            
            //To populate Qualified CRE field for BSE process
            if(lea.RecordTypeId == LeadConstants.BSELeadRecordTypeId && lea.Remarks__c != NULL &&
               oldMap.get(lea.Id).Status__c != lea.Status__c && lea.Status__c == 'Assign For Evaluation' && lea.Followup_Lead_Created__c == False){
                   lea.Qualified_CRE__c = UserInfo.getName();
               }
        }
    }
    
    //Added by Deepali
    public static void onAfterUpdate(Map<Id,Lead> newMap, Map<Id,Lead> oldMap, List<Lead> newList){
        List<Lead> qualifiedBuyerList = new List<Lead>();
        //Set<Id> pushLeadBuyerIdSet = new Set<Id>();
        Id currentUserId = UserInfo.getUserId();
        List<Id> listOfLeadIDs = new List<Id>();
        List<Id> listOfElvLeadIDs = new List<Id>();      
        List<Id> listOfLeadIDsToUnclock = new List<Id>();
        Set<String> servicableCity = new Set<String>();
        List<Lead> listOfLeadToCPT = new List<Lead>();
        List<lead> qualifiedsellerleads = new List<lead>();
        List<lead> qualifiedElvSellerleads = new List<lead>(); // CRM-1311
        List<lead> qualifiedPiSellerleads = new List<lead>(); // CRM-1313
        List<Id> sellerLeadIdtoLock = new List<Id>();
        List<Lead> bseQualifiedLeads = new List<Lead>();
        List<Id> bseLeadToLock = new List<Id>();
        Set<Id> r2wLeadIdsPushToLostAPI = new Set<id>();
        List<Id> finlostLeadsToLock = new List<Id>();
        List<Lead> populateStateChatbotLeads = new List<Lead>();
        List<Lead> repushLeadList = new List<Lead>();
        
        Map<String,Integer> slotMap = new Map<String,Integer>();
        
        //For fin
        List<Lead> vertChangeLeadList = new List<Lead>();
        
        //For CnB
        Set<Id> idstoLeadStatusChange = new Set<Id>();
        List<Lead> leadListToCallCnBOpp = new List<Lead>();
        List<Id> cnbIdsToLock = new List<Id>();
        Set<Id> leadCalloutifCarIdisNULL = new Set<Id>();
        List<Lead> leaList = new List<Lead>();
        List<Lead> sendLeadsToIBB = new List<Lead>();
        
        //For Seller HI
        List<Lead> sellerHIList = new List<Lead>();
        List<Lead> changedSellerHIList = new List<Lead>();
        List<Id> sellerHIListToLock = new List<Id>();
        //For Seller HI/Buyer Automated SMS trigger
        List<Lead> smsLeadList = new List<Lead>();
        List<Lead> buyerSMSLeads = new List<Lead>();
        String templateName;
        
        //For Ecom
        Set<Id> ecomLeads = new Set<Id>();
        Set<Id> bucLeads = new Set<Id>();
        Set<Id> bucLeadsPush = new Set<Id>();
        
        
        List<Lead> CreateSmsLog = new List<Lead>();
        
        // 28feb2022:Asif:Start Autofin Lead Coversion
        List<Lead> autoFinConvertedLeads = new List<Lead>();
        // 28feb2022:Asif:End
        
        
        //10Jan2022:Shivam:Start
        
        List<Lead> hiLeadArr = new List<Lead>();
        Map<Id, Lead> hiLeadMap = new Map<Id, Lead>();
        for(Lead lRec : newList)
        {
            System.debug('lRec 1: '+lRec.RecordTypeId);
            if(lRec.RecordTypeId == LeadConstants.SellerLeadRecordTypeId) {
                
                if(oldMap != null && oldMap.containsKey(lRec.Id) && (oldMap.get(lRec.Id).Status__c != lRec.Status__c || oldMap.get(lRec.Id).Seller_City__c != lRec.Seller_City__c || oldMap.get(lRec.Id).HI_Serviceable__c != lRec.HI_Serviceable__c
                   || (oldMap.get(lRec.Id).Lead_Flag__c != lRec.Lead_Flag__c && (lRec.Lead_Flag__c == 'non_ico_journey_completed_user_dropped' || lRec.Lead_Flag__c == 'ico_journey_pending_user_dropped' || lRec.Lead_Flag__c == 'ico_journey_completed')))) {  //14-APR-2023:Sachin::CRM:112: Added the condition for Lead_Flag__c
                    hiLeadMap.put(lRec.Id, oldMap.get(lRec.Id));
                    hiLeadArr.add(lRec);
                }   
                
            }
        }
        
        if(!hiLeadArr.isEmpty()) {
              ElisonLeadActivityService.init(hiLeadArr, hiLeadMap);  //14-APR-2023:Sachin::CRM:1126: Uncommented the line
        }
        
        //10Jan2022:Shivam:End
        
        
        List<Id> leadIdToUpdateOppArr = new List<Id>();  // 9Mar2022:Asif:Start :: to Update Opportunities
        List<Lead> leadToUpdateOppArr = new List<Lead>(); // 9Mar2022:Asif:Start :: to Update Opportunities
        
        List<Lead> leadOwnerUpdateArr = new List<Lead>(); // 31May2022:Asif :: to update lead owner
        
        //Added by Aravindan for ozenetel integration    
        for(Lead l : newMap.values()){
            System.debug('L.status__c' + l.Status__c);
            
            
            //For Seller HI
            if(l.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && l.Status__c == 'Valuator to be Assigned' && l.HI_Serviceable__c == '1' &&
               l.HI_Preference__c != NULL && l.Status__c != OldMap.get(l.Id).Status__c && l.Followup_Lead_Created__c == false){
                   sellerHIList.add(l);
               }
            
            if(l.RecordTypeId == LEadConstants.SellerLeadRecordTypeId && l.Status__c == 'Valuator to be Assigned' && l.Followup_Lead_Created__c == true &&
               ( l.Valuation_Schedule_Time_Slot__c != oldMap.get(l.Id).Valuation_Schedule_Time_Slot__c || l.Valuator_Assigned_Visit_Date__c != OldMAp.get(l.Id).Valuator_Assigned_Visit_Date__c ||
                l.Remarks__c != oldMap.get(l.Id).Remarks__c) ){
                    changedSellerHIList.add(l);
                }
            
            if(l.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && l.Status__c != NULL && l.Status__c != oldMap.get(l.Id).Status__c && 
               l.Status__c == 'Valuator to be Assigned' && l.HI_Serviceable__c == '1'){
                   sellerHIListToLock.add(l.Id);
               }
            // Sumit::Start::CRM-1311-Lead To be Qualified
            if(l.RecordTypeId == LeadConstants.ElvLeadRecordTypeId && l.Status__c != NULL && l.Status__c != oldMap.get(l.Id).Status__c && 
               l.Status__c == 'Whatsapp Msg Sent' && l.LeadSource == 'ELV'){
                   qualifiedElvSellerleads.add(l);
                   system.debug('------test qualified');
               }
            // CRM-1313 :: Start
            if(l.RecordTypeId == LeadConstants.ElvLeadRecordTypeId && l.Status__c != NULL && l.Status__c != oldMap.get(l.Id).Status__c && 
               (l.Status__c == 'Appointment Booked' || l.Status__c == 'Still planning to buy but no vehicle finalised yet' && l.LeadSource == 'PI') ){
                   qualifiedPiSellerleads.add(l);
                   system.debug('------test Pi qualified');
               }
            // CRM-1313 :: End
            
            
            if(l.RecordTypeId == LeadConstants.ElvLeadRecordTypeId && l.Status != NULL && l.Status != oldMap.get(l.Id).Status &&
               (l.Status == LeadConstants.LEAD_STATUS_QUALIFIED || l.Status__c == LeadConstants.LEAD_STATUS_LOST ||  (l.Status__c == 'Duplicate Lead' && l.LeadSource == 'PI')) ||  (l.Status__c == 'Invalid Lead' && l.LeadSource == 'PI') ){
                   system.debug('ELV Lock Rec');
                    listOfElvLeadIDs.add(l.Id); 
               }
             // Sumit::End::CRM-1311-Lead To be Qualified
            
            //ForCnb
            if((l.RecordTypeId == leadConstants.CnBLeadRecordTypeId || l.RecordTypeId == leadConstants.CnBBikeLeadRecordTypeId) && 
               (l.Status__c != oldMap.get(l.Id).status__c || l.FirstName != oldMap.get(l.Id).Firstname || l.Email != oldMap.get(l.Id).Email || l.LastName != oldMap.get(l.Id).LastName 
                || l.Area_City__c != oldMap.get(l.Id).Area_City__c || l.Area_PinCode__c != oldMap.get(l.Id).Area_Pincode__c || l.Phone != oldMap.get(l.Id).Phone) 
               && UserInfo.getUserId() != System.Label.Integration_User){
                   idstoLeadStatusChange.add(l.Id);
                   LeaList.add(l);
               }
            if((l.RecordTypeId == leadConstants.CnBLeadRecordTypeId || l.RecordTypeId == leadConstants.CnBBikeLeadRecordTypeId)&& l.Status__c != NULL && l.Followup_Lead_Created__c == False &&
               (l.Status__c == '1' || l.Status__c == '8' || l.Status__c == '9') && (l.Car_Lead_Id__c != NULL || l.Bike_Lead_Id__c != NULL) && l.Form_Type_Id__c != NULL){
                   leadListToCallCnBOpp.add(l);
               }
            
            if((l.RecordTypeId == leadConstants.CnBLeadRecordTypeId || l.RecordTypeId == leadConstants.CnBBikeLeadRecordTypeId) && (l.Followup_Lead_Created__c == true || l.Status == 'Lost')){
                cnbIdsToLock.add(l.Id);
            }
            
            if(l.RecordTypeId == leadConstants.financeLeadRecordTypeId && l.Lead_For__c != oldMap.get(l.Id).Lead_For__c &&
               l.Lead_For__c != NULL){
                   vertChangeLeadList.add(l);
               }
            
            /* 

//To Call method to create BSE opp
if(l.RecordTypeId == LeadConstants.BSELeadRecordTypeId && l.Remarks__c != NULL &&
oldMap.get(l.Id).Status__c != l.Status__c && l.Status__c == 'Assign For Evaluation' && l.Followup_Lead_Created__c == False){
bseQualifiedLeads.add(l);
}

//To lock qualified BSE Leads
if(l.RecordTypeId == LeadConstants.BSELeadRecordTypeId && l.Followup_Lead_Created__c == TRUE && l.Status__c == 'Assign For Evaluation'){
bseLeadToLock.add(l.Id);
}
*/
            
            // 28Feb2022:Asif:Start Autofin Lead Conversion
            if(l.recordTypeId == LeadConstants.AutofinRecordtyeId && l.Status__c == LeadConstants.StatusInProcess) {
                autoFinConvertedLeads.add(l);
            }
            // 28Feb2022:Asif:End
            
        }
        
        for(Serviceable_City__c scCustomSetting :Serviceable_City__c.getAll().values() ){
            servicableCity.add(scCustomSetting.City_Name__c.toLowerCase());
        }
        
        for(Lead lea : newMap.values()){          
            if(lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && lea.Status__c != NULL  && oldMap.get(lea.Id).status__c != lea.status__c && lea.Status__c == LeadConstants.LeadStatus && lea.Seller_City__c  != null && 
               servicableCity.contains(lea.Seller_City__c.toLowerCase()) && lea.HI_Serviceable__c == '0'){
                   listOfLeadToCPT.add(lea);   
               }
            //To filter qualified Seller leads
            if(lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && lea.Status__c != NULL  && oldMap.get(lea.Id).status__c != lea.status__c && 
               (lea.Status__c == LeadConstants.LeadStatus || lea.status__c == 'Evaluated' || lea.Status__c == 'Assigned') && lea.Followup_Lead_Created__c == false && lea.HI_Serviceable__c == '0'){
                   qualifiedsellerleads.add(lea);
               }
            
            //To take ids so as to lock record
            if(lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && lea.Status__c != NULL  && oldMap.get(lea.Id).status__c != lea.status__c 
               && (lea.Status__c == LeadConstants.LeadStatus || lea.Status__c == LeadConstants.Lead_Status_del || lea.Status__c == LeadConstants.Lead_Status_Evaluated 
                   || lea.Status__c == LeadConstants.Lead_Status_Assigned || lea.Status__c == 'Lost') && lea.HI_Serviceable__c == '0')
            {
                sellerLeadIdtoLock.add(lea.Id);    
            }
            
            //For Seller HI automated SMS triggering
            if(lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && lea.HI_Serviceable__c == '1'){
                if(lea.HI_Preference__c == 'Home' && lea.Status__c == 'Valuator to be Assigned' && lea.Status__c != oldMap.get(lea.Id).Status__c){
                    smsLeadList.add(lea);
                    templateName = 'SELL_VTBA_Home';
                }
                else if(lea.HI_Preference__c == 'Store' && lea.Status__c == 'Valuator to be Assigned' && lea.Status__c != oldMap.get(lea.Id).Status__c){
                    smsLeadList.add(lea);
                    templateName = 'SELL_VTBA_Store';
                }
                else if((lea.Status__c == 'Lost' || lea.Status__c == 'Already Evaluated' || lea.Status__c == 'Location Not Serviceable' || lea.Status__c == 'Language Issue') 
                        && lea.Status__c != oldMap.get(lea.Id).Status__c){
                            smsLeadList.add(lea);
                            templateName = 'SELL_Status_Lost';
                        }
                else if(lea.Status__c == 'Follow up' && lea.Status__c != oldMap.get(lea.Id).Status__c){
                    smsLeadList.add(lea);
                    templateName = 'SELL_Status_Followup';
                }
                else if((lea.Status__c == 'Switched Off/Not Reachable' || lea.Status__c == 'No Response') && lea.Status__c != oldMap.get(lea.Id).Status__c ){
                    smsLeadList.add(lea);
                    templateName = 'SELL_Status_Noresponse';
                }
            }
            
            //to Call Ecom CnB and LMS when status is changed.
            if(lea.RecordTypeId == LeadConstants.buyerLeadRecordTypeId && lea.Status__c != oldMap.get(lea.id).Status__c && 
               lea.Status__c != NULL && lea.Lead_Flag__c == 'Reserve'){
                   ecomLeads.add(lea.Id);
               }
            if(lea.RecordTypeId == LeadConstants.buyerLeadRecordTypeId && lea.Status__c != oldMap.get(lea.id).Status__c && 
               lea.Status__c != NULL){
                   //  bucLeads.add(lea.Id); // sumit
               }
            if(lea.RecordTypeId == LeadConstants.buyerLeadRecordTypeId && lea.Customer_Id__c == Null){
                bucLeadsPush.add(lea.Id);
                system.debug('bucLeadsPush'+bucLeadsPush);
            }
            
            
            
            //added by Deepali
            //to filter out qualified Buyer Leads
            if(lea.RecordTypeId == LeadConstants.buyerLeadRecordTypeId && lea.Status != NULL 
               && lea.Status != oldMap.get(lea.Id).Status && lea.Status == LeadConstants.leadStatus_Qualified){
                   qualifiedBuyerList.add(lea);
               }
            /*  if(lea.RecordTypeId == LeadConstants.buyerLeadRecordTypeId && lea.Status__c != NULL 
&& lea.Status__c != oldMap.get(lea.Id).Status__c && currentUserId != System.label.Integration_User){
pushLeadBuyerIdSet.add(lea.Id);
} */ //Commented by Soumya 17/09/2020
            
            if(lea.recordTypeId == LeadConstants.buyerLeadRecordTypeId 
               && lea.status != null && (lea.status == LeadConstants.LEAD_STATUS_DEALER_STOCK_ASSIGNED 
                                         || lea.status == LeadConstants.LEAD_STATUS_QUALIFIED) 
               && oldMap.get(lea.Id).status != lea.status){
                   
                   listOfLeadIDs.add(lea.Id);   
               }
            if(lea.recordTypeId == LeadConstants.buyerLeadRecordTypeId  
               && oldMap.get(lea.Id).status != null && oldMap.get(lea.Id).status != lea.status && (lea.status == LeadConstants.LEAD_STATUS_DEALER_STOCK_ASSIGNED 
                                                                                                   || lea.status == LeadConstants.LEAD_STATUS_QUALIFIED) ){
                                                                                                       
                                                                                                       listOfLeadIDsToUnclock.add(lea.Id);   
                                                                                                   }
            
            if((lea.Area_City__c != NULL || lea.Seller_City__c != NULL) && (lea.LeadSource == 'MFC-Chat' || lea.LeadSource == 'CnB-Chat')){
                populateStateChatbotLeads.add(lea);
            }
            
            // 9Mar2022:Asif:Start :: to Update Opportunities
            if(lea.recordTypeId == LeadConstants.buyerLeadRecordTypeId && lea.Sub_Status__c != oldMap.get(lea.Id).Sub_Status__c) {
                leadToUpdateOppArr.add(lea);
                leadIdToUpdateOppArr.add(lea.Id);
            }
            // 9Mar2022:Asif:End
            
            // 16June2022:Ankit:Start :: Ticket 870-chatbot issue
            if(lea.recordTypeId == LeadConstants.buyerLeadRecordTypeId && lea.LeadSource != 'MFC-Chat') {
                leadOwnerUpdateArr.add(lea);
            }
            // 16June2022:Ankit:End
        } 
        if(!listOfLeadIDsToUnclock.isEmpty()){
            System.debug('Unlock');
            UtilityClass.unlockRecords(listOfLeadIDsToUnclock);
        }
        System.debug('listOfLeadIDs'+listOfLeadIDs);
        if(!listOfLeadIDs.isEmpty()){
            System.debug('lock');
            UtilityClass.lockRecords(listOfLeadIDs);
        }
        //Added by Deepali
        System.debug('qualifiedBuyerList'+qualifiedBuyerList);
        if(!qualifiedBuyerList.isEmpty()){
            //LeadTriggerHelper.createOpportunityOnLeadConvert(qualifiedBuyerList);
            //commented by Kunal
        }
        
        system.debug('listOfLeadToCPT'+listOfLeadToCPT);
        if(!listOfLeadToCPT.isEmpty()){
            LeadTriggerHelper.sendLeadDataToCPT(listOfLeadToCPT);
        }
        
        system.debug('qualifiedsellerleads'+qualifiedsellerleads);
        if(!qualifiedsellerleads.isEmpty()){
            LeadTriggerHelper.createSellerOpportunity(qualifiedsellerleads);
        }
        
        //To call the method that locks the Record matching criteria
        if(!sellerLeadIdtoLock.isEmpty()){
            system.debug('Lock'+sellerLeadIdtoLock);
            UtilityClass.lockRecords(sellerLeadIdtoLock);
        }
        
        //Call bse opp method
        if(!bseQualifiedLeads.isEmpty()){
            LeadTriggerHelper.createBSEOppotunity(bseQualifiedLeads);
        }
        
        //To lock bse qualified leads
        if(!bseLeadToLock.isEmpty()){
            UtilityClass.lockRecords(bseLeadToLock);
        }
        
        //for Cnb
        System.debug('idstoLeadStatusChange '+idstoLeadStatusChange);
        system.debug('leadListToCallCnBOpp'+leadListToCallCnBOpp);
        if(!idstoLeadStatusChange.isEmpty()){
            LeadTriggerHelper.callLeadStatusChange(idstoLeadStatusChange);
        }
        if(!leadListToCallCnBOpp.isEmpty()){
            LeadTriggerHelper.cnbLeadOpportunity(leadListToCallCnBOpp);
        }
        System.debug('Cnb Lea Lis'+leaList);
        if(!leaList.isEmpty()){
            LeadTriggerHelper.updateAccNameAndSubLeads(leaList);
        }
        if(!cnbIdsToLock.isEmpty()){
            UtilityClass.lockRecords(cnbIdsToLock);
        }
        
        
        //For Seller HI
        if(!sellerHIList.isEmpty()){
            LeadTriggerHelper.createSellerOpportunity(sellerHIList);
           if(LeadPushCPT.apiFired){
               LeadPushCPT.setDataforHICallout(sellerHIList);
           }
        }
        // Creating Opportunity :: CRM-1311
        if(!qualifiedElvSellerleads.isEmpty()){
            
            if(CheckRecursiveTrigger.RunOnces()) {
                System.debug('Aleardy Created');
               // return;
            }
            
            system.debug('------test opp creation');
            LeadTriggerHelper.createElvOpportunity(qualifiedElvSellerleads);
        }
        // CRM-1313 :: Start
        if(!qualifiedPiSellerleads.isEmpty()){     
            system.debug('------test PI opp creation');
            LeadTriggerHelper.createElvOpportunity(qualifiedPiSellerleads);
        }
        // CRM-1313 :: End
        if(!listOfElvLeadIDs.isEmpty()){
            System.debug('lock ELv');
            UtilityClass.lockRecords(listOfElvLeadIDs);
        }        
        // CRM-1311 :: End
        
        
        if(!changedSellerHIList.isEmpty()){
            LeadPushCPT.setDataforHICallout(changedSellerHIList);
        }
        
        if(!sellerHIListToLock.isEmpty()){
            UtilityClass.lockRecords(sellerHIListToLock);
        }
        
        //For Seller HI SMS
        System.debug('smsLeadList '+smsLeadList);
        if(!smsLeadList.isEmpty()){
            LeadTriggerHelper.sendSMSToUser(templateName, smsLeadList);
        }
        
        //Added on 13/07/2021 to call LMS and Eccom
        if(!ecomLeads.isEmpty()){
            System.debug('__making LMS Callout from LeadTriggerHandler.onAfterUpdate pushSingleLeadsToLMS ecomLeads');
            LeadtriggerHelper.pushSingleLeadsToLMS(ecomLeads);
           // LeadTriggerHelper.callEcomCallout(ecomLeads); // Sumit::CRM-1078-Disable CNB callouts from Lead for reserve lead status updates
        }
        
        // 28Feb2022:Asif:Start AutoFin Lead Conversion
        if(!autoFinConvertedLeads.isEmpty()) {
            LeadTriggerhelper.onAfterConverted(autoFinConvertedLeads);
        }
        // 28Feb2022:Sarthak:End  
        
        // 9March2022:Asif:Start
        if(!leadToUpdateOppArr.isEmpty()) {
            LeadTriggerhelper.updateOppFromLead(leadIdToUpdateOppArr, leadToUpdateOppArr);
        }
        // 9March2022:Asif:End
        
        // 31May2022:Asif:Start
        if(!leadOwnerUpdateArr.isEmpty()) {
            LeadTriggerhelper.updateOwner(leadOwnerUpdateArr);
        }
        // 31May2022:Asif:End
    }  
}