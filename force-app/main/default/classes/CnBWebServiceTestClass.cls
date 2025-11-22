@isTest
public class CnBWebServiceTestClass {
    
    //Method1
    public static testmethod void cnbLeadPush1(){
        Lead l = new Lead();
        l.LastName = 'Test Demo';
        l.Phone = '8088088000';
        l.Form_Type_Id__c = '4';
        l.CnB_API_Fire__c = true;
        l.LeadSource = 'CNB';
        insert l;
        String s = '{"data":[ { "vehicle_type" : "car",  "sfdc_lead_id" : null, "id_dealer":"1234", "duration_days":"21", "pincode" : null, "name" : "'+l.LastName +'", "mobile" : "'+l.Phone+'", "marketing_status" : null, "leads" : [ { "variant" : "1.2 Magna Plus Petrol", "utm_term" : "(none)", "utm_source" : "self", "utm_medium" : "push-notification", "utm_content" : "(none)", "utm_campaign" : "(none)", "url" : "/hyundai-cars/elite-i20", "source" : "Desktop", "sfdc_lead_id" : null, "pincode" : "600001", "model" : "Elite i20", "marketing_status" : null, "manufacturer" : "Hyundai", "id_source" : "1", "id_pincode" : "75991", "id_form_type":"'+l.Form_Type_Id__c+'", "id_dealer" : "1234", "id_city" : "1186", "id_car_variant" : "16372", "id_car_model" : "1366", "id_car_manufacturer" : "115", "id_car_lead" : "14366", "id_bike_variant" : null, "id_bike_model" : null, "id_bike_lead" : null, "form_name" : "testdrive", "duration_days" :"20" , "dealer_name" : "test", "date_time" : "2021-02-23 14:00:00", "city" : "Chennai", "affiliate_type" :"test" , "affiliate_status" : null, "affiliate_response" :"test" , "affiliate_date" : "2021-03-09 13:26:5" } ], "is_verified" : "0", "id_user" : null, "id_car_lead" : null, "follow_up_date" :"2021-03-09 13:26:5", "first_visit_date" : "2021-03-09 13:26:55", "email" : "testcnb@gmail.com", "date_time" : null, "callStatus" : null } ]}';
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse(); 
        request.requestUri ='https://mfcwcnb--partial.sandbox.my.salesforce.com/services/apexrest/cnbleadupsert';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(S);  
        RestContext.request = request;
        RestContext.response= response;
        
        test.startTest();
        CnBWebService.getTheLeadInfo();
        test.stopTest();
    }
    
    public static testmethod void test2(){
       
    
    
        Lead l = new Lead();
        l.LastName = 'Test Demo';
        l.Phone = '8088088000';
        l.Form_Type_Id__c = '4';
        l.Status__c = '2';
        l.bike_Model_Id__c = '1517';
        l.RecordTypeId = LeadConstants.CnBBikeLeadRecordTypeId;
        l.LeadSource = 'CNB';
        insert l;
        String S1 = '{"data" :[ { "vehicle_type" : "bike", "sfdc_lead_id" : null, "pincode" : null, "name" : "Karyanand", "mobile" : "9044184545", "marketing_status" : "7", "leads" : [ { "variant" : "Signals Edition", "utm_term" : null, "utm_source" : null, "utm_medium" : null, "utm_content" : null, "utm_campaign" : null, "url" : null, "source" : null, "sfdc_lead_id" : null, "pincode" : "202001", "model" : "Classic 350", "marketing_status" : "7", "manufacturer" : "Royal Enfield", "id_source" : "1", "id_pincode" : "9683", "id_form_type" : "16", "id_dealer" : null, "id_city" : "1217", "id_car_variant" : null, "id_car_model" : null, "id_car_manufacturer" : null, "id_car_lead" : null, "id_bike_variant" : "11357", "id_bike_model" : "1174", "id_bike_lead" : "2348784", "form_name" : null, "duration_days" : null, "dealer_name" : null, "date_time" : null, "city" : "Aligarh", "affiliate_type" : null, "affiliate_status" : "test1", "affiliate_response" : null, "affiliate_date" : null } ], "is_verified" : "0", "id_user" : "1234", "id_car_lead" : null, "follow_up_date" : null, "first_visit_date" : "2021-03-09 12:23:20", "email" : "karyanand@gmail.com", "date_time" : null, "callStatus" : "tst" } ]}';
        RestRequest request1 = new RestRequest();
        RestResponse response1 = new RestResponse(); 
        request1.requestUri ='https://mfcwcnb--partial.sandbox.my.salesforce.com/services/apexrest/cnbleadupsert';
        request1.httpMethod = 'POST';
        request1.addHeader('Content-Type', 'application/json');
        request1.requestBody = Blob.valueOf(S1);  
        RestContext.request = request1;
        RestContext.response= response1;
        
        test.startTest();
        CnBWebService.getTheLeadInfo();
        test.stopTest();
        
    }

}