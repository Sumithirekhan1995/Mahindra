/*
* Class created by Deepali
* Purpose: To execute business logic on Lead records
*/
public class LeadTriggerHelper {
    
    public static boolean apiFired = false;
    
    //Added by Deepali 
    //Purpose: To tag existing Customer account to Buyer Leads based on Phone
    public static void tagCustomerAccountToLead(List<Lead> newList){
        Set<String> leadPhoneSet = new Set<String>();
        List<Account> existingCustomersList = new List<Account>();
        Map<String, Account> customerPhoneToIdMap = new Map<String, Account>();
        List<Lead> leadWithoutExistingCustomerList = new List<Lead>();
        
        for(Lead lea: newList){
            leadPhoneSet.add(lea.Phone);
        }
        
        if(!leadPhoneSet.isEmpty()){
            existingCustomersList = [SELECT Id, Phone /* , Do_Not_Call__c */ FROM Account WHERE RecordTypeId =: AccountConstants.customerAccountRecordTypeId AND ExtrnId_Phone__c IN :leadPhoneSet Order by CreatedDate Desc limit 5000];
        }
        
        System.debug('existingCustomersList'+existingCustomersList);
        if(!existingCustomersList.isEmpty()){
            for(Account acc : existingCustomersList){
                customerPhoneToIdMap.put(acc.Phone, acc);
            }
        }
        
        for(Lead lea : newList){
            if(customerPhoneToIdMap.containsKey(lea.Phone)){
                lea.Customer__c = customerPhoneToIdMap.get(lea.Phone).Id;
                /* if( customerPhoneToIdMap.get(lea.Phone).Do_Not_Call__c  == True && 
(lea.RecordTypeId == LeadConstants.buyerLeadRecordTypeId || lea.RecordTypeId == LeadConstants.SellerLeadRecordTypeId)){
lea.DoNotCall = true;
lea.Status__c = 'Do Not Call';
lea.OwnerId = '00G1s000001Kc7F';
} */
                
            }else{
                leadWithoutExistingCustomerList.add(lea);
            }
        }
        
        
        System.debug('leadWithoutExistingCustomerList'+leadWithoutExistingCustomerList);
        if(!leadWithoutExistingCustomerList.isEmpty()){
            createNewCustomerAndTagToLead(leadWithoutExistingCustomerList);
        }
    }
    
    //Added by Deepali
    //Purpose: To create new Customer Account and tag it to Lead based on Phone
    public static void createNewCustomerAndTagToLead(List<Lead> newList){
        Map<String, Lead> phoneToLeadMap = new Map<String, Lead>();
        List<Account> customersToInsertList = new List<Account>();
        Map<String, Id> customerPhoneToIdMap = new Map<String, Id>();
        
        for(Lead lea: newList){
            phoneToLeadMap.put(lea.Phone, lea);
        }
        
        if(!phoneToLeadMap.keySet().isEmpty()){
            for(String leadPhone : phoneToLeadMap.keySet()){
                Account acc = new Account();
                acc.RecordTypeId = AccountConstants.customerAccountRecordTypeId;
                acc.Phone = leadPhone;
                acc.Salutation = phoneToLeadMap.get(leadPhone).Salutation;
                acc.LastName = phoneToLeadMap.get(leadPhone).LastName;
                acc.FirstName = phoneToLeadMap.get(leadPhone).FirstName;
                acc.PersonEmail = phoneToLeadMap.get(leadPhone).email ; 
                customersToInsertList.add(acc);
            }
        }
        
        System.debug('customersToInsertList ' + customersToInsertList);
        if(!customersToInsertList.isEmpty() && !Test.isRunningTest()){
            insert customersToInsertList;
        }
        
        if(!customersToInsertList.isEmpty()){
            for(Account acc : customersToInsertList){
                customerPhoneToIdMap.put(acc.Phone, acc.Id);
            }
        }
        
        for(Lead lea : newList){
            if(customerPhoneToIdMap.containsKey(lea.Phone)){
                lea.Customer__c = customerPhoneToIdMap.get(lea.Phone);
            }
        }
        
    }
    
    
    //Added by Deepali
    //Purpose: To create an opportunity from lead when lead is qualified
    
    // 9Feb2022:Asif:Start :: to stop inserting multiple dispatch with same data
    public static Map<String, String> leadPhoneStockMap = new Map<String, String>();
    // 9Feb2022:Asif:End
    
    //Added by Kunal
    public static void pushSingleLeadsToLMS(Set<Id> leadIds){
        System.debug('pushSingleLeadsToLMS' + leadIds);
        
        if(LeadConstants.fireLMSApiFromLead){
            for(Id lid : leadIds){
                Set<Id> leadId = new Set<Id>();
                leadId.add(lid);
                pushLeadToLmsfuture(leadId);
            }
            
            LeadConstants.fireLMSApiFromLead = FALSE;
        }
    }
    
    //Added by Deepali
    //Purpose: To push the leads to LMS system through a future context
    public static void pushLeadToLmsfuture(Set<Id> leadIdSet){
        System.debug('LeadTriggerHelper.pushLeadToLmsfuture::');
        if(!CheckRecursiveTrigger.runOnceLMS()) {
            System.debug('Already Ran LMS Lead Callout, EXITING_FUNCTION');
            return;
        }
        
        List<Id> leadIdList = new List<Id>();
        for(Id leadId : leadIdSet){
            leadIdList.add(leadId);
        }
    //    if(LeadConstants.isFromLeadupsert || LeadConstants.isFromAura){  // sumit for android
            System.debug('leadIdList ' + leadIdList);
            if(!leadIdList.isEmpty()) {
                System.debug('__calling makeLMSCallout');
                makeLMSCallout(leadIdList);  
            }
      //  }  //sumit for android
       
    }
    
    // 22Nov2021:Sarthak:Start
    @future(callout=true)
    public static void makeLMSCallout(List<Id> leadIds) {
        LeadPushToLMS.pushLeadsToLms(leadIds);
    }
    // 22Nov2021:Sarthak:End
    
