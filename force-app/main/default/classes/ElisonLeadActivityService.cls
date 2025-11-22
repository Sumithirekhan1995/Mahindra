public class ElisonLeadActivityService {
    public static void init(List<Lead> newList, Map<Id, Lead> oldMap) {
        
        ElisonLeadActivityService ELAServiceObj = new ElisonLeadActivityService();
        ELAServiceObj.start(newList, oldMap);
        
    } 
    public void start(List<Lead> newList, Map<Id, Lead> oldMap) {
        //for eligibles campaigns
        Set<String> categoryList = new Set<String>();
        //list for new lead
        List<Lead> lead1=new List<Lead>();
        
        // Business hour check
        DateTime elisionDueDate;
        Boolean isInBusinessHour;
        Set<Id> leadId = new Set<Id>();
        Set<String> phone = new Set<String>();
        
        Map<String, Lead> elisionLeadMap = new Map<String, Lead>();
        
        //for custom setting record 
        List<String> cityList = new List<String>();
        List<HiServiceableCity__c> hiServiceableCityList = [Select City__c from HiServiceableCity__c];
        for(HiServiceableCity__c hsc : hiServiceableCityList) {
            cityList.add(hsc.city__c.toLowerCase());
        }
        
        for(Lead lRec : newList) {
            
            phone.add(lRec.Phone);
            leadId.add(lRec.Id);
            
            Lead lRec1 = new Lead( Id = lRec.id);
            
            String keyStr = lRec.RecordTypeId + '-' + lRec.HI_Serviceable__c + '-' + lRec.CTIDuplicate__c;
            System.debug('Lea Status'+lRec.RecordTypeId +' '+lRec.HI_Serviceable__c+' '+lRec.CTIDuplicate__c + ' '+lRec.Seller_City__c);
            //12-06-2025:Sachin:CRM:1312: Start:ELV_Lead_Source campaign
            if (lRec.RecordTypeId == LeadConstants.ElvLeadRecordTypeId && lRec.LeadSource == 'ELV') {
                System.debug('Lea Status'+lRec);
                categoryList.add('ELV Lead source'); 
            }
            //CRM:1312:End:ELV_Lead_Source campaign
            //18-06-2025:Sachin:CRM:1316: Start:PI campaign
            else if(lRec.RecordTypeId == LeadConstants.ElvLeadRecordTypeId && lRec.LeadSource == 'PI') {
                System.debug('Lea Status'+lRec);
                categoryList.add('Premium Inspection'); 
            }
            //CRM:1316:End:PI campaign
            else if( lRec.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && lRec.HI_Serviceable__c == '1' && lRec.CTIDuplicate__c ==false && lRec.Seller_City__c !=null && cityList.contains(lRec.Seller_City__c.toLowerCase()) )
            {
                System.debug('Lea Status'+lRec);
                if((lRec.Status__c=='Open' || lRec.Status__c==null )&&(lRec.Status =='New'|| lRec.Status =='Open'||lRec.Status =='Follow Up'|| lRec.Status ==null ) )
                {
                    if(lRec.ICO_eligible_flag__c)            //04-APR-2023: Sachin: CRM::1126: Start
                    {
                        if(lRec.Lead_Flag__c == 'non_ico_journey_completed_user_dropped' || lRec.Lead_Flag__c == 'ico_journey_pending_user_dropped' || lRec.Lead_Flag__c == 'ico_journey_completed'){
                        categoryList.add('HI Procurement');   
                        }  
                    }
                    else{
                        categoryList.add('HI Procurement');
                        }  									  //04-APR-2023: Sachin: CRM::1126: End
                }
            }
            
            System.debug('Category: '+categoryList);
            
            elisionLeadMap.put(keyStr, lRec);
        }
        
        
        //Fetch Related Leads
        
        List<Lead> relatedLead = new List<Lead>();
        
        Map<Id,Id> relatedLeadId = new Map<Id,Id>();
        relatedLead = [Select Id, customer__C  from Lead where Phone IN :phone and Id Not IN :leadId];
        for(Lead lea : relatedLead){
            relatedLeadId.put(lea.Id,lea.customer__C);
        }
        
        Set<Id> relatedOpenLeadId = new Set<Id>();
        Set<Id> relatedAccountId = new Set<Id>();
        
        List<Task> taskRec = [Select Id, WhoId, AccountId from Task where WhoId IN :relatedLeadId.keySet() And Status = 'Open'  ];
        for(Task tRec1 : taskRec)
        {
            relatedOpenLeadId.add(tRec1.AccountId);
            relatedAccountId.add(relatedLeadId.get(tRec1.WhoId));
        }
        
        
        // Working hours
        DateTime businessStartTime = Datetime.newInstanceGMT(System.now().year(), System.now().month(), System.now().day(), 3, 30, 0);
        DateTIme businessEndTime = businessStartTime.addHours(11);  //10-JAN-2024: Sachin: CRM::1224: Changed the business working time 
        DateTime nextWorkingHourDT = businessStartTime.addDays(1);
        DateTime nextWorkingHourD = nextWorkingHourDT.addMinutes(-60* 12); // today end time
        
        // for Task insert       
        List<Task> taskToInsertArr = new List<Task>();
        //for Lead update
        List<Lead> lRecToUpdateArr = new List<Lead>();
        
        // fetching eligibles campaigns
        Map<String, Elision_Campaign__c> elisionCampaignMatchedMap = new Map<String, Elision_Campaign__c>();
        
        // querying campaings
        List<Elision_Campaign__c> elisionCampaignDBArr = [SELECT Id, Name, Lead_Flag__c, Lead_Source__c, Status__c, Stage__c, Elision_Campaign_Category__c, Campaign_Id_NWH__c, Campaign_Id_WH__c, CampaignId_FollowUp__c FROM Elision_Campaign__c WHERE Elision_Campaign_Category__c In :categoryList ];
        System.debug('elisionCampaignDBArr ' + elisionCampaignDBArr);
        for(Elision_Campaign__c ecRec : elisionCampaignDBArr) {
            
            //String keyStr = ecRec.RecordType + '-' + ecRec.HI_Serviceable__c + '-' + ecRec.CTIDuplicate__c;
            
            elisionCampaignMatchedMap.put(ecRec.Elision_Campaign_Category__c, ecRec);
        }
        System.debug('elisionCampaignMatchedMap ' + elisionCampaignMatchedMap);
        
        for(Lead lRec : newList){
            
            if(relatedAccountId.contains(lRec.Customer__c))
            {
                continue;
            }
            
            Lead lRec1 = new Lead( Id = lRec.id);
            String keyStr = '';
            //12-06-2025:Sachin:CRM:1312: Start:ELV_Lead_Source campaign
            if ( lRec.RecordTypeId == LeadConstants.ElvLeadRecordTypeId && lRec.LeadSource == 'ELV') {
                lRec1.Elision_Campaign_category__c ='ELV Lead source';
                keyStr = 'ELV Lead source';
                lead1.add(lRec1);
            }
            //CRM:1312:End:ELV_Lead_Source campaign
            //18-06-2025:Sachin:CRM:1316: Start:PI campaign
            else if(lRec.RecordTypeId == LeadConstants.ElvLeadRecordTypeId && lRec.LeadSource == 'PI') {
                lRec1.Elision_Campaign_category__c ='Premium Inspection';
                keyStr = 'Premium Inspection';
                lead1.add(lRec1); 
            }
            //CRM:1316:End:PI campaign
            else if( lRec.RecordTypeId == LeadConstants.SellerLeadRecordTypeId && lRec.HI_Serviceable__c == '1' && lRec.CTIDuplicate__c ==false && lRec.Seller_City__c !=null && cityList.contains(lRec.Seller_City__c.toLowerCase()) )
            {
                if((lRec.Status__c=='Open' || lRec.Status__c==null )&&(lRec.Status =='New'|| lRec.Status =='Open'||lRec.Status =='Follow Up'|| lRec.Status == null ) )
                {
                    if(lRec.ICO_eligible_flag__c)        //04-APR-2023: Sachin: CRM::1126: Start
                    {
                        if(lRec.Lead_Flag__c == 'non_ico_journey_completed_user_dropped' || lRec.Lead_Flag__c == 'ico_journey_pending_user_dropped' || lRec.Lead_Flag__c == 'ico_journey_completed'){
                         lRec1.Elision_Campaign_category__c ='HI Procurement';
                         keyStr = 'HI Procurement';
                         lead1.add(lRec1);
                         }   
                    } 
                    else{
                        lRec1.Elision_Campaign_category__c ='HI Procurement';
                        keyStr = 'HI Procurement';
                        lead1.add(lRec1);
                        } 								//04-APR-2023: Sachin: CRM::1126: End
                } 
            }
            
            if(!elisionCampaignMatchedMap.containsKey(keyStr)) 
            {
                continue;
            }
            Elision_Campaign__c ecRec = elisionCampaignMatchedMap.get(keyStr);
            
            //DateTime elisionDueDate;
            // Business hour check
            //Boolean isInBusinessHour;
            //Boolean followUp;        
            
            System.debug('CreatedDate > '+lRec.CreatedDate);
            System.debug('businessStartTime > '+businessStartTime);
            System.debug('businessEndTime > '+businessEndTime);
            if(lRec.CreatedDate >= businessStartTime && lRec.CreatedDate <= businessEndTime) { // In Businness Hour
                
                isInBusinessHour = true;
                // followUp = false;
                elisionDueDate = lRec.CreatedDate.addMinutes(15);
            }
            else { // out Business Hour
                
                isInBusinessHour = false;
                //followUp = false;
                elisionDueDate = lRec.CreatedDate >= nextWorkingHourD ? businessStartTime : nextWorkingHourDT;
                elisionDueDate = elisionDueDate.addHours(1);
                
            }
            
            system.debug('IsInBusines: '+isInBusinessHour);
            //system.debug('IsInBusines: '+followUp);
            
            // if matched create 
            //  create Task
            Task tRec = new Task();       
            tRec.WhoId = lRec.Id;
            tRec.Elision_Campaign__c = ecRec.Id;
            tRec.Campaign_Id__c = isInBusinessHour ? ecRec.Campaign_Id_WH__c : ecRec.Campaign_Id_NWH__c;
            tRec.Campaign_Name__c = ecRec.Name;
            tRec.Subject = 'Elision BUC Call';
            tRec.Elision_Due_Date__c = elisionDueDate;
            tRec.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('Elision').getRecordTypeId();
            taskToInsertArr.add(tRec);
            
            system.debug('taskToInsertArr' +taskToInsertArr); 
            lRecToUpdateArr.add(lRec1);
        }//end for loop
        
        // Task insert
        if(!taskToInsertArr.isEmpty()) {
            insert taskToInsertArr;
        }
        System.debug('lRecToUpdateArr ' + lRecToUpdateArr);
        
        // lead update
        if(!lRecToUpdateArr.isEmpty()) {
            update lRecToUpdateArr;
        }
        
        
    }
}