public class LeadPushCPT {
    public static boolean apiFired = true;
    
    public class AuthWrapper{
        public String username;
        public String password;
    }
    public class CPTRequest{
        List<LeadWrapper> data;
        public String access_token;
        public String tag;
        public String price; // Added by Amulya 1039(01-24-23)
    }
    public class AuthResponse{
        public String status;
        public String status_code;
        public String access_token;
        public String expires_at;
    }
    
    public class CptResponseMessage{
        public String status;
        public List<ResponseLeadobj> lead_result;
    }
    public class CptResponse{
        public List<ResponseLeadobj> success;
        public List<ResponseLeadobj> error;
    }
    public class ResponseLeadobj{
        public String sfdc_lead_id;
        public String cpt_lead_id;
        public String status;
        public String message;
    }
    
    public class LeadCptWrapper{
        public List<LeadWrapper> data;
        
        public LeadCptWrapper(){
            data = new List<LeadWrapper>();
        }
        
    }
    
    //Added by Soumya 21/05/2021 -- Start
    public class HI_AuthRequest{
        public String username;
        public String password;
    }
    
    public class HI_AuthResponse{
        public String status;
        public String status_code;
        public String access_token;
        public String expires_at;
    }
    
    public class HI_ReqWrapper{
        public String access_token;
        public String sfdc_lead_id;
        public String state;
        public String city;
        public String customer_name;
        public String customer_mobile;
        public String customer_email;
        public String customer_pincode;
        public String customer_address;
        public String customer_expected_price;
        public String yom;
        public String make;
        public String model;
        public String variant;
        public String inspect_type;
        public String store_name;
        public String valuator_visit_date;
        public String valuator_visit_slot;
        public String latitude;
        public String longitude;
        public String fuel_type;
        public String lead_from;
        public Integer odometer; 
        public String lead_source;
        public String ico_eligible_flag; // ico eligible flag,price added by Amulya 01-24-2023  CRM-1039
        Public String price;
        public String lead_flag;
    }
    
    public class HI_ResWrapper{
        public String status;
        public String status_code;
        public String message;
        public String sfdc_lead_id;
    }
    //-End
    public class LeadWrapper{
        public String sfdc_lead_id;
        public String lead_id;
        public String lead_created_from;
        public String vehicle_category;
        public String customer_name;
        public String customer_mobile; 
        public String customer_email;
        public String customer_address;
        public String customer_pincode;
        public String city_name;
        
        public String state_name;
        public String reject_reason;
        public String evaluation_city;
        public String evaluation_state;
        public String registration_city;
        public String registration_state;
        public String evaluation_name;
        //Added By Hiral
        public String valuator_visit_date;
        public String valuator_visit_slot;
        
        public String make;
        public String model;
        public String variant;
        public String year;
        public String kilometer;
        public String fuel_type;
        public String total_owner;
        public String registration_number;
        public String colour;
        public String source;
        public String sub_source;
        public String inspect_type;
        public String inspected_date;
        public String valuator_visit_date_time;
        public String status;
        public String valuation_remarks;
        