    //Added by Swetha
    //Purpose: To check if Lead is Duplicate before inserting
    public static void checkDuplicates(List<Lead> checkforDuplicates, String recrdtype){
        Set<String> phoneNumbers = new Set<String>();
        Set<String> agrmNumbers = new Set<String>();
        Map<String,Lead> newMap = new Map<String,Lead>();
        Map<String,Lead> oldMap = new Map<String,Lead>();
        List<Lead> LeadToUpdate = new List<Lead>();
        List<Lead> LeadError = new List<Lead>();
        Map<String, Id> queueMap = new Map<String, Id>();
        Set<Id> leadIds = new Set<Id>();
        for(Group grp : [Select Id,Name,type from Group where type = 'queue']){
            queueMap.put(grp.Name, grp.Id);
        }
        for(Lead item : checkforDuplicates){
            phoneNumbers.add(item.Phone);
            //Added by Soumya 01/10/2020 -- Start
            if(recrdtype == LeadConstants.BuyerConstant){
                newMap.put(item.Phone+'-',item);
            } // --End
            else if(recrdtype == LeadConstants.ProcurementConstant){
                newMap.put(item.Phone+'-'+item.Year_of_Manufacture__c+'-'+item.Make__c+'-'+item.Model__c,item);
            }
            //Added by Soumya for CnB duplication Logic
            else if(recrdtype == LeadConstants.LEAD_TYPE_CNB){
                newMap.put(item.Phone+'-'+item.City_Id__c+'-'+item.Car_Model_Id__c, item);
            }
            else if(recrdtype == LeadConstants.LEAD_TYPE_BSE){
                newMap.put(item.Phone, item);
            }
            else if(recrdtype == LeadConstants.LEAD_TYPE_CNB_BIKE){
                newMap.put(item.Phone+'-'+item.City_Id__c+'-'+item.Bike_Model_Id__c, item);
            }
        }
        System.debug('New Map'+newMap);
        
        for(Lead l : [select id,City_Id__c,LeadSource,Year_of_Manufacture__c, MAke__c, Model__c, Car_Model_Id__c,Bike_Model_Id__c, Product__r.Stock_ID__c, Product__c, dealer__r.Code__c, Phone, CreatedDate, Active__c, Repeat__c, Lead_Type__c, dealer__c, RepeatCreatedDate__c,Agreement_Number__c from Lead where ExtrnId_Phone__c in: phoneNumbers And Active__c = true and Lead_Type__c =: recrdtype]){
            system.debug('Lead List'+ l);
            //Added by Soumya 01/10/2020 -- Start
            if(recrdtype == LeadConstants.BuyerConstant){
                oldMap.put(l.Phone+'-',l);
            } // --End
            else if(recrdtype == LeadConstants.ProcurementConstant){
                oldMap.put(l.Phone+'-'+l.Year_of_Manufacture__c+'-'+l.Make__c+'-'+l.Model__c,l);
            }
            //Added by Soumya for CnB duplication logic
            else if(recrdtype == LeadConstants.LEAD_TYPE_CNB){
                oldMap.put(l.Phone+'-'+l.City_Id__c+'-'+l.Car_Model_Id__c, l);
            }
            else if(recrdtype == LeadConstants.LEAD_TYPE_BSE){
                oldMap.put(l.Phone, l);
            }
            else if(recrdtype == LeadConstants.LEAD_TYPE_CNB_BIKE){
                oldMap.put(l.Phone+'-'+l.City_Id__c+'-'+l.Bike_Model_Id__c, l);
            }
        }
        System.debug('Old map' + oldMap);
        for(String newPhone : newMap.keySet()){
            if(oldMap.containsKey(newPhone)){
                System.debug('**********' + oldMap.containsKey(newPhone));
                Lead leadRecord = oldMap.get(newPhone);
                //Added by Soumya 01/10/2020
                
                if((/*leadRecord.CreatedDate >= (Date.today() - 1)  &&*/ recrdtype == LeadConstants.BuyerConstant ) ||  
                   (leadRecord.CreatedDate >= (Date.today() - 7) && recrdtype == LeadConstants.ProcurementConstant && leadRecord.LeadSource != 'MFC-Chat') ||//24-Jan-2023:Sachin::CRM-1033
                   (leadRecord.CreatedDate >= (Date.today() - 1)  && recrdtype == LeadConstants.LEAD_TYPE_CNB ) || 
                   (leadRecord.CreatedDate >= (Date.today() - 7)  && recrdtype == LeadConstants.LEAD_TYPE_BSE ) ||
                   (leadRecord.CreatedDate >= (Date.today() - 1)  && recrdtype == LeadConstants.LEAD_TYPE_CNB_BIKE)){ 
                       System.debug('Entered');
                       leadRecord.Repeat__c = true;
                       leadRecord.RepeatCreatedDate__c = System.now();
                       leadRecord.Repeat__c = true;
                       LeadToUpdate.add(leadRecord);
                       if(UserInfo.getUserId() != System.label.Integration_User && UserInfo.getUserId() != System.label.Exotel_Site_user &&  
                          UserInfo.getUserId() != System.label.Platform_Integration_User &&  UserInfo.getUserId() != System.label.MFCW_Site_Host &&
                          UserInfo.getUserId() != System.label.CnB_Site_Host &&  UserInfo.getUserId() != System.label.AutomatedProcess){
                              if(!Test.isRunningTest())
                                  newMap.get(newPhone).addError('Lead already exists'+' LeadId-'+leadRecord.Id);
                          }
                       newMap.get(newPhone).Upload_Message__c = 'This is a duplicate lead. The previous lead has been marked as repeat.';
                       newMap.get(newPhone).IsDuplicate__c = true;
                       newMap.get(newPhone).Active__c = false;
                       if(recrdtype == LeadConstants.ProcurementConstant)
                           newMap.get(newPhone).Status__c = 'Duplicate';
                       if(queueMap.containsKey('BUC_Duplicate') && recrdtype == LeadConstants.BuyerConstant ){
                           newMap.get(newPhone).OwnerId = queueMap.get('BUC_Duplicate');
                       }
                       else if(queueMap.containsKey('SC_Duplicates') && recrdtype== LeadConstants.ProcurementConstant 
                               && newMap.get(newPhone).HI_Serviceable__c == '0'){
                                   //newMap.get(newPhone).OwnerId = queueMap.get('SC_Duplicates');
                               }
                       else if(queueMap.containsKey('HI_Duplicates') && recrdtype== LeadConstants.ProcurementConstant && 
                               newMap.get(newPhone).HI_Serviceable__c == '1'){
                                   newMap.get(newPhone).OwnerId = queueMap.get('HI_Duplicates');
                               }
                       else if(queueMap.containsKey('CnB_NewCar_Duplicates') && recrdtype== LeadConstants.LEAD_TYPE_CNB_BIKE){
                           newMap.get(newPhone).OwnerId = queueMap.get('CnB_NewCar_Duplicates');
                       }
                       else if(queueMap.containsKey('CnB_NewBike_Duplicates') && recrdtype== LeadConstants.LEAD_TYPE_CNB){
                           newMap.get(newPhone).OwnerId = queueMap.get('CnB_NewBike_Duplicates');
                       }
                       
                       else if(queueMap.containsKey('BSE_Duplicates') && recrdtype== LeadConstants.LEAD_TYPE_BSE){
                           newMap.get(newPhone).OwnerId = queueMap.get('BSE_Duplicates');
                       }
                   }
                else if((leadRecord.CreatedDate.getTime()-System.now().getTime())/3600000 > 24){
                    newMap.get(newPhone).Active__c = true;
                    leadRecord.Active__c = false;
                    LeadToUpdate.add(leadRecord);
                }
            }
        }
        
        System.debug('Existing Lead List'+LeadToUpdate);
        if(LeadToUpdate.size() > 0 && !Test.isRunningTest()){
            update LeadToUpdate;
            LeadToUpdate.clear();
        }
    }
    //Added by Rohan to push lead to CPT
    public static void sendLeadDataToCPT(List<Lead> listOfLeads){
        LeadPushCPT.getLeadDetails(listOfLeads);
    }
    
