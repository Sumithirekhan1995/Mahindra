/*
* Class to Upsert Lead for CnB
* Last Modified by Soumya on 08/10/2020
*/

public class CnBLeadUpsert {
    public static void upsertCnBLead(List<CnBLeadWrapperClass.CnBWrapper> cnbLeadList, RestResponse res, String EndPoint){
        System.debug('cnbObjLeadList'+ cnbLeadList );
        List<Lead> cnbLeadtoUpsert = new List<Lead>();
        List<CnBLeadWrapperClass.CnBResponseWrapper> cnbResponse = new List<CnBLeadWrapperClass.CnBResponseWrapper>();
        List<String> sfdcLeadList = new List<String>();
        List<String> carLeadIdList = new List<String>();
        List<String> bikeLeadIdList = new List<String>();
        List<Lead> cnbCarList = new List<Lead>();
        List<Lead> cnbBikeList = new List<Lead>();
        List<Database.UpsertResult> cnbLeadResult1 = new List<Database.UpsertResult>();
        List<Database.UpsertResult> cnbLeadResult2 = new List<Database.UpsertResult>();
        Integer i = 0;
        
        List<AssignmentRule> lstAssignmentRule = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Lead' AND Active = true LIMIT 1];
        AssignmentRule objAssignmentRule = new AssignmentRule();
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        if(lstAssignmentRule.size() > 0)
        {
            objAssignmentRule = lstAssignmentRule[0];
            dmlOpts.assignmentRuleHeader.assignmentRuleId= objAssignmentRule.id;
        }
        
        for(CnBLeadWrapperClass.CnBWrapper cnbw : cnbLeadList){
            system.debug(' cnbw.cnbWrap '+ cnbw.leads);
            for(CnBLeadWrapperClass.CnBLeadWrapper cnbLeadWrap : cnbw.leads){
                Lead lea = new Lead();
                if(cnbLeadWrap.sfdc_lead_id == null || cnbLeadWrap.sfdc_lead_id == ''){
                    lea.setOptions(dmlOpts);
                }
                if(!String.isBlank(cnbw.mobile)){
                    lea.Phone = cnbw.mobile;
                }
                if(!String.isBlank(cnbw.name)){
                    lea.LastName = cnbw.name;
                }
                if(!String.isBlank(cnbw.email)){
                    lea.Email = cnbw.email;
                }
                if(!String.isBlank(cnbw.marketing_status)){
                    lea.status__c = cnbw.marketing_status;
                }
                if(!String.isBlank(cnbw.follow_up_date)){
                    try{
                        lea.Follow_Up_Date_Time__c = Date.valueOF(cnbw.follow_up_date);
                    }
                    catch(Exception e){
                        System.debug('Exception occured'+e);
                        CnBLeadWrapperClass.CnBResponseWrapper reswrap = new CnBLeadWrapperClass.CnBResponseWrapper();
                        reswrap.message = 'Invalid Followup Date';
                        reswrap.status_code = 'Failed';
                        reswrap.sfdc_lead_id = '';
                        reswrap.id_car_lead = cnbLeadWrap.id_car_lead;
                        String responseJSON = System.JSON.serializePretty(reswrap);
                        res.responseBody =  Blob.valueOf(responseJSON);
                        continue;
                    }
                }
                if(!String.isBlank(cnbw.is_verified)){
                    lea.Is_Verified__c = cnbw.is_verified;
                } 
                
                if(!String.isBlank(cnbw.id_user)){
                    lea.User_Id__c = cnbw.id_user;
                }
                if(!String.isBlank(cnbw.callStatus)){
                    lea.Call_Status__c = cnbw.callStatus;
                }
                if(!String.isBlank(cnbw.first_visit_date)){
                    try{
                        lea.First_Visit_Date__c = DateTime.valueOf(cnbw.first_visit_date);
                    }
                    catch(Exception e){
                        System.debug('Exception occured'+e);
                        CnBLeadWrapperClass.CnBResponseWrapper reswrap = new CnBLeadWrapperClass.CnBResponseWrapper();
                        reswrap.message = 'Invalid First Visit Date';
                        reswrap.status_code = 'Failed';
                        reswrap.sfdc_lead_id = '';
                        reswrap.id_car_lead = cnbLeadWrap.id_car_lead;
                        String responseJSON = System.JSON.serializePretty(reswrap);
                        res.responseBody =  Blob.valueOf(responseJSON);
                        continue;
                    }
                }
                if(!String.isBlank(cnbLeadWrap.id_car_lead)){
                    lea.Car_Lead_Id__c = cnbLeadWrap.id_car_lead;
                }
                if(String.isBlank(cnbLeadWrap.id_car_lead) && cnbw.vehicle_type == 'car'){
                    CnBLeadWrapperClass.CnBResponseWrapper reswrap = new CnBLeadWrapperClass.CnBResponseWrapper();
                    reswrap.message = 'Car Lead ID is missing';
                    reswrap.status_code = 'Failed';
                    reswrap.sfdc_lead_id = '';
                    reswrap.id_car_lead = '';
                    String responseJSON = System.JSON.serializePretty(reswrap);
                    res.responseBody =  Blob.valueOf(responseJSON);
                    continue;
                }
                if(String.isBlank(cnbLeadWrap.id_bike_lead) && cnbw.vehicle_type == 'bike'){
                    CnBLeadWrapperClass.CnBResponseWrapper reswrap = new CnBLeadWrapperClass.CnBResponseWrapper();
                    reswrap.message = 'Bike Lead ID is missing';
                    reswrap.status_code = 'Failed';
                    reswrap.sfdc_lead_id = '';
                    reswrap.id_Bike_lead = '';
                    String responseJSON = System.JSON.serializePretty(reswrap);
                    res.responseBody =  Blob.valueOf(responseJSON);
                    continue;
                }
                 if(!String.isBlank(cnbLeadWrap.id_bike_lead)){
                    lea.Bike_Lead_Id__c = cnbLeadWrap.id_bike_lead;
                }
                
                if(!String.isBlank(cnbLeadWrap.id_car_model)){
                    lea.Car_Model_Id__c = cnbLeadWrap.id_car_model;
                }
                if(!String.isBlank(cnbLeadWrap.id_bike_model)){
                    lea.Bike_Model_Id__c = cnbLeadWrap.id_bike_model; 
                }
                if(!String.isBlank(cnbLeadWrap.id_car_variant)){
                    lea.Car_Variant_Id__c = cnbLeadWrap.id_car_variant;
                }
                if(!String.isBlank(cnbLeadWrap.id_car_manufacturer)){
                    lea.Manufacturer_Car_Id__c = cnbLeadWrap.id_car_manufacturer;
                }
                if(!String.isBlank(cnbLeadWrap.manufacturer)){
                    lea.Manufacturer__c = cnbLeadWrap.manufacturer;
                }
                if(!String.isBlank(cnbLeadWrap.model)){
                    lea.Primary_Model__c = cnbLeadWrap.model;
                }
                if(!String.isBlank(cnbLeadWrap.variant)){
                    lea.Variant__c = cnbLeadWrap.variant;
                }
                if(!String.isBlank(cnbLeadWrap.id_city)){
                    lea.City_Id__c = cnbLeadWrap.id_city;
                }
                if(!String.isBlank(cnbLeadWrap.id_bike_variant)){
                    lea.Bike_Variant_Id__c = cnbLeadWrap.id_bike_variant;
                }
                if(!String.isBlank(cnbLeadWrap.city)){
                    lea.Area_City__c = cnbLeadWrap.city;
                }
                if(!String.isBlank(cnbLeadWrap.id_pincode)){
                    lea.Pincode_Id__c = cnbLeadWrap.id_pincode;
                }
                if(!String.isBlank(cnbLeadWrap.id_form_type)){
                    lea.Form_Type_Id__c = cnbLeadWrap.id_form_type;
                }
                if(!String.isBlank(cnbLeadWrap.pincode)){
                    lea.Area_PinCode__c = cnbLeadWrap.pincode;
                }
                if(!String.isBlank(cnbLeadWrap.id_dealer)){
                    lea.Dealer_Id__c = cnbLeadWrap.id_dealer;
                }
                if(!String.isBlank(cnbLeadWrap.dealer_name)){
                    lea.Dealer_Name__c = cnbLeadWrap.dealer_name;
                }            
                if(!String.isBlank(cnbLeadWrap.date_time)){
                    lea.date_time__c = Date.valueOF(cnbLeadWrap.date_time);
                }
                if(!String.isBlank(cnbLeadWrap.id_source)){
                    lea.Source_Id__c = cnbLeadWrap.id_source;
                }
                if(!String.isBlank(cnbLeadWrap.source)){
                    lea.LeadSource = cnbLeadWrap.source;
                }
                if(!String.isBlank(cnbLeadWrap.duration_days)){
                    lea.Duration_Days__c = cnbLeadWrap.duration_days;
                }
                if(!String.isBlank(cnbLeadWrap.utm_source)){
                    lea.UTM_Source__c = cnbLeadWrap.utm_source;
                }
                if(!String.isBlank(cnbLeadWrap.utm_medium)){
                    lea.UTM_Medium__c = cnbLeadWrap.utm_medium;
                }
                if(!String.isBlank(cnbLeadWrap.utm_campaign)){
                    lea.UTM_Campaign__c = cnbLeadWrap.utm_campaign;
                }
                if(!String.isBlank(cnbLeadWrap.utm_content)){
                    lea.UTM_Content__c = cnbLeadWrap.utm_content;
                }
                if(!String.isBlank(cnbLeadWrap.utm_term)){
                    lea.UTM_Term__c = cnbLeadWrap.utm_term;
                }
                if(!String.isBlank(cnbLeadWrap.url)){
                    lea.URL__c = cnbLeadWrap.url;
                }
                if(!String.isBlank(cnbLeadWrap.affiliate_type)){
                    lea.Affiliate_Type__c = cnbLeadWrap.affiliate_type;
                }
                if(!String.isBlank(cnbLeadWrap.affiliate_status)){
                    lea.Affiliate_Status__c = cnbLeadWrap.affiliate_status;
                }
                if(!String.isBlank(cnbLeadWrap.affiliate_date)){
                    try{
                        lea.Affiliate_Date__c = DateTime.valueOf(cnbLeadWrap.affiliate_date);
                    }	
                    catch(Exception e){
                        System.debug('Exception occured'+e);
                        CnBLeadWrapperClass.CnBResponseWrapper reswrap = new CnBLeadWrapperClass.CnBResponseWrapper();
                        reswrap.message = 'Invalid affiliate Date';
                        reswrap.status_code = 'Failed';
                        reswrap.sfdc_lead_id = '';
                        reswrap.id_car_lead = cnbLeadWrap.id_car_lead;
                        String responseJSON = System.JSON.serializePretty(reswrap);
                        res.responseBody =  Blob.valueOf(responseJSON);
                        continue;
                    }
                }
                if(!String.isBlank(cnbLeadWrap.affiliate_response)){
                    lea.Affiliate_Response__c = cnbLeadWrap.affiliate_response;
                }
                
                if(!String.isblank(cnbw.vehicle_type)){
                    lea.Vehicle_Type__c = cnbw.vehicle_type;
                }
                
                if(cnbw.vehicle_type == 'car'){
                    lea.RecordTypeId = LeadConstants.CnBLeadRecordTypeId;
                }
                
                if(cnbw.vehicle_type == 'bike'){
                    lea.RecordTypeId = LeadConstants.CnBBikeLeadRecordTypeId;
                }
                cnbLeadtoUpsert.add(lea);
            }
        }
        System.debug('cnbLeadtoUpsert '+cnbLeadtoUpsert);
        if(!cnbLeadtoUpsert.isEmpty()){
            for(lead lea : cnbLeadtoUpsert){
                sfdcLeadList.add(lea.Id);
                carLeadIdList.add(lea.Car_Lead_Id__c);
                bikeLeadIdList.add(lea.Bike_Lead_Id__c);
                if(lea.Vehicle_Type__c == 'car'){
                    cnbCarList.add(lea);
                }
                else if(lea.Vehicle_Type__c == 'bike'){
                    cnbBikeList.add(lea);
                }
            }
        }
        
        System.debug('cnbCarList '+cnbCarList);
        System.debug('cnbBikeList '+cnbBikeList);
        
        if(!cnbCarList.isEmpty()){
            Schema.SObjectField externalField = Lead.Fields.Car_Lead_Id__c;
            System.debug('Size'+cnbCarList.size()+'Contents'+cnbCarList);
            cnbLeadResult1 = Database.upsert(cnbCarList, externalField, False);
        }
        else if(!cnbBikeList.isEmpty()){
            Schema.SObjectField externalField = Lead.Fields.bike_lead_id__c;
            System.debug('Size'+cnbBikeList.size()+'Contents'+cnbBikeList);
            cnbLeadResult2 = Database.upsert(cnbBikeList, externalField, False);
        }
        System.debug('cnbLeadResult2 '+cnbLeadResult2);
        System.debug('cnbLeadResult1 '+cnbLeadResult2);
            
        
        for(Database.UpsertResult result : cnbLeadResult1){
            SYstem.debug('error: '+result.getErrors());
            SYstem.debug('getId: '+result.getId());
            SYstem.debug('result.isCreated(): '+result.isCreated());
            CnBLeadWrapperClass.CnBResponseWrapper reswrap = new CnBLeadWrapperClass.CnBResponseWrapper();
            reswrap.status_code = result.success == TRUE ? 'Success' : 'Failed';
            reswrap.message = result.success == TRUE ? 'Upserted Successfully' : (String.valueOf(result.errors)).contains('INVALID_EMAIL_ADDRESS')?'Invalid Email':(String.valueOf(result.errors)).contains('bad value')?'bad value for restricted picklist field':(String.valueOf(result.errors)).contains('DUPLICATE_VALUE')?'Duplicate Id':(String.valueOf(result.errors)).contains('Phone number cannot be blank')?'Phone number cannot be blank':(String.valueOf(result.errors)).contains('Phone number can be only 10 digits')?'Phone number can be only 10 digits and should begin with 6,7,8,9 only':'Lead Insertion Failed';
            reswrap.sfdc_lead_id = result.success == TRUE ?result.getId():sfdcLeadList[i];
            reswrap.id_car_lead = carLeadIdList[i];
            i++;
            String responseJSON = System.JSON.serializePretty(reswrap);
            String requestJSON = System.JSON.serializePretty(cnbLeadList);
            LogService.createApiLogs('/cnbleadupsert',requestJSON,responseJSON,reswrap.status_code,'Cnb Car Lead Create' );
            res.responseBody =  Blob.valueOf(responseJSON);
        }
        
        for(Database.UpsertResult result : cnbLeadResult2){
            SYstem.debug('error: '+result.getErrors());
            SYstem.debug('getId: '+result.getId());
            SYstem.debug('result.isCreated(): '+result.isCreated());
            CnBLeadWrapperClass.CnBResponseWrapper reswrap = new CnBLeadWrapperClass.CnBResponseWrapper();
            reswrap.status_code = result.success == TRUE ? 'Success' : 'Failed';
            reswrap.message = result.success == TRUE ? 'Upserted Successfully' : (String.valueOf(result.errors)).contains('INVALID_EMAIL_ADDRESS')?'Invalid Email':(String.valueOf(result.errors)).contains('bad value')?'bad value for restricted picklist field':(String.valueOf(result.errors)).contains('DUPLICATE_VALUE')?'Duplicate Id':(String.valueOf(result.errors)).contains('Phone number cannot be blank')?'Phone number cannot be blank':(String.valueOf(result.errors)).contains('Phone number can be only 10 digits')?'Phone number can be only 10 digits and should begin with 6,7,8,9 only':'Lead Insertion Failed';
            reswrap.sfdc_lead_id = result.success == TRUE ?result.getId():sfdcLeadList[i];
            reswrap.id_bike_lead = bikeLeadIdList[i];
            i++;
            String responseJSON = System.JSON.serializePretty(reswrap);
            String requestJSON = System.JSON.serializePretty(cnbLeadList);
            LogService.createApiLogs('/cnbleadupsert',requestJSON,responseJSON,reswrap.status_code,'Cnb bike Lead Create' );
            res.responseBody =  Blob.valueOf(responseJSON);
        }
    }
    
}