/*
* Wrapper Class for Lead CnB
* Last Modified by Soumya on 06/10/2020
*/

public class CnBLeadWrapperClass {
     public List<CnBWrapper> data;
    
    //Response Wrapper Class for CnB Leads
    public class CnBResponseWrapper{
        public String message;
        public String sfdc_lead_id;
        public String status_code;
        public String id_car_lead;
        public String id_bike_lead;
    }
    
    //Lead Inner json Wrapper Class
    public class CnBLeadWrapper{
        public String id_car_lead;
        public String id_car_model;
        public String id_car_variant;
        public String id_bike_lead;
        public String id_bike_model;
        public String id_bike_variant;
        public String id_car_manufacturer;
        public String manufacturer;
        public String model;
        public String variant;
        public String id_city;
        public String city;
        public String id_pincode;
        public String pincode;
        public String id_form_type;
        public String form_name;
        public String id_dealer;
        public String dealer_name;
        public String id_source;
        public String source;
        public String date_time;
        public String duration_days;
        public String utm_source;
        public String utm_medium;
        public String utm_campaign;
        public String utm_content;
        public String utm_term;
        public String url;
        public String affiliate_type;
        public String affiliate_status;
        public String affiliate_date;
        public String affiliate_response;
        public Integer marketing_status;
        public String sfdc_lead_id;
    }
    
    //Lead Wrapper Outer json wrapper Class
    public class CnBWrapper{
        public String mobile;
        public String name;
        public String email;
        public String marketing_status;
        public String follow_up_date;
        public String is_verified;
        public String id_user;
        public String first_visit_date;
        public String date_time; 
        public String callStatus;
        public String vehicle_type;
        public String id_car_lead;
        public String sfdc_lead_id;
        public String pincode;
        public List<CnBLeadWrapper> leads;
    }
    public Class CarWrapper{
        public List<CnBWrapper> data;
    }
    //LeadWrapper for bike inner JSON Class 
    public Class LeadDataBike {
        public String id_form_type;
        public String id_bike_lead;
        public String id_bike_model;
        public String id_bike_variant;
        public String id_city;
        public String id_pincode;
        public String duration_days;
        public String id_dealer;
        public String id_source;
        public String loan_requirement;
        public String loan_amount;
        public String loan_term;
        public String employment_type;
        public String company_name;
        public String monthly_income;  
    }
 
    //LeadWrapper for Data JSON bike
    public class LeadBikeWrapper{
        public String name;
        public String email;
        public String mobile;
        public String marketing_status;
        public String first_visit_date;
        public String is_verified;
        public String date_time;
        public String vehicle_type;
        public String sfdc_lead_id;
        public String id_bike_lead;
        public String pincode;
        public List<LeadDataBike> leads;
    }
    
    //Main Wrapper
    public Class BikeWrapper{
        public List<LeadBikeWrapper> data;
    }
    
    public class CnBCalloutResponseWrapper{
        public String status_code;
        public CnBCalloutResponse response; 
    }
    
    public class CnBCalloutResponse{
        public CnBResponseData recommendedData;
        public List<CnBCalloutResponseData> searchData;
    } 
    
    public class CnBResponseData{
        @AuraEnabled
        public List<CnBCalloutResponseData> recommended;
        @AuraEnabled
        public List<CnBCalloutResponseData> cross_sell;
    }
    
    public class CnBCalloutResponseData{
        @AuraEnabled
        public String model_name;
        @AuraEnabled
        public String id_car_model;
        @AuraEnabled
        public String id_bike_model;
        @AuraEnabled
        public String min_price;
        @AuraEnabled
        public String max_price;
        @AuraEnabled
        public String manufacturer_name;
        @AuraEnabled
        public String min_mileage;
        @AuraEnabled
        public String max_mileage;
        @AuraEnabled
        public String rating;
        @AuraEnabled
        public Boolean check;
        @AuraEnabled
        public String status;
    }
    
    public Class CnBLeadStatusChange{
        public Integer marketing_status;
        public Integer id_car_model;
        public String id_bike_model;
        public String sfdc_lead_id;
    }
    public class CnBLeadStatusChangeWrapper{
        public Integer marketing_status;// 1,
        public String id_car_lead; //1162833,
        public String id_bike_lead;
        public String sfdc_lead_id; //"00Q1s000001RqPSEA0",
        public List<CnBLeadWrapper> leads;
    }
    
    public class CnBCalloutLeadWrapper{
        public String mobile;
        public String name;//"cnb test",
        public String email;// "test@gmail.com",
        public Integer marketing_status;// 1,
        public Integer is_verified;// 0,
        public Integer id_car_model;// 1496,
        public String id_bike_model;
        public String city;//"Hyderabad",
        public Integer id_form_type;// 1,
        public Integer id_source;// 207
    }
    
    public class NewLeadCallout{
        public String mobile;
        public String name;
        public String email;
        public String marketing_status;
        public String is_verified;
        public String id_car_model;
        public String id_bike_model;
        public String city;
        public String id_form_type;
        public String id_source;
        public String pincode;
        public String sfdc_lead_id;
    }
    public Class NewLeadCalloutWrapper{
        public List<NewLeadCallout> leads;
    }
    
    public class Response {
        public List<Data> data;
    }
    
    public String status_code;
    public Response response;
    
    public class Data {
        public Success success;
        public String error;
        public String id_car_model;
        public String id_bike_model;
        public String mobile;
    }
    
    public class Success {
        public String id_car_lead;
        public String sfdc_lead_id;
        public String id_bike_lead;
    }
}