    //Purpose - To Create new seller opportunity
    public static void createSellerOpportunity(List<Lead> leadlist){
        List<opportunity> oppListToInsert = new List<opportunity>();
        map<String, id> mapofCPTIDandOppId = new map<String, id>();
        system.debug('leadlist'+leadlist);
        
        for(lead l : leadlist){
            Opportunity opp = new Opportunity();
            opp.Name = l.LastName;
            opp.Bypass_validation__c = false; // 25July2022:Asif :: Bypass Validation on Stage
            opp.CloseDate = system.today()+10;
            opp.StageName = OpportunityConstants.OpportunityStage_Qualification;
            opp.RecordTypeId = OpportunityConstants.sellerCarRecordTypeID; 
            opp.AccountId = l.Customer__c;
            opp.Variant__c = l.Variant__c;
            opp.lead__c = l.Id;
            opp.Year__c = l.Year__c;
            opp.Lead_Category__c = l.Lead_Category__c; // Edited by Amulya on 01-03-22 to populate Lead Category in Follow up lead
            opp.Kilometer__c = l.Kilometer__c;
            opp.Total_Owner__c = l.Total_Owner__c;
            opp.Registration_Number__c = l.Registration_Number__c;
            opp.Inspect_Type__c = l.Inspect_Type__c;
            opp.Valuator_Visit_Date_Time__c = l.Valuator_Visit_Date_Time__c;
            opp.Valuation_Remarks__c = l.Valuation_Remarks__c;
            opp.status__c = l.status__c;
            opp.Vehicle_Category__c = l.Vehicle_Category__c;
            opp.Phone__c = l.Phone;
            opp.Email__c = l.Email;
            opp.Address__c = l.Address__c;
            opp.Area_Pincode__c = l.Area_PinCode__c;
            opp.Area_City__c = l.Seller_City__c;
            opp.Area_State__c = l.Seller_State__c;
            opp.LeadSource = l.LeadSource;
            opp.evaluation_city__c = l.evaluation_city__c;
            opp.evaluation__c = l.evaluation_state__c;
            opp.evaluation_Name__c = l.evaluation_name__c;
            opp.evaluator_contact_number__c = l.evaluator_contact_number__c;
            opp.evaluator_email__c = l.evaluator_email__c;
            opp.registration_city__c = l.registration_city__c;
            opp.registration_State__c = l.registration_state__c;
            opp.cpt_admin_contact_number__c = l.cpt_admin_contact_number__c;
            opp.cpt_admin_email__c = l.cpt_admin_email__c;
            opp.cpt_admin_name__c = l.cpt_admin_name__c;
            opp.CPT_Admin_Access_Location__c = l.CPT_Admin_Access_Location__c;
            opp.CPT_Admin_Login_Id__c = l.CPT_Admin_Login_Id__c;
            opp.CPT_Admin_UID__c = l.CPT_Admin_UID__c;
            opp.CPT_Admin_ZM__c = l.CPT_Admin_ZM_Name__c;
            opp.Team_Lead__c = l.Team_Lead__c;
            opp.Assign_Type__c = l.Assign_Type__c;
            opp.Autoinspekt__c = l.Autoinspekt__c;
            opp.qc_approved_date__c = l.qc_approved_date__c;
            opp.auction_end_date__c = l.auction_end_date__c;
            opp.auction_id__c = l.auction_id__c;
            opp.auction_start_date__c = l.auction_start_date__c;
            opp.Followup_remarks__c = l.follwoup_remarks__c;
            opp.live_followup_date__c = l.live_followup_date__c;
            opp.reject_date__c = l.reject_date__c;
            opp.deal_finalized_on__c = l.deal_finalized_on__c;
            opp.sold_out_on__c = l.sold_out_on__c;
            opp.ibb_price__c = l.ibb_price__c;
            opp.Customer_Expected_Price__c = l.Customer_Expected_Price__c;
            opp.inspected_date__c = l.inspected_date__c;
            opp.Evaluator_Name__c = l.evaluator_name__c;
            opp.Lead_Created_From__c = l.Lead_Created_From__c;
            opp.Make__c = l.Make__c;
            opp.Model__c = l.Model__c;
            opp.Colour__c = l.Color__c;
            opp.Reject_Reason__c = l.reject_reason__c;
            opp.Lead_Type__c = l.Lead_Type__c;
            opp.Seller_Price__c = l.Seller_Price__c;
            opp.Valuator_Assigned_Visit_Date__c = l.Valuator_Assigned_Visit_Date__c;
            opp.Valuator_Assigned_Visit__c = l.Valuator_Assigned_Visit__c;
            opp.HI_Preference__c = l.HI_Preference__c;
            opp.HI_Serviceable__c = l.HI_Serviceable__c;
            opp.RP_Dealer__c = l.RP_Dealer__c;
            opp.Valuation_Schedule_Time_Slot__c = l.Valuation_Schedule_Time_Slot__c;
            oppListToInsert.add(opp);
        }
        
        if(!oppListToInsert.isEmpty() && !Test.isRunningTest()){
            insert oppListToInsert;                                
        }
    }
    
