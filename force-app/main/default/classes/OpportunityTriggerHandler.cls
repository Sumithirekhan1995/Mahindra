public class OpportunityTriggerHandler {
    /*CRM-1106 Pankaj Kumar 23-03-2023 Start*/
    public static Map<Id,Account> dealerMap = new Map<Id,Account>();
    /*CRM-1106 Pankaj Kumar 23-03-2023 End*/
    
    // 22nov2022:Shubham:Start
    public static void beforeinsert(list<Opportunity>newList){
        List<Opportunity> oppWithoutLead = new List<Opportunity>();
        map<String, Opportunity> OpportunityDBMap = new map<String, Opportunity>();
        List<Id> leadIdArr = new List<Id>(); // for LeadId list
 
        set<Id> listofOpp = new set<Id>();
        for(Opportunity opp : newList){
            if(opp.Opportunity_Owner__c == Null){
               opp.Opportunity_Owner__c = opp.OwnerId; // CRM-1147
            } 
            system.debug('opp ' + opp);
            //to filter out Buyer Leads with Phone number and without Account
            if(opp.Lead__c == NULL){
                oppWithoutLead.add(opp);
                system.debug('oppWithoutLead ' + oppWithoutLead);
            } else {
                leadIdArr.add(opp.Lead__c); // collecting LeadIds
                system.debug('leadIdArr ' + leadIdArr);
            }
            
        }
                
        // 22Nov2022:Shubham:Start ::show error message  
        Map<String, String> leadMap = new Map<String, String>();
        for(lead lRec : [SELECT Id,customer__c FROM lead WHERE Id IN :leadIdArr]) {
            leadMap.put(lrec.Id,lRec.customer__c);          
        }   
        for(Opportunity oRec : [SELECT Lead__c, Dealer__c, Product__c,Dealer__r.name,lead__r.Id,Product__r.name FROM Opportunity WHERE Lead__c IN :leadIdArr]) {
            OpportunityDBMap.put(oRec.Lead__c + '-' + oRec.Dealer__c + '-' + oRec.Product__c,oRec);
            system.debug('oRec ' + oRec);
        }
        
        for(Opportunity opp : newList){
            String leadStockDealerStr = opp.Lead__c + '-' + opp.Dealer__c + '-' + opp.Product__c;
            if(!OpportunityDBMap.containsKey(leadStockDealerStr)) { //not contains
                OpportunityDBMap.put(leadStockDealerStr, opp);
                system.debug('leadStockDealerStr ' + leadStockDealerStr);
            } else {
                Opportunity oldOpp = OpportunityDBMap.get(leadStockDealerStr);
               // string DealerName = oldOpp.Dealer__r.name; // CRM-1145
                String ProductName = oldOpp.Product__r.name;
                // 05 May  2023:Sumit:Start :: Remove duplicate error on non stock opportunity creation(CRM-1145) 
              /* if(DealerName != null){
                    opp.addError('Enquiry for Dealer :' + DealerName + ' already exists' );
                } */
                // 05 May  2023:Sumit:End :: Remove duplicate error on non stock opportunity creation(CRM-1145) 
                if(ProductName != null){
                    opp.addError('Enquiry For Stock :' + ProductName + ' already exists' );
                }
            }
            
            if(leadMap.containsKey(opp.Lead__c)) {
                opp.AccountId = leadMap.get(opp.Lead__c);
            }
        }
        
    }
    
    // 22nov2022:Shubham:End
    public static void onAfterInsert(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        
        System.debug('OppTriggerHandler.onAfterInsert');
        Set<Id> LmsOppPush = new Set<Id>();
        Set<Id> LmsleadPush = new Set<Id>();
        
        /*CRM-1105 Pankaj Kumar 16-03-2023 Start*/
        Map<Id, Opportunity> oppWhatsapMsgMap = new Map<Id, Opportunity>();        
        /*CRM-1105 Pankaj Kumar 16-03-2023 End*/
        
        /*CRM-1111 Pankaj Kumar 29-03-2023 Start*/
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> oppId = new Set<Id>(); // CRM-1147   
        Set<Id> leasIdSet = new Set<Id>(); // CRM-1147 
        Set<Id> dealerIdSet = new Set<Id>(); // CRM-1147
        Map<String, String> OwnerTypeMaps = new Map<String, String>(); // CRM-1147  
        Map<Id, Id> oppOwnerUpdateDealerIdList = new Map<Id, Id>(); // CRM-1147   
        Set<Id> DealerCodeSet = new Set<Id>(); // CRM-1147  
        Map<Id, Opportunity> oppWalkInWhatsapMsgMap = new Map<Id, Opportunity>();    
        Map<Id, list<Opportunity>> ListOfRelatedOpp = new Map<Id, list<Opportunity>>(); // CRM-1147 
        /*CRM-1111 Pankaj Kumar 29-03-2023 End*/
        
        //Shivam Start
        List<Opportunity> bucOppArr = new List<Opportunity>();
        Map<Id, Opportunity> bucOppoldMap = new Map<Id, Opportunity>();
        
        /*CRM-1111 Pankaj Kumar 29-03-2023 Start*/
        for(Opportunity oRec : newList) {
            accountIdSet.add(oRec.Dealer__c);
        }
        if(!accountIdSet.isEmpty()){
            dealerMap = new Map<Id,Account>([SELECT id, BillingCity FROM Account WHERE id in :accountIdSet]);
        }
        /*CRM-1111 Pankaj Kumar 29-03-2023 End*/
        
       //26Oct2023::Amulya Start ::CRM-1200        
        list<Id> OppLst = new List<Id>();
        Set<String> daelerSet = new Set<String>();
        Set<String> PhoneSet = new Set<String>();
        Set<String> BuyerRecordTypeSet = new Set<String>();
        set<String> leadIdSet = new set<String>();
        for(Opportunity oRec : newList) {  
            daelerSet.add(oRec.Dealer_Code_for_opp__c);
                PhoneSet.add(oRec.Customer_Phone__c);
                BuyerRecordTypeSet.add(oRec.RecordTypeName__c);
                leadIdSet.add(oRec.Lead__c);
                }
        integer count = 0;  
        
        for(Opportunity oRecs : [ Select Id,RecordTypeName__c,Customer_Phone__c,CreatedDate, lead__r.phone, Lead__r.DealerCode__c, lead__r.recordtypename__c from opportunity where Lead__c IN :leadIdSet AND Dealer_Code_for_opp__c IN :daelerSet AND lead__r.recordtypename__c IN: BuyerRecordTypeSet AND Lead__r.Phone IN :PhoneSet AND CreatedDate = THIS_MONTH]) {  
            count++;
            system.debug('oRecs:-------'+oRecs);
            if(count == 1) { 
                
                continue;
            }
            
            OppLst.add(oRecs.Id);
        }
        
        list<Opportunity> updatelst = new List<Opportunity>();
        if( OppLst.size() > 0 ){
            
            for(Id EtrateLst: OppLst){
                Opportunity o = new Opportunity();
                o.Id = EtrateLst;
                o.Duplicate_Lead__c = true;
                updatelst.add(o);
            }
             system.debug('updatelst:-------'+updatelst);
           // database.update(updatelst,false);
           OpportunityTriggerHelper.updateOpportunity(updatelst);
        }
        
      //26Oct2023::Amulya End::CRM-1200
        
        for(Opportunity oRec : newList) {   
            //19May2023:Sumit:Start:CRM-1147
            if(oRec.Opportunity_Owner__c != Null){
                OppId.add(oRec.Id);
                system.debug('OppId :----'+OppId);
            }
            if(oRec.Lead__c != Null){
                leasIdSet.add(oRec.Lead__c);
            }
            if(oRec.Dealer__c != Null){
                dealerIdSet.add(oRec.Dealer__c);
            }
            //19May2023:Sumit:End
            
            if(oRec.RecordTypeId == OpportunityConstants.buyerOppRecordTypeId) {
                bucOppArr.add(oRec);
                
                /*CRM-1105 Pankaj Kumar 16-03-2023 Start*/
                if((!String.isEmpty(oRec.Lead_Flag__c)) && oRec.Lead_Flag__c == OpportunityConstants.Lead_Flag_Getseller && oRec.Stock_Id__c != null && oRec.WhatsApp_Consent__c == 'yes'){
                    oppWhatsapMsgMap.put(oRec.Id, oRec);                    
                }
                /*CRM-1105 Pankaj Kumar 16-03-2023 End*/
                
                /*CRM-1111 Pankaj Kumar 29-03-2023 Start*/
                if(oRec.Lead_Category__c != null && oRec.Lead_Category__c.equalsIgnoreCase('Walk in register') && oRec.WhatsApp_Consent__c == 'yes'){
                    oppWalkInWhatsapMsgMap.put(oRec.Id, oRec);                    
                }
                /*CRM-1111 Pankaj Kumar 29-03-2023 End*/
                
                if(oldMap != null && oldMap.containsKey(oRec.Id)) {
                    bucOppoldMap.put(oRec.Id, oldMap.get(oRec.Id));
                }   
                
                //to Call Ecom CnB and LMS when status is changed.
                System.debug('__Line 82 ' + oRec.LMS_Opp_Id__c);
                if(oRec.RecordTypeId == OpportunityConstants.buyerOppRecordTypeId && oRec.LMS_Opp_Id__c == NULL ){
                    LmsOppPush.add(oRec.Id);
                }
            }
        }
        
        //19May2023:Sumit:Start:CRM-1147
        if(!OppId.isEmpty()) {
            for(Opportunity o : [SELECT Id,Opportunity_Owner__r.MFC_User_Type__c FROM Opportunity where Id=: OppId]) {
                if(o.Opportunity_Owner__r.MFC_User_Type__c == 'Sales')
                    OwnerTypeMaps.put(o.Id, o.Opportunity_Owner__r.MFC_User_Type__c);
            }
        }
  
        for(Opportunity op : newList) {
            if(OwnerTypeMaps.containsKey(op.Id)) {
                oppOwnerUpdateDealerIdList.put(op.Lead__c, op.Opportunity_Owner__c);
                DealerCodeSet.add(op.Dealer__c);
            }
        }
        
        if(!oppOwnerUpdateDealerIdList.isEmpty()) {
            system.debug('Calling OpportunityTriggerHelper Class ');
            OpportunityTriggerHelper.ownerInsertOnOpportunity(oppOwnerUpdateDealerIdList,DealerCodeSet);
        }
        //30May2023:Sumit:Start:CRM-1147: Exception Handle
        for(Opportunity recOpportunity : [select Id,Opportunity_Owner__c,Lead__c,Opportunity_Owner__r.MFC_User_Type__c from Opportunity where  Lead__c  IN :leasIdSet AND Dealer__c IN :dealerIdSet ]) {
            system.debug('I am inside Dealer ');
            if(ListOfRelatedOpp.containsKey(recOpportunity.Lead__c)) {
                system.debug('I am inside containsKey ');
                ListOfRelatedOpp.get(recOpportunity.Lead__c).add(recOpportunity);
            } else {
                system.debug('I am inside else containsKey ');
                ListOfRelatedOpp.put(recOpportunity.Lead__c, new List<opportunity>{recOpportunity});
            }  
        }  
        list<Id> listOfOpportunity = new list<Id>();
        list<Opportunity> oppList = new list<Opportunity>();
        for(String leadId : ListOfRelatedOpp.keySet()) {
            integer OwnerSalesCount = 0;
            integer OwnerDealerCount = 0;
            String dealerOwner, salesOwner;
            for(Opportunity opp : ListOfRelatedOpp.get(leadId)) {
                if(opp.Opportunity_Owner__r.MFC_User_Type__c == 'dealer' || opp.Opportunity_Owner__r.MFC_User_Type__c == null) {
                    OwnerDealerCount++;
                    dealerOwner = opp.Opportunity_Owner__c;
                }
                if(opp.Opportunity_Owner__r.MFC_User_Type__c == 'sales' || opp.Opportunity_Owner__r.MFC_User_Type__c == null) {
                    OwnerSalesCount++;
                    salesOwner = opp.Opportunity_Owner__c;
                }
            }
            system.debug('OwnerSalesCount :---'+OwnerSalesCount);
            system.debug('OwnerDealerCount :---'+OwnerDealerCount);
            if(OwnerSalesCount >= OwnerDealerCount) {
                system.debug('sales is greater than dealer');
                for(Opportunity opp : ListOfRelatedOpp.get(leadId)) {
                    if(opp.Opportunity_Owner__c != salesOwner) {
                        oppList.add(new Opportunity(
                            Id = opp.Id,
                            Opportunity_Owner__c = salesOwner
                        ));
                    }
                }
            } 
            else if(OwnerSalesCount <= 0){
                for(Opportunity opp : ListOfRelatedOpp.get(leadId)) {
                    if(opp.Opportunity_Owner__c != dealerOwner) {
                        oppList.add(new Opportunity(
                            Id = opp.Id,
                            Opportunity_Owner__c = dealerOwner
                        ));
                    }
                }
            }                
        }
        if(!oppList.isEmpty()) {
            System.debug('oppList ' + oppList);
            OpportunityTriggerHelper.ownerChangeException(oppList);
        } 
        //19May2023:Sumit:End:CRM-1147 
        
        if(!bucOppArr.isEmpty()) {
            ElisionOppActivityService.init(bucOppArr, bucOppoldMap);
        }
        //Shivam End

        /*CRM-1105 Pankaj Kumar 16-03-2023 Start*/
        if(!oppWhatsapMsgMap.isEmpty()){
            OpportunityTriggerHelper.createWhatsappMsgTask(oppWhatsapMsgMap, 'FB_Message_6646737', null);
        }
        /*CRM-1105 Pankaj Kumar 16-03-2023 End*/
        /*CRM-1111 Pankaj Kumar 16-03-2023 Start*/
        if(!oppWalkInWhatsapMsgMap.isEmpty()){
            OpportunityTriggerHelper.createWhatsappMsgTask(oppWalkInWhatsapMsgMap, 'WalkinRegister_6567878', dealerMap);
        }
        /*CRM-1111 Pankaj Kumar 16-03-2023 End*/
        
        if(!LmsOppPush.isEmpty()){
            //oppIdPushLMSOnInsert = new List<Id>(LmsOppPush);
            system.debug('LmsOppPush'+LmsOppPush);
            system.debug('Make Opportunity insert Lms Callout though UI ');
            OpportunityTriggerHelper.pushSingleOppToLMS(LmsOppPush);
        }
        /*CRM-1139 Pankaj Kumar 24-04-2023 Start*/
        OpportunityTriggerHelper.updateRelatedLeadRec(oldMap,newList,false);
        /*CRM-1139 Pankaj Kumar 24-04-2023 End*/
    }
    
    public static void beforeUpdate(Map<Id,Opportunity> listOfOpp, Map<Id,Opportunity> oldMap){
        System.debug('OpportunityTriggerHandler.beforeUpdate ::');
        List<Id> unlockOpp = new List<Id>();
        String profileName;
        // 05Aug2022:Ankit:Start ::CRM-897-m2all status and m2all followup comments field should only show what is changed by m2all CRE profile and Buyer lead CRE profile  
        List<Profile> ProfileList = [Select Id, Name from Profile where Id=:userinfo.getProfileId() limit 1];   
        // added by Mishal as a part of 995
        if(!ProfileList.isEmpty()) {
            system.debug('ProfileSet EMPTY'+ProfileList);
            profileName = ProfileList[0].name;
        }   
        // 05Aug2022:Ankit:End ::CRM-897-m2all status and m2all followup comments field should only show what is changed by m2all CRE profile and Buyer lead CRE profile
        for(Opportunity opp : listOfOpp.values()) {           
            if(opp.status__c != null && opp.status__c != oldMap.get(opp.Id).Status__c && UserInfo.getUserId() != System.label.Integration_User){
                opp.Status_Updated_By__c = UserInfo.getName();
                
            }
            
            if(!opp.Warranty_Edit__c){
                opp.Warranty_Edit__c = false;
            }
            
            Date tempDate = System.today()+14;
            if(opp.RecordTypeId == OpportunityConstants.sellerCarRecordTypeID  && opp.Valuator_Assigned_Visit_Date__c > tempDate){
                opp.addError('Choose the date within 2 weeks');
            }
            date dt=date.today();
            
            DateTime tempDT = System.now();
            time tempTime1 = tempDt.time();
            Time tempTime2 = Time.newInstance(12, 00, 00, 00);
            if(opp.Valuation_Schedule_Time_Slot__c != OldMap.get(opp.Id).Valuation_Schedule_Time_Slot__c && tempTime2 > tempTime1  && opp.Valuator_Assigned_Visit_Date__c <=dt &&
               (opp.Valuation_Schedule_Time_Slot__c == '10 AM - 12 PM' || opp.Valuation_Schedule_Time_Slot__c == '12 PM - 2 PM')){
                   opp.addError('You can choose slot 2 PM - 4 PM and 4PM - 6 PM only');
               }
            else if(opp.Valuation_Schedule_Time_Slot__c != OldMap.get(opp.Id).Valuation_Schedule_Time_Slot__c && tempTime2 < tempTime1 && opp.Valuator_Assigned_Visit_Date__c <=dt &&
                    (opp.Valuation_Schedule_Time_Slot__c == '2 PM - 4 PM' || opp.Valuation_Schedule_Time_Slot__c == '12 PM - 2 PM' ||  opp.Valuation_Schedule_Time_Slot__c == '4 PM - 6 PM')){
                        opp.addError('It cant be scheduled today');
                    }
            
            // 14Dec2021:Sarthak:Start ::Adding new validation for Status__c : Rescheduled
            if(opp.RecordTypeId == OpportunityConstants.sellerCarRecordTypeID 
               && opp.HI_Serviceable__c == '1' 
               && (opp.Valuation_Schedule_Time_Slot__c != oldMap.get(opp.Id).Valuation_Schedule_Time_Slot__c 
                   || opp.Valuator_Assigned_Visit_Date__c != oldMap.get(opp.Id).Valuator_Assigned_Visit_Date__c 
                   || opp.Remarks__c != OldMap.get(opp.Id).Remarks__c 
                   || opp.HI_Preference__c != OldMap.get(opp.Id).HI_Preference__c 
                   || opp.Address__c != oldMap.get(opp.Id).Address__c 
                   || opp.Area_Pincode__c != oldMap.get(opp.Id).Area_Pincode__c 
                  )
              ) {
                  if((oldMap.get(opp.Id).Status__c != OpportunityConstants.Status_ValuatorToBeAssigned && oldMap.get(opp.Id).Status__c != OpportunityConstants.Status_Assigned )
                     && opp.Status__c == OpportunityConstants.Status_Rescheduled
                    )  {
                        opp.addError('Valuation Schedule Time Slot, Valuation Assigned DateTime, Remarks, HI Preference, Address, Pincode cannot be changed when OldStatus is Valuator to be assigned/Assigned and NewStatus not Rescheduled');
                        continue;
                    } else  {
                        continue;
                    }
                  if(opp.Status__c != OpportunityConstants.Status_ValuatorToBeAssigned) {
                      opp.addError('Valuation Schedule Time Slot, Valuation Assigned DateTime, Remarks, HI Preference, Address, Pincode cannot be changed when status is not Valuator to be assigned');
                  }
              }
            // 14Dec2021:Sarthak:End 

            // 7Jun2022:Asif:Start :: saving status, followUp Comments values if not from API
            if(!OpportunityConstants.isFromAPI && !(System.isBatch() || System.isFuture()) && (profileName == 'Superstore M2All CRE' || profileName == 'Buyer Lead CRE Agents' || profileName == 'Buyer Team Lead')) { // 05Aug2022:Ankit::CRM-897-m2all status and m2all followup comments field should only show what is changed by m2all CRE profile and Buyer lead CRE profile
                System.debug('__assigning m2all fields');
                opp.M2All_Status__c = opp.status__c;
                opp.M2All_Followup_Comment__c = opp.Followup_Comments__c;
            }
            // 7Jun2022:Asif:End
        }
        if(unlockOpp.size() > 0){
            UtilityClass.unLockRecords(unlockOpp);
        }
        
    }
    
    public static void afterUpdate(Map<Id,Opportunity> listOfOpp, Map<Id,Opportunity> oldMap, List<Opportunity> newList){
        System.debug('OpportunityTriggerHandler.afterUpdate ::');
        
        List<Id> listOfOppIdsToLock = new List<Id>();
        List<Id> listOfOppIdsToUnLock = new List<Id>();
        List<Id> sellerOppIdstoLock = new List<Id>();
        List<Id> listOfVerifiedOppsToLock = new List<Id>();
        List<Opportunity> oppToSendSMS = new List<Opportunity>();  
        List<Opportunity> oppToSendSMS2 = new List<Opportunity>(); 
        
        //28Jan2022:Asif:Start :: trigger SMS on Rescheduled
        List<Opportunity> oppMap_ForSMS_Rescheduled_Home = new List<Opportunity>();
        List<Opportunity> oppMap_ForSMS_Rescheduled_Store = new List<Opportunity>();
        //28Jan2022:Asif:End
        
        List<Id> lockOpps = new List<Id>();
        List<Id> cnbIdsToLock = new List<Id>();
        List<Id> buyerSoldRecToLock = new List<Id>();
        Set<Id> LmsOpp = new Set<Id>();
        Set<Id> oppToBeSend = new Set<Id> (); 
        Set<Id> oppSend = new Set<Id> (); 

        //Shivam Start
        List<Opportunity> bucOppArr = new List<Opportunity>();
        Map<Id, Opportunity> bucOppoldMap = new Map<Id, Opportunity>();
        
        /*CRM-1107 Pankaj Kumar 16-03-2023 Start*/
        Map<Id, Opportunity> createTaskForBUCMap = new Map<Id, Opportunity>();
        /*CRM-1107 Pankaj Kumar 16-03-2023 End*/
        
        /*CRM-1106 Pankaj Kumar 23-03-2023 Start*/
        Map<Id, Opportunity> createVisitRescheduledTask = new Map<Id, Opportunity>();
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Profile> userProfileMap = new Map<Id,Profile>([SELECT id FROM Profile where name in ('Superstore Dealer CRE','Buyer Lead CRE Agents')]);        
        /*CRM-1106 Pankaj Kumar 23-03-2023 End*/
        
        /*CRM-1110 Pankaj Kumar 23-03-2023 Start*/
        Map<Id, Opportunity> testDriveTask = new Map<Id, Opportunity>();      
        /*CRM-1110 Pankaj Kumar 23-03-2023 End*/
        
        /*CRM-1124 Pankaj Kumar 23-03-2023 Start*/
        Map<Id, Opportunity> soldMsgTask = new Map<Id, Opportunity>();      
        /*CRM-1124 Pankaj Kumar 23-03-2023 End*/
        Map<String, String> OwnerTypeMap = new Map<String, String>(); //CRM-1147
        Map<Id, Id> oppOwnerUpdateDealerIdList = new Map<Id, Id>(); //CRM-1147
        Map<Id, Id> OwnerUpdateLst = new Map<Id, Id>(); //CRM-1147
        Set<Id> OppId = new Set<Id>(); //CRM-1147
        Set<String> DealerCodeSet = new Set<String>(); //CRM-1147
        for(Opportunity oRec : newList) {
            //18May2023:Sumit:Start:CRM-1147
              if(oldMap.get(oRec.Id).Opportunity_Owner__c != oRec.Opportunity_Owner__c ) {
                     OppId.add(oRec.Id); 
                } 
            //18May2023:Sumit:End  
            /*CRM-1106 Pankaj Kumar 23-03-2023 Start*/
            accountIdSet.add(oRec.Dealer__c);
            /*CRM-1106 Pankaj Kumar 23-03-2023 End*/
            if(oRec.RecordTypeId == OpportunityConstants.buyerOppRecordTypeId) {
                if(oldMap != null && oldMap.containsKey(oRec.Id) && (oldMap.get(oRec.Id).status__c != oRec.status__c || oldMap.get(oRec.Id).Lead_Flag__c != oRec.Lead_Flag__c) ) {
                    bucOppArr.add(oRec);
                    bucOppoldMap.put(oRec.Id, oldMap.get(oRec.Id));
                } 
            }   
        } 
        //18May2023:Sumit:Start:CRM-1147
        if(!OppId.isEmpty()) {
            for(Opportunity o : [SELECT Id,Opportunity_Owner__r.MFC_User_Type__c FROM Opportunity where Id=: OppId]) {
                if(o.Opportunity_Owner__r.MFC_User_Type__c == 'Sales')
                    OwnerTypeMap.put(o.Id, o.Opportunity_Owner__r.MFC_User_Type__c);
                system.debug('OwnerTypeMap'+OwnerTypeMap);
            }
        }
        //18May2023:Sumit:End
        
        /*CRM-1106 Pankaj Kumar 23-03-2023 Start*/
        if(!accountIdSet.isEmpty()){
            dealerMap = new Map<Id,Account>([SELECT id, Dealer_Address_Map_Link__c FROM Account WHERE id in :accountIdSet]);
        }
        /*CRM-1106 Pankaj Kumar 23-03-2023 End*/
        System.debug('bucOppArr ' + bucOppArr);
        if(!bucOppArr.isEmpty()) {
            ElisionOppActivityService.init(bucOppArr, bucOppoldMap);
        }
        //Shivam End
        
        List<Opportunity> byPassedOppArr = new List<Opportunity>(); // 25Jun2022:Asif:Start :: Bypass validation
        //CRM- 1070 added by Mishal
        for(Opportunity opp : listOfOpp.values()){
            System.debug('opp after update start : '+opp.Lead__c);
            if(opp.status__c != oldMap.get(opp.Id).status__c && opp.Lead_Flag__c == 'Reserve') {
                oppToBeSend.add(opp.Id);
            }
            //Mishal End
            
           
            
            //Opportunities to lock if warranty status is verified
            if(opp.RecordTypeId == OpportunityConstants.buyerOppRecordTypeId && opp.status__c != null &&
               oldMap.get(opp.Id).Warranty_Status__c != opp.Warranty_Status__c && opp.Warranty_Status__c == 'Verified'){
                   listOfVerifiedOppsToLock.add(opp.Id);
               }
            
            if(opp.RecordTypeId == OpportunityConstants.buyerOppRecordTypeId && opp.status__c != NULL &&
               oldMap.get(opp.Id).Status__c != opp.status__c && (opp.status__c == 'Sold' || opp.status__c == 'Lost')){
                   buyerSoldRecToLock.add(opp.Id);
               }

            if(opp.RecordTypeId == OpportunityConstants.buyerOppRecordTypeId 
               && opp.Status__c != null  && oldMap.get(opp.Id).Status__c== 'Sold' 
               && opp.Status__c != oldMap.get(opp.Id).Status__c ){
                   listOfOppIdsToUnLock.add(opp.Id);  
               }
            
            if(opp.RecordTypeId == OpportunityConstants.CnBRecordTypeId && opp.Status__c != oldMap.get(opp.Id).Status__c && opp.Status__c == '6'){
                cnbIdsToLock.add(opp.Id);
            }
            
            if(opp.RecordTypeId == OpportunityConstants.sellerCarRecordTypeID && opp.Status__c != null
               && opp.Status__c != oldMap.get(opp.Id).Status__c && (opp.Status__c == 'Lost' || opp.Status__c == 'Not Interested')){
                   sellerOppIdstoLock.add(opp.Id);
               }

            if((opp.Status__c == 'Evaluated' && opp.Status__c != oldMap.get(opp.Id).Status__c) && opp.HI_Serviceable__c == '1'){
                system.debug('__adding in oppToSendSMS');  
                oppToSendSMS.add(opp);
            } 
            
            if((opp.Status__c == 'Evaluated with report link' && opp.Status__c != oldMap.get(opp.Id).Status__c) && opp.HI_Serviceable__c == '1'){
                system.debug('__adding in oppToSendSMS2');  
                oppToSendSMS2.add(opp);
            }
            
            //28Jan2022:Asif:Start :: trigger SMS on Rescheduled 
            if(opp.HI_Serviceable__c == '1' && opp.Status__c != oldMap.get(opp.Id).Status__c && opp.Status__c == OpportunityConstants.Status_Rescheduled) {
                if(opp.HI_Preference__c == 'Home') {
                    oppMap_ForSMS_Rescheduled_Home.add(opp);
                } else if(opp.HI_Preference__c == 'Store') {
                    oppMap_ForSMS_Rescheduled_Store.add(opp);
                }
            }
            //28Jan2022:Asif:End
            
            if(opp.Warranty_Edit__c) {
                listOfOppIdsToUnLock.add(opp.Id);
            }
            
            // 25Jun2022:Asif:Start
            if(!opp.Bypass_validation__c) {
                byPassedOppArr.add(opp);
            }
            // 25Jun2022:Asif:End
            
            //  09/06/2023:Sumit:Start:CRM-1156 :: to Call Ecom CnB and LMS when status and lead flag are changed.
            if((opp.RecordTypeId == OpportunityConstants.buyerOppRecordTypeId) && ((opp.Status__c != oldMap.get(opp.id).Status__c && 
               opp.Status__c != NULL) ||  (opp.Lead_Flag__c != oldMap.get(opp.id).Lead_Flag__c && opp.Lead_Flag__c != NULL) || 
               (opp.Reservation_Status__c != oldMap.get(opp.id).Reservation_Status__c ))){
                   LmsOpp.add(opp.Id);
             }								//06-DEC-2023: Sachin: CRM::1207: Added the callout criteria of Reservation_Status__c field in addition to the existing.
            //09/06/2023:Sumit:Start:CRM-1156 End*/
            
            /*CRM-1107 Pankaj Kumar 16-03-2023 Start*/
            if(opp.RecordTypeId == OpportunityConstants.buyerOppRecordTypeId && opp.status__c == 'No response' && opp.WhatsApp_Consent__c == 'yes' && opp.No_Response_Count__c != null && opp.No_Response_Count__c != oldMap.get(opp.Id).No_Response_Count__c && (opp.No_Response_Count__c == 3 || opp.No_Response_Count__c == 5)){
                createTaskForBUCMap.put(opp.Id,opp);
            }
            /*CRM-1107 Pankaj Kumar 16-03-2023 End*/
            /*CRM-1106 Pankaj Kumar 23-03-2023 Start*/
           /*CRM-1144 Pankaj Kumar 05-05-2023 Start*/
            if(opp.RecordTypeId == OpportunityConstants.buyerOppRecordTypeId && userProfileMap.keySet().contains(UserInfo.getProfileId()) && opp.Status__c != oldMap.get(opp.id).Status__c && (opp.status__c == 'Visit Scheduled' || opp.status__c == 'Visit Rescheduled' || opp.status__c == 'Qualified') && opp.Product__c != null && opp.WhatsApp_Consent__c == 'yes' && opp.Dealer__c != null && dealerMap.containsKey(opp.Dealer__c) && dealerMap.get(opp.Dealer__c).Dealer_Address_Map_Link__c != null){
            /*CRM-1144 Pankaj Kumar 05-05-2023 End*/
                createVisitRescheduledTask.put(opp.Id,opp);
            }
            /*CRM-1106 Pankaj Kumar 23-03-2023 End*/
            /*CRM-1110 Pankaj Kumar 23-03-2023 Start*/
            if(opp.RecordTypeId == OpportunityConstants.buyerOppRecordTypeId && userProfileMap.keySet().contains(UserInfo.getProfileId()) && opp.Status__c != oldMap.get(opp.id).Status__c && (opp.status__c == 'Test Drive Scheduled' || opp.status__c == 'Test Drive Rescheduled') && opp.Product__c != null && opp.WhatsApp_Consent__c == 'yes'){
                testDriveTask.put(opp.Id,opp);
            }
            /*CRM-1110 Pankaj Kumar 23-03-2023 End*/
            /*CRM-1124 Pankaj Kumar 23-03-2023 Start*/
            if(opp.RecordTypeId == OpportunityConstants.buyerOppRecordTypeId && opp.Status__c != oldMap.get(opp.id).Status__c && opp.status__c == 'Sold' && opp.WhatsApp_Consent__c == 'yes'){
                soldMsgTask.put(opp.Id,opp);
            }
            /*CRM-1124 Pankaj Kumar 23-03-2023 End*/
            
            //18May2023:Sumit:Start:CRM-1147
            if(OwnerTypeMap.containskey(opp.Id)) {
                oppOwnerUpdateDealerIdList.put(opp.Lead__c, opp.Opportunity_Owner__c);
                DealerCodeSet.add(opp.Dealer_Code__c);
            }
            //18May2023:Sumit:End
        }
        //18May2023:Sumit:Start:CRM-1147:Calling Handler Class
        if(!oppOwnerUpdateDealerIdList.isEmpty()) {
            OpportunityTriggerHelper.ownerUpdateOnOpportunity(oppOwnerUpdateDealerIdList,DealerCodeSet);
        } 
        //18May2023:Sumit:End
        //Added by Mishal as part of CRM-1040
        system.debug('oppToBeSend chacking :-'+oppToBeSend);
        
          
        if(!oppToBeSend.isEmpty()){
            if(CheckRecursiveTrigger.runOnceCNB()) {
                System.debug('Aleardy made CTI Callout');
                 return;
            }
            system.debug('CNB Callout Opp Id :-'+oppToBeSend);
            OpportunityTriggerHelper.cnbCallout(oppToBeSend);
       }
        
        
        if(!LmsOpp.isEmpty()){
            OpportunityTriggerHelper.pushSingleOppToLMS(LmsOpp);
        }
        
        if(!listOfOppIdsToLock.isEmpty()){
            UtilityClass.lockRecords(listOfOppIdsToLock);
        }
        if(!listOfOppIdsToUnLock.isEmpty()){
            UtilityClass.unLockRecords(listOfOppIdsToUnLock);
        }
        
        if(!sellerOppIdstoLock.isEmpty()){
            UtilityClass.lockRecords(sellerOppIdstoLock);
        }
        
        if(!listOfVerifiedOppsToLock.isEmpty()){
            UtilityClass.lockRecords(listOfVerifiedOppsToLock);
        }
        
        if(!cnbIdsToLock.isEmpty()){
            UtilityClass.lockRecords(cnbIdsToLock);
        }
        
        if(!buyerSoldRecToLock.isEmpty()){
            UtilityClass.lockRecords(buyerSoldRecToLock);
        }
        
        //To send SMS if Opp is Evaluated
        if(!oppToSendSMS.isEmpty()){
            OpportunityTriggerHelper.sendSMSToUser('Hi FollowUp SMS', oppToSendSMS);
        }
        
        if(!oppToSendSMS2.isEmpty()){
            OpportunityTriggerHelper.sendSMSToUser('HI FollowUp WIth Link', oppToSendSMS2);
        }
        
        //28Jan2022:Asif:Start ::trigger SMS on Rescheduled 
        if(!oppMap_ForSMS_Rescheduled_Home.isEmpty()) {
            OpportunityTriggerHelper.sendSMSToUser('HI_VTBA_FollowUp_Home', oppMap_ForSMS_Rescheduled_Home);
        }
        if(!oppMap_ForSMS_Rescheduled_Store.isEmpty()) {
            OpportunityTriggerHelper.sendSMSToUser('HI_VBTA_FollowUp_Store', oppMap_ForSMS_Rescheduled_Store);
        }
        //28Jan2022:Asif:End
        
        // Elision Trigger
        // ElisionOpportunityService.initFuture(listOfOpp.keySet());
        
        // 25Jun2022:Asif:Start :: Bypass validation
        if(!byPassedOppArr.isEmpty()) {
            List<Opportunity> oppToUpdateArr = new List<Opportunity>();
            for(Opportunity o : byPassedOppArr) {
                oppToUpdateArr.add(new Opportunity(
                    Id = o.Id,
                    Bypass_validation__c = true
                ));
            }
            update oppToUpdateArr;
        }
        // 25Jun2022:Asif:End
        /*CRM-1107 Pankaj Kumar 16-03-2023 Start*/
        if(!createTaskForBUCMap.isEmpty()){
            OpportunityTriggerHelper.createWhatsappMsgTask(createTaskForBUCMap, 'NoResponse_6646704', null);
        }
        /*CRM-1107 Pankaj Kumar 16-03-2023 End*/
        /*CRM-1106 Pankaj Kumar 23-03-2023 Start*/
        if(!createVisitRescheduledTask.isEmpty()){
            OpportunityTriggerHelper.createWhatsappMsgTask(createVisitRescheduledTask, 'Walkin_Alert_6646765', dealerMap);
        }
        /*CRM-1106 Pankaj Kumar 23-03-2023 Start*/
        /*CRM-1110 Pankaj Kumar 23-03-2023 Start*/
        if(!testDriveTask.isEmpty()){
            OpportunityTriggerHelper.createWhatsappMsgTask(testDriveTask, 'TDScheduled_6646756', null);
        }
        /*CRM-1124 Pankaj Kumar 23-03-2023 Start*/
        if(!soldMsgTask.isEmpty()){
            OpportunityTriggerHelper.createWhatsappMsgTask(soldMsgTask, 'Sold_Msg_6602534', null);
        }
        /*CRM-1124 Pankaj Kumar 23-03-2023 Start*/
        /*CRM-1139 Pankaj Kumar 24-04-2023 Start*/
        OpportunityTriggerHelper.updateRelatedLeadRec(oldMap,newList,true);
        /*CRM-1139 Pankaj Kumar 24-04-2023 End*/
    }
}