        public String evaluator_name;
        public String evaluator_contact_number;
        public String evaluator_email;
        public String cpt_admin_name;
        public String cpt_admin_contact_number;
        public String cpt_admin_email;
        public String qc_approved_date;
        public String auction_id;
        public String auction_start_date;
        public String auction_end_date;
        public String live_followup_date;
        public String follwoup_remarks;
        public String reject_date;
        public String deal_finalized_on;
        public String sold_out_on;
        public String ibb_price;
        public String customer_expected_price;
        public String seller_price;
        //Added by Soumya 21/09/2020
        public String lead_url;
        public String utm_term;
        //Added by Soumya 
        public Integer whatsapp_consent;
        public String lead_created_type;
        public String uid;
        public String valuation_date_time;
        public String remarks;
        public String auto_inspekt;
        public String valuator_assigned_visit_date;
        //Added by Soumya 21/05/2021
        public Integer hi_serviceable;
        public String hi_store;
        public String hi_preference;
        public String referrer;
        public String lead_source;
        public String lead_category; //Added lead category by Amulya 14-07-22
        public Integer is_otp_verified;
        public String Longitude;
        public String latitude;
        public String marketing_source;
        public String marketing_campaign;
        public String marketing_device;
        public String marketing_content;
        public String marketing_medium;
        public String marketing_term;
        public String td_client_id;
        //added by Vinay
        public String quality_score;
        public String pdf_report_link;
        public String ico_eligible_flag; // ico eligible flag,price added by Amulya 01-24-2023  CRM-1039
        public String price;
        public String lead_flag;
        
        
    }
    public static void getLeadDetails(List<Lead> listOfLeads){
        try{
            List<LeadWrapper> listOfLeadWrappers = new List<LeadWrapper>();
            for(Lead l: listOfLeads){
                LeadWrapper lw = new LeadWrapper();
                lw.sfdc_lead_id = l.Id;
                lw.vehicle_category = 'PV';
                
                lw.customer_name = l.LastName;
                if(l.FirstName != null){
                    lw.customer_name = l.FirstName + ' ' +lw.customer_name;
                }
                lw.customer_mobile = l.Phone;
                lw.customer_email = l.Email;
                lw.customer_address = l.address__c;
                lw.customer_pincode = l.Area_PinCode__c ;
                lw.lead_created_type = l.Assign_Type__c;
                lw.uid = l.CPT_Admin_UID__c;
                lw.valuation_date_time = String.valueOf(l.Valuation_Date_Time__c);
                lw.remarks = l.Remarks__c;
                lw.auto_inspekt = l.Autoinspekt__c;
                ///lw.evaluation_city = l.evaluation_city__c;
                //lw.evaluation_state = l.evaluation_state__c;
                //lw.registration_city = l.registration_city__c;
                //lw.registration_state = l.registration_state__c;
                //lw.evaluation_name = l.evaluation_name__c;
                lw.city_name = l.registration_city__c ; 
                lw.state_name = l.registration_state__c ;
                lw.make = l.Make__c;
                lw.model = l.Model__c;
                lw.variant = l.Variant__c;
                lw.year = l.Year__c;
                lw.kilometer = String.valueOf(l.Kilometer__c);
                lw.total_owner = String.valueOf(l.Total_Owner__c);
                lw.registration_number = l.Registration_Number__c;
                lw.colour = l.Color__c;
                lw.source = l.LeadSource;
                lw.ico_eligible_flag = String.valueOf(l.ICO_eligible_flag__c);  // ico eligible flag,price,lead flag added by Amulya 01-24-2023  CRM-1039
                lw.price= l.ICO_Price__c;
                lw.lead_flag = l.Lead_Flag__c ; 
                lw.sub_source = l.Sub_Source__c;
                lw.inspect_type = l.Inspect_Type__c;
                //lw.inspected_date = String.valueOf(l.inspected_date__c);
                lw.valuator_visit_date_time = l.Valuator_Visit_Date_Time__c;
                lw.status = l.Status;
                lw.valuation_remarks = l.Valuation_Remarks__c;
                //lw.evaluator_name = l.evaluator_name__c;
                //lw.evaluator_contact_number = l.evaluator_contact_number__c;
                //lw.evaluator_email = l.evaluator_email__c;
                //lw.cpt_admin_name = l.cpt_admin_name__c;
                //lw.cpt_admin_contact_number = l.cpt_admin_contact_number__c;
                //lw.cpt_admin_email = l.cpt_admin_email__c;
                //lw.qc_approved_date = String.valueOf(l.qc_approved_date__c);
                //lw.auction_id = l.auction_id__c;
                //lw.auction_start_date = String.valueOf(l.auction_start_date__c);
                //lw.auction_end_date = String.valueOf(l.auction_end_date__c);
                //lw.live_followup_date = String.valueOf(l.live_followup_date__c);
                //lw.follwoup_remarks = l.follwoup_remarks__c;
                //lw.reject_date = String.valueOf(l.reject_date__c);
                //lw.deal_finalized_on = String.valueOf(l.deal_finalized_on__c);
                //lw.sold_out_on = String.valueOf(l.sold_out_on__c);
                //lw.ibb_price = String.valueOf(l.ibb_price__c);
                lw.customer_expected_price = String.valueOf(l.Customer_Expected_Price__c);
                lw.seller_price = l.Seller_Price__c;
                lw.lead_created_from = l.Lead_Created_From__c;
                listOfLeadWrappers.add(lw);
            }
            
            CPTRequest creq = new CPTRequest();
            creq.data = listOfLeadWrappers;
            creq.tag = 'web';
            List<CPT_Auth_Details__c> listOfCPTAuthDetails = CPT_Auth_Details__c.getAll().values();
            AuthWrapper au = new AuthWrapper();
            au.username = listOfCPTAuthDetails[0].username__c;
            au.password = listOfCPTAuthDetails[0].password__c;
            System.debug('Body++'+JSON.serialize(creq));
            getAuthDetailsAndSendLead(JSON.serialize(au),listOfCPTAuthDetails[0].Endpoint__c,listOfCPTAuthDetails[0].EndPoint_for_Lead_Data__c , JSON.serialize(creq));
        }catch(Exception e){
            LogService.createApiLogs('LeadPushCPT - getLeadDetails', '', e.getMessage() + e.getLineNumber(), 'Failed','LeadPushCPT - getLeadDetails');
            
        }
    }
    @future(callout = true)
    public static void getAuthDetailsAndSendLead(String authDetails, String authEndPoint,String CPTEndPoint, String data){
        
        AuthWrapper au = new AuthWrapper();
        CPTRequest cptReq = new CPTRequest();
        AuthResponse ar = new AuthResponse();
        HttpResponse res1 = new HttpResponse();
        try{
            CalloutHelper chObj = new CalloutHelper();
            HttpResponse res = chObj.sendAsPOST(authEndPoint, authDetails, null);
            System.debug('Response'+res);
            System.debug('Response Body'+res.getBody());
            ar = (AuthResponse)JSON.deserialize(res.getBody(), AuthResponse.class);
            System.debug(ar.access_token);
            cptReq = (CPTRequest)JSON.deserialize(data, CPTRequest.class);
            cptReq.access_token = ar.access_token;
           
            res1 = chObj.sendAsPOST(CPTEndPoint, JSON.serialize(cptReq), null);
            if(res1.getStatusCode() == 200){
                LogService.createApiLogs(CPTEndPoint, JSON.serialize(cptReq), res1.getBody(), 'Success','LeadPushCPT - getAuthDetailsAndSendLead');
            }
            else{
                LogService.createApiLogs(CPTEndPoint, JSON.serialize(cptReq), res1.getBody(), 'Failed','LeadPushCPT - getAuthDetailsAndSendLead'); 
            }
            System.debug(res1.getBody());
        }catch(Exception e){
            LogService.createApiLogs(CPTEndPoint, JSON.serialize(cptReq), e.getMessage() + e.getLineNumber(), 'Failed','LeadPushCPT');
            
        }
        
        //Added by Soumya on 22/03/2021 for handling the error Response
        Map<String, LeadPushCPT.ResponseLeadobj> errorMap = new Map<String, LeadPushCPT.ResponseLeadobj>();
        List<Lead> updateList = new List<Lead>();
        CptResponse cptRes = (CptResponse)System.JSON.deserialize(res1.getBody(), CptResponse.class);
        if(cptRes.Error != NULL){
            System.debug('Inside Error '+cptRes.error);
            for(LeadPushCPT.ResponseLeadobj res : cptRes.error){
                errorMap.put(res.sfdc_lead_id, res);
            }
        }
        System.debug('ErrorMAp '+errorMap);
        if(errorMap.size() > 0){
            for(String key : errorMap.keySet()){
                Lead lea = new Lead();
                lea.Id = key;
                lea.Upload_Message__c = errorMap.get(lea.Id).message;
                lea.Mobile_Number_already_Exists__c = true;
                updateList.add(lea);
            }
        }
        
        if(!updateList.isEmpty()){
            update updateList;
        }
    }
    
