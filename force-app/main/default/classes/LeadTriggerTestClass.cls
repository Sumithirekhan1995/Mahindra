// Aravindan A

@isTest
public class LeadTriggerTestClass {
    
    public static List<Lead> leadToInsert = new List<Lead>();
    public static List<Lead> leadToUpdate = new List<Lead>();
    
    @isTest
    public static void testAll() {
        
        Elision_Campaign__c  ecRec = new Elision_Campaign__c ();
        ecRec.Name = 'HI Procurement';
        ecRec.Elision_Campaign_Category__c = 'HI Procurement';
        ecRec.Campaign_Id_NWH__c = '22201';
        ecRec.Campaign_Id_WH__c = '22202';
        ecRec.CampaignId_FollowUp__c = '22203';
        insert ecRec;
        
        HiServiceableCity__c serviceAbleCity = new HiServiceableCity__c();
        serviceAbleCity.Name = 'PUNE';
        serviceAbleCity.City__c = 'PUNE'; 
        insert serviceAbleCity; 
        
         List<Id> listId = new List<Id>();
         Id oldId ;
        
        List<Lead> lstLead = new List<Lead>();
        // SMS templates
        List<SMS_Template__c> stRecArr = new List<SMS_Template__c>();
        if(true) {
            SMS_Template__c stRec = new SMS_Template__c();
            stRec.Name = 'BUY_Notinterested';
            stRec.Module__c = 'Buy Used Car';
            stRec.SMS_Body__c = 'Test';
            stRec.isActive__c = true;    
            stRecArr.add(stRec);
        }
        if(true) {
            SMS_Template__c stRec = new SMS_Template__c();
            stRec.Name = 'SELL_Status_Noresponse';
            stRec.Module__c = 'Buy Used Car';
            stRec.SMS_Body__c = 'Test';
            stRec.isActive__c = true;    
            stRecArr.add(stRec);
        }
        if(true) {
            SMS_Template__c stRec = new SMS_Template__c();
            stRec.Name = 'SELL_Leadcreate';
            stRec.Module__c = 'Buy Used Car';
            stRec.SMS_Body__c = 'Test';
            stRec.isActive__c = true;    
            stRecArr.add(stRec);
        }
        
        insert stRecArr;
        
        // Seller Dependecies
        RP_Dealer__c rpDealerRec = new RP_Dealer__c();
        rpDealerRec.Name = 'Test';
        insert rpDealerRec;
        if(true) {
            
            OzonetelEndpoint__c oeRec = new OzonetelEndpoint__c();
            oeRec.Name = 'Ozontel_2';
            oeRec.EndPoint_Ozonetel__c = 'cpt_data';
            oeRec.API_Key__c = 'Test_APi_KEY';
            insert oeRec;
            
            CnB_Endpoint__c cnbObj = new CnB_Endpoint__c();
            cnbObj.Name = 'cnb';
            cnbObj.x_app_api_key__c = 'Test';
            cnbObj.x_app_api_secret__c = 'Test';
            cnbObj.CreateNewLead__c = 'Test';
            cnbObj.NewBike_NewLead__c = 'Test';
            insert cnbObj;
            
            oeRec.Id = null;
            oeRec.Name = 'Ozontel1234';
            oeRec.EndPoint_Ozonetel__c = 'cpt_data';
            oeRec.API_Key__c = 'Test_APi_KEY';
            insert oeRec;
            
            LeadPushAPI__c lpRec = new LeadPushAPI__c();
            lpRec.Endpoint__c = 'cpt_auth';
            lpRec.Name = 'Get Token1234';
            insert lpRec;
            LeadPushAPI__c lpRec1 = new LeadPushAPI__c();
            lpRec1.Endpoint__c = 'cpt_data';
            lpRec1.Name = 'DND Lead123';
            insert lpRec1;
            
            
            HI_Endpoints__c credRec = new HI_Endpoints__c();
            credRec.Name = 'Test';
            credRec.Username__c = 'test';
            credRec.Password__c = 'Test';
            credRec.Auth_Endpoint__c = 'cpt_auth';
            credRec.Lead_Enpoint__c = 'cpt_data';
            insert credRec;
            CPT_Auth_Details__c cpt = new CPT_Auth_Details__c();
            cpt.Name = 'test';
            cpt.Endpoint__c = 'cpt_auth';
            cpt.EndPoint_for_Lead_Data__c = 'cpt_data';
            cpt.Username__c = 'test';
            cpt.Password__c = 'test';
            insert cpt;
            Test.setMock(HttpCalloutMock.class, new mockAll());
        }
        
        if(true) {
            Email__c mail = new Email__c();
            mail.Name = 'test Email';
            mail.Person_Email__c = 'test@test.co';
            insert mail;
            
            Finance_Auth_Details__c fin = new Finance_Auth_Details__c();
            fin.Username__c = 'test';
            fin.Password__c = 'test';
            fin.Name = 'test';
            fin.Endpoint__c = 'ibbAuth';
            fin.NonQualified_R2W_Endpoint__c = 'nonQualify';
            fin.EndPoint_for_Finance_Lead_Data__c = 'ibb';
            insert fin;
            
            // mmfsl
            Fin_MMFSL__c f = new Fin_MMFSL__c();
            f.Name = 'test Fin_MMFSL__c';
            f.endpoint__c = 'mmfsl';
            f.client_id__c = 'test client Id';
            f.subscriber_code__c = 'test subscriber code';
            insert f;
        }
        
        Branch__c bRec = new Branch__c();
        bRec.Name = 'Test Branch';
        insert bRec;
        
        Executive__c eRec = new Executive__c();
        eRec.Name = 'test Exe';
        eRec.Branch__c = bRec.Id;
        eRec.Executive_Id__c = '123456';
        insert eRec;
        
        List<Account> accArr = new List<Account>();
        if(true) {
            Account aRec = new Account();
            aRec.Name = 'Warp Test';
            aRec.RecordTypeId = AccountConstants.dealerAccountRecordTypeId;
            accArr.add(aRec);
        } 
        if(true) {
            Account aRec = new Account();
            aRec.Name = 'Warp Drive';
            aRec.RecordTypeId = AccountConstants.dealerAccountRecordTypeId;
            aRec.Code__c = '39361';
            accArr.add(aRec);
        }
        if(true) {
            Account aRec = new Account();
            aRec.Name = 'Warp Test';
            aRec.ExtrnId_Phone__c = '8400123412';
            aRec.RecordTypeId = AccountConstants.dealerAccountRecordTypeId;
            accArr.add(aRec);
        } 
        insert accArr;
        
        Product2 pRec = new Product2();
        pRec.Dealer_Name__c = accArr[0].Id;
        pRec.Name = 'Honda';
        pRec.Body_Type__c ='Shield';
        pRec.Color__c = 'Black';
        insert pRec;
        
        Serviceable_City__c scRec = new Serviceable_City__c();
        scRec.City_Name__c = 'Allahabad';
        scRec.Name = 'Allahabad';
        insert scRec;
        
        
        List<Lead> leadArr = new List<Lead>();
        Map<Id,List<Lead_Dispatch__c>> mapOfDisLead = new Map<Id,List<Lead_Dispatch__c>>();
        
        List<Lead_Dispatch__c> leadDisp = new List<Lead_Dispatch__c>();
        
        // Finance Lead : Lead0
        if(true) {
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.Lead_For__c = 'New Car';
            lRec.Given_For__c = 'New';
            lRec.Agreement_Number__c = '12345';
            lRec.Executive_Related__c = eRec.Id;
            lRec.Exe_Id__c = eRec.Executive_Id__c;
            lRec.Branch_Related__c = bRec.Id;
            lRec.Seller_State__c = 'Uttar Pradesh';
            lRec.Area_City__c = 'Allahabad';
            lRec.Lead_Type__c = LeadConstants.LEAD_TYPE_FINANCE;
            lRec.RecordTypeId = LeadConstants.financeLeadRecordTypeId;
            lRec.LeadSource = 'Bulk';
            lRec.Bypass_validation__c = false;
            lRec.Status__c = 'Hot';
            lRec.App_Status__c = 'Hot';
            lRec.Customer__c = accArr[2].Id;
            leadArr.add(lRec);
        }
        if(true) { // : Lead1
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.Lead_For__c = 'Used Car';
            lRec.Given_For__c = 'Used';
            lRec.Executive_Related__c = eRec.Id;
            lRec.Exe_Id__c = eRec.Executive_Id__c;
            lRec.Branch_Related__c = bRec.Id;
            lRec.Seller_State__c = 'Uttar Pradesh';
            lRec.Area_City__c = 'Allahabad';
            lRec.Lead_Type__c = LeadConstants.LEAD_TYPE_FINANCE;
            lRec.RecordTypeId = LeadConstants.financeLeadRecordTypeId;
            lRec.LeadSource = 'R2W';
            lRec.Status__c = 'Hot';
            lRec.App_Status__c = 'Hot';
            lRec.Bypass_validation__c = false;
            leadArr.add(lRec);
        }
        if(true) { //Seller : Lead2
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.HI_Serviceable__c = '0';
            lRec.Seller_City__c = 'Allahabad';
            lRec.Seller_State__c = 'Bihar';
            lRec.Status__c = 'Assigned';
            lRec.Lead_Type__c = LeadConstants.ProcurementConstant;
            lRec.RecordTypeId = LeadConstants.SellerLeadRecordTypeId;
            lRec.LeadSource = 'Advertisement';
            lRec.Bypass_validation__c = false;
            lRec.Followup_Lead_Created__c = false;
            leadArr.add(lRec);
        } 
        if(true) { // HI :  Lead3
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.HI_Serviceable__c = '1';
            lRec.Seller_City__c = 'Allahabad';
            lRec.Status__c = 'Assigned';
            lRec.Lead_Type__c = LeadConstants.ProcurementConstant;
            lRec.RecordTypeId = LeadConstants.SellerLeadRecordTypeId;
            lRec.LeadSource = 'Advertisement';
            lRec.Bypass_validation__c = false;
            leadArr.add(lRec);
        }
        
        // BUC
        if(true) { // Lead4
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.Seller_State__c = 'Uttar Pradesh';
            lRec.Seller_City__c = 'Allahabad';
            lRec.Dealer_Code__c = '3936';
            lRec.Lead_Type__c = LeadConstants.BuyerConstant;
            lRec.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
            lRec.LeadSource = 'Advertisement';
            lRec.Bypass_validation__c = false;
            leadArr.add(lRec);
            lstLead.add(lRec);
            
            Lead_Dispatch__c leadDispatch = new Lead_Dispatch__c();
        	leadDispatch.Lead__c = lRec.Id;
            leadDispatch.Warranty_Type__c = 'Test';
            leadDisp.add(leadDispatch);
            mapOfDisLead.put(leadDispatch.Id,leadDisp);
            
        }
        
        if(true) { // Lead5
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.Source_Id__c = 'CreatedByMFCChatBot';
            lRec.Seller_State__c = 'Uttar Pradesh';
            lRec.Seller_City__c = 'Allahabad';
            lRec.Dealer_Code__c = '3936';
            lRec.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
            lRec.Dealer__c = accArr[0].Id;
            lRec.LeadSource = 'Advertisement';
            lRec.Bypass_validation__c = false;
            leadArr.add(lRec);
        }
        if(true) { // HI :  Lead6
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.HI_Serviceable__c = '1';
            lRec.Seller_City__c = 'Pune';
            lRec.Area_State__c = 'Maharashtra';
            lRec.Status__c = LeadConstants.LeadStatus;
            lRec.Lead_Type__c = LeadConstants.ProcurementConstant;
            lRec.RecordTypeId = LeadConstants.SellerLeadRecordTypeId;
            lRec.LeadSource = 'Advertisement';
            lRec.Bypass_validation__c = false;
            leadArr.add(lRec);
        }
        
        if(true) { // HI :  Lead6.1
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8299526141';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.HI_Serviceable__c = '1';
            lRec.Seller_City__c = 'Pune';
            lRec.Area_State__c = 'Maharashtra';
            lRec.Status__c = 'Open';
            lRec.Lead_Type__c = LeadConstants.ProcurementConstant;
            lRec.RecordTypeId = LeadConstants.SellerLeadRecordTypeId;
            lRec.LeadSource = 'Advertisement';
            lRec.Bypass_validation__c = false;
            lRec.CTIDuplicate__c = false;
            leadArr.add(lRec);
        }
        if(true) { // HI :  Lead7
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.HI_Serviceable__c = '1';
            lRec.Seller_City__c = 'Allahabad';
            lRec.Area_State__c = 'Uttar Pradesh';
            lRec.Status__c = 'Assigned';
            lRec.Lead_Type__c = LeadConstants.ProcurementConstant;
            lRec.RecordTypeId = LeadConstants.SellerLeadRecordTypeId;
            lRec.LeadSource = 'Advertisement';
            lRec.Bypass_validation__c = false;
            leadArr.add(lRec);
        }
        if(true) { // BUC : Lead8
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.Seller_State__c = 'Uttar Pradesh';
            lRec.Seller_City__c = 'Allahabad';
            lRec.Dealer_Code__c = '3936';
            lRec.Lead_Type__c = LeadConstants.BuyerConstant;
            lRec.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
            lRec.LeadSource = 'Advertisement';
            lRec.Bypass_validation__c = false;
            leadArr.add(lRec);
        }
        if(true) { // BUC : Lead9
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.Seller_State__c = 'Uttar Pradesh';
            lRec.Seller_City__c = 'Allahabad';
            lRec.Dealer_Code__c = '3936';
            lRec.Lead_Type__c = LeadConstants.BuyerConstant;
            lRec.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
            lRec.LeadSource = 'Advertisement';
            lRec.Bypass_validation__c = false;
            leadArr.add(lRec);
        }
        if(true) { // BUC: Lead10
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.Seller_State__c = 'Uttar Pradesh';
            lRec.Seller_City__c = 'Allahabad';
            lRec.Dealer_Code__c = '3936';
            lRec.Lead_Type__c = LeadConstants.BuyerConstant;
            lRec.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
            lRec.LeadSource = 'Advertisement';
            lRec.Bypass_validation__c = false;
            leadArr.add(lRec);
        }
        if(true) { // BUC:Lead11
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.Seller_State__c = 'Uttar Pradesh';
            lRec.Seller_City__c = 'Allahabad';
            lRec.Dealer_Code__c = '3936';
            lRec.Lead_Type__c = LeadConstants.BuyerConstant;
            lRec.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
            lRec.LeadSource = 'Advertisement';
            lRec.Bypass_validation__c = false;
            leadArr.add(lRec);
        }
        if(true) { // BUC:Lead12
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.Seller_State__c = 'Uttar Pradesh';
            lRec.Seller_City__c = 'Allahabad';
            lRec.Dealer_Code__c = '3936';
            lRec.Lead_Type__c = LeadConstants.BuyerConstant;
            lRec.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
            lRec.LeadSource = 'Advertisement';
            lRec.Bypass_validation__c = false;
            leadArr.add(lRec);
        }
        if(true) { // BUC:Lead13
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.Seller_State__c = 'Uttar Pradesh';
            lRec.Seller_City__c = 'Allahabad';
            lRec.Dealer_Code__c = '3936';
            lRec.Lead_Type__c = LeadConstants.BuyerConstant;
            lRec.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
            lRec.LeadSource = 'Advertisement';
            lRec.Bypass_validation__c = false;
            leadArr.add(lRec);
        }
        if(true) { // BUC:Lead14
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.Seller_State__c = 'Uttar Pradesh';
            lRec.Seller_City__c = 'Allahabad';
            lRec.Dealer_Code__c = '3936';
            lRec.Lead_Type__c = LeadConstants.BuyerConstant;
            lRec.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
            lRec.LeadSource = 'Advertisement';
            lRec.Bypass_validation__c = false;
            leadArr.add(lRec);
        }
        
        // BSE
        if(true) { // BUC:Lead15
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.Seller_State__c = 'Uttar Pradesh';
            lRec.Seller_City__c = 'Allahabad';
            lRec.RecordTypeId = LeadConstants.BSELeadRecordTypeId;
            lRec.HPA_Number__c = '1234567';
            lRec.MFCWL_Number__c  = '1212121212';
            lRec.Branch_Name_BSE__c = 'Test';
            lRec.Vehicle__c = '121212121212';
            lRec.Date_of_Loan__c = System.today();
            lRec.ACM_Name__c = 'Test';
            lRec.DM__c = 'test';
            lRec.LeadSource = 'Advertisement';
            lRec.Bypass_validation__c = false;
            //leadArr.add(lRec);
        }
        if(true) { // BUC:Lead16
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.Seller_State__c = 'Uttar Pradesh';
            lRec.Seller_City__c = 'Allahabad';
            lRec.RecordTypeId = leadConstants.CnBLeadRecordTypeId;
            lRec.LeadSource = 'Advertisement';
            lRec.Car_Model_Id__c = 'Test';
            lRec.Form_Type_Id__c = '8';
            lRec.Bypass_validation__c = false;
            leadArr.add(lRec);
        }
        if(true) { // BUC:Lead17
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Status__c = LeadConstants.StatusInProcess;
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.Seller_State__c = 'Uttar Pradesh';
            lRec.Seller_City__c = 'Allahabad';
            lRec.RecordTypeId = LeadConstants.AutofinRecordtyeId;
            lRec.LeadSource = 'Advertisement';
            lRec.Bypass_validation__c = false;
            leadArr.add(lRec);
        }
        
        // ELV
        if(true) { // ELV :  Lead18
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.HI_Serviceable__c = '1';
            lRec.Seller_City__c = 'Pune';
            lRec.Area_State__c = 'Maharashtra';
            lRec.Status__c = LeadConstants.LeadStatus;
            lRec.Lead_Type__c = LeadConstants.ProcurementConstant;
            lRec.RecordTypeId = LeadConstants.ElvLeadRecordTypeId;
            lRec.LeadSource = 'ELV';
            lRec.Bypass_validation__c = false;
            leadArr.add(lRec);
        }
        
        leadToInsert = leadArr;
        
        List<Lead> updateLead = new List<Lead>();
        
        insert leadArr;
            system.debug('leadArr'+leadArr);
       
        /*  ******* Update ****** */
        List<Lead> leadArrToUpdate = new List<Lead>();
        
        // Finance
        if(true) {
            system.debug('leadArr[0]'+leadArr[0].Id);
            Lead lRec = leadArr[0];
            lRec.Follow_Up_Date_Time__c = System.now().addDays(1);
            lRec.cc_remarks__c = 'Test cc';
            lRec.Bypass_validation__c = false;
            leadArrToUpdate.add(lRec);
        }
        if(true) {
            Lead lRec = leadArr[1];
            lRec.App_Remarks__c = 'Test cc';
            lRec.Bypass_validation__c = false;
            leadArrToUpdate.add(lRec);
        }
        // BUC
        if(true) {
            Lead lRec = leadArr[4];
            lRec.Lead_Flag__c = 'Reserve';
            lRec.Status__c = 'Hot';
            lRec.Bypass_validation__c = false;
            lRec.Status = 'Dealer/Stock Assigned';
            lRec.Bypass_validation__c = false;
            lRec.Sub_Status__c = 'Interested in Test Drive';
            lRec.Bypass_validation__c = false;
            leadArrToUpdate.add(lRec);
        }
        if(true) {
            Lead lRec = leadArr[8];
            lRec.Lead_Flag__c = 'Reserve';
            lRec.Status__c = 'No Response';
            lRec.Bypass_validation__c = false;
            leadArrToUpdate.add(lRec);
        }
        if(true) {
            Lead lRec = leadArr[9];
            lRec.Lead_Flag__c = 'Reserve';
            lRec.Status__c = 'Warm';
            lRec.Sub_Status__c = 'Interested in Test Drive';
            lRec.Dealer__c = accArr[0].Id;
            lRec.Bypass_validation__c = false;
            leadArrToUpdate.add(lRec);
        }
        if(true) {
            Lead lRec = leadArr[10];
            lRec.Lead_Flag__c = 'Reserve';
            lRec.Status__c = 'No Response';
            lRec.Dealer__c = accArr[0].Id;
            lRec.Bypass_validation__c = false;
            leadArrToUpdate.add(lRec);
        } 
        if(true) {
            Lead lRec = leadArr[11];
            lRec.Lead_Flag__c = 'Reserve';
            lRec.Status__c = 'Call Back';
            lRec.Dealer__c = accArr[0].Id;
            lRec.Bypass_validation__c = false;
            leadArrToUpdate.add(lRec);
        } 
        if(true) {
            Lead lRec = leadArr[12];
            lRec.Lead_Flag__c = 'Reserve';
            lRec.Status__c = 'Cold';
            lRec.Sub_Status__c = 'Interested in Test Drive';
            lRec.Dealer__c = accArr[0].Id;
            lRec.Bypass_validation__c = false;
            leadArrToUpdate.add(lRec);
        } 
        if(true) {
            Lead lRec = leadArr[13];
            lRec.Lead_Flag__c = 'Reserve';
            lRec.Status__c = 'Visiting';
            lRec.Dealer__c = accArr[0].Id;
            lRec.Bypass_validation__c = false;
            leadArrToUpdate.add(lRec);
        } 
        if(true) {
            Lead lRec = leadArr[14];
            lRec.Lead_Flag__c = 'Reserve';
            lRec.Status__c = 'Not Interested';
            lRec.Dealer__c = accArr[0].Id;
            lRec.Bypass_validation__c = false;
            leadArrToUpdate.add(lRec);
        } 
        
        
        //Seller
        if(true) {
            Lead lRec = leadArr[2];
            lRec.Status__c = LeadConstants.LeadStatus;
            lRec.Bypass_validation__c = false;
            leadArrToUpdate.add(lRec);
        }
        if(true) {
            Lead lRec = leadArr[3];
            lRec.Valuator_Assigned_Visit_Date__c = System.today().addDays(1);
            lRec.Valuation_Schedule_Time_Slot__c = '12 PM - 2 PM';
            lRec.Address__c  = 'Test';
            lRec.Area_PinCode__c = '201305';
            lRec.Year__c = '2022';
            lRec.HI_Preference__c = 'Store';
            lRec.RP_Dealer__c =  rpDealerRec.Id;
            lRec.Status__c = LeadConstants.LeadStatus;
            lRec.Seller_State__c = 'Bihar';
            lRec.Make__c = 'test';
            lRec.Model__c = 'test';
            lRec.Bypass_validation__c = false;
            leadArrToUpdate.add(lRec);
        }
        if(true) {
            Lead lRec = leadArr[6];
            lRec.Valuator_Assigned_Visit_Date__c = System.today().addDays(1);
            lRec.Valuation_Schedule_Time_Slot__c = '12 PM - 2 PM';
            lRec.Address__c  = 'Test';
            lRec.Area_PinCode__c = '201305';
            lRec.Year__c = '2022';
            lRec.HI_Preference__c = 'Home';
            lRec.Status__c = 'Follow up';
            lRec.Seller_State__c = 'Bihar';
            lRec.Make__c = 'test';
            lRec.Model__c = 'test';
            lRec.Bypass_validation__c = false;
            leadArrToUpdate.add(lRec);
        }
        if(true) {
            Lead lRec = leadArr[7];
            lRec.Valuator_Assigned_Visit_Date__c = System.today().addDays(1);
            lRec.Valuation_Schedule_Time_Slot__c = '12 PM - 2 PM';
            lRec.Address__c  = 'Test';
            lRec.Area_PinCode__c = '201305';
            lRec.Year__c = '2022';
            lRec.Seller_State__c = 'Bihar';
            lRec.HI_Preference__c = 'Home'; 
            lRec.Status__c = 'No Response';
            lRec.Make__c = 'test';
            lRec.Model__c = 'test';
            lRec.Bypass_validation__c = false;
            leadArrToUpdate.add(lRec);
        }
        
        if(true) {
            Lead lRec = leadArr[18];
            lRec.Status__c = 'Whatsapp Msg Sent';
            lRec.Bypass_validation__c = false;
            leadArrToUpdate.add(lRec);
        } 
        
        leadToUpdate = leadArrToUpdate;
        
        
        update new List<Lead>{leadToUpdate[13], leadToUpdate[12],leadToUpdate[11],leadToUpdate[9]};
            update new List<Lead>{leadToUpdate[8],leadToUpdate[7], leadToUpdate[6],leadToUpdate[5],leadToUpdate[4],leadToUpdate[14]};
             //   update new List<Lead>{leadToUpdate[3],leadToUpdate[2], leadToUpdate[1],leadToUpdate[0]};
        
        Test.startTest();
        LeadTriggerHelper.onAfterConverted(new List<Lead>{leadToInsert[5], leadToInsert[7]});
        LeadTriggerHelper.cnbLeadOpportunity(new List<Lead>{leadToInsert[16]});
        LeadTriggerHelper.createBSEOppotunity(new List<Lead>{leadToInsert[15]});
        LeadTriggerHelper.callDNDAPI(new Set<Id>{leadToInsert[0].Id});
        LeadTriggerHelper.accDND(new List<Lead>{leadToInsert[0]});
        LeadTriggerHelper.markLeadDND(new List<Lead>{leadToInsert[0]});
        LeadTriggerHelper.updateAccNameAndSubLeads(new List<Lead>{leadToInsert[0]});
        LeadTriggerHelper.sendLeadDataToCPT(lstLead);
        LeadTriggerHelper.liveChatTranscriptOpp(null);
        LeadTriggerHelper.deleteLeads(listId, oldId);
      //  LeadTriggerHelper.callEcomCallout(new Set<Id>{leadToInsert[14].Id});
        Test.stopTest();   
    }
    
    
    