    //CRM-1311 :: Start :: Purpose - To Create new ELV opportunity  
    public static void createElvOpportunity(List<Lead> leadlist){
        List<opportunity> oppListToInsert = new List<opportunity>();
        system.debug('leadlist'+leadlist);
        
        for(lead l : leadlist){
            Opportunity opp = new Opportunity();
            opp.Name = l.LastName;
            opp.Bypass_validation__c = false; // 25July2022:Asif :: Bypass Validation on Stage
            opp.CloseDate = system.today()+10;
            opp.StageName = OpportunityConstants.OpportunityStage_Qualification;  
            opp.RecordTypeId = OpportunityConstants.ElvCarRecordTypeID; 
            opp.AccountId = l.Customer__c;
            opp.Variant__c = l.Variant__c;
            opp.lead__c = l.Id;
            opp.Year__c = l.Year__c;
            opp.Lead_Category__c = l.Lead_Category__c; // Edited by Amulya on 01-03-22 to populate Lead Category in Follow up lead
            opp.Kilometer__c = l.Kilometer__c;
            opp.Total_Owner__c = l.Total_Owner__c;
            opp.Registration_Number__c = l.Registration_Number__c;
            opp.Inspect_Type__c = l.Inspect_Type__c;
            opp.Valuator_Visit_Date_Time__c = l.Valuator_Visit_Date_Time__c;
            opp.Valuation_Remarks__c = l.Valuation_Remarks__c;
            opp.status__c = l.status__c;
            opp.Vehicle_Category__c = l.Vehicle_Category__c;
            opp.Phone__c = l.Phone;
            opp.Email__c = l.Email;
            opp.Address__c = l.Address__c;
            opp.Area_Pincode__c = l.Area_PinCode__c;
            opp.Area_City__c = l.Seller_City__c;
            opp.Area_State__c = l.Seller_State__c;
            opp.LeadSource = l.LeadSource;
            opp.evaluation_city__c = l.evaluation_city__c;
            opp.evaluation__c = l.evaluation_state__c;
            opp.evaluation_Name__c = l.evaluation_name__c;
            opp.evaluator_contact_number__c = l.evaluator_contact_number__c;
            opp.evaluator_email__c = l.evaluator_email__c;
            opp.registration_city__c = l.registration_city__c;
            opp.registration_State__c = l.registration_state__c;
            opp.cpt_admin_contact_number__c = l.cpt_admin_contact_number__c;
            opp.cpt_admin_email__c = l.cpt_admin_email__c;
            opp.cpt_admin_name__c = l.cpt_admin_name__c;
            opp.CPT_Admin_Access_Location__c = l.CPT_Admin_Access_Location__c;
            opp.CPT_Admin_Login_Id__c = l.CPT_Admin_Login_Id__c;
            opp.CPT_Admin_UID__c = l.CPT_Admin_UID__c;
            opp.CPT_Admin_ZM__c = l.CPT_Admin_ZM_Name__c;
            opp.Team_Lead__c = l.Team_Lead__c;
            opp.Assign_Type__c = l.Assign_Type__c;
            opp.Autoinspekt__c = l.Autoinspekt__c;
            opp.qc_approved_date__c = l.qc_approved_date__c;
            opp.auction_end_date__c = l.auction_end_date__c;
            opp.auction_id__c = l.auction_id__c;
            opp.auction_start_date__c = l.auction_start_date__c;
            opp.Followup_remarks__c = l.follwoup_remarks__c;
            opp.live_followup_date__c = l.live_followup_date__c;
            opp.reject_date__c = l.reject_date__c;
            opp.deal_finalized_on__c = l.deal_finalized_on__c;
            opp.sold_out_on__c = l.sold_out_on__c;
            opp.ibb_price__c = l.ibb_price__c;
            opp.Customer_Expected_Price__c = l.Customer_Expected_Price__c;
            opp.inspected_date__c = l.inspected_date__c;
            opp.Evaluator_Name__c = l.evaluator_name__c;
            opp.Lead_Created_From__c = l.Lead_Created_From__c;
            opp.Make__c = l.Make__c;
            opp.Model__c = l.Model__c;
            opp.Colour__c = l.Color__c;
            opp.Reject_Reason__c = l.reject_reason__c;
            opp.Lead_Type__c = l.Lead_Type__c;
            opp.Seller_Price__c = l.Seller_Price__c;
            opp.Valuator_Assigned_Visit_Date__c = l.Valuator_Assigned_Visit_Date__c;
            opp.Valuator_Assigned_Visit__c = l.Valuator_Assigned_Visit__c;
            opp.HI_Preference__c = l.HI_Preference__c;
            opp.HI_Serviceable__c = l.HI_Serviceable__c;
            opp.RP_Dealer__c = l.RP_Dealer__c;
            opp.Valuation_Schedule_Time_Slot__c = l.Valuation_Schedule_Time_Slot__c;
            oppListToInsert.add(opp);
        }
        
        if(!oppListToInsert.isEmpty() && !Test.isRunningTest()){
            insert oppListToInsert;                                
        }
    }
    //CRM-1311 :: End
    
    //To update stage in leads if status = 'Valuator to be assigned'
    public static void updateStage(list<lead> llist){
        System.debug('LeadTriggerHelper.updateStage ::');
        system.debug('Lead list ' + llist);
        for(lead l : llist){
            l.Bypass_validation__c = false;
            l.Status = LeadConstants.LEAD_STATUS_QUALIFIED;
        }
        if(!llist.isEmpty())
            update llist;
        system.debug('updated');
    }
    
    //To populate state name against city name
    public static void populateState(List<Lead> LeadwoState){
        Set<String> city = new Set<String>();
        Map<String,City_State__mdt> mapct = new Map<String,City_State__mdt>();
        
        for(Lead l : LeadwoState){
            city.add(l.Seller_City__c);
        }
        
        for(City_State__mdt m:   [select MasterLabel,developerName, State__c from City_State__mdt where MasterLabel IN :city]){
            mapct.put(m.MasterLabel.toUpperCase(), m);
        }
        
        System.debug('Mapct '+Mapct);
        for(Lead l : LeadwoState){
            String city1 = l.Seller_City__c.toUpperCase();
            System.debug('City1 '+city1);
            if(mapct.containsKey(city1)){
                //System.debug('Mapct '+Mapct+'mapct.containsKey(l.registration_city__c '+mapct.containsKey(l.registration_city__c));
                l.Seller_State__c = mapct.get(city1).State__c;
                l.Area_State__c = l.Seller_State__c;
            }
            system.debug('SellerState'+l.Seller_State__c);
        }
        system.debug('LeadwoState'+LeadwoState);
    }
    
    //To Create Opportunity of CnB Leads
    //Added by Soumya -- 14/10/20
    public static void cnbLeadOpportunity(List<Lead> leadList){
        System.debug('Lead List '+leadList);
        List<Opportunity> oppToInsert = new List<Opportunity>();
        
        for(Lead l : leadList){
            if(l.Followup_Lead_Created__c == false){
                Opportunity opp = new Opportunity();
                opp.Bypass_validation__c = false; // 25July2022:Asif :: Bypass Validation on Stage
                opp.Name = l.LastName;
                opp.Phone__c = l.Phone;
                opp.Email__c = l.Email;
                opp.StageName = 'Qualification';
                opp.CloseDate = System.today()+10;
                opp.AccountId = l.Customer__c;
                opp.Marketing_Status__c = l.Marketing_Status__c;
                opp.Followup_Date_Time__c = l.Follow_Up_Date_Time__c;
                opp.First_Visit_Date__c = l.First_Visit_Date__c;
                opp.User_Id__c = l.User_Id__c;
                opp.Date_Time__c = l.Date_Time__c;
                opp.Followup_Comments__c = l.Comments__c;
                opp.Call_Status__c = l.Call_Status__c;
                if(l.RecordTypeId == LeadConstants.CnBLeadRecordTypeId){
                    opp.Car_Lead_Id__c = l.Car_Lead_Id__c;
                    opp.Car_Model_Id__c = l.Car_Model_Id__c;
                    opp.RecordTypeId = OpportunityConstants.CnBRecordTypeId;
                }
                else if(l.RecordTypeId == LeadConstants.CnBBikeLeadRecordTypeId){
                    opp.Bike_Lead_Id__c = l.Bike_Lead_Id__c;
                    opp.Bike_Model_Id__c = l.Bike_Model_Id__c;
                    opp.RecordTypeId = OpportunityConstants.CnBBikeRecordTypeId;
                }
                opp.Variant_Car_Id__c = l.Car_Variant_Id__c;
                opp.Manufacturer_Car_Id__c = l.Manufacturer_Car_Id__c;
                opp.Car_Model_Name__c = l.Primary_Model__c;
                opp.Variant__c = l.Primary_Variant__c;
                opp.Manufacturer__c = l.Manufacturer__c;
                opp.City_Id__c = l.City_Id__c;
                opp.Area_City__c = l.Area_City__c;
                opp.Pincode_Id__c = l.Pincode_Id__c;
                opp.Area_Pincode__c = l.Area_PinCode__c;
                opp.Form_Type_Id__c = l.Form_Type_Id__c;
                opp.Dealer_Id__c = l.Dealer_Id__c;
                opp.DealerName__c = l.Dealer_Name__c;
                opp.Source_Id__c = l.Source_Id__c;
                opp.LeadSource = l.LeadSource;
                opp.Duration_Days__c = l.Duration_Days__c;
                opp.UTM_Campaign__c = l.UTM_Campaign__c;
                opp.UTM_Content__c = l.UTM_Content__c;
                opp.UTM_Medium__c = l.UTM_Medium__c;
                opp.UTM_Source__c = l.UTM_Source__c;
                opp.UTM_Term__c = l.UTM_Term__c;
                opp.URL__c = l.URL__c;
                opp.status__c = l.Status__c;
                opp.Affiliate_Date_Time__c = l.Affiliate_Date__c;
                opp.Affiliate_Response__c = l.Affiliate_Response__c;
                opp.Affiliate_Type__c = l.Affiliate_Type__c;
                opp.affiliate_status__c = l.Affiliate_Status__c;
                opp.Lead__c = l.Id;
                oppToInsert.add(opp);            
            }
        }
        
        if(!oppToInsert.isEmpty() && !Test.isRunningTest()){
            insert oppToInsert;                                      
        }
    }
    
