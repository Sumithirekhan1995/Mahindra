public without sharing class  CnBRecommendationController {
    
    @AuraEnabled
    public static CnBLeadWrapperClass.CnBResponseData getCarRecommendations(String leaRecId){
        CnBLeadWrapperClass.CnBResponseData recommendationList = new CnBLeadWrapperClass.CnBResponseData();
        Lead leadRec = [Select Id,Car_Model_Id__c, Bike_Model_Id__c from Lead Where Id =: leaRecId];
        if(leadRec.Car_Model_Id__c != NULL){
           recommendationList = CnBCallOutService.getRecommendations(leadRec.Car_Model_Id__c, 'car');
        }
        //Added by Soumya for Bike API 28/12/20
        else if(leadRec.Bike_Model_Id__c != NULL){
           recommendationList = CnBCallOutService.getRecommendations(leadRec.Bike_Model_Id__c, 'bike');
        }
        System.debug('recomded list'+recommendationList);
        for(CnBLeadWrapperClass.CnBCalloutResponseData car : recommendationList.recommended){
            car.check = false; 
        }
        for(CnBLeadWrapperClass.CnBCalloutResponseData car : recommendationList.cross_sell){
            car.check = false; 
        }
        System.debug('recommendationList: '+recommendationList);
        return recommendationList;
    }
    
    @AuraEnabled
    public static List<CnBLeadWrapperClass.CnBCalloutResponseData> searchRecommendations(String searchParam, String leaRecId){
        Lead leadRec = [Select Id,Car_Model_Id__c, Bike_Model_Id__c from Lead Where Id =: leaRecId];
        List<CnBLeadWrapperClass.CnBCalloutResponseData> recommendationList = new List<CnBLeadWrapperClass.CnBCalloutResponseData>();
        if(leadRec.Car_Model_Id__c != NULL){
            recommendationList = CnBCallOutService.searchCar(searchParam, 'car');
        }
        else if(leadRec.Bike_Model_Id__c != NULL){
            recommendationList = CnBCallOutService.searchCar(searchParam, 'bike');
        }
    	for(CnBLeadWrapperClass.CnBCalloutResponseData car : recommendationList){
            car.check = false;
        }
        return recommendationList;
    }
    
    @AuraEnabled
    public static void createLead(String selectedCars, String recId, String LeadSource){
        System.debug('selectedCars: '+selectedCars);
        List<CnBLeadWrapperClass.CnBCalloutResponseData> carList = (List<CnBLeadWrapperClass.CnBCalloutResponseData>)JSON.deserialize(selectedCars,List<CnBLeadWrapperClass.CnBCalloutResponseData>.class);
        System.debug('carList '+carList);
        System.debug('recId '+recId);
        List<Lead> leadListToInsert = new List<Lead>();
        
        Lead leadRec = [select id, RecordtypeId, LeadSource, Is_Verified__c, LastName, Car_Lead_Id__c, Bike_Lead_Id__c, Form_Type_Id__c, phone, Email, city_id__c, area_city__c, pincode_id__c, area_pincode__c from lead where id = :recId];
        
        for(CnBLeadWrapperClass.CnBCalloutResponseData car : carList){
            Lead l = new Lead();
            l.LastName = leadRec.LastName;
            l.Phone = leadRec.Phone;
            l.Email = leadRec.Email;
            l.City_Id__c = leadRec.City_Id__c;
            l.Area_City__c = leadRec.Area_City__c;
            l.Pincode_Id__c = leadRec.Pincode_Id__c;
            l.Area_PinCode__c = leadRec.Area_PinCode__c;
            l.Form_Type_Id__c = leadRec.Form_Type_Id__c;
            l.Is_Verified__c = leadRec.Is_Verified__c;
            if(leadRec.RecordTypeId == LeadConstants.CnBLeadRecordTypeId){
                l.Car_Model_Id__c = car.id_car_model;
                l.Parent_Lead_Id__c = leadRec.Car_Lead_Id__c;
            }
            else if(leadRec.RecordTypeId == LeadConstants.CnBBikeLeadRecordTypeId){
                l.Bike_Model_Id__c = car.id_bike_model;
                l.Parent_Lead_Id__c = leadRec.Bike_Lead_Id__c;
            }
            l.Manufacturer__c = car.manufacturer_name;
            l.Primary_Model__c = car.model_name;
            l.Status__c = car.status;
            l.LeadSource = LeadSource;
            l.RecordTypeId = leadRec.RecordTypeId;
            //l.CnB_API_Fire__c = true;
            leadListToInsert.add(l);  
        }
        System.debug('leadListToInsert '+leadListToInsert);
        
        Set<Id> subLeadIds = new Set<Id>();
        subLeadIds.add(recId);
        if(!leadListToInsert.isEmpty()){
            insert leadListToInsert;
            System.debug('Inserted '+leadListToInsert);
            for(lead l : leadListToInsert){
                subLeadIds.add(l.id);
            }
        }
        
        //To Call callout method updateLeadStatus.
          if(!subLeadIds.isEmpty()){
            //LeadTriggerHelper.callLeadStatusChange(subLeadIds);
        }
        
        
    }
    
    @AuraEnabled
    public static Lead returnLead(String leadRecId){
        Lead lea = [Select id, name,Car_Model_Id__c, Bike_model_id__c, Bike_lead_id__c, area_city__c,form_type_id__c, status__c, car_lead_id__c from Lead where Id = :leadRecId];
        System.debug('Lead '+lea);
        return lea;
    }

}