    //Added by Soumya 
    public static void setDataforHICallout(List<Lead> hiLeadList){
        try{
            HI_ReqWrapper req = new HI_ReqWrapper();
            req.sfdc_lead_id = hiLeadList[0].Id;
            req.city = hiLeadList[0].Seller_City__c; 
            req.state = hiLeadList[0].Seller_State__c;
            if(hiLeadList[0].Address__c == NULL)
                req.customer_address = '';
            else
                req.customer_address = hiLeadList[0].Address__c;
            if(hiLeadList[0].Email == NULL)
                req.customer_email = ' ';
            else
                req.customer_email = hiLeadList[0].Email;
            req.customer_expected_price = String.valueOf(hiLeadList[0].Customer_Expected_Price__c);
            // Add by Amulya 17-06-22 to remove +91
            Integer lengthphone = hiLeadList[0].Phone.length();
            System.debug('length of the phone number is' + lengthphone);
            if(lengthphone > 10 ){
                req.customer_mobile = hiLeadList[0].Phone.right(10);
                System.debug('customer mobile number ' +req.customer_mobile);
            }
            else{
                req.customer_mobile = hiLeadList[0].Phone;
            }
            // end by Amulya
            req.customer_name = hiLeadList[0].LastName;
            if(hiLeadList[0].Area_PinCode__c == NULL)
                req.customer_pincode  = '';
            else
                req.customer_pincode = hiLeadList[0].Area_PinCode__c;
            
            
            if(hiLeadList[0].Fuel__c == NULL)
                req.fuel_type = '';
            else
                req.fuel_type = hiLeadList[0].Fuel__c;
            
            req.inspect_type = hiLeadList[0].HI_Preference__c;
            // 5Jan2022:Asif:Start :: All caps Lead Source
            String leadSource = String.valueOf(hiLeadList[0].LeadSource);
            if(leadSource != null) {
                leadSource = leadSource.toUpperCase();
            }
            req.lead_source = leadSource;
            // 5Jan2022:Asif:End
             req.ico_eligible_flag =String.valueOf(hiLeadList[0].ICO_eligible_flag__c);  // ico eligible flag,price,lead flag added by Amulya 01-24-2023  CRM-1039
             req.price = hiLeadList[0].ICO_Price__c;
             req.lead_flag = hiLeadList[0].Lead_Flag__c;
            req.make = hiLeadList[0].Make__c;
            req.model = hiLeadList[0].Model__c;
            if(hiLeadList[0].RP_Dealer__c != NULL){
                req.store_name = hiLeadList[0].RP_Dealer_Name__c;
            }
            req.valuator_visit_date = String.valueOf(hiLeadList[0].Valuator_Assigned_Visit_Date__c); 
            req.valuator_visit_slot = hiLeadList[0].Valuation_Schedule_Time_Slot__c;
            if(hiLeadList[0].Variant__c == NULL)
                req.variant = '';
            else
                req.variant = hiLeadList[0].Variant__c;
            req.yom = String.valueOf(hiLeadList[0].year__c);
            req.lead_from = hiLeadList[0].Lead_Created_From__c;
            if(hiLeadList[0].Kilometer__c == NULL)
                req.odometer = NULL; 
            else
                req.odometer = Integer.valueOf(hiLeadList[0].Kilometer__c); 
            sendLeadDetailsToHI(JSON.serialize(req));
        }
        catch(Exception e){
            System.debug('Errors '+e.getMessage());
        }
    }
    
    @future(callout = true)
    public static void sendLeadDetailsToHI(String data){
        List<API_Log__c> apiLogs = new List<API_Log__c>();
        List<HI_Endpoints__c> hiEndpointList = HI_Endpoints__c.getAll().Values();
        HI_AuthRequest authReq = new HI_AuthRequest();
        if(!hiEndpointList.isEmpty()) {
            
            
            authReq.username = hiEndpointList[0].Username__c;
            authReq.password = hiEndpointList[0].Password__c;
            
            CalloutHelper chObj = new CalloutHelper();
            System.debug('Endpoint '+hiEndpointList[0].Auth_Endpoint__c+'Request Body '+JSON.serialize(authReq));
            httpResponse authRes = chObj.sendAsPOST( hiEndpointList[0].Auth_Endpoint__c, JSON.serialize(authReq), NULL);
            System.debug('Response '+authRes+'Resbody '+authRes.getBody());
            if(authRes.getStatusCode() == 200){
                apiLogs.add(LogService.createApiLogs(hiEndpointList[0].Auth_Endpoint__c, JSON.serialize(authReq), authRes.getBody(), 'Success', 'HI Lead Auth Callout', null, false));
            }
            else{
                apiLogs.add(LogService.createApiLogs(hiEndpointList[0].Auth_Endpoint__c, JSON.serialize(authReq), authRes.getBody(), 'Failure', 'HI Lead Auth Callout', null, false));
            }
            
            
            HI_AuthResponse authResWrap = (HI_AuthResponse)System.JSON.deserialize(authRes.getBody(), HI_AuthResponse.class);
            System.debug('Access token '+authResWrap.access_token);
            
            
            HI_ReqWrapper ReqWrap = (HI_ReqWrapper)System.JSON.deserialize(data, HI_ReqWrapper.class);
            ReqWrap.access_token = authResWrap.access_token;
            
            System.debug('Endpoint '+hiEndpointList[0].Lead_Enpoint__c+ 'Request body '+JSON.serialize(ReqWrap));
            HttpResponse ResWrap = chObj.sendAsPOST(hiEndpointList[0].Lead_Enpoint__c, JSON.serialize(ReqWrap), NULL);
            apiFired = false;
            System.debug('Response body '+ResWrap.getBody());
            String responsedata = resWrap.getBody();
            String SfId = responsedata.substringBetween('"sfdc_lead_id":"','"');
            
            if(ResWrap.getStatusCode() == 200){
                apiLogs.add(LogService.createApiLogs(hiEndpointList[0].Lead_Enpoint__c, JSON.serialize(ReqWrap), ResWrap.getBody(), 'Success', 'HI Seller Lead Callout', SfId, false));
            }
            else{
                apiLogs.add(LogService.createApiLogs(hiEndpointList[0].Lead_Enpoint__c, JSON.serialize(ReqWrap), ResWrap.getBody(), 'Failed', 'HI Seller Lead Callout', SfId, false));
            }
            
            HI_ResWrapper resWrap1 = (HI_ResWrapper)System.JSON.deserialize(resWrap.getBody(), HI_ResWrapper.class);
            System.debug('resWrap1 '+resWrap1);
            
            
            Lead lea = new Lead();
            lea.Id = resWrap1.sfdc_lead_id;
            lea.Upload_Message__c = resWrap1.message;
            // 5Jan2022:Asif:Start :: Added uncheck/check on basis of responseBody status_code
            if(resWrap1.status_code != null) {
                if(Integer.valueOf(resWrap1.status_code) != 200){
                    lea.Mobile_Number_already_Exists__c = true;
                } else {
                    lea.Mobile_Number_already_Exists__c = false;
                }
            }
            // 5Jan2022:Asif:End
            System.debug('LEad '+lea);
            if(!test.isRunningTest())
                update lea;
            
            
            System.debug('Api Logs '+apiLogs);
            if(!apiLogs.isEmpty()){
                LogService.createApiLogs(apiLogs);
            }
        }
        
    }    
}