    //Create BSE lead opportunity
    public static void createBSEOppotunity(List<Lead> BSELeadList){
        List<Opportunity> bseOpptoInsert = new List<Opportunity>();
        
        for(Lead l : BSELeadList){
            if(l.Followup_Lead_Created__c == False){
                Opportunity o = new Opportunity();
                o.Bypass_validation__c = false; // 25July2022:Asif :: Bypass Validation on Stage
                o.Name = l.LastName;
                o.Phone__c = l.Phone;
                o.Email__c = l.Email;
                o.AccountId = l.Customer__c;
                o.status__c = l.Status__c;
                o.CloseDate = System.today()+7;
                o.StageName = 'Qualification';
                o.Priority__c = l.Priority__c;
                o.MFCWL_Id__c = l.MFCWL_Number__c;
                o.HPA_Number__c = l.HPA_Number__c;
                o.Branch_Name__c = l.Branch_Name_BSE__c;
                o.State__c = l.Area_State__c;
                o.Vehicle__c = l.Vehicle__c;
                o.Reg_No__c = l.Reg_No__c;
                o.Date_of_Loan__c = l.Date_of_Loan__c;
                o.ACM_Email__c = l.ACM_Email__c;
                o.ACM_Name__c = l.ACM_Name__c;
                o.DM_Name__c = l.DM__c;
                o.DM_Email__c = l.DM_Email__c;
                o.Guarantor_Mobile_Number__c = l.Guarantor_Phone_number__c;
                o.Guarantor_Name__c = l.Guarantor_Name__c;
                o.Place__c = l.Place__c;
                o.Post_Office__c = l.Post_Office__c;
                o.City_Village__c = l.City_Village__c;
                o.Repo_Price__c = l.Repo_Price__c;
                o.X90_Repo_Price__c = l.X90_Repo_Price__c;
                o.Pending_Loan_Amount__c = l.Pending_Loan_Amount__c;
                o.Contacted_By__c = l.Contacted_By__c;
                o.Contacted_Date__c = l.Contacted_Date__c;
                o.Remarks__c = l.Remarks__c;
                o.Location__c = l.Location__c;
                o.Receipt_for_Payment_NOC_status__c = l.Receipt_for_Payment_NOC_Status__c;
                o.Payment_Mode__c = l.Payment_Mode__c;
                o.Executive_Name__c = l.Executive_Name__c;
                o.Executive_Mobile_Number__c = l.Executive_Mobile_Number__c;
                o.Next_Followup_Date__c = l.Next_Followup_Date_Time__c;
                o.Qualified_CRE__c = l.Qualified_CRE__c;
                o.RecordTypeId = OpportunityConstants.BSERecordTypeId;
                o.Lead__c = l.Id;
                bseOpptoInsert.add(o);              
            }
        }
        
        if(!bseOpptoInsert.isEmpty() && !Test.isRunningTest()){
            insert bseOpptoInsert;                                 
        }
        
    }
    
    
    //For CnB -- Start
    @future(callout = true)
    public static void callNewLeadAPI(Set<Id> leadList){
        if(!Test.isRunningTest()){
            CnBCalloutService.NewLead(leadList);
        }
    }
    
    @future(callout = true)
    public static void callLeadStatusChange(Set<Id> leadIds){
       CnBCalloutService.updateLeadStatus(leadIds);
    } // --End
    
    //To Update Account Name and Sub Lead Details -- CnB
    public static void updateAccNameAndSubLeads(List<Lead> leaList){
        Set<String> phoneList = new Set<String>();
        Map<String, Lead> leadMap = new Map<String, Lead>();
        Set<Id> leadIds = new Set<Id>();
        Id customerAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id CnBLeadRecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('New_Car').getRecordTypeId();
        Id CnBBikeLeadRecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('New_Bike').getRecordTypeId();
        
        
        for(Lead lea : leaList){
            phoneList.add(lea.Phone);
            leadMap.put(lea.Phone, lea);
            leadIds.add(lea.Id);
        }
        
        System.debug('Phone List '+phoneList);
        System.debug('Lead Map '+leadMap);
        
        List<Account> customerAcc = [Select id, FirstName, LastName, Phone, ExtrnId_Phone__c from Account where ExtrnId_Phone__c IN :phoneList AND RecordTypeId = :customerAccountRecordTypeId limit 1];
        
        System.debug('Customer Accounts '+customerAcc);
        if(!customerAcc.isEmpty()){
            for(Account acc : customerAcc){
                acc.FirstName = leadMap.get(acc.Phone).FirstName;
                acc.LastName = leadMap.get(acc.Phone).LastName;
            }
            update customerAcc;
        }
        
        List<Lead> subLeadList = [Select Id, FirstName, LastName, Phone, Email, Area_City__c, Area_Pincode__c, ExtrnId_Phone__c from Lead where Id NOT IN :leadIds AND (Car_Model_Id__c != NULL OR Bike_Model_Id__c != NULL) AND ExtrnId_Phone__c IN :phoneList];
        for(Lead lea : subLeadList){
            System.debug('LastNAme '+leadMap.get(lea.Phone).LastName);
            if(lea.FirstName != NULL){
                lea.FirstName = leadMap.get(lea.Phone).FirstName;
            }
            lea.LastName = leadMap.get(lea.Phone).LastName;
            if(lea.Email != NULL)
                lea.Email = leadMap.get(lea.Phone).Email;
            if(lea.Area_City__c != NULL)
                lea.Area_City__c = leadMap.get(lea.Phone).Area_City__c;
            if(lea.Area_PinCode__c != NULL)
                lea.Area_PinCode__c = leadMap.get(lea.Phone).Area_Pincode__c;
        }
        
        System.debug('subLeadList '+subLeadList);
        if(!subLeadList.isEmpty() && !Test.isRunningTest()){
            update subLeadList;
        }    
    }
    
    //To check chatbotduplicate leads
    public static void checkChatbotDuplicates(List<lead> dupList){
        List<String> phoneNum = new List<String>();
        List<Lead> leadtoUpdate = new List<Lead>();
        List<Id> duplicateIds = new List<Id>();
        Map<String, Lead> oldMap = new Map<String, Lead>();
        Map<Id,Lead> oldMapExotel = new Map<Id,Lead>();
        for(Lead l : duplist){
            phoneNum.add(l.Phone);
            duplicateIds.add(l.Id);
        }
        Map<String,Lead> mapOfLead = new Map<String,Lead>();
        Map<String,Lead> mapOfLeads = new Map<String,Lead>();
        // Added by Mishal for ChatBot 04/01/2023
        List<Lead> oldLead = new List<Lead>();
        
        List<lead> oldLeads = new List<Lead>();
        
        List<Id> leadIds = new List<Id>();
        
        List<Lead> oldList = [Select id, name,LastName,RecordTypeName__c,Transfer_to_Agent__c,Chat_Stages__c, recordtypeid,CreatedDate, LeadSource, Lead_Type__c, phone, isduplicate__c, ExtrnId_Phone__c from lead where ExtrnId_Phone__c in :phoneNum And (LeadSource = 'MFC-Chat' OR LeadSource = 'CnB - Chat' OR LeadSource = 'Exotel') AND Id Not in : duplicateIds Order By CreatedDate desc limit 10 ];
        System.debug('oldList'+oldList);
        for(lead lea : oldList){
            if(lea.LeadSource == 'Exotel') {
                mapOfLead.put(lea.Phone,lea);
            }
            else if(lea.LeadSource == 'MFC-Chat') {
                mapOfLeads.put(lea.Phone,lea);
                
            }
            
        }
        system.debug('mapOfLead'+mapOfLead);
        for(Lead objLead:dupList) {
            if(mapOfLead.containsKey(objLead.Phone)) {
                oldLead.add(mapOfLead.get(objLead.Phone));
                leadIds.add(objLead.Id);
            }
            else if(mapOfLeads.containsKey(objLead.Phone)) {
                oldLead.add(mapOfLeads.get(objLead.Phone));
                leadIds.add(objLead.Id);
            }
        } 
        
        if(!leadIds.isEmpty()) {
            // swapping Ids
            /*
            Id oldLeadId = oldLead[0].Id;
            List<LiveChatTranscript> lstChatTranscript = [SELECT Id,LeadId FROM LiveChatTranscript WHERE LeadId = :leadIds];
            for(LiveChatTranscript chat : lstChatTranscript) {
                chat.LeadId = oldLeadId;
            }
            System.debug('lstChatTranscript ' + lstChatTranscript);
            update lstChatTranscript;
*/
        }
        
        
        // opp create
     /*   system.debug('oldLead'+oldLead);
        if(!oldLead.isEmpty()){
            createOpportunityFromLeads(oldLead);
        }  else {
            createOpportunityFromLeads(duplist);
        }*/
        
        // delete
     /*   if(!System.isFuture() && !System.isBatch()) {
            
            if(!oldLead.isEmpty()) {
                deleteLeads(leadIds, oldLead[0].Id);
            } else {
                deleteLeads(null, dupList[0].Id);
            }
            
        }*/
        //End of Mishal 04/01/2023
        
        
    }
    
    //To mark lead as DND
    public static void markLeadDND(List<Lead> leadList){
        System.debug('Lead List '+leadList);
        Set<String> phoneSet = new Set<String>();
        for(Lead lea : leadList){
            phoneSet.add(lea.Phone);
        }
        
        System.debug('Phoneset '+phoneSet);
        
        List<Lead> existingLeadList = [Select id, phone, ExtrnId_Phone__c, DoNotCall from lead where ExtrnId_Phone__c IN :phoneSet and (RecordtypeId = :LeadConstants.buyerLeadRecordTypeId OR RecordtypeId = :LeadConstants.SellerLeadRecordTypeId)];
        
        if(!existingLeadList.isEmpty() && existingLeadList[0].DoNotCall == true){
            for(Lead lea : LeadList){
                lea.DoNotCall = true;
                lea.OwnerId = '00G1s000001Kc7F';
            }
        }
    }
    
    //Added by Soumya
    public static void accDND(List<Lead> dndLeadIdSet){
        Set<Id> pushDNDToLMS = new Set<Id>();
        
        apiFired = true;
        Lead lea = new Lead();
        lea.Id = dndLeadIdSet[0].Id;
        lea.Status__c = 'Do Not Call';
        lea.OwnerId = '00G1s000001Kc7F';
        if(!Test.isRunningTest())
            update lea;
        pushDNDToLMS.add(lea.Id);
        if(!pushDNDToLMS.isEmpty()){
            LeadTriggerHelper.pushLeadToLmsfuture(pushDNDToLMS);
            LeadTriggerHelper.callDNDAPI(pushDNDToLMS);
        }
        
    }
    
    public static void callDNDAPI(Set<Id> leadids){
        sendDNDLeadToLMS(leadIds);
    }
    
    //To Send the phonenumber to LMS DND
    @future(callout = true)
    public static void sendDNDLeadToLMS(Set<Id> dndLeadIds){
        apiFired = true;
        List<LeadPushAPI__c> endpointList = LeadPushAPI__c.getAll().values();
        
        String accessToken;
        String jsonToGetAccessToken = '{"username":"crmsfdc@lms.com","password":"p@ssword","tag":"android"}';
        String accessTokenEndpoint= '';
        String resJson;
        String dndEndpoint;
        
        
        if(!endpointList.isEmpty()){
            for(LeadPushAPI__c endpnt : endpointList){
                if(endpnt.Name =='Get Token'){
                    accessTokenEndpoint = endpnt.Endpoint__c;
                }
                if(endpnt.Name == 'DND Lead'){
                    dndEndpoint = endpnt.Endpoint__c;
                }
            }
        }
        
        HttpResponse res = new HttpResponse();
      /*  if(!Test.isRunningTest()){
        //    res = HttpCalloutRequestClass.httpRequest('POST',accessTokenEndpoint,jsonToGetAccessToken,NULL);
            if(res != Null){
                System.debug('res.getBody()'+res.getBody());
                resJson = res.getBody();
            }
            Map<String,Object> untypedObject = (Map<String,Object>)JSON.deserializeUntyped(resJson);
            System.debug('untypedObject'+untypedObject);
            System.debug('untypedObject.get'+untypedObject.get('status_code'));
            if(untypedObject.get('status_code') == 200){
                accessToken = (String)untypedObject.get('access_token');
            } 
            System.debug('accessToken'+accessToken);
        }*/
        
        List<Lead> dndLead = [Select id, phone, name, DoNotCall from lead where Id = :dndLeadIds];
        
        DNDLeadRequest req = new DNDLeadRequest();
        req.customer_mobile = dndLead[0].Phone;
        req.dnd_status = 'yes';
        req.access_token = accessToken;
        
        httpResponse response1 = new HttpResponse();
      //  response1 =  FinanceLeadCallout.requestHandler('POST',dndEndpoint,JSON.serialize(req),NULL);
        
        System.debug('Response '+response1+'Response Body '+response1.getBody());
        
        
        
    }
    
    //Wrapper for DND
    public class DNDLeadRequest{
        public String access_token;
        public String customer_mobile;
        public String dnd_status;
    }
    
    
    //Added by Soumya for automated sms firing
    public static void sendSMSToUser(String smsTempName, List<Lead> smsLeadList){
        System.debug('LeadTriggerHelper.sendSMSToUser::');
        List<SMS_Template__c> templateArr = [Select Id, SMS_Body__c from SMS_Template__c where Name = :smsTempName and isActive__c = true];
        if(templateArr.isEmpty()) {
            return;
        }
        SMS_Template__c template = templateArr[0];
        
        // 20Jan2022:Asif:Start :: Bulkifying insertion to trigger SMS on every Lead in the List
        List<SMS_Log__c> logToInsert = new List<SMS_Log__c>();
        for(Lead l : smsLeadList) {
            SMS_Log__c smsLog = new SMS_Log__c();
            
            // template details
            smsLog.SMS_Template__c = template.Id;
            smsLog.SMS_Body__c = template.SMS_Body__c;
            
            // lead details
            smsLog.Lead__c = l.Id;
            smsLog.Send_To__c = l.Phone;
            if(l.RP_Dealer__c != null) {
                smsLog.rp_dealer__c = l.RP_Dealer__c;
            } 
            if(l.Dealer__c != null) {
                smsLog.Dealer__c = l.Dealer__c;
            }
            
            logToInsert.add(smsLog);
        }
        if(!logToInsert.isEmpty() && !Test.isRunningTest()) {
            insert logToInsert;
        }
        // 20Jan2022:Asif:Start 
    }
    
    //to call ecom callout class
    public static void callEcomCallout(Set<Id> leadIds){
        System.debug('LeadTriggerHelper.callEcomCallout::');
        if(apiFired) {
            System.debug('__already made callout  EcomCallout.ecomLeads');
            return;
        }
        if(!System.isBatch() && !System.isFuture()){ 
            EcomCallout.ecomLeads(leadIds);
        }
        apiFired = true;
    }   
    
    // 11Dec2021:Sarthak:Start lead conversion
    public static void onAfterConverted(List<Lead> Leadlist) {
        System.debug('LeadTriggerHelper.onAfterConverted ::');
        System.debug('Leadlist: ' + Leadlist.size());
        try {
            User currentUser = [Select Id from User where UserName =: userinfo.getUserName() LIMIT 1];
            LeadStatus convertStatus = [Select MasterLabel from LeadStatus where IsConverted = true limit 1];
            
            List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
            for (Lead lead1: Leadlist) {
                System.debug('lead1 '+lead1.Id);
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(lead1.Id);
                lc.setDoNotCreateOpportunity(true);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                lc.setOwnerId(currentUser.Id);
                
                leadConverts.add(lc);
            }
            
            Set<Id> accountIds = new Set<Id>();
            Set<Id> ContactIds = new Set<Id>();
            if (!leadConverts.isEmpty()) {
                List<Database.LeadConvertResult> lcr = Database.convertLead(leadConverts);
                for (Database.LeadConvertResult sr : lcr) {
                    if (sr.isSuccess()) {
                        accountIds.add(sr.getAccountId()); 
                        ContactIds.add(sr.getContactId()); 
                    }
                }
                System.debug('Database.LeadConvertResult: ' + lcr);
            }
            if(accountIds.size()>0){
                List<Account> AccountList =[select id from Account where id in: accountIds]; 
                if(!AccountList.isEmpty()) {
                    delete AccountList;
                }
            }
            if(ContactIds.size()>0){
                List<Contact>  ContactList =[select id from Contact where id in: ContactIds];
                if(!ContactList.isEmpty()) {
                    delete ContactList;
                }                
            }   
        } catch(Exception e) {
            System.debug('Exception: ' + e);
        }
    }
    // 11Dec2021:Sarthak:End
    
    // 11Feb2022:Asif:Start :: search dealer by code 
    public static void fillLeadDetails(List<Lead> leadArr) {
        System.debug('LeadTriggerHelper.fillLeadDetails ::');
        try {
            List<String> dealerCodeArr = new List<String>();
            Map<String, Account> dealerMap = new Map<String, Account>();
            
            for(Lead l : leadArr) {
                if(l.Dealer_Code__c != null) {
                    dealerCodeArr.add(l.Dealer_Code__c);
                }
            }
            System.debug('dealerCodeArr ' + dealerCodeArr);
            
            if(!dealerCodeArr.isEmpty()) {
                List<Account> dealerArr = [SELECT Id, Code__c FROM Account WHERE Code__c IN :dealerCodeArr And RecordType.name = 'Dealer'];
                for(Account a : dealerArr) {
                    dealerMap.put(a.Code__c, a);
                }
            }
            System.debug('dealerMap ' + dealerMap);
            
            if(!dealerMap.isEmpty()) {
                for(Lead l : leadArr) {
                    if(l.Dealer_Code__c != null && dealerMap.containsKey(l.Dealer_Code__c)) {
                        l.Dealer__c = dealerMap.get(l.Dealer_Code__c).Id;
                        l.Bypass_validation__c = false;
                        l.Status = LeadConstants.leadStatus_Qualified;
                    }
                }
            }
            
        } catch(Exception e) {
            System.debug('Exception ' + e);
        }
    }
    // 11Feb2022:Asif:End 
    
    // 9Mar2022:Asif:Start ::Updating FollowUpLead status, SubStatus on Lead:SubStatus Change
    public static void updateOppFromLead(List<Id> leadIdArr, List<Lead> leadArr) {
        System.debug('LeadTriggerHelper.updateOppFromLead ::');
        try {
            
            // getting opportunities
            Map<Id, List<Id>> leadIdToOppIdMap = new Map<Id, List<Id>>();
            for(Opportunity opp : [SELECT Id, Lead__c FROM Opportunity WHERE Lead__c IN :leadIdArr]) {
                if(leadIdToOppIdMap.containsKey(opp.Lead__c)) {
                    leadIdToOppIdMap.get(opp.Lead__c).add(opp.Id);
                } else {
                    leadIdToOppIdMap.put(opp.Lead__c, new List<Id>{opp.Id});
                }
            }
            
            // opp to update
            List<Opportunity> oppToUpdateArr = new List<Opportunity>();
            
            for(Lead l : leadArr) {
                
                // if Opportunity is not there for current Lead
                if(!leadIdToOppIdMap.containsKey(l.Id)) continue;
                
                Opportunity opp = new Opportunity();
                
                // changes
                if(l.RecordTypeId == LeadConstants.buyerLeadRecordTypeId) {
                    opp.Status__c = l.Status__c;
                    opp.Sub_Status__c = l.Sub_Status__c;
                }
                
                // iterating all opp for this lead
                for(Id oppId : leadIdToOppIdMap.get(l.Id)) {
                    opp.Id = oppId;
                    oppToUpdateArr.add(opp);
                }
            }
            
            // perform update
            if(!oppToUpdateArr.isEmpty() && !Test.isRunningTest()) {
                System.debug('oppToUpdateArr ' + oppToUpdateArr.size());
                update oppToUpdateArr;
            }
            
        } catch(Exception e) {
            System.debug('Exception ' + e);
        }
    }
    // 9Mar2022:Asif:End
    
    // 31May2022:Asif:Start :: to update Lead Owner
    public static Boolean runOnce_updateOwner = true;
    public static void updateOwner(List<Lead> leadArr) {
        if(System.isBatch() || System.isFuture()) {
            return ;
        } else {
            if(runOnce_updateOwner) {
                runOnce_updateOwner = false;
            } else {
                return ; 
            }
        }
        
        try {
            List<AssignmentRule> assignmentRuleArr = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Lead' AND Active = true LIMIT 1];
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            if(!assignmentRuleArr.isEmpty()) {
                AssignmentRule objAssignmentRule = new AssignmentRule();
                objAssignmentRule = assignmentRuleArr[0];
                dmlOpts.assignmentRuleHeader.assignmentRuleId= objAssignmentRule.id;
            }            
            List<Lead> leadToUpdateArr = new List<Lead>();
            for(Lead l : leadArr) {
                Lead lRec = new Lead();
                lRec.Id = l.Id;
                lRec.setOptions(dmlOpts);
                
                leadToUpdateArr.add(lRec);
            }
            
            update leadToUpdateArr;
            
        } catch(Exception e) {
            System.debug('Excpeption ' + e);
        }
    }
    // 31May2022:Asif:End
    // 
    //added by Mishal as part of 995
   /* public static void createOpportunityFromLeads(List<Lead> lstMfcLeads) {
        //List<Lead> lstLead = [SELECT Id,LastName, Phone FROM Lead];
        System.debug('createOpportunityFromLeads');
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        
        SET<Id> recordTypeIdSet = new SET<Id>();
        for(Lead objLead : lstMfcLeads){
            recordTypeIdSet.add(objLead.RecordTypeId);
        }
        System.debug('recordTypeIdSet == >> '+recordTypeIdSet);
        List<RecordType> recordTypeLst = new List<RecordType>();
        MAP<Id,String> mapLeadRecordType = new MAP<Id,String>();
        if(!recordTypeIdSet.isEmpty()){
             recordTypeLst = [SELECT id, DeveloperName
                              FROM RecordType
                              WHERE ID IN : recordTypeIdSet];
        }
        System.debug('recordTypeLst == >> '+recordTypeLst);
        if(!recordTypeLst.isEmpty()){
            for(RecordType obj : recordTypeLst){
                mapLeadRecordType.put(obj.Id,obj.DeveloperName);
            }
        }
        System.debug('mapLeadRecordType == '+mapLeadRecordType);
        for(Lead objLead:lstMfcLeads) {
            System.debug('objLead == >> '+objLead);
            //String leadRecordTypeName = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get(objLead.RecordTypeName__c).getRecordTypeId();            
            
            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Lead__c = objLead.Id;
            objOpportunity.LeadSource = 'MFC-Chat';
            
            if(mapLeadRecordType != null){
                if(mapLeadRecordType.containskey(objLead.RecordTypeId)){
                    if(mapLeadRecordType.get(objLead.RecordTypeId) != null){
                       // objOpportunity.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get(mapLeadRecordType.get(objLead.RecordTypeId)).getRecordTypeId();
                    }
                }
            }
            
            objOpportunity.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get(objLead.RecordTypeName__c).getRecordTypeId();
            objOpportunity.status__c = 'New';
            objOpportunity.Customer_Phone__c = objLead.Phone;
            objOpportunity.Owner__c = 'chatbot Queue';
            objOpportunity.StageName = 'Qualified Lead';
            objOpportunity.CloseDate = System.today();
            objOpportunity.Transfer_to_Agent__c = objLead.Transfer_to_Agent__c;
            objOpportunity.Chat_stages__c = objLead.Chat_Stages__c;
            
            objOpportunity.Name = objLead.LastName;
            System.debug('objLead.RecordTypeName__c == >> '+objLead.RecordTypeName__c);
            System.debug('objOpportunity.RecordTypeId == >> '+objOpportunity.RecordTypeId);
            
            lstOpportunity.add(objOpportunity);
        }
        System.debug('lstOpportunity @@@'+lstOpportunity);
        Database.insert(lstOpportunity,false);
        System.debug('lstOpportunity'+lstOpportunity);
        liveChatTranscriptOpp(lstMfcLeads[0].Id);
        
    }*/
    public static void liveChatTranscriptOpp(String Id) {
        
        List<LiveChatTranscript> lstChatTranscript = [SELECT Id,LeadId,Opportunity__c FROM LiveChatTranscript WHERE LeadId = :Id ORDER BY CreatedDate DESC LIMIT 1];
        List<Opportunity> lstOpportunity;
        if(!lstChatTranscript.isEmpty()) {
            lstOpportunity = [SELECT Id,Lead__c FROM Opportunity WHERE Lead__c =: lstChatTranscript[0].LeadId ORDER BY CreatedDate DESC LIMIT 1];
            
        }
        system.debug('lstChatTranscript'+lstChatTranscript);
        List<LiveChatTranscript> lstChatTranscriptnew = new List<LiveChatTranscript>();
        for(LiveChatTranscript objChatTranscipt:lstChatTranscript) {
            objChatTranscipt.Opportunity__c = lstOpportunity[0].Id;
            System.debug('objChatTranscipt :'+objChatTranscipt);
            lstChatTranscriptnew.add(objChatTranscipt);
            
        }
        System.debug('lstChatTranscriptnew ' +lstChatTranscriptnew);
       // update lstChatTranscriptnew;
        
    }
    // Mishal end
    @future
    public static void deleteLeads(List<Id> leadId, Id oldLeadId) {
        
        // new lead
        if(leadId == null) {
            
            List<LiveChatTranscript> lstChatTranscript = [SELECT Id,LeadId, Opportunity__c FROM LiveChatTranscript WHERE LeadId = :oldLeadId ORDER BY CreatedDate DESC LIMIT 1];
            List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Lead__c = :oldLeadId ORDER BY CreatedDate DESC LIMIT 1];
            for(LiveChatTranscript chat : lstChatTranscript) {
                if(!opps.isEmpty()) {
                    chat.Opportunity__c = opps[0].Id;
                }
            }
            System.debug('lstChatTranscript ' + lstChatTranscript);
            update lstChatTranscript;
            
        }
        
        // same lead - delete lead
        if(leadId != null) {
            List<LiveChatTranscript> lstChatTranscript = [SELECT Id,LeadId, Opportunity__c FROM LiveChatTranscript WHERE LeadId = :leadId ORDER BY CreatedDate DESC LIMIT 1];
            List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Lead__c = :oldLeadId ORDER BY CreatedDate DESC LIMIT 1];
            for(LiveChatTranscript chat : lstChatTranscript) {
                chat.LeadId = oldLeadId;
                if(!opps.isEmpty()) {
                    chat.Opportunity__c = opps[0].Id;
                }
            }
            System.debug('lstChatTranscript ' + lstChatTranscript);
            update lstChatTranscript;
            
            
            List<Lead> lstLead = [Select Id FROM Lead Where Id =:leadId];
            if(!lstLead.isEmpty()) {
                delete lstLead;
            } 
        }
        
        
    }
}