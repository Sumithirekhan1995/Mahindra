/**
* @description       : 
* @author            : Kunal Nadkarni
* @group             : 
* @last modified on  : 10-12-2020
* @last modified by  : Kunal Nadkarni
* Modifications Log 
* Ver   Date         Author           Modification
* 1.0   10-12-2020   Kunal Nadkarni   Initial Version
**/
public class CnBCallOutService {
    //LeadResponseWrapper for LeadStatusChange API when Lead is single -- Start
    public class Response {
        public Data data;
    }
    public String status_code;
    public Response response;
    
    public class Data {
        public String success;
    } //End
    
    private static CnB_Endpoint__c cnbEndpoint = CnB_Endpoint__c.getAll().values()[0];
    private static HttpRequest req = new HttpRequest();
    private static HttpResponse res = new HttpResponse();
    private static Http h = new Http();
    
    private static void generateHeader(){
        String username = cnbEndpoint.Username__c; 
        String password = cnbEndpoint.Password__c;
        // Add basic authentication to header
        // Create blob of user:pass
        Blob headerValue = Blob.valueOf(username + ':' + password);
        // Base 64 Encode the blob and prepend "Basic "
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        // Add the basic auth string to the Request Header
        req.setHeader('Authorization', authorizationHeader);            
        
        // Configure standard headers
        req.setHeader('Accept', '*/*');
        // This tells the API that we are sending and receiving the data as a JSON object 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-app-api-key', cnbEndpoint.x_app_api_key__c);
        req.setHeader('x-app-api-secret', cnbEndpoint.x_app_api_secret__c);
    }
    
    public static List<CnBLeadWrapperClass.CnBCalloutResponseData> searchCar(String searchParameter, String VehicleType){
        CnBLeadWrapperClass.CnBCalloutResponseWrapper responseWrapperObj;
        generateHeader();
        String endpoint;
        if(VehicleType == 'car'){
            endpoint = cnbEndpoint.Search_Car__c +'?q='+searchParameter;
        }
        else if(VehicleType == 'bike'){
            endpoint = cnbEndpoint.NewBike_SearchCar__c + '?q='+searchParameter+'&vehicle_type=bike';
        }
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        res = h.send(req);
        System.debug('Request '+req);
        System.debug('res.getBody(): '+res.getBody());
        if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null) {
            String jsonStr = res.getBody();
            jsonStr = jsonStr.replace('data','searchData');
            responseWrapperObj = (CnBLeadWrapperClass.CnBCalloutResponseWrapper)JSON.deserialize(jsonStr, CnBLeadWrapperClass.CnBCalloutResponseWrapper.class);
            System.debug('responseWrapperObj: '+responseWrapperObj);
            return responseWrapperObj.response.searchData;
        }
        return null;         
    }
    
    //Callout when status is changed from the lightning component and a new lead is created.
    public static CnBLeadWrapperClass.CnBResponseData getRecommendations(String carModelId, String VehicleType){
        CnBLeadWrapperClass.CnBCalloutResponseWrapper responseWrapperObj;
        generateHeader();
        String endpoint;
        if(VehicleType == 'car'){
            endpoint = cnbEndpoint.Recommendation__c+'?id_car_model='+carModelId;
        }
        else if(VehicleType == 'bike'){
            endpoint = cnbEndpoint.NewBike_Recommendation__c + '?id_bike_model='+carModelId+'&vehicle_type=bike';
        }
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        res = h.send(req);
        System.debug('Request '+req);
        System.debug('res.getBody(): '+res.getBody());
        
        if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null) {
            String jsonStr = res.getBody();
            jsonStr = jsonStr.replace('cross-sell','cross_sell');
            jsonStr = jsonStr.replace('data','recommendedData');
            responseWrapperObj = (CnBLeadWrapperClass.CnBCalloutResponseWrapper)JSON.deserialize(jsonStr, CnBLeadWrapperClass.CnBCalloutResponseWrapper.class);
            System.debug('responseWrapperObj: '+responseWrapperObj);
            return responseWrapperObj.response.recommendedData;
        }
        return null; 
        
    }
    
    public static void updateLeadStatus(Set<Id> subLeadIds){//Map<Id,Set<Id> leadIdMap
        generateHeader();
        List<Lead> updateList = new List<Lead>();
        List<CnBLeadWrapperClass.CnBLeadWrapper> wrap = new List<CnBLeadWrapperClass.CnBLeadWrapper>();
        List<API_log__c> insertAPIList = new List<API_Log__c>();
        Map<String, Lead> mapOfExistingCarLeadId = new Map<String, Lead>();
        CnBLeadWrapperClass.CarWrapper car = new CnBLeadWrapperClass.CarWrapper();
        CnBLeadWrapperClass.BikeWrapper bike = new CnBLeadWrapperClass.BikeWrapper();
        String JsonLeadStr;
        String endpoint;
        Set<String> resCarLeadId = new Set<String>();
        List<Lead> leaRec = [Select Id,FirstName, LastName, Phone, Email, RecordtypeId, Follow_Up_Date_Time__c, Is_Verified__c, User_Id__c,First_Visit_Date__c,Date_Time__c,Vehicle_Type__c,
                             Call_Status__c, Car_Model_Id__c,Car_Lead_Id__c, Car_Variant_Id__c, Manufacturer_Car_Id__c, Variant__c, City_Id__c, area_City__c, pincode_id__c,
                             area_pincode__c, Dealer_Id__c, Dealer_Name__c, Primary_Model__c, Source_Id__c , Duration_Days__c, Url__c,UTM_Campaign__c,  UTM_Content__c, UTM_Medium__c,
                             UTM_Source__c, UTM_Term__c, Affiliate_Date__c, Affiliate_Response__c,  Affiliate_Status__c,    Affiliate_Type__c, Manufacturer__c, Bike_Lead_Id__c, 
                             Loan_Amount__c, Loan_Requirement__c, Bike_Model_Id__c,Bike_Variant_Id__c, Monthly_Income__c,company, status__c,Employment_Type__c,Form_Type_Id__c, Loan_Term__c  from Lead Where Id IN :subLeadIds];
        System.debug('leaRec'+leaRec);
        List<CnBLeadWrapperClass.CnBWrapper> listOfCnbCar = new List<CnBLeadWrapperClass.CnBWrapper>();
        List<CnBLeadWrapperClass.CnBLeadWrapper> listOfCnbLead = new List<CnBLeadWrapperClass.CnBLeadWrapper>();
        List<CnBLeadWrapperClass.LeadBikeWrapper> listOfCnBBike = new List<CnBLeadWrapperClass.LeadBikeWrapper>();
        List<CnBLeadWrapperClass.LeadDataBike> listOfCnbBikeLead = new List<CnBLeadWrapperClass.LeadDataBike>();
        //for(Lead lea : LeaRec){
            if(leaRec[0].RecordTypeId == LeadConstants.CnBLeadRecordTypeId){                  
                for(Integer i = 1 ; i< leaRec.size() ; i++){
                    CnBLeadWrapperClass.CnBLeadWrapper cnbWrap = new CnBLeadWrapperClass.CnBLeadWrapper();
                    cnbWrap.affiliate_date = String.valueOf(leaRec[i].Affiliate_Date__c);
                    //cnbWrap.affiliate_response = leaRec[i].Affiliate_Response__c;
                    cnbWrap.affiliate_status = leaRec[i].Affiliate_Status__c;
                    cnbWrap.affiliate_type = leaRec[i].Affiliate_Type__c;
                    cnbWrap.city = leaRec[i].Area_City__c;
                    cnbWrap.date_time = String.valueOf(leaRec[i].Date_Time__c);
                    cnbWrap.dealer_name = leaRec[i].Dealer_Name__c;
                    cnbWrap.duration_days = leaRec[i].Duration_Days__c;
                    cnbWrap.id_car_lead = leaRec[i].Car_Lead_Id__c;
                    cnbWrap.id_car_manufacturer = leaRec[i].Manufacturer_Car_Id__c;
                    cnbWrap.id_car_model =leaRec[i].Car_Model_Id__c;
                    //cnbWrap.variant = leaRec[i].Variant__c;
                    cnbWrap.id_city = leaRec[i].City_Id__c;
                    cnbWrap.id_dealer = leaRec[i].Dealer_Id__c;
                    cnbWrap.id_form_type = leaRec[i].Form_Type_Id__c;
                    cnbWrap.id_pincode = leaRec[i].Pincode_Id__c;
                    cnbWrap.id_source = leaRec[i].Source_Id__c;
                    cnbWrap.manufacturer = leaRec[i].Manufacturer__c;
                    if(leaRec[i].Status__c != Null)
                        cnbWrap.marketing_status = Integer.valueOf(leaRec[i].Status__c);
                    cnbWrap.model = leaRec[i].Primary_Model__c;
                    cnbWrap.pincode = leaRec[i].Area_PinCode__c;
                    cnbWrap.sfdc_lead_id = leaRec[i].Id;
                    cnbWrap.url = leaRec[i].URL__c;
                    cnbWrap.utm_campaign = leaRec[i].UTM_Campaign__c;
                    //cnbWrap.utm_content = leaRec[i].UTM_Content__c;
                    cnbWrap.utm_medium = leaRec[i].UTM_Medium__c;
                    cnbWrap.utm_source = leaRec[i].UTM_Source__c;
                    cnbWrap.utm_term = leaRec[i].UTM_Term__c;
                    cnbWrap.variant = leaRec[i].Variant__c;
                    listOfCnbLead.add(cnbWrap);        
                
                }
                    CnBLeadWrapperClass.CnBWrapper cnbCar = new CnBLeadWrapperClass.CnBWrapper();
                    cnbCar.callStatus = leaRec[0].Call_Status__c;
                    cnbCar.date_time = String.valueOf(leaRec[0].Date_Time__c);
                    cnbCar.email = leaRec[0].Email;
                    cnbCar.first_visit_date = String.valueOf(leaRec[0].First_Visit_Date__c);
                    cnbCar.follow_up_date = String.valueOf(leaRec[0].Follow_Up_Date_Time__c);
                    cnbCar.id_user = leaRec[0].User_Id__c;
                    cnbCar.is_verified = leaRec[0].Is_Verified__c;
                    cnbCar.pincode = leaRec[0].area_pincode__c;
                    if(leaRec[0].Status__c != NULL)
                       cnbCar.marketing_status = leaRec[0].Status__c;
                    cnbCar.mobile = leaRec[0].Phone;
                    cnbCar.id_car_lead = leaRec[0].car_lead_id__c;
                    cnbCar.sfdc_lead_id = leaRec[0].id;
                    if(leaRec[0].FirstName != NULL){
                        cnbCar.name =leaRec[0].FirstName+ ''+ leaRec[0].LastName;
                    }
                    else {
                        cnbCar.name =leaRec[0].LastName;
                    }
                    cnbCar.vehicle_type = leaRec[0].Vehicle_Type__c;
                    cnbCar.leads = listOfCnbLead;
                    listOfCnbCar.add(cnbCar);
                
                car.data = listOfCnbCar;
                JsonLeadStr =System.JSON.serialize(car);
                endpoint = cnbEndpoint.LeadStatusChange__c;  
            }
            else if(leaRec[0].RecordTypeId == LeadConstants.CnBBikeLeadRecordTypeId){
                for(Integer i = 1 ; i< leaRec.size() ; i++){
                        CnBLeadWrapperClass.LeadDataBike cnbBike = new CnBLeadWrapperClass.LeadDataBike();
                        cnbBike.company_name = leaRec[i].Company;
                        cnbBike.duration_days = leaRec[i].Duration_Days__c;
                        cnbBike.employment_type = leaRec[i].Employment_Type__c;
                        cnbBike.id_bike_lead = leaRec[i].Bike_Lead_Id__c;
                        cnbBike.id_bike_model = leaRec[i].Bike_Model_Id__c;
                        cnbBike.id_bike_variant = leaRec[i].Bike_Variant_Id__c;
                        cnbBike.id_city = leaRec[i].City_Id__c;
                        cnbBike.id_dealer = leaRec[i].Dealer_Id__c;
                        cnbBike.id_form_type = leaRec[i].Form_Type_Id__c;
                        cnbBike.id_pincode = leaRec[i].Pincode_Id__c;
                        cnbBike.id_source = leaRec[i].Source_Id__c;
                        cnbBike.loan_amount = leaRec[i].Loan_Amount__c;
                        cnbBike.loan_requirement = leaRec[i].Loan_Requirement__c;
                        cnbBike.loan_term = leaRec[i].Loan_Term__c;
                        cnbBike.monthly_income = leaRec[i].Monthly_Income__c;
                        listOfCnbBikeLead.add(cnbBike);
                }
                
                    CnBLeadWrapperClass.LeadBikeWrapper cnbLead = new CnBLeadWrapperClass.LeadBikeWrapper();
                    cnbLead.date_time = String.valueOf(leaRec[0].Date_Time__c);
                    cnbLead.email = leaRec[0].Email;
                    cnbLead.first_visit_date = String.valueOf(leaRec[0].First_Visit_Date__c);
                    cnbLead.is_verified = leaRec[0].Is_Verified__c;
                    cnbLead.pincode = leaRec[0].area_pincode__c;
                    if(leaRec[0].Status__c != NULL)
                        cnbLead.marketing_status = leaRec[0].Status__c;
                    cnbLead.mobile = leaRec[0].Phone;
                    if(leaRec[0].Bike_Lead_Id__c != NULL)
                        cnbLead.id_bike_lead = leaRec[0].Bike_Lead_Id__c;
                    if(leaRec[0].FirstName != NULL){
                        cnbLead.name =leaRec[0].FirstName+ ''+ leaRec[0].LastName;
                    }
                    else {
                        cnbLead.name =leaRec[0].LastName;
                    }
                    cnbLead.vehicle_type = leaRec[0].Vehicle_Type__c;
                    cnbLead.leads = listOfCnbBikeLead;
                    cnbLead.sfdc_lead_id = leaRec[0].Id;
                    listOfCnBBike.add(cnbLead);
                
                System.debug('listOfCnBBike '+listOfCnBBike+'listOfCnbBikeLead '+listOfCnbBikeLead);
                bike.data = listOfCnBBike;
                System.debug('bike '+bike.data);
                JsonLeadStr =System.JSON.serialize(bike);
                System.debug('JSON str 1'+JSONLeadStr);
                endpoint = CnbEndpoint.NewBike_LeadStatus__c;
                System.debug('Endpoint '+endpoint);
            }
        //}
        System.debug('JsonLeadStr '+JsonLeadStr);
        System.debug('endpoint '+endpoint);
        
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        if(JsonLeadStr != NULL){
            req.setBody(JsonLeadStr);
        }
        res = h.send(req);
        System.debug('JsonLeadStr '+JsonLeadStr);
        String responseData = res.getBody();
        System.debug('res.getBody(): '+responseData);
        System.debug('res'+res);
        String SfId = responseData.substringBetween('"sfdc_lead_id":"','"');
        
        if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null) {
            insertAPIList.add(LogService.createApiLogs(endPoint, req.getBody(), res.getBody(), 'Success',  'CnB New Lead Create',SfId, false));
        }
        else{
            system.debug('Entered else');
            insertAPIList.add(LogService.createApiLogs(endPoint, req.getBody(), res.getBody(), 'Failed', 'CnB New Lead Create', SfId, false));
        }
        if(!insertAPIList.isEmpty()){
            LogService.createApiLogs(insertAPIList);
        }
       
        
        
    }
    
    //Sends the data to CnB system.
    public static void NewLead(Set<Id> lIds){
        generateHeader();
        List<CnBLeadWrapperClass.NewLeadCallout> newLeadWrap = new List<CnBLeadWrapperClass.NewLeadCallout>();
        List<API_log__c> insertAPIList = new List<API_Log__c>();
        Map<String, Lead> mapOfExistingCarLeadId = new Map<String, Lead>();
        Set<String> resCarLeadId = new Set<String>();
        Set<String> resBikeLeadId = new Set<String>();
        
        List<Lead> leadList = [Select id, Lastname, recordtypeId, phone, email, area_city__c, status__c,Car_Model_Id__c,Bike_Model_id__c, Form_Type_Id__c,Source_Id__c,Is_Verified__c, Area_PinCode__c from Lead where Id IN :lIds ];
        System.debug('leadList '+leadList);
        for(Lead l : leadList){
            CnBLeadWrapperClass.NewLeadCallout wrap = new CnBLeadWrapperClass.NewLeadCallout();
            wrap.name = l.LastName;
            wrap.mobile = l.Phone;
            wrap.email = l.Email;
            wrap.city = l.Area_City__c;
            wrap.marketing_status = l.status__c;
            wrap.id_form_type = l.Form_Type_Id__c;
            if(l.Car_Model_Id__c != NULL){
                wrap.id_car_model = l.Car_Model_Id__c;
            }
            if(l.Bike_Model_Id__c != NULL){
                wrap.id_bike_model = l.Bike_Model_Id__c;
            }
             if(l.Is_Verified__c != NULL){
                wrap.is_verified = l.Is_Verified__c;
             }
            if(l.Form_Type_Id__c != NULL){
                wrap.id_form_type = l.Form_Type_Id__c;
            }
            if(l.Source_Id__c != NULL){
                wrap.id_source = l.Source_Id__c;
            }
            
            if(l.Area_PinCode__c != NULL){
                wrap.pincode = l.Area_PinCode__c;
            }
            wrap.sfdc_lead_id = l.Id;
            newLeadWrap.add(wrap);
        }
        System.debug('newLeadWrap '+newLeadWrap);
        
        CnBLeadWrapperClass.NewLeadCalloutWrapper newLead = new  CnBLeadWrapperClass.NewLeadCalloutWrapper();
        newLead.leads = newLeadWrap;
        
        String JSONstr = System.JSON.serialize(newLead);
        System.debug('JSONstr'+JSONstr);
        String endpoint;
        if(leadList[0].RecordtypeId == LeadConstants.CnBLeadRecordTypeId){
            endpoint = cnbEndpoint.CreateNewLead__c;
        }
        else if(leadList[0].RecordtypeId == LeadConstants.CnBBikeLeadRecordTypeId){
            endpoint = CnbEndpoint.NewBike_NewLead__c;
        }
        req.setMethod('POST');
        req.setEndpoint(endPoint);
        req.setHeader('Content-Type', 'application/json');
        if(JSONstr != NULL){
            req.setBody(JSONstr);
        }
        res = h.send(req);
        System.debug('res'+res);
        System.debug('Res body '+res.getBody());
        String responseData = res.getBody();
        System.debug('responseData '+responseData);
        String SfId = responseData.substringBetween('"sfdc_lead_id":"','"');
        
        if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null) {
            insertAPIList.add(LogService.createApiLogs(endPoint, req.getBody(), res.getBody(), 'Success',  'CnB New Lead Create',SfId, false));
            
        }
        else{
            system.debug('Entered else');
            insertAPIList.add(LogService.createApiLogs(endPoint, req.getBody(), res.getBody(), 'Failed', 'CnB New Lead Create', SfId, false));
        }
        if(!insertAPIList.isEmpty()){
            LogService.createApiLogs(insertAPIList);
        }
        
        Map<String,Object> responseObj = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
        System.debug('responseObj '+responseObj);
        String responseWrap = JSON.serialize(responseObj.get('response'));
        System.debug('responseWrap '+responseWrap);
        CnBLeadWrapperClass.Response leadRes = new CnBLeadWrapperClass.Response();
        leadRes = (CnBLeadWrapperClass.Response)JSON.deserialize(responseWrap, CnBLeadWrapperClass.Response.class);
        
        
        Map<String, CnBLeadWrapperClass.Success> resData = new Map<string, CnBLeadWrapperClass.Success>();
        for(CnBLeadWrapperClass.data r : leadRes.data){
            CnBLeadWrapperClass.Success s = r.success;
            if(s.sfdc_lead_id != NULL && s.sfdc_lead_id != ''){
                resData.put(s.sfdc_lead_id,s);
                if(s.id_car_lead != NULL && s.id_car_lead != ''){
                    resCarLeadId.add(s.id_car_lead);
                }
            }
        }
        System.debug('resData '+resData);
        List<Lead> leadListWithCarId = [Select id, Car_Lead_Id__c, name from lead where Car_Lead_Id__c IN :resCarLeadId ];
        if(!leadListWithCarId.isEmpty()){
            for(Lead l : leadListWithCarId){
                mapOfExistingCarLeadId.put(l.Car_Lead_Id__c , l);
            }
        }
        
        List<Group> queueName = [Select id, name from group where type = 'Queue' and name like 'CnB_New%' limit 2];
        Map<Id, String> queueMap = new Map<Id, String>();
        for(Group queue1 : queueName){
            queueMap.put(queue1.id, queue1.name);
        }
        List<Lead> updateList = new List<Lead>();
        if(!resData.isEmpty()){
            for(String leaId : resData.keySet()){
                Lead lea = new Lead();
                lea.Id = leaId;
                if(mapOfExistingCarLeadId.containsKey(resData.get(leaId).id_car_lead)){
                    lea.Upload_Message__c = 'Duplicate Lead';
                    //lea.OwnerId = queueName.Id;
                    lea.IsDuplicate__c = true;
                }else{
                    lea.Car_Lead_Id__c = resData.get(leaId).id_car_lead;
                    if(resData.get(leaId).id_bike_lead != NULL || resData.get(leaId).id_bike_lead != ''){
                        lea.Bike_Lead_Id__c = resData.get(leaId).id_bike_lead;
                    }
                   
                }
                updateList.add(lea);
            }
        }
        System.debug('updateList  '+updateList);
        if(!updateList.isEmpty() && !Test.isRunningTest()){
            update updateList;
        }
    }
}