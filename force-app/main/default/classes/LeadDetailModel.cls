/*
 * Class created by Deepali
 * Purpose: To have a wrapper of all json objects in one class
*/
public class LeadDetailModel {
    
    public class DealerWrapper{
        public String Code;
        public String Name;
        public String Address1;
        public String Address2;
        public String Pincode;
        public String City;
        public String State;
        public String Mobile;
        public String Latitude;
        public String Longitude;
        public String PrincipleEmail;
        public String SellingEmail;
    }
    
    public class LeadWrapper{
        public String lead_type;
        public String lead_source;
        public String lead_title;
        public String lead_category;
        public String lead_tags;
        public String lead_flag;
        public String lead_priority;
        public String customer_name;
        public String customer_mobile;
        public String customer_email;
        public String is_otp_verfied;
        public String whatsapp_consent;
        public String funding_amount;
        public String area_state;
        public String area_city;
        public String area_pincode;
        public String stock_id;
        public String stock_type;
        public String primary_make;
        public String primary_model;
        public String primary_variant;
        public String secondary_make;
        public String secondary_model;
        public String secondary_variant;
        public String mfg_year;
        public String mfg_month;
        public String register_month;
        public String register_year;
        public String color;
        public String kms;
        public String owner;
        public String rating;        
        public String register_no;
        public String register_city;
        public String stock_listed_price;
        public String leadsource_dealer_id;
        public String comments;
        public String marketing_source;
        public String marketing_campaign;
        public String marketing_device;
        public String marketing_content;
        public String marketing_medium;
        public String marketing_term;
        public String is_autofin_lead; // Sumit::CRM-1013/1014
        public List<Target> target;
        public String client_ip;
        
        // 21Jan2022:Asif:Start
        public Integer hi_serviceable;
        // 21Jan2022:Asif:End
         
        //public String LMS_leadid;
        public String sfdc_lead_id;
        public String lead_stage;
        public String lead_status;
        public String lost_reason;
        public String customer_expected_price;
        public String customer_address;
        public String created_date;
        public String lms_lead_id;
        public String created_at;
        //Added by Aravindan, Date: 1/9/2020
        public String private_lead_id;
        //Added by Soumya 21/09/2020
        public String lead_url;
        public String utm_term;
        //Added by soumya 13/11/20
        public String sf_lead_id;
        public String td_client_id;

        public String order_id; // 11April2022:Asif :: mapping order id from the Request Body
 
    }
    
    public class Target{
        public String sfdc_lead_id;  // sumit for demo purpose
        public String is_autofin_lead; // Sumit::CRM-1013/1014
        public String lms_dispatch_id;
        public String sfdc_lead_dispatch_id;
        public String target_name;
        public String target_source;
        public String target_id;
        public String followup_date;
        public String status;
        public String followup_comments;
        public String status_updated_by;
        public String employee_id;
        public String employee_name;
        public String employee_type;
        public String Ext_warranty_amount;
        public String Ext_warranty_cancelled;
        public String Ext_warranty_end_date;
        public String Ext_warranty_end_kilometre;
        public String Ext_warranty_number;
        public String Ext_warranty_punched;
        public String Ext_warranty_recommended;
        public String Ext_warranty_sold_date;
        public String Ext_warranty_start_date;
        public String Ext_warranty_start_kilometre;
        public String Warranty;
        public String Warranty_Cancelled;
        public String Warranty_End_Date;
        public String Warranty_End_Kilometre;
        public String Warranty_Number;
        public String Warranty_Punched_Date;
        public String Warranty_Start_Date;
        public String Warranty_Start_Kilometre;
        public String Warranty_Type;
        public String stock_id;        
        public String sold_stock_type;
        public String sold_make;
        public String sold_model;
        public String sold_variant;
        public String sold_mfg_year;
        public String sold_mfg_month;
        public String sold_register_month;
        public String sold_register_year;
        public String sold_color;
        public String sold_kms;
        public String sold_owner;
        public String sold_register_no;
        public String sold_register_city;
        public String testdrive_datetime;        
    }
    
    public class MainWrapperClass{
        public List<LeadWrapper> data;
        public String access_token;
        public String tag;
    }
    
    public class ResponseWrapperClass{
        public String message;
        public String status_code;
        public String sfdc_lead_id;
        public String id;
        public String sfdc_lead_dispatch_id;
        public String target_id;
        public String leadsDispatch_id;
    }
    
    public class ResponseMessage{
        public String status;
        public List<ResponseLeadobj> lead_result;
        public List<ResponseDispatchobj> lead_dispatch_result;
    }
    
    public class ResponseLeadobj{ 
        public String customer_mobile;   // lms_lead_id replace sumit
        public String sf_lead_id;
        public String phone;
        public String status;
        public String message;
        public String private_lead_id;
        public String lms_lead_id; 
    }
    
    public class ResponseDispatchobj{
        public String lms_dispatch_id ;
        public String sf_lead_dispatch_id;
        public String status;
        public String message;
    }

}