    public class mockAll implements HttpCalloutMock  {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            // res.setBody('[Status=OK, StatusCode=200]');
            String endPoint = req.getEndpoint();
            if(endPoint.contains('cpt_auth')) {
                res.setBody('{"status":"success","status_code":200,"access_token":"65BxPck9xonDGWuvsgK3lbqOM7wCAJvtbJEZuNF","expires_at":"2021-02-07 12:47:06"}');
            } else
            if(endPoint.contains('cpt_data')) {
                res.setBody('{"success":[{"message":"Lead Created","sfdc_lead_id":"00Q2v00001hLJSkEAO","status_code":200}]}');
            } else
            if(req.getEndpoint().contains('ibbAuth')) {
                res.setBody('{"status":"success","status_code":200,"access_token":"nY5cGouW507wH2DvqUMWBMo5aFgq8TbAnr8ulSu","expires_at":"2020-09-12 18:08:50"}');
            } else
            if(req.getEndpoint().contains('ibb')) {
                res.setBody('{"success": [ { "message": "Lead Created", "sfdc_lead_id": "2222021", "mfin_lms_lead_id": "1485744", "status_code": 200 } ] }');
            } else
            if(req.getEndpoint().contains('mmfsl')) {
                res.setBody('{"EnquiryResult":{"application_number":"","enquiry_no":"700086186","error_msg":null,"status_msg":"SUCCESS","application_ref_no":"00Q1s000002h7VSEAY"}}');
            } else
            if(req.getEndpoint().contains('nonQualify')) {
                res.setBody('{"success":[{"message":"Lead status updated successfully","sfdc_lead_id":"00Q1s000001j9ZSEAY","mfin_lms_lead_id":"75067","status_code":200}]}');
            } else {
                res.setBody('{"response": { "data" : [] } }');
            }
            
            res.setStatusCode(200);
            return res;
        }
    }
}