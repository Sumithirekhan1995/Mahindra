@isTest
public class LeadPushToLMSTestClass {
    
    public static testmethod void LeadPushToTest() {
        
        // endPoints
        List<LeadPushAPI__c> configs= new List<LeadPushAPI__c>();
        configs.add(new LeadPushAPI__c(
            Name = 'Get Token',
            Endpoint__c = 'auth_url'
        ));
        configs.add(new LeadPushAPI__c(
            Name = 'Lead Create',
            Endpoint__c = 'data_url'
        )); 
        configs.add(new LeadPushAPI__c(
            Name = 'Lead Update',
            Endpoint__c = 'data_update_url'
        )); 
        insert configs;
        
        
        // Test data
        // Dealer
        Account A = new Account();
        a.Name  = 'test';
        a.Code__c = '12345';
        A.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        insert A;
        
        // Product
        Product2 P = new Product2();
        P.Dealer_Name__c = A.Id;
        P.Name = 'Honda';
        P.Body_Type__c ='Shield';
        P.Color__c = 'Black';
        p.Stock_ID__c = '12345';
        insert P;
        
        // Lead
        Lead l = new Lead();
        l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Buyer_Used_Car').getRecordTypeId();
        l.Status__c = 'Open';
        l.Phone = '8400989800';
        l.Product__c = p.Id;
        l.Customer_Id__c = '12345';
        l.LeadSource = 'Advertisement';
        insert l;
        
        // insert opportunity Records
        Opportunity d = new Opportunity();
        d.Name = 'Test';
        d.Phone__c = l.Phone;
        d.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('Buyer_Used_Car').getRecordTypeId();
        d.StageName = 'Qualification';
        d.CloseDate = System.today();
        d.Lead__c = l.Id;
        d.Dealer__c = a.Id;
        d.Status__c = 'Assigned';
        d.HI_Serviceable__c = '1';
        d.Remarks__c = 'test';
        d.HI_Preference__c = 'Home';
        d.Bypass_validation__c = false;
        d.LeadSource = 'Advertisement';
        insert d;
        
  /*      // Lead Dispatch
        Lead_Dispatch__c d = new Lead_Dispatch__c();
        d.Lead__c = l.Id;
        insert d;  */
        

        
        // mock Callouts
        Test.setMock(HttpCalloutMock.class, new mockAll());
        
        // prep Request
		RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='https://mfcw--uat.my.salesforce.com/services/apexrest/leadupsert';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response= response;
       
        // start test
        test.startTest();

        // lead creation 1
        String req1 = '{"data":[{"lead_type":"USEDCARSALES","lead_title":"reserve","lead_category":null,"lead_tags":"usedcar","lead_flag":"reserve","customer_name":"Vikram","customer_mobile":"8548548541","customer_email":"fuckchelsea@mailinator.com","is_otp_verfied":"no","funding_amount":null,"area_state":"Karnataka","area_city":"Bangalore","area_pincode":560001,"stock_id":"12345","stock_type":"MFC","stock_source":"MFC","primary_make":"TOYOTA","primary_model":"INNOVA(2005-2009)","primary_variant":"2.5 G1","secondary_make":"","secondary_model":"","secondary_variant":"","color":"Silver","kms":237000,"owner":1,"register_no":"KA04MF3477","register_city":"Bangalore","stock_listed_price":530000,"leadsource_dealer_id":null,"lead_stage":"","lead_source":"CNB","lead_priority":"Red","lead_status":"open","marketing_source":"Direct","marketing_campaign":"Direct","marketing_device":"Desktop","marketing_content":"Direct","marketing_medium":"Direct","marketing_term":"test","comments":"test","customer_expected_price":"12.12","funding_amount":"123.12","whatsapp_consent":"true","lead_category":"Open","register_month":"jan","register_year":"2022","target":[{"target_name":"Zippy Automart","target_source":"MFC","target_id":"12345","followup_date":"2022-02-04","status":"open","followup_comments":"","stock_id":"12345","employee_id":"123445","employee_type":"test","employee_name":"test","Ext_warranty_amount":"12345","Ext_warranty_cancelled":"true","Ext_warranty_number":"12344","Ext_warranty_end_date":"2022-02-03 21:10:42","Ext_warranty_end_kilometre":"12345","Ext_warranty_punched":"12345","Ext_warranty_recommended":"test","Ext_warranty_sold_date":"2022-02-03 21:10:42","Ext_warranty_start_date":"2022-02-03 21:10:42","Ext_warranty_start_kilometre":"123454","status_updated_by":"test","Warranty":"true","Warranty_Cancelled":"true","Warranty_End_Date":"2022-02-03 21:10:42","Warranty_End_Kilometre":"1212","Warranty_Number":"123434","Warranty_Punched_Date":"2022-02-03 21:10:42","Warranty_Start_Date":"2022-02-03 21:10:42","Warranty_Start_Kilometre":"1212","Warranty_Type":"Open","sold_stock_type":"test","sold_make":"test","sold_model":"test","sold_variant":"test","sold_mfg_year":"2022","sold_mfg_month":"jan","sold_register_month":"jan","sold_color":"test","sold_kms":"1212","sold_owner":"test","sold_register_no":"121212","sold_register_city":"test","followup_comments":"test","sold_register_year":"121212"}],"lms_lead_id":"","td_client_id":"121212","client_ip":"20.0.2.80","leadsource_ref_id":638983,"created_date":"2022-02-03 21:10:42","mfg_year":"2008","mfg_month":"05"}],"tag":"web"}';
        request.requestBody = Blob.valueOf(req1); 
        LeadPushToLMS.getLeadInfo();

        // lead creation 2
        req1 = '{"data":[{"lead_type":"USEDCARSALES","sfdc_lead_id":"' + l.Id + '","lead_title":"","lead_category":"","lead_tags":"","lead_flag":"True","customer_name":"Chaturabuyerlead","customer_mobile":"8400989800","customer_email":"test@gmail.com","is_otp_verfied":"yes","funding_amount":"","area_state":"haryana","area_city":"gurgaon","area_pincode":"","stock_id":"290705","stock_type":null,"primary_make":"HYUNDAI","primary_model":"SONATA","primary_variant":"2.4 GDI AT","secondary_make":"","secondary_model":"","secondary_variant":"","mfg_year":"2019","mfg_month":"2","register_month":"1","register_year":"2020","color":"B.Green","kms":"4000","owner":"1","register_no":"MH04FB4545","register_city":"Aahwa","stock_listed_price":"","lead_source":"CNB","comments":"Testing the P&S functionality","marketing_source":"Direct","marketing_campaign":"Direct","marketing_device":"Desktop","marketing_content":"Direct","marketing_medium":"Direct","customer_expected_price":null,"customer_address":"","created_date":"5/19/2020 5:05:58 AM","created_at":"","target":[{"stock_id":"290705","target_name":"Prestige Autoworld","target_source":"","target_id":"242","followup_date":"5/20/2020 10:35:58 AM","status":"SOLD","followup_comments":"Testing the P&S functionality","status_updated_by":"","employee_id":"","employee_name":"","employee_type":"","lms_dispatch_id":"","Ext_warranty_amount":"","Ext_warranty_cancelled":null,"Ext_warranty_end_date":"","Ext_warranty_end_kilometre":"","Ext_warranty_number":null,"Ext_warranty_punched":"","Ext_warranty_recommended":"","Ext_warranty_sold_date":"","Ext_warranty_start_date":"","Ext_warranty_start_kilometre":null,"Warranty":null,"Warranty_Cancelled":"Active","Warranty_End_Date":"5/25/2021 8:49:17 PM","Warranty_End_Kilometre":"","Warranty_Number":"AFP024205203896","Warranty_Punched_Date":"5/25/2020 8:49:17 PM","Warranty_Start_Date":"5/25/2020 8:49:17 PM","Warranty_Start_Kilometre":"123","Warranty_Type":"AssistFirst","sold_variant":"1.8V AT","sold_stock_type":"mfc","sold_register_year":"2016","sold_register_no":"RT87TY8388","sold_register_month":"Mar","sold_register_city":"Ajmer","sold_owner":"3","sold_model":"CIVIC","sold_mfg_year":"2013","sold_mfg_month":"4","sold_make":"HONDA","sold_kms":"123","sold_color":"A Blue"}],"client_ip":"13.235.101.138","lms_lead_id":null}],"tag":"web","sfdc_lead_dispatch_id":"' + d.Id + '"}'; 
        request.requestBody = Blob.valueOf(req1);  
        LeadPushToLMS.getLeadInfo();  

        // lead creation 3
        req1 = '{"data":[{"lead_type":"PROCUREMENT","sfdc_lead_id":"' + l.Id + '","lead_title":"","lead_category":"","lead_tags":"","lead_flag":"True","customer_name":"Chaturabuyerlead","customer_mobile":"9999999999","customer_email":"test@gmail.com","is_otp_verfied":"yes","funding_amount":"","area_state":"haryana","area_city":"gurgaon","area_pincode":"","stock_id":"290705","stock_type":null,"primary_make":"HYUNDAI","primary_model":"SONATA","primary_variant":"2.4 GDI AT","secondary_make":"","secondary_model":"","secondary_variant":"","mfg_year":"2019","mfg_month":"2","register_month":"1","register_year":"2020","color":"B.Green","kms":"4000","owner":"1","register_no":"MH04FB4545","register_city":"Aahwa","stock_listed_price":"","lead_source":"CNB","comments":"Testing the P&S functionality","marketing_source":"Direct","marketing_campaign":"Direct","marketing_device":"Desktop","marketing_content":"Direct","marketing_medium":"Direct","customer_expected_price":null,"customer_address":"","created_date":"5/19/2020 5:05:58 AM","created_at":"","target":[{"stock_id":"290705","target_name":"Prestige Autoworld","target_source":"","target_id":"242","followup_date":"5/20/2020 10:35:58 AM","status":"SOLD","followup_comments":"Testing the P&S functionality","status_updated_by":"","employee_id":"","employee_name":"","employee_type":"","lms_dispatch_id":"","sfdc_lead_dispatch_id":"' + d.Id + '","Ext_warranty_amount":"","Ext_warranty_cancelled":null,"Ext_warranty_end_date":"","Ext_warranty_end_kilometre":"","Ext_warranty_number":null,"Ext_warranty_punched":"","Ext_warranty_recommended":"","Ext_warranty_sold_date":"","Ext_warranty_start_date":"","Ext_warranty_start_kilometre":null,"Warranty":null,"Warranty_Cancelled":"Active","Warranty_End_Date":"5/25/2021 8:49:17 PM","Warranty_End_Kilometre":"","Warranty_Number":"AFP024205203896","Warranty_Punched_Date":"5/25/2020 8:49:17 PM","Warranty_Start_Date":"5/25/2020 8:49:17 PM","Warranty_Start_Kilometre":"123","Warranty_Type":"AssistFirst","sold_variant":"1.8V AT","sold_stock_type":"mfc","sold_register_year":"2016","sold_register_no":"RT87TY8388","sold_register_month":"Mar","sold_register_city":"Ajmer","sold_owner":"3","sold_model":"CIVIC","sold_mfg_year":"2013","sold_mfg_month":"4","sold_make":"HONDA","sold_kms":"123","sold_color":"A Blue"}],"client_ip":"13.235.101.138","lms_lead_id":"12345"}],"tag":"web"}'; 
        request.requestBody = Blob.valueOf(req1);  
        LeadPushToLMS.getLeadInfo();
        
        // lead creation 4
        req1 = '{"data":[{"lead_type":"USEDCARSALES","sfdc_lead_id":null,"private_lead_id":"12345","lead_title":"","lead_category":"","lead_tags":"","lead_flag":"True","customer_name":"Chaturabuyerlead","customer_mobile":"9999999999","customer_email":"test@gmail.com","is_otp_verfied":"yes","funding_amount":"","area_state":"haryana","area_city":"gurgaon","area_pincode":"","stock_id":"290705","stock_type":null,"primary_make":"HYUNDAI","primary_model":"SONATA","primary_variant":"2.4 GDI AT","secondary_make":"","secondary_model":"","secondary_variant":"","mfg_year":"2019","mfg_month":"2","register_month":"1","register_year":"2020","color":"B.Green","kms":"4000","owner":"1","register_no":"MH04FB4545","register_city":"Aahwa","stock_listed_price":"","lead_source":"CNB","comments":"Testing the P&S functionality","marketing_source":"Direct","marketing_campaign":"Direct","marketing_device":"Desktop","marketing_content":"Direct","marketing_medium":"Direct","customer_expected_price":null,"customer_address":"","created_date":"5/19/2020 5:05:58 AM","created_at":"","target":[{"stock_id":"290705","target_name":"Prestige Autoworld","target_source":"","target_id":"242","followup_date":"5/20/2020 10:35:58 AM","status":"SOLD","followup_comments":"Testing the P&S functionality","status_updated_by":"","employee_id":"","employee_name":"","employee_type":"","lms_dispatch_id":"12345","sfdc_lead_dispatch_id":null,"Ext_warranty_amount":"","Ext_warranty_cancelled":null,"Ext_warranty_end_date":"","Ext_warranty_end_kilometre":"","Ext_warranty_number":null,"Ext_warranty_punched":"","Ext_warranty_recommended":"","Ext_warranty_sold_date":"","Ext_warranty_start_date":"","Ext_warranty_start_kilometre":null,"Warranty":null,"Warranty_Cancelled":"Active","Warranty_End_Date":"5/25/2021 8:49:17 PM","Warranty_End_Kilometre":"","Warranty_Number":"AFP024205203896","Warranty_Punched_Date":"5/25/2020 8:49:17 PM","Warranty_Start_Date":"5/25/2020 8:49:17 PM","Warranty_Start_Kilometre":"123","Warranty_Type":"AssistFirst","sold_variant":"1.8V AT","sold_stock_type":"mfc","sold_register_year":"2016","sold_register_no":"RT87TY8388","sold_register_month":"Mar","sold_register_city":"Ajmer","sold_owner":"3","sold_model":"CIVIC","sold_mfg_year":"2013","sold_mfg_month":"4","sold_make":"HONDA","sold_kms":"123","sold_color":"A Blue"}],"client_ip":"13.235.101.138","lms_lead_id":"12345"}],"tag":"web"}'; 
        request.requestBody = Blob.valueOf(req1);  
        LeadPushToLMS.getLeadInfo();

        // lead creation 5
        req1 = '{"data":[{"lead_type":"USEDCARSALES","sfdc_lead_id":null,"private_lead_id":"12345","lead_title":"","lead_category":"","lead_tags":"","lead_flag":"True","customer_name":"Chaturabuyerlead","customer_mobile":"9999999999","customer_email":"test@gmail.com","is_otp_verfied":"yes","funding_amount":"","area_state":"haryana","area_city":"gurgaon","area_pincode":"","stock_id":"290705","stock_type":null,"primary_make":"HYUNDAI","primary_model":"SONATA","primary_variant":"2.4 GDI AT","secondary_make":"","secondary_model":"","secondary_variant":"","mfg_year":"2019","mfg_month":"2","register_month":"1","register_year":"2020","color":"B.Green","kms":"4000","owner":"1","register_no":"MH04FB4545","register_city":"Aahwa","stock_listed_price":"","lead_source":"CNB","comments":"Testing the P&S functionality","marketing_source":"Direct","marketing_campaign":"Direct","marketing_device":"Desktop","marketing_content":"Direct","marketing_medium":"Direct","customer_expected_price":null,"customer_address":"","created_date":"5/19/2020 5:05:58 AM","created_at":"","client_ip":"13.235.101.138"}],"tag":"web"}'; 
        request.requestBody = Blob.valueOf(req1);  
        LeadPushToLMS.getLeadInfo();

        // lead creation 6
        req1 = '{"data":[{"lead_type":"USEDCARSALES","sfdc_lead_id":null,"private_lead_id":"12345","lead_title":"","lead_category":"","lead_tags":"","lead_flag":"True","customer_name":"Chaturabuyerlead","customer_mobile":"9999999999","customer_email":"test@gmail.com","is_otp_verfied":"yes","funding_amount":"","area_state":"haryana","area_city":"gurgaon","area_pincode":"","stock_id":"290705","stock_type":null,"primary_make":"HYUNDAI","primary_model":"SONATA","primary_variant":"2.4 GDI AT","secondary_make":"","secondary_model":"","secondary_variant":"","mfg_year":"2019","mfg_month":"2","register_month":"1","register_year":"2020","color":"B.Green","kms":"4000","owner":"1","register_no":"MH04FB4545","register_city":"Aahwa","stock_listed_price":"","lead_source":"CNB","comments":"Testing the P&S functionality","marketing_source":"Direct","marketing_campaign":"Direct","marketing_device":"Desktop","marketing_content":"Direct","marketing_medium":"Direct","customer_expected_price":null,"customer_address":"","created_date":"5/19/2020 5:05:58 AM","created_at":"","target":[{"stock_id":"290705","target_name":"Prestige Autoworld","target_source":"","target_id":"4317","followup_date":"5/20/2020 10:35:58 AM","status":"SOLD","followup_comments":"Testing the P&S functionality","status_updated_by":"","employee_id":"","employee_name":"","employee_type":"","lms_dispatch_id":null,"sfdc_lead_dispatch_id":null,"Ext_warranty_amount":"","Ext_warranty_cancelled":null,"Ext_warranty_end_date":"","Ext_warranty_end_kilometre":"","Ext_warranty_number":null,"Ext_warranty_punched":"","Ext_warranty_recommended":"","Ext_warranty_sold_date":"","Ext_warranty_start_date":"","Ext_warranty_start_kilometre":null,"Warranty":null,"Warranty_Cancelled":"Active","Warranty_End_Date":"5/25/2021 8:49:17 PM","Warranty_End_Kilometre":"","Warranty_Number":"AFP024205203896","Warranty_Punched_Date":"5/25/2020 8:49:17 PM","Warranty_Start_Date":"5/25/2020 8:49:17 PM","Warranty_Start_Kilometre":"123","Warranty_Type":"AssistFirst","sold_variant":"1.8V AT","sold_stock_type":"mfc","sold_register_year":"2016","sold_register_no":"RT87TY8388","sold_register_month":"Mar","sold_register_city":"Ajmer","sold_owner":"3","sold_model":"CIVIC","sold_mfg_year":"2013","sold_mfg_month":"4","sold_make":"HONDA","sold_kms":"123","sold_color":"A Blue"}],"client_ip":"13.235.101.138","lms_lead_id":"12345"}],"tag":"web"}'; 
        request.requestBody = Blob.valueOf(req1);  
        LeadPushToLMS.getLeadInfo();
        
        LeadPushToLMS.pushLeadsToLms(new List<Id>{l.Id});
         LeadPushToLMS.pushLeadsToLms(new List<Id>{d.Id});

        // end test
        test.stopTest(); 
    }
    
    public class mockAll implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
           
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Token', 'value');
           
            res.setStatusCode(200);
            
            Lead l = [SELECT Id FROM Lead LIMIT 1];
            Opportunity d = [SELECT Id FROM Opportunity LIMIT 1];
            
            if(req.getEndpoint().contains('auth_url')) {
                res.setBody('{"access_token":"token","status_code": 200}');
            } else  if(req.getEndpoint().contains('data_fail_url')){
                String json = '{"error": [{"message": "lead Created","status_code": 200,"id": "12345","leadsDispatch_id": "95945","sfdc_lead_id": "' + l.Id + '","target_id": "1","sfdc_lead_dispatch_id": "' + d.Id + '"}]}';
                res.setBody(json);
            } else  {
                String json = '{"success": [{"message": "lead Created","status_code": 200,"id": "12345","leadsDispatch_id": "95945","sfdc_lead_id": "' + l.Id + '","target_id": "1","sfdc_lead_dispatch_id": "' + d.Id + '"}],"error": [{"message": "lead Created","status_code": 200,"id": "147948","leadsDispatch_id": "95945","sfdc_lead_id": "' + l.Id + '","target_id": "1","sfdc_lead_dispatch_id": "' + d.Id + '"}]}';
                res.setBody(json);
            }
            
            return res;    
            
        } 
    }
}