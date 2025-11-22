public class ElisionOppActivityService {
    
    public static void init(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        
        ElisionOppActivityService EOAServiceObj = new ElisionOppActivityService();
        EOAServiceObj.start(newList, oldMap);
        
    }
    
    public void start(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
      system.debug('123');  
        // filter list
        List<String> leadFlagArr = new List<String>();
        List<String> leadSourceArr = new List<String>();
        List<String> statusArr = new List<String>();
        List<String> stageArr = new List<String>();
        
        Set<String> categoryList = new Set<String>();
        
        // list for new opportunity k
        List<opportunity> oopl=new List<opportunity>();
        List<Opportunity> relatedOpportunity = new List<Opportunity>();
        
        Map<String, Opportunity> elisionOppMap = new Map<String, Opportunity>();
        Set<Id> leadId = new Set<Id>();
        Set<Id> oppId = new Set<Id>();
        
        // Girish 30-06-2023
        for(Opportunity oRec : newList) {
            leadId.add(oRec.Lead__c);
            oppId.add(oRec.Id);
        }
        
        //Fetching Related Opportunity
        Set<Id> relatedOpportunityId = new Set<Id>();
        relatedOpportunity = [Select Id  from Opportunity where Lead__c IN :leadId ]; // Girish 30-06-2023
        System.debug('relatedOpportunity > '+relatedOpportunity);
        for(Opportunity opp : relatedOpportunity){
            relatedOpportunityId.add(opp.Id);
        }
        System.debug('relatedOpportunityId > '+relatedOpportunityId);
        
        Set<Id> relatedAccountId = new Set<Id>();
        
        List<Task> taskRec = [Select Id, AccountId from Task where WhatId IN :relatedOpportunityId And Status = 'Open' AND RecordTypeName__c = 'Elision' ]; //27-JUN-2023:Sachin :: CRM-1161 : Get record of Elision recordtype
        for(Task tRec1 : taskRec) {
            relatedAccountId.add(tRec1.AccountId);
        }
        System.debug('relatedAccountId > '+relatedAccountId);
        
        // fetching eligibles campaigns
        Map<String, Elision_Campaign__c> elisionCampaignMatchedMap = new Map<String, Elision_Campaign__c>();
        
        // querying campaings
        List<Elision_Campaign__c> elisionCampaignDBArr = [SELECT Id, Name, Dealer__c, City__c, Lead_Flag__c, Lead_Source__c, Status__c, Stage__c, Elision_Campaign_Category__c, Campaign_Id_NWH__c, Campaign_Id_WH__c FROM Elision_Campaign__c Where isActive__c = true ]; //22-JUN-2023:Sachin :: CRM-1161 : Added Dealer and CIty in query and checking for active record
        System.debug('elisionCampaignDBArr ' + elisionCampaignDBArr);
        for(Elision_Campaign__c ecRec : elisionCampaignDBArr) {
            //String keyStr = ecRec.Lead_Flag__c + '-' + ecRec.Lead_Source__c + '-' + ecRec.Status__c + '-' + ecRec.Stage__c;
            
            elisionCampaignMatchedMap.put(ecRec.Elision_Campaign_Category__c, ecRec);
        }
        System.debug('elisionCampaignMatchedMap ' + elisionCampaignMatchedMap);
        
        // Working hours calcs
        DateTime businessStartTime = Datetime.newInstanceGMT(System.now().year(), System.now().month(), System.now().day(), 3, 30, 0);
        DateTIme businessEndTime = businessStartTime.addHours(10); // 03-AUG-2023:Sachin::CRM:1173:Changing of working hours
        DateTime nextWorkingHourDT = businessStartTime.addDays(1);
        DateTime nextWorkingHourD = nextWorkingHourDT.addMinutes(-60* 14);// 03-AUG-2023:Sachin::CRM:1173:Changing of working hours
        
        System.debug('businessStartTime > '+businessStartTime);
        System.debug('businessEndTime > '+businessEndTime);
        System.debug('nextWorkingHourDT > '+nextWorkingHourDT);
        System.debug('nextWorkingHourD > '+nextWorkingHourD);
        
        List<Task> taskToInsertArr = new List<Task>();
        List<Opportunity> oRecToUpdateArr = new List<Opportunity>();
        
        system.debug('oppList' +oopl); 
        // Matching opp with Campaigns
        for(Opportunity oRec : newList) {
            if(relatedAccountId.contains(oRec.AccountId))
            {
                System.debug('__83__');
                continue;
            }
            Opportunity oRec1 = new Opportunity( Id = oRec.id);
            String keyStr = '';
            
            if(oRec.LeadSource == 'MFC-Chat')
            {
                System.debug('__89__');
                continue;
            }
            else if(oRec.LeadSource == 'Exotel')
            {
                System.debug('__94__');
                continue;
            }
            else if(oRec.Dealer_Code_for_opp__c == '4419' || oRec.Dealer_Code_for_opp__c == '4317' )
            {
                System.debug('__99__');
                continue;
            }
            else if(oRec.Lead_Flag__c == 'PaymentPending')
            {
                System.debug('__104__');
                continue;
            }
            else if(oRec.LeadSource == 'Call Centre')
            {
                System.debug('__109__');
                Continue;
            }
            else if(oRec.status__c=='New' && oRec.Dealer_Role__c == 'RD' && oRec.Marketing_Source__c == 'FBLeadForms' && elisionCampaignMatchedMap.containsKey('FB Lead Forms') && elisionCampaignMatchedMap.get('FB Lead Forms').Dealer__c.replaceAll( '\\s+', '').split(',').contains(oRec.Dealer_Code_for_opp__c)){ //20-Sep-2023:Sachin :: CRM-1180: Start
                System.debug('inside else if for FBLeadForms');
                oRec1.Elision_Campaign_Category__c = 'FB Lead Forms';
                oRec1.Call_Center_Lead__c = true;
                oopl.add(oRec1);
                keyStr = 'FB Lead Forms';
            }                                                                            //20-Sep-2023:Sachin :: CRM-1180: End
            else if((oRec.Dealer_Role__c == 'RD' || oRec.Dealer_Role__c == 'Autokart' || oRec.Dealer_Role__c == 'MFC XMart')) // 22-feb-2023 : Shivam : CRM 1097
            {
                System.debug('__114__');
                Continue;
            }
            else if(oRec.Stock_Type_From_Product__c != 'Private' && oRec.Product__c != null ) // 22-feb-2023 : Shivam : CRM 1097
            {
                System.debug('__119__');
                Continue;
			}
            else if(oRec.Lead_Flag__c=='Reserve' && (oRec.status__c=='New'|| oRec.status__c=='Reserved') && oRec.StageName=='New') {
                oRec1.Elision_Campaign_Category__c = 'Ecomm Reservation';
                oRec1.Call_Center_Lead__c = true;  //17-Aug-2023:Sachin :: CRM-1177
                oopl.add(oRec1);
                keyStr = 'Ecomm Reservation';
                system.debug('oppList __126__' +oRec1); 
                
                //leadFlagArr.add(oRec.Lead_Flag__c);
            }
            else if(oRec.Lead_Flag__c=='uc_testdrive' && (oRec.status__c=='New'|| oRec.status__c=='Test Drive' || oRec.status__c=='Test Drive Scheduled') && (oRec.StageName=='New' || oRec.StageName=='Test Drive')){
                oRec1.Elision_Campaign_Category__c = 'Ecomm TestDrive';
                oRec1.Call_Center_Lead__c = true;  //17-Aug-2023:Sachin :: CRM-1177
                oopl.add(oRec1);
                keyStr = 'Ecomm TestDrive';
                system.debug('oppList__134__' +oRec1);
            } 
            else if(oRec.Lead_Flag__c=='PaymentFailed' && (oRec.status__c=='New'|| oRec.status__c=='Payment Failed') && oRec.StageName=='New'){
                oRec1.Elision_Campaign_Category__c = 'Ecomm PaymentFailed';
                oRec1.Call_Center_Lead__c = true;  //17-Aug-2023:Sachin :: CRM-1177
                oopl.add(oRec1);
                keyStr = 'Ecomm PaymentFailed';
                system.debug('oppList __140__' +oRec1);
            }
            else if(oRec.Lead_Flag__c == 'inspection report' && oRec.status__c=='New' && oRec.StageName=='New' )
            {
                oRec1.Elision_Campaign_Category__c = 'Inspection Report Download';
                oRec1.Call_Center_Lead__c = true;  //17-Aug-2023:Sachin :: CRM-1177
                oopl.add(oRec1);
                keyStr = 'Inspection Report Download';
                system.debug('oppList __147__' +oRec1);
            }
            //Start : 09-JUN-2023:Sachin :: CRM-1158 : Added new Elision campaigns and mapped the dealer code //Start : 22-JUN-2023:Sachin :: CRM-1161 : New automation added for checking the elision campaign of records. // Girish 30-06-2023
            else if(oRec.status__c=='New' && oRec.Lead_Category__C == 'CNB MS' && elisionCampaignMatchedMap.containsKey('NCR Cluster - Microsite') && elisionCampaignMatchedMap.get('NCR Cluster - Microsite').Dealer__c.replaceAll( '\\s+', '').split(',').contains(oRec.Dealer_Code_for_opp__c)) 
            { 
                System.debug('inside else if for NCR Cluster - Microsite');
                oRec1.Elision_Campaign_Category__c = 'NCR Cluster - Microsite';
                oRec1.Call_Center_Lead__c = true;  //17-Aug-2023:Sachin :: CRM-1177
                oopl.add(oRec1);
                keyStr = 'NCR Cluster - Microsite';
            }
            else if(oRec.status__c=='New' && oRec.Lead_Category__C == 'CNB MS' && elisionCampaignMatchedMap.containsKey('Kerala Cluster - Microsite') && elisionCampaignMatchedMap.get('Kerala Cluster - Microsite').Dealer__c.replaceAll( '\\s+', '').split(',').contains(oRec.Dealer_Code_for_opp__c)) 
            { 
                System.debug('inside else if for Kerala Cluster - Microsite');
                oRec1.Elision_Campaign_Category__c = 'Kerala Cluster - Microsite';
                oRec1.Call_Center_Lead__c = true;  //17-Aug-2023:Sachin :: CRM-1177
                oopl.add(oRec1);
                keyStr = 'Kerala Cluster - Microsite';
            }
            else if(oRec.status__c=='New' && oRec.Lead_Category__C == 'CNB MS' && elisionCampaignMatchedMap.containsKey('Maharashtra Cluster - Microsite') && elisionCampaignMatchedMap.get('Maharashtra Cluster - Microsite').Dealer__c.replaceAll( '\\s+', '').split(',').contains(oRec.Dealer_Code_for_opp__c))
            { 
                System.debug('inside else if for Maharashtra Cluster - Microsite');
                oRec1.Elision_Campaign_Category__c = 'Maharashtra Cluster - Microsite';
                oRec1.Call_Center_Lead__c = true;  //17-Aug-2023:Sachin :: CRM-1177
                oopl.add(oRec1);
                keyStr = 'Maharashtra Cluster - Microsite';
            }
            else if(oRec.status__c=='New' && elisionCampaignMatchedMap.containsKey('NCR Cluster') && (elisionCampaignMatchedMap.get('NCR Cluster').Dealer__c.replaceAll( '\\s+', '').split(',').contains(oRec.Dealer_Code_for_opp__c) || (oRec.Dealer_Role__c == 'Focus Cluster RD' && elisionCampaignMatchedMap.get('NCR Cluster').City__c.replaceAll( '\\s+', '').toUppercase().split(',').contains((oRec.Dealer_City__c).toUppercase()))))
            { 
                System.debug('inside else if for NCR Cluster');
                oRec1.Elision_Campaign_Category__c = 'NCR Cluster';
                oRec1.Call_Center_Lead__c = true;  //17-Aug-2023:Sachin :: CRM-1177
                oopl.add(oRec1);
                keyStr = 'NCR Cluster';
            }
            else if(oRec.status__c=='New' && elisionCampaignMatchedMap.containsKey('Kerala Cluster') && (elisionCampaignMatchedMap.get('Kerala Cluster').Dealer__c.replaceAll( '\\s+', '').split(',').contains(oRec.Dealer_Code_for_opp__c) || (oRec.Dealer_Role__c == 'Focus Cluster RD' && elisionCampaignMatchedMap.get('Kerala Cluster').City__c.replaceAll( '\\s+', '').toUppercase().split(',').contains((oRec.Dealer_City__c).toUppercase()))))
            { 
                System.debug('inside else if for Kerala Cluster');
                oRec1.Elision_Campaign_Category__c = 'Kerala Cluster';
                oRec1.Call_Center_Lead__c = true;  //17-Aug-2023:Sachin :: CRM-1177
                oopl.add(oRec1);
                keyStr = 'Kerala Cluster';
            }
            else if(oRec.status__c=='New' && elisionCampaignMatchedMap.containsKey('Maharashtra Cluster') && (elisionCampaignMatchedMap.get('Maharashtra Cluster').Dealer__c.replaceAll( '\\s+', '').split(',').contains(oRec.Dealer_Code_for_opp__c) || (oRec.Dealer_Role__c == 'Focus Cluster RD' && elisionCampaignMatchedMap.get('Maharashtra Cluster').City__c.replaceAll( '\\s+', '').toUppercase().split(',').contains((oRec.Dealer_City__c).replaceAll( '\\s+', '').toUppercase())))) // 24-Jul-2023:Sachin:CRM:1169::Added sapce remover for Dealer City
            { 
                System.debug('inside else if for Maharashtra Cluster');
                oRec1.Elision_Campaign_Category__c = 'Maharashtra Cluster';
                oRec1.Call_Center_Lead__c = true;  //17-Aug-2023:Sachin :: CRM-1177
                oopl.add(oRec1);
                keyStr = 'Maharashtra Cluster';
            }
            //End : 09-JUN-2023:Sachin::CRM-1158 : Added new Elision campaigns and mapped the dealer code //End : 22-JUN-2023:Sachin :: CRM-1161 : New automation added for checking the elision campaign of records. // Girish 30-06-2023
            else if(oRec.status__c=='New' && oRec.StageName=='New' && oRec.Zone__c=='South'){
                oRec1.Elision_Campaign_Category__c = 'General BUC - South';
                oRec1.Call_Center_Lead__c = true;  //17-Aug-2023:Sachin :: CRM-1177
                oopl.add(oRec1);
                keyStr = 'General BUC - South';
            }
            else if(oRec.status__c=='New' && oRec.StageName=='New'){
                oRec1.Elision_Campaign_Category__c = 'General BUC - Others';
                oRec1.Call_Center_Lead__c = true;  //17-Aug-2023:Sachin :: CRM-1177
                oopl.add(oRec1);
                keyStr = 'General BUC - Others';
                System.debug('oopl ' + oRec) ;
            }
            
            System.debug('Elision Camp: '+elisionCampaignMatchedMap.get(keyStr)+' '+keyStr);
            
            //String keyStr = oRec.Lead_Flag__c + '-' + oRec.LeadSource + '-' + oRec.status__c + '-' + oRec.StageName;
            if(!elisionCampaignMatchedMap.containsKey(keyStr)) 
            {
                continue;
            }
            Elision_Campaign__c ecRec = elisionCampaignMatchedMap.get(keyStr);
            
            DateTime elisionDueDate;
            // Business hour check
            Boolean isInBusinessHour;
            if(oRec.LastModifiedDate >= businessStartTime && oRec.LastModifiedDate <= businessEndTime) { // In Businness Hour
                isInBusinessHour = true;
                elisionDueDate = oRec.LastModifiedDate.addMinutes(15);
            } else { // out Business Hour
                isInBusinessHour = false;
                elisionDueDate = oRec.LastModifiedDate >= nextWorkingHourD ? businessStartTime : nextWorkingHourDT;
                elisionDueDate = elisionDueDate.addHours(1);
            }
            
            system.debug('1234');
            
            // if matched create Activity for Opp
            Task tRec = new Task();       
            tRec.WhatId = oRec.Id;
            tRec.Elision_Campaign__c = ecRec.Id;
            tRec.Campaign_Id__c = isInBusinessHour ? ecRec.Campaign_Id_WH__c : ecRec.Campaign_Id_NWH__c;
            tRec.Campaign_Name__c = ecRec.Name;
            tRec.Subject = 'Elision BUC Call';
            tRec.Elision_Due_Date__c = elisionDueDate;
            tRec.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('Elision').getRecordTypeId();
            taskToInsertArr.add(tRec);
            
            system.debug('taskToInsertArr' +taskToInsertArr); 
            
            
            // to update opp
            // Opportunity oRecToUpdate = new Opportunity(
            //     Id = oRec.Id
            // );
            //oRecToUpdate.Elision_Campaign_Category__c = ecRec.Elision_Campaign_Category__c;
            oRecToUpdateArr.add(oRec1);
        }
        //System.debug('taskToInsertArr ' + taskToInsertArr);
        
        //function for Task object       
        
        
        // Task insert
        if(!taskToInsertArr.isEmpty()) {
            insert taskToInsertArr;
        }
        
        System.debug('oRecToUpdateArr ' + oRecToUpdateArr);
        // Opp update
        if(!oRecToUpdateArr.isEmpty()) {
            update oRecToUpdateArr;
        }
    }    
}