//Added by Aravindan

public class ExotelCallSummaryTriggerHelper {
    //added by Swetha
    public static void createLeadRecord(list<Exotel_Call_Summary__c> newlist){
        Id buyerLeadRecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Buyer_Used_Car').getRecordTypeId();
        List<Lead> LeadsToInsert = new List<Lead>();
        Set<String> dealerPhones = new Set<String>();
        Map<String,Account> dealerMap = new Map<String,Account>();  
        List<Opportunity> oppoList = new List<Opportunity>();    //Added by Shubham
        Set<id> leadIds = new Set<Id>();
        List<id> AccId = new List<id>();
        Map<String,String> RemoveExotelRecord = new Map<String,String>();
        Map<String,String> CustomerNumberAndDealerNumber = new Map<String,String>();
        String dealerRTId = AccountConstants.dealerAccountRecordTypeId;
        Map<String,Exotel_Call_Summary__c> mapToOpportunity = new Map<String,Exotel_Call_Summary__c>();
        Map<String,String> DealerPhoneWithOppId = new Map<String,String>();
        Map<String,String> DealerPhoneWithLeadId = new Map<String,String>();
        Set<String> leadIdFromOpp = new Set<String>();
        Set<String> customerPhones = new Set<String>(); 
        Opportunity objOpportunity = new Opportunity();
        Set<Id> setIds = new Set<Id>();
        
        
        System.debug('***newlist****' + newlist);
        
        for(Exotel_Call_Summary__c item : newlist){
            dealerPhones.add(right(item.OutgoingPhoneNumber__c,10));
            CustomerNumberAndDealerNumber.put(right(item.OutgoingPhoneNumber__c,10), right(item.From__c,10));
            mapToOpportunity.put(right(item.OutgoingPhoneNumber__c,10),item);
            customerPhones.add(right(item.From__c,10));
            
        }
        
        
        System.debug('***dealerPhones****' + dealerPhones);
        System.debug('***CustomerNumberAndDealerNumber****' + CustomerNumberAndDealerNumber);
        System.debug('*** customerPhones *** '+customerPhones);
        
        
        for(Account a : [select id,Phone,Exotel_Landing_Number__c,Code__c, BillingState from Account where Exotel_Landing_Number__c IN: dealerPhones And RecordTypeId =: dealerRTId]){
            dealerMap.put(a.Exotel_Landing_Number__c, a);  
            AccId.add(a.Id);         
        }
        
        System.debug('**AccId******' + AccId);
        System.debug('**dealerMap******' + dealerMap);
        
        //followup check
        List<Opportunity> UpdateOpportunityList = new List<Opportunity>();
        
        Map<String, Opportunity> updateLeadSourceFromOpp = new Map<String, Opportunity>();
        for(Opportunity o : [select id,name,Dealer_Phone__c, Exotel_Call__c,dealer__r.Exotel_Landing_Number__c, Status__c,Dealer__c, Exotel_Repeat__c,Customer_Phone__c,Lead__c from Opportunity where Dealer__c IN :AccId AND Status__c != 'Sold' AND Status__c != 'Lost' AND dealer__r.Exotel_Landing_Number__c != NULL AND dealer__r.Exotel_Landing_Number__c IN :dealerPhones AND Customer_Phone__c != null AND Customer_Phone__c IN :customerPhones]){
            // checking for Account is present or not
            
            if(dealerMap.containsKey(o.dealer__r.Exotel_Landing_Number__c) && CustomerNumberAndDealerNumber.containsKey(o.dealer__r.Exotel_Landing_Number__c))
            {
                if(o.Dealer__c != null && o.Dealer__c == dealerMap.get(o.dealer__r.Exotel_Landing_Number__c).id && o.Customer_Phone__c == CustomerNumberAndDealerNumber.get(o.dealer__r.Exotel_Landing_Number__c)) 
                    
                {
                    
                    RemoveExotelRecord.put(o.dealer__r.Exotel_Landing_Number__c,o.Dealer__c);
                    DealerPhoneWithOppId.put(o.dealer__r.Exotel_Landing_Number__c,o.id);
                    DealerPhoneWithLeadId.put(o.dealer__r.Exotel_Landing_Number__c, o.Lead__c);
                    Opportunity o1 = new Opportunity();
                    o1.Id = o.id;
                    o1.Exotel_Repeat__c = true;
                    o1.Exotel_Repeat_Date_Time__c = System.now();
                    if(mapToOpportunity.get(o.dealer__r.Exotel_Landing_Number__c).CallType__c == 'Completed'){
                        //    o1.status__c = 'Exotel Call';
                        o1.status__c = 'New';
                        updateLeadSourceFromOpp.put(o.Customer_Phone__c, o1);
                        leadIdFromOpp.add(o.Lead__c);
                    }
                    else{
                        //  o1.status__c = 'Exotel Missed Call';
                        o1.status__c = 'New';
                        updateLeadSourceFromOpp.put(o.Customer_Phone__c, o1);
                        leadIdFromOpp.add(o.Lead__c);
                    }
                    UpdateOpportunityList.add(o1);
                }
            }
        }
        System.debug('updateLeadSourceFromOpp '+updateLeadSourceFromOpp);
        System.debug('Lead Ids '+leadIdFromOpp);
        //Added by soumya to update leadsource in lead accordingly
        List<Lead> updateLead = new List<Lead>();
        for(Lead l : [Select id, leadSource, Exotel_Repeat__c, status__c, Phone from lead where Id IN :leadIdFromOpp AND status != 'Lost' AND recordtypeId = :buyerLeadRecordTypeId]){
            System.debug('l '+l);
            if(updateLeadSourceFromOpp.containsKey(l.Phone)){
                System.debug('Entered');
                l.Status__c = updateLeadSourceFromOpp.get(l.Phone).Status__c;
                //  if(l.Exotel_Repeat__c == false){
                //   l.Exotel_Repeat__c = true;
                //    }
                updateLead.add(l);
            }
        }
        System.debug('updateLead '+updateLead);
        if(!updateLead.isEmpty()){
            update updateLead;
        }
        
        System.debug('RemoveExotelRecord'+RemoveExotelRecord);
        System.debug('****UpdateOpportunityList***** ' + UpdateOpportunityList + ' ***List Size** ' + UpdateOpportunityList.size());
        if(!UpdateOpportunityList.isEmpty()){
            update UpdateOpportunityList;
        }
        
        //Added By Aravindan
        System.debug('*******mapToOpportunity*******' + mapToOpportunity);
        System.debug('*******DealerPhoneWithOppId*******' + DealerPhoneWithOppId);
        Set<String> setOfIdsToUpdate = new Set<String>();
        List<Exotel_Call_Summary__c> UpdateExotelRecordList = new List<Exotel_Call_Summary__c>();
        List<Exotel_Call_Summary__c> UpdateExotelRecordList1 = new List<Exotel_Call_Summary__c>();
        if(DealerPhoneWithOppId.size() > 0){
            for(String key : DealerPhoneWithOppId.keySet()){ 
                setOfIdsToUpdate.add(mapToOpportunity.get(key).id);
            }
        }
        
        if(setOfIdsToUpdate.size() > 0){
            UpdateExotelRecordList = [select id, name,Leads_assigned_to_Dealers__c,OutgoingPhoneNumber__c from  Exotel_Call_Summary__c where id IN: setOfIdsToUpdate];
        }
        
        for(Exotel_Call_Summary__c sum : UpdateExotelRecordList)  
        {
            // sum.Leads_assigned_to_Dealers__c = DealerPhoneWithOppId.get(right(sum.OutgoingPhoneNumber__c,10));
            //  sum.Lead__c = DealerPhoneWithLeadId.get(right(sum.OutgoingPhoneNumber__c,10));
            UpdateExotelRecordList1.add(sum);
        }
        
        if(!UpdateExotelRecordList1.isEmpty())
        {
            Database.update(UpdateExotelRecordList1,False);
        }
        
        List<AssignmentRule> lstAssignmentRule = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Lead' AND Active = true LIMIT 1];
        AssignmentRule objAssignmentRule = new AssignmentRule();
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        if(lstAssignmentRule.size() > 0)
        {
            objAssignmentRule = lstAssignmentRule[0];
            dmlOpts.assignmentRuleHeader.assignmentRuleId= objAssignmentRule.id;
        }
        //17oct2022:Shubham:Start:Lead is created only if there is no lead with the same phone number for buc recordtype
        List<Lead> leadlist = [Select Id,RecordTypeId,Phone,LastName from Lead Where RecordTypeId=:LeadConstants.buyerLeadRecordTypeId AND Phone=:right(newlist[0].From__c,10)];
        if(leadlist.isEmpty()) {
            //Shubham:End  
            
            for(Exotel_Call_Summary__c item : newlist){
                if(!RemoveExotelRecord.containsKey(right(item.OutgoingPhoneNumber__c,10)))
                {
                    Lead leadRecord = new Lead();
                    leadRecord.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Buyer Used Car').getRecordTypeId();
                    leadRecord.LeadSource = 'Exotel';
                    leadRecord.Lead_Type__c = 'USEDCARSALES';
                    leadRecord.LastName = 'Exotel Call ' + right(item.From__c,10);
                    leadRecord.Phone = right(item.From__c,10);
                    leadRecord.IsDuplicate__c = false;
                    leadRecord.Reassignment__c = 'No';
                    
                    if(item.CallType__c == 'completed'){
                        leadRecord.Call_Type__c = 'Exotel Call';
                        leadRecord.Lead_Category__c = 'Exotel Call';
                        // 19/12/2022:Shubham:Start :: CRM-989-Set default status for Fresh and Followup leads created by Open to "New"	
                        leadRecord.Status__c = 'New';	
                        // 19/12/2022:Shubham:End :: CRM-989-Set default status for Fresh and Followup leads created by Open to "New"
                        
                    } else{
                        leadRecord.Call_Type__c = 'Exotel Missed Call';
                        leadRecord.Lead_Category__c = 'Exotel Missed Call';
                        // 19/12/2022:Shubham:Start :: CRM-989-Set default status for Fresh and Followup leads created by Open to "New"	
                        leadRecord.Status__c = 'New';	
                        // 19/12/2022:Shubham:End :: CRM-989-Set default status for Fresh and Followup leads created by Open to "New"
                    }
                    
                    if(dealerMap.containsKey(right(item.OutgoingPhoneNumber__c,10))){
                        // leadRecord.Dealer__c = dealerMap.get(right(item.OutgoingPhoneNumber__c,10)).Id;
                        if(dealerMap.get(right(item.OutgoingPhoneNumber__c,10)).BillingState != null){
                            leadRecord.Area_State__c = dealerMap.get(right(item.OutgoingPhoneNumber__c,10)).BillingState.toUpperCase();
                        }
                        leadRecord.Status = LeadConstants.leadStatus_Qualified;
                        
                    }
                    leadRecord.setOptions(dmlOpts);
                    LeadsToInsert.add(leadRecord);
                    
                }
                
            }
            system.debug('LeadsToInsert' + LeadsToInsert);
            if(LeadsToInsert.size() > 0){
                Database.insert(LeadsToInsert, false);
                system.debug('LeadsToInsert' + LeadsToInsert);
            }
            //17oct2022:Shubham:Start
            // because we are inserting new lead so insert opp new as well here. 
            List<Opportunity> lstObjOpportunity = [SELECT Id, Lead__c,StageName,Name,Dealer__c,CreatedDate,LeadSource,Phone__c, Exotel_Call__c FROM Opportunity where LeadSource='Exotel' AND Phone__c = :right(newlist[0].From__c,10) AND Lead__c =:LeadsToInsert[0].Id order
                                                   by CreatedDate desc LIMIT 1];
            System.debug('lstObjOpportunity' + lstObjOpportunity);
            for(Opportunity objOpp:lstObjOpportunity) {
                system.debug('objOpp'+objOpp);
                setIds.add(objOpp.Id);
            }
            if(lstObjOpportunity.isEmpty()) {
                system.debug('lstObjOpportunity ' + lstObjOpportunity);  
                for(Lead l : LeadsToInsert){
                    system.debug('l'+l);
                    //  if(l.Dealer__c != null){
                    if(dealerMap.containsKey(right(newlist[0].OutgoingPhoneNumber__c,10))){    
                        leadIds.add(l.Id);
                        Opportunity opp = new Opportunity();
                        opp.Lead__c = l.Id;
                        opp.StageName = 'New'; // Sumit::CRM-1062-Default Opportunity stage on creation should be "New" and not "Qualification"
                        opp.Name = l.LastName;
                        opp.Dealer__c = dealerMap.get(right(newlist[0].OutgoingPhoneNumber__c,10)).Id;
                        //   opp.Phone__c = l.Phone;
                        opp.LeadSource = 'Exotel';
                        // 21/12/2022:Shubham:Start :: CRM-989-Set default status for Followup leads created by l.Call_Type__c to "New"
                        opp.status__c = 'New'; 
                        // 21/12/2022:Shubham:End :: CRM-989-Set default status for Followup leads created by l.Call_Type__c to "New"
                        opp.Customer_Phone__c = LeadsToInsert[0].Phone;
                        opp.CloseDate = System.today();  
                        opp.Dealer_Phone__c = dealerMap.get(right(newlist[0].OutgoingPhoneNumber__c,10)).Exotel_Landing_Number__c;
                        opp.Dealer_Code__c = dealerMap.get(right(newlist[0].OutgoingPhoneNumber__c,10)).Code__c;
                        if(dealerMap.get(right(newlist[0].OutgoingPhoneNumber__c,10)).BillingState != null){
                            opp.State__c = dealerMap.get(right(newlist[0].OutgoingPhoneNumber__c,10)).BillingState.toUpperCase();
                        }  
                        System.debug('opp'+opp);
                        oppoList.add(opp);
                        system.debug('oppoList'+oppoList);
                        
                    }
                    system.debug('oppoList'+oppoList);
                    if(oppoList.size() > 0){
                        insert oppoList;
                        system.debug('oppoList' + oppoList);
                        if(leadIds.size() > 0){
                            LeadConstants.fireLMSApiFromLead = TRUE;
                            LeadTriggerHelper.pushSingleLeadsToLMS(leadIds);
                        }
                        Exotel_Call_Summary__c item1 = new Exotel_Call_Summary__c();
                        system.debug('item1 ' + item1);
                        item1.Leads_assigned_to_Dealers__c = oppoList[0].Id;
                        item1.Lead__c = null;
                        item1.Id= newlist[0].Id;
                        update item1;
                        system.debug('item1 ' + item1);
                    }
                }
                
                
            }   
            
        }
        //17oct:Shubham:End
        
        //18oct:Shubham:Start
        else {
            // because we are updating same existing lead, so create new opp on the same lead here.
            
            List<Opportunity> lstOpps = [Select Id,Dealer__c,LeadSource From Opportunity where Dealer__c =:dealerMap.get(right(newlist[0].OutgoingPhoneNumber__c,10)).Id AND LeadSource = 'Exotel' AND Lead__c =:leadlist[0].Id];
            system.debug('lstOpps ' + lstOpps);
            if(lstOpps.isEmpty()){
                system.debug('lstOpps ' + lstOpps);
                Opportunity oplist = new Opportunity();
                system.debug('oplist ' + oplist);
                oplist.Lead__c = leadlist[0].Id;
                oplist.StageName = OpportunityConstants.OpportunityStage_Qualification;
                oplist.CloseDate = System.today();
                // 21/12/2022:Shubham:Start :: CRM-989-Set default status for Followup leads created by Open to "New"
                oplist.status__c = 'New';  
                // 21/12/2022:Shubham:End :: CRM-989-Set default status for Followup leads created by Open to "New"
                oplist.Phone__c = right(newlist[0].From__c,10);
                oplist.Name = leadlist[0].LastName;
                //  oplist.State__c = dealerMap.get(right(newlist[0].OutgoingPhoneNumber__c,10)).BillingState.toUpperCase();
                oplist.LeadSource = 'Exotel';
                oplist.Customer_Phone__c = right(newlist[0].From__c,10);
                
                oplist.Dealer__c = dealerMap.get(right(newlist[0].OutgoingPhoneNumber__c,10)).Id;
                oplist.Dealer_Code__c = dealerMap.get(right(newlist[0].OutgoingPhoneNumber__c,10)).Code__c;
                oplist.Dealer_Phone__c = dealerMap.get(right(newlist[0].OutgoingPhoneNumber__c,10)).Exotel_Landing_Number__c;
                
                insert oplist;
                system.debug('oplist '+ oplist);
                
                Exotel_Call_Summary__c item2 = new Exotel_Call_Summary__c();
                system.debug('item2 ' + item2);
                item2.Leads_assigned_to_Dealers__c = oplist.Id;
                item2.Lead__c = null;
                item2.Id= newlist[0].Id;
                update item2;
                system.debug('item2 ' + item2); 
                
                
            }
            
            else
            {
                for(Exotel_Call_Summary__c objExotel:newlist) {
                    lstOpps[0].Exotel_Call__c = objExotel.Id;
                    system.debug('lstOpps ' + lstOpps);
                    
                }
                
                try {
                    update lstOpps;
                    system.debug('lstOpps '+ lstOpps);
                }
                catch(Exception e) {
                    system.debug(e.getMessage());
                }
            } 
            
        }
    }
    //18oct:shubham:end
    
    //added by Swetha
    public static String right(String s, Integer i) {
        if (s == null || s == '' || i <=0 ) {
            return '';
        } else if (i >= s.length()) {
            return s;
        } else {
            return s.subString(s.length() - i, s.length());
        }
    }
    
    @future(callout = True)
    public static void callExotelCallout(Set<Id> exotelIds){
        if(!exotelIds.isEmpty()){
            ExotelCallout.sendExotelInfo(exotelIds);
        }
    }
    
    
}