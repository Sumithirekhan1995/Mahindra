public class CptLeadUpsert {
    
    public static void UpsertLead(List<LeadPushCPT.LeadWrapper> leadObjectList, RestResponse res,String Endpoint){
        List<Lead> leadToUpsertList = new List<Lead>();
        List<Lead> leadToUpsertListWithSfId = new List<Lead>();
        List<Lead> leadAndOppToUpsert= new List<Lead>();
        List<Database.UpsertResult> leadResult = new List<Database.UpsertResult>();
        List<Database.UpsertResult> leadAndOppResult = new List<Database.UpsertResult>();
        List<Lead> LeadToOpportunityList = new List<Lead>();
        List<LeadPushCPT.ResponseLeadobj> resLeadWrapList = new List<LeadPushCPT.ResponseLeadobj>();
        Set<Id> leadIdSet = new Set<Id>();
        Set<Id> leadIdSet1 = new Set<Id>();
        Map<Id,String> sfIdAndexternalIdMap = new Map<Id,String>();
        Map<Id,String> sfIdAndexternalIdMap1 = new Map<Id,String>();
        List<String> failureExternalId = new List<String>();
        List<String> failureExternalId1 = new List<String>();
        List<String> failureSfId = new List<String>();
        List<String> failureSfId1 = new List<String>();
        Map<String,String> FailureUpsertedMap = new Map<String,String>();
        Map<String,String> FailureUpsertedMap1 = new Map<String,String>();
        Map<String,String> FailureSfMap = new Map<String,String>();
        Map<String,String> FailureSfMap1 = new Map<String,String>();
        List<String> listOfUID = new List<String>();
        Map<String, Team_Lead__c> mapOfTLs = new Map<String, Team_Lead__c>();
        //Adding Variable for Failed Status 9 AUG
        Boolean isInserted = true;
        Integer i = 0;
        Integer j = 0;
        
        //Added by Soumya for HI Start Date 24/05/2021
        List<Lead> leadToInsert = new List<Lead>();
        List<Lead> leadWithSfIDtoUpdate = new List<Lead>();
        List<Database.SaveResult> resultOfInsertedLeads = new List<Database.SaveResult>();
        List<Database.SaveResult> resultOfUpdatedLeads = new List<Database.SaveResult>();
        Map<String, RP_Dealer__c> mapOfDealers = new Map<String, RP_Dealer__c>();
        List<String> listOfDealerCode = new List<String>();
        
        for(LeadPushCPT.LeadWrapper obj : leadObjectList){
            if(!String.isBlank(obj.uid)){
                listOfUID.add(obj.uid);
            }
            if(!String.isBlank(obj.hi_store)){
                listOfDealerCode.add(obj.hi_store);
            }
        }
        
        for(Team_Lead__c tl : [Select id, name, User_Id__c, Login_Id__c from Team_Lead__c where User_Id__c IN :listOfUID AND Is_Active__c = true ]){
            mapOfTLs.put(tl.User_Id__c, tl);
        }
        
        for(Rp_Dealer__c rp : [Select id, name,external_field__c from rp_Dealer__c where rp_code__c IN :listOfDealerCode]){
            mapOfDealers.put(rp.external_field__c, rp);
        }
        
        List<AssignmentRule> lstAssignmentRule = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Lead' AND Active = true LIMIT 1];
        AssignmentRule objAssignmentRule = new AssignmentRule();
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        if(lstAssignmentRule.size() > 0)
        {
            objAssignmentRule = lstAssignmentRule[0];
            dmlOpts.assignmentRuleHeader.assignmentRuleId= objAssignmentRule.id;
        }
        
        for(LeadPushCPT.LeadWrapper obj : leadObjectList)
        {
            Lead lea = new Lead();
            // 6Jan2022:Asif:Start :: triggering Assignment rules on insert only
            if(String.isBlank(obj.sfdc_lead_id)) {
                lea.setOptions(dmlOpts);
            }
            // 6Jan2022:Asif:End
            if(!String.isBlank(obj.sfdc_lead_id)){
                try{
                    lea.Id = obj.sfdc_lead_id;
                    System.debug('lead id check' + obj.sfdc_lead_id);  
                    if(!String.isBlank(obj.vehicle_category)){
                        System.debug('vehicle category1' + obj.vehicle_category );
                        lea.Vehicle_Category__c = obj.vehicle_category;
                    }
                    if(!String.isBlank(obj.customer_name))
                        lea.LastName = obj.customer_name;
                    if(!String.isBlank(obj.customer_mobile))
                        lea.Phone = (obj.customer_mobile).right(10);
                    if(!String.isBlank(obj.customer_email))
                        lea.Email = obj.customer_email;
                    if(!String.isBlank(obj.customer_address))
                        lea.Address__c = obj.customer_address;
                    if(!String.isBlank(obj.customer_pincode))
                        lea.Area_PinCode__c = obj.customer_pincode;
                    if(!String.isBlank(obj.reject_reason))
                        lea.reject_reason__c = obj.reject_reason;
                    if(!String.isBlank(obj.evaluation_city))
                        lea.evaluation_city__c = obj.evaluation_city;
                    if(!String.isBlank(obj.evaluation_state))
                        lea.evaluation_state__c = obj.evaluation_state;
                    //29Dec2021:Asif:Start
                    if(!String.isBlank(obj.registration_city))
                        lea.registration_city__c = obj.registration_city;
                    if(!String.isBlank(obj.registration_state))
                        lea.registration_state__c = obj.registration_state;
                    
                    if(!String.isBlank(obj.evaluation_city))
                        lea.Seller_City__c = obj.evaluation_city;
                    if(!String.isBlank(obj.evaluation_state))
                        lea.Seller_State__c = obj.evaluation_state;
                    //29Dec2021:Asif:End
                    if(!String.isBlank(obj.city_name))
                        lea.Seller_City__c = obj.city_name;
                    if(!String.isBlank(obj.state_name))
                        lea.Seller_State__c = obj.state_name;
                    if(!String.isBlank(obj.make)){
                        lea.Make__c = obj.make;
                        lea.Primary_Make__c = obj.make;
                    }
                    if(!String.isBlank(obj.customer_pincode)){
                        lea.Area_PinCode__c = obj.customer_pincode;
                    }
                    
                    
                    if(!String.isBlank(obj.model)){
                        lea.Model__c= obj.model;
                        lea.Primary_Model__c= obj.model;
                    }
                    if(!String.isBlank(obj.variant)){
                        lea.Variant__c = obj.variant;
                        lea.Primary_Variant__c = obj.variant;
                    }
                    if(!String.isBlank(obj.latitude)){
                        lea.Latitude = Decimal.valueOf(obj.latitude);
                    }
                    if(!String.isBlank(obj.longitude)){
                        lea.Longitude = Decimal.valueOf(obj.longitude);
                    }
                    
                    if(!String.isBlank(obj.uid)){
                        if(mapOfTLs.containsKey(obj.uid)){
                            lea.Team_Lead__c = mapOfTLs.get(obj.uid).Id;
                        }
                        else if(!mapOfTLs.containsKey(obj.uid)){
                            try{
                                lea.Team_Lead__c = mapOfTLs.get(obj.uid).Id;
                            }
                            catch(Exception e){
                                System.debug('Exception Occured ' + e);
                                LeadPushCPT.ResponseLeadobj resLeadWrap = new LeadPushCPT.ResponseLeadobj();
                                resLeadWrap.status = 'Failed';
                                resLeadWrap.message = 'This team leader id doesn’t exist or is de-activated';   
                                resLeadWrap.sfdc_lead_id = obj.sfdc_lead_id;
                                resLeadWrap.cpt_lead_id = obj.lead_id;
                                resLeadWrapList.add(resLeadWrap);  
                                continue;
                            }
                        }
                    }
                    
                    if(!String.isBlank(obj.year))
                        lea.Year__c = obj.year;
                    if(!String.isBlank(String.valueOf(obj.is_otp_verified))){
                        lea.Is_Otp_Verified__c = String.valueOf(obj.is_otp_verified);
                    }
                    else if(String.isBlank(String.valueOf(obj.is_otp_verified)) && obj.hi_serviceable == 1){
                        lea.Is_Otp_Verified__c = 'yes';
                    }
                    if(!String.isBlank(obj.kilometer))
                        lea.Kilometer__c = Decimal.valueOf(obj.kilometer);
                    if(!String.isBlank(obj.total_owner))
                        lea.Total_Owner__c = Decimal.valueOf(obj.total_owner);
                    if(!String.isBlank(obj.registration_number))
                        lea.Registration_Number__c = obj.registration_number;
                    if(!String.isBlank(obj.colour))
                        lea.Color__c = obj.colour;
                    
                    // SUmit::Start::CRM-1085
                    if(!String.isBlank(obj.source)){
                        if(!String.isBlank(obj.sfdc_lead_id)){  // update case
                              // We are not Updating LeadSource in case of update 
                        } else { // insert case
                            lea.LeadSource = obj.source; 
                        }
                        
                    }
                    
                    if(!String.isBlank(obj.lead_source)){
                        if(!String.isBlank(obj.sfdc_lead_id)){  // update case
                              // We are not Updating LeadSource in case of update 
                        } else { // insert case
                            lea.LeadSource = obj.lead_source; 
                        }
                        
                    }   
                    // Sumit::End::CRM-1085
                     
                 //   if(!String.isBlank(obj.source))  
                       // lea.LeadSource = obj.source;
                  //  if(!String.isBlank(obj.lead_source))
                       // lea.LeadSource = obj.lead_source;
                       
                    //Added lead category by Amulya 14-07-22
                    if(!String.isBlank(obj.lead_category))
                		lea.Lead_Category__c = obj.lead_category;  
                    if(!String.isBlank(obj.sub_source))
                        lea.Sub_Source__c = obj.sub_source;
                    if(!String.isBlank(obj.inspect_type))
                        lea.Inspect_Type__c = obj.inspect_type;
                    if(!String.isBlank(obj.inspected_date))
                        lea.inspected_date__c = DateTime.ValueOf(obj.inspected_date);
                    if(!String.isBlank(obj.status))
                        lea.Status__c = obj.status;
                    if(!String.isBlank(obj.valuation_remarks))
                        lea.Valuation_Remarks__c = obj.valuation_remarks;
                    if(!String.isBlank(obj.evaluator_name))
                        lea.evaluator_name__c = obj.evaluator_name;
                    if(!String.isBlank(obj.evaluator_contact_number))
                        lea.evaluator_contact_number__c = obj.evaluator_contact_number;
                    if(!String.isBlank(obj.evaluator_email))
                        lea.evaluator_email__c = obj.evaluator_email;
                    if(!String.isBlank(obj.cpt_admin_name))
                        lea.cpt_admin_name__c = obj.cpt_admin_name;
                    if(!String.isBlank(obj.cpt_admin_contact_number))
                        lea.cpt_admin_contact_number__c = obj.cpt_admin_contact_number;
                    if(!String.isBlank(obj.cpt_admin_email))
                        lea.cpt_admin_email__c = obj.cpt_admin_email;
                    if(!String.isBlank(obj.qc_approved_date))
                        lea.qc_approved_date__c = DateTime.ValueOf(obj.qc_approved_date);
                    if(!String.isBlank(obj.auction_id))
                        lea.auction_id__c = obj.auction_id;
                    if(!String.isBlank(obj.seller_price))
                        lea.Seller_Price__c = obj.seller_price;
                    if(!String.isBlank(obj.Lead_Created_From))
                        lea.Lead_Created_From__c = obj.Lead_Created_From;
                    if(!String.isBlank(obj.auction_start_date))
                        lea.auction_start_date__c = DateTime.ValueOf(obj.auction_start_date);
                    if(!String.isBlank(obj.auction_end_date))
                        lea.auction_end_date__c = DateTime.ValueOf(obj.auction_end_date);
                    if(!String.isBlank(obj.live_followup_date))
                        lea.live_followup_date__c = DateTime.ValueOf(obj.live_followup_date);
                    if(!String.isBlank(obj.follwoup_remarks))
                        lea.follwoup_remarks__c = obj.follwoup_remarks;
                    if(!String.isBlank(obj.reject_date))
                        lea.reject_date__c = DateTime.ValueOf(obj.reject_date);
                    if(!String.isBlank(obj.deal_finalized_on))
                        lea.deal_finalized_on__c = DateTime.ValueOf(obj.deal_finalized_on);
                    if(!String.isBlank(obj.sold_out_on))
                        lea.sold_out_on__c = DateTime.ValueOf(obj.sold_out_on);
                    if(!String.isBlank(obj.latitude)){
                        lea.Latitude = Decimal.valueOf(obj.latitude);
                    }
                    if(!String.isBlank(obj.longitude)){
                        lea.Longitude = Decimal.valueOf(obj.longitude);
                    }
                    if(!String.isBlank(obj.quality_score)){
                        lea.quality_score__c = Decimal.valueOf(obj.quality_score);
                    }
                    if(!String.isBlank(obj.pdf_report_link)){
                        lea.pdf_report_link__c = obj.pdf_report_link;
                    }
                    if(!String.isBlank(obj.valuator_assigned_visit_date))
                        lea.Valuator_Assigned_Visit__c = Date.valueOf(obj.valuator_assigned_visit_date);
                    if(!String.isBlank(obj.ibb_price))
                        lea.ibb_price__c = Decimal.valueOf(obj.ibb_price);
                    if(!String.isBlank(obj.customer_expected_price))
                        lea.Customer_Expected_Price__c = Decimal.valueOf(obj.customer_expected_price);
                    if(!String.isBlank(obj.lead_id))
                        lea.external_cpt_id__c = obj.lead_id;
                    if(!String.isBlank(String.valueOf(obj.whatsapp_consent)))
                        lea.WhatsApp_consent__c = String.valueOf(obj.whatsapp_consent);
                    if(!String.isBlank(String.valueOf(obj.hi_serviceable)))
                        lea.HI_Serviceable__c = String.valueOf(obj.hi_serviceable);
                    if(!String.isBlank(obj.hi_preference))
                        lea.HI_Preference__c = obj.hi_preference;
                    if(!String.isBlank(obj.hi_store)){
                        if(mapOfDealers.containsKey(obj.lead_source+'-'+obj.hi_store+'-'+obj.registration_city))
                            
                            lea.Rp_Dealer__c = mapOfDealers.get(obj.lead_source+'-'+obj.hi_store+'-'+obj.registration_city).id;
                    }
                    //Added by Amulya to map Fuel Type field date:03-02-2022
                    if(!String.isBlank(obj.fuel_type))
                        lea.Fuel__c =obj.fuel_type;
                    if(!String.isBlank(obj.marketing_source))
                        lea.Marketing_Source__c = obj.marketing_source;
                    if(!String.isBlank(obj.marketing_campaign))
                        lea.Marketing_Campaign__c = obj.marketing_campaign;
                    if(!String.isBlank(obj.marketing_device))
                        lea.Marketing_Device__c = obj.marketing_device;
                    if(!String.isBlank(obj.marketing_content))
                        lea.Marketing_Content__c = obj.marketing_content;
                    if(!String.isBlank(obj.marketing_medium))
                        lea.Marketing_Medium__c = obj.marketing_medium;
                    if(!String.isBlank(obj.marketing_term))
                        lea.Marketing_Term__c = obj.marketing_term;
                    if(!String.isBlank(obj.td_client_id))
                        lea.Td_Client_Id__c = obj.td_client_id;
                    if(!String.isBlank(obj.referrer))
                        lea.Referrer__c = obj.referrer;
                     // ico eligible flag,price,lead flag added by Amulya 01-24-2023  CRM-1039
                    if(!String.isBlank( String.valueOf(obj.ico_eligible_flag))){
                    if(String.valueOf(obj.ico_eligible_flag)=='1')
                        lea.ICO_eligible_flag__c = True;
                        else
                       if(String.valueOf(obj.ico_eligible_flag)=='0')
                          lea.ICO_eligible_flag__c = False; 
                       }
                     if(!String.isBlank(obj.price))
                         lea.ICO_Price__c = obj.price; 
                     if(!String.isBlank(obj.lead_flag))
                         lea.Lead_Flag__c = obj.lead_flag;
                    //Added by Hiral
                    //system.debug('lea.Valuator_Assigned_Visit_Date__c--------'+obj.valuator_visit_date+'---'+date.valueOf(obj.valuator_visit_date));
                    
                    if(!String.isBlank(obj.valuator_visit_date))
                        lea.Valuator_Assigned_Visit_Date__c = date.valueOf(obj.valuator_visit_date);    
                    if(!String.isBlank(obj.valuator_visit_slot))
                        lea.Valuation_Schedule_Time_Slot__c =obj.valuator_visit_slot;
                    
                    
                    
                    
                    lea.RecordTypeId = LeadConstants.SellerLeadRecordTypeId;
                    // System.debug('ToUpper' + obj.lead_created_from.toUpperCase());
                    if(!String.isBlank(obj.lead_created_from) && obj.lead_created_from.toUpperCase().equals(LeadConstants.NonNcdConstants) && 
                       !String.isBlank(obj.lead_id)) {
                           System.debug('Inside if lead' + obj.lead_created_from.toUpperCase());
                           leadToUpsertList.add(lea);
                           
                       } else if(!String.isBlank(obj.lead_created_from) && ( obj.lead_created_from.toUpperCase().equals(LeadConstants.NcdConstants) || obj.lead_created_from.toUpperCase().equals(LeadConstants.CptConstants)) &&
                                 !String.isBlank(obj.lead_id)){
                                     System.debug('Inside if Opp with sfid' + obj.lead_created_from.toUpperCase());
                                     leadAndOppToUpsert.add(lea);
                                 } 
                    else if(String.isBlank(obj.lead_id) && lea.Id != NULL){
                        System.debug('Inside Update list');
                        leadWithSfIDtoUpdate.add(lea);
                    }
                    else
                    {
                        isInserted = false;   
                    }
                }
                catch(Exception e)
                {
                    System.debug('Exception Occured ' + e + e.getLineNumber());
                    LeadPushCPT.ResponseLeadobj resLeadWrap = new LeadPushCPT.ResponseLeadobj();
                    resLeadWrap.status = 'Failed';
                    resLeadWrap.message = 'Invalid SF Id';   
                    resLeadWrap.sfdc_lead_id = obj.sfdc_lead_id;
                    resLeadWrap.cpt_lead_id = obj.lead_id;
                    resLeadWrapList.add(resLeadWrap);  
                }continue;
                
            }
            if(!String.isBlank(obj.vehicle_category)){
                System.debug('vehicle category' + obj.vehicle_category );
                lea.Vehicle_Category__c = obj.vehicle_category;
            }
            if(!String.isBlank(obj.customer_pincode)){
                lea.Area_PinCode__c = obj.customer_pincode;
            }
            if(!String.isBlank(obj.customer_name))
                lea.LastName = obj.customer_name;
            if(!String.isBlank(obj.customer_mobile))
                lea.Phone = (obj.customer_mobile).right(10);
            if(!String.isBlank(obj.customer_email))
                lea.Email = obj.customer_email;
            if(!String.isBlank(obj.customer_address))
                lea.Address__c = obj.customer_address;
            if(!String.isBlank(obj.customer_pincode))
                lea.Area_PinCode__c = obj.customer_pincode;
            if(!String.isBlank(obj.evaluation_city))
                lea.evaluation_city__c = obj.evaluation_city;
            if(!String.isBlank(obj.evaluation_state))
                lea.evaluation_state__c = obj.evaluation_state;
            if(!String.isBlank(obj.registration_city))
                lea.Seller_City__c = obj.registration_city;
            if(!String.isBlank(obj.registration_state))
                lea.Seller_State__c = obj.registration_state;
            if(!String.isBlank(obj.city_name))
                lea.Seller_City__c = obj.city_name;
            if(!String.isBlank(obj.state_name))
                lea.Seller_State__c = obj.state_name;
            if(!String.isBlank(obj.make)){
                lea.Make__c = obj.make;
                lea.Primary_Make__c = obj.make;
                
            }
            if(!String.isBlank(obj.model)){
                lea.Model__c= obj.model;
                lea.Primary_Model__c = obj.model;
            }
            if(!String.isBlank(obj.variant)){
                lea.Variant__c = obj.variant;
                lea.Primary_Variant__c = obj.variant;
            }
            if(!String.isBlank(obj.uid)){
                if(mapOfTLs.containsKey(obj.uid)){
                    lea.Team_Lead__c = mapOfTLs.get(obj.uid).Id;
                }
                else if(!mapOfTLs.containsKey(obj.uid)){
                    try{
                        lea.Team_Lead__c = mapOfTLs.get(obj.uid).Id;
                    }
                    catch(Exception e){
                        System.debug('Exception Occured ' + e);
                        LeadPushCPT.ResponseLeadobj resLeadWrap = new LeadPushCPT.ResponseLeadobj();
                        resLeadWrap.status = 'Failed';
                        resLeadWrap.message = 'This team leader id doesn’t exist or is de-activated';   
                        resLeadWrap.sfdc_lead_id = obj.sfdc_lead_id;
                        resLeadWrap.cpt_lead_id = obj.lead_id;
                        resLeadWrapList.add(resLeadWrap);  
                        continue;
                    }
                }
            }
            
            if(!String.isBlank(obj.year))
                lea.Year__c = obj.year;
            if(!String.isBlank(obj.reject_reason))
                lea.reject_reason__c = obj.reject_reason;
            if(!String.isBlank(obj.kilometer))
                lea.Kilometer__c = Decimal.valueOf(obj.kilometer);
            if(!String.isBlank(obj.total_owner))
                lea.Total_Owner__c = Decimal.valueOf(obj.total_owner);
            if(!String.isBlank(obj.registration_number))
                lea.Registration_Number__c = obj.registration_number;
            if(!String.isBlank(obj.colour))
                lea.Color__c = obj.colour;
            if(!String.isBlank(obj.source))
                lea.LeadSource = obj.source;
            if(!String.isBlank(obj.lead_source))
                lea.LeadSource = obj.lead_source;
            //Added lead category by Amulya 14-07-22
            if(!String.isBlank(obj.lead_category))
                lea.Lead_Category__c = obj.lead_category;
            if(!String.isBlank(obj.sub_source))
                lea.Sub_Source__c = obj.sub_source;
            if(!String.isBlank(obj.inspect_type))
                lea.Inspect_Type__c = obj.inspect_type;
            if(!String.isBlank(obj.inspected_date))
                lea.inspected_date__c = DateTime.ValueOf(obj.inspected_date);
            if(!String.isBlank(obj.status))
                lea.Status__c = obj.status;
            if(!String.isBlank(obj.valuation_remarks))
                lea.Valuation_Remarks__c = obj.valuation_remarks;
            if(!String.isBlank(obj.evaluator_name))
                lea.evaluator_name__c = obj.evaluator_name;
            if(!String.isBlank(obj.evaluator_contact_number))
                lea.evaluator_contact_number__c = obj.evaluator_contact_number;
            if(!String.isBlank(obj.evaluator_email))
                lea.evaluator_email__c = obj.evaluator_email;
            if(!String.isBlank(obj.cpt_admin_name))
                lea.cpt_admin_name__c = obj.cpt_admin_name;
            if(!String.isBlank(obj.cpt_admin_contact_number))
                lea.cpt_admin_contact_number__c = obj.cpt_admin_contact_number;
            if(!String.isBlank(obj.cpt_admin_email))
                lea.cpt_admin_email__c = obj.cpt_admin_email;
            if(!String.isBlank(obj.qc_approved_date))
                lea.qc_approved_date__c = DateTime.ValueOf(obj.qc_approved_date);
            if(!String.isBlank(obj.auction_id))
                lea.auction_id__c = obj.auction_id;
            if(!String.isBlank(obj.auction_start_date))
                lea.auction_start_date__c = DateTime.ValueOf(obj.auction_start_date);
            if(!String.isBlank(obj.auction_end_date))
                lea.auction_end_date__c = DateTime.ValueOf(obj.auction_end_date);
            if(!String.isBlank(obj.live_followup_date))
                lea.live_followup_date__c = DateTime.ValueOf(obj.live_followup_date);
            if(!String.isBlank(obj.follwoup_remarks))
                lea.follwoup_remarks__c = obj.follwoup_remarks;
            if(!String.isBlank(obj.reject_date))
                lea.reject_date__c = DateTime.ValueOf(obj.reject_date);
            if(!String.isBlank(obj.deal_finalized_on))
                lea.deal_finalized_on__c = DateTime.ValueOf(obj.deal_finalized_on);
            if(!String.isBlank(obj.sold_out_on))
                lea.sold_out_on__c = DateTime.ValueOf(obj.sold_out_on);
            if(!String.isBlank(obj.valuator_assigned_visit_date))
                lea.Valuator_Assigned_Visit__c = Date.valueOf(obj.valuator_assigned_visit_date); 
            //Added by Amulya to valuator_visit_date date:04-07-2022
            if(!String.isBlank(obj.valuator_visit_date))
                lea.Valuator_Assigned_Visit_Date__c = date.valueOf(obj.valuator_visit_date);              
            if(!String.isBlank(obj.ibb_price))
                lea.ibb_price__c = Decimal.valueOf(obj.ibb_price);
            if(!String.isBlank(obj.customer_expected_price))
                lea.Customer_Expected_Price__c = Decimal.valueOf(obj.customer_expected_price);
            if(!String.isBlank(obj.seller_price))
                lea.Seller_Price__c = obj.seller_price;
            if(!String.isBlank(obj.Lead_Created_From))
                lea.Lead_Created_From__c = obj.Lead_Created_From;
            if(!String.isBlank(obj.lead_id))
                lea.external_cpt_id__c = obj.lead_id;
            if(!String.isBlank(String.valueOf(obj.whatsapp_consent)))
                lea.WhatsApp_consent__c = String.valueOf(obj.whatsapp_consent);
            if(!String.isBlank(String.valueOf(obj.hi_serviceable)))
                lea.HI_Serviceable__c = String.valueOf(obj.hi_serviceable);
            if(!String.isBlank(obj.hi_preference))
                lea.HI_Preference__c = obj.hi_preference;
            if(!String.isBlank(obj.hi_store))
                lea.HI_Store__c = obj.hi_store;
            if(!String.isBlank(obj.referrer))
                lea.Referrer__c = obj.referrer;
            if(!String.isBlank(String.valueOf(obj.is_otp_verified))){
                lea.Is_Otp_Verified__c = String.valueOf(obj.is_otp_verified);
            }
            else if(String.isBlank(String.valueOf(obj.is_otp_verified)) && String.valueOf(obj.hi_serviceable) == '1'){
                lea.Is_Otp_Verified__c = 'yes';
            }
            if(!String.isBlank(obj.fuel_type))
                lea.Fuel__c =obj.fuel_type;
            if(!String.isBlank(obj.marketing_source))
                lea.Marketing_Source__c = obj.marketing_source;
            if(!String.isBlank(obj.marketing_campaign))
                lea.Marketing_Campaign__c = obj.marketing_campaign;
            if(!String.isBlank(obj.marketing_device))
                lea.Marketing_Device__c = obj.marketing_device;
            if(!String.isBlank(obj.marketing_content))
                lea.Marketing_Content__c = obj.marketing_content;
            if(!String.isBlank(obj.marketing_medium))
                lea.Marketing_Medium__c = obj.marketing_medium;
            if(!String.isBlank(obj.marketing_term))
                lea.Marketing_Term__c = obj.marketing_term;
             // ico eligible flag,price,lead flag added by Amulya 01-24-2023  CRM-1039
            if(!String.isBlank( String.valueOf(obj.ico_eligible_flag))){
                if(String.valueOf(obj.ico_eligible_flag)=='1')
                    lea.ICO_eligible_flag__c = True;
                      else
                   if(String.valueOf(obj.ico_eligible_flag)=='0')
                       lea.ICO_eligible_flag__c = False; 
                  }
                  if(!String.isBlank(obj.price))
                       lea.ICO_Price__c = obj.price;
                   if(!String.isBlank(obj.lead_flag))
                      lea.Lead_Flag__c = obj.lead_flag;
            if(!String.isBlank(obj.td_client_id))
                lea.Td_Client_Id__c = obj.td_client_id;
            lea.RecordTypeId = LeadConstants.SellerLeadRecordTypeId;
            System.debug('ToUpper' + obj.lead_created_from.toUpperCase());
            if(!String.isBlank(obj.lead_created_from) && obj.lead_created_from.toUpperCase().equals(LeadConstants.NonNcdConstants) &&
               !String.isBlank(obj.lead_id)) {
                   System.debug('Inside if lead' + obj.lead_created_from.toUpperCase());
                   leadToUpsertList.add(lea);
                   
               }else if(!String.isBlank(obj.lead_created_from) && ( obj.lead_created_from.toUpperCase().equals(LeadConstants.NcdConstants) || obj.lead_created_from.toUpperCase().equals(LeadConstants.CptConstants)) &&
                        !String.isBlank(obj.lead_id)){
                            System.debug('Inside if Opp without sfid' + obj.lead_created_from.toUpperCase());
                            leadAndOppToUpsert.add(lea);
                        } 
            else if(String.isBlank(obj.lead_id)){
                System.debug('Inside Insert condition');
                leadToInsert.add(lea);
            }
            
        }
        
        System.debug('leadAndOppToUpserttttttttt' + leadAndOppToUpsert);
        System.debug('leadToInsert '+leadToInsert);
        
        if(!leadToUpsertListWithSfId.isEmpty()){
            for(Lead l : leadToUpsertListWithSfId)
            {
                failureSfId.add(l.id);
            }
        }
        
        
        if(!leadToUpsertList.isEmpty()){
            for(Lead l : leadToUpsertList)
            {
                failureExternalId.add(l.external_cpt_id__c);   //list it will store all ids in Order
                if(l.Id != null)
                {
                    FailureUpsertedMap.put(l.external_cpt_id__c,l.id); //if sf id is present the storing it into a map
                }
            }
            
            Schema.SObjectField externalField = Lead.Fields.external_cpt_id__c;
            leadResult = Database.upsert(leadToUpsertList,FALSE); 
            System.debug('leadResult Size' + leadResult.size());
            for(Database.UpsertResult result: leadResult)
            {
                if(result.isSuccess()){
                    leadIdSet.add(result.id); 
                }
                
            }
            
            for(Lead l : [select id,external_cpt_id__c from Lead where id IN :leadIdSet]){
                sfIdAndexternalIdMap.put(l.id, l.external_cpt_id__c);
                
                for(String ids : failureExternalId){
                    if(ids == l.external_cpt_id__c)
                    {
                        ids.remove(l.external_cpt_id__c);
                        
                    }
                    if(FailureUpsertedMap.containsKey(l.external_cpt_id__c)){
                        FailureUpsertedMap.remove(l.external_cpt_id__c);
                    }
                    
                }
            } 
            for(Database.UpsertResult result: leadResult){
                LeadPushCPT.ResponseLeadobj resLeadWrap = new LeadPushCPT.ResponseLeadobj();
                resLeadWrap.status = result.success == TRUE ? 'Success' : 'Failed';
                
                System.debug('error: '+String.valueOf(result.errors));
                
                // 26Nov2021:Sarthak:Start :: Error handling for upsertion
                String dbError = '';
                for(Database.Error err : result.getErrors()) {
                    dbError += '[' + err.getMessage() + ']';
                }
                // 26Nov2021:Sarthak:End
                
                resLeadWrap.message = result.success == TRUE?'Upserted successfully!'
                    :(String.valueOf(result.errors)).contains('MISSING_ARGUMENT')?'CPT Id missing'
                        :(String.valueOf(result.errors)).contains('INVALID_EMAIL_ADDRESS')?'Invalid Email'
                            :(String.valueOf(result.errors)).contains('It cant be scheduled today')?'It cannot be Schedule at this time'
                                :(String.valueOf(result.errors)).contains('Sunday cannot be chosen, also')?'Sunday cannot be chosen'
                                    :(String.valueOf(result.errors)).contains('DUPLICATE_VALUE')?'Duplicate Id'
                                        :(String.valueOf(result.errors)).contains('Phone number cannot be blank')?'Phone number cannot be blank'
                                            :(String.valueOf(result.errors)).contains('Phone number can be only 10 digits')?'Phone number can be only 10 digits and should begin with 6,7,8,9 only' 
                                                :((String.valueOf(result.errors)).contains('when status is not Valuator to be assigned') || (String.valueOf(result.errors)).contains('NewStatus not Rescheduled'))?'Invalid Status'
                                                    :(String.valueOf(result.errors)).contains('invalid date')?String.valueOf(result.errors).substringBetween('ge=',':')+':Invalid date'
                                                        :(String.valueOf(result.errors)).contains('Schedule Time Slot: bad value for restricted')?'Invalid Time Slot'
                                                            :(String.valueOf(result.errors)).contains(' You cannot edit this')?'You Cannot Edit This Record'
                                                                :(String.valueOf(result.errors)).contains('Referrer: data value too large:')?String.valueOf(result.errors)+':Referrer Field'
                                                                    : dbError;
                
                // resLeadWrap.message = result.success == TRUE?'Upserted successfully!':(String.valueOf(result.errors)).contains('MISSING_ARGUMENT')?'CPT Id missing':(String.valueOf(result.errors)).contains('INVALID_EMAIL_ADDRESS')?'Invalid Email':(String.valueOf(result.errors)).contains('DUPLICATE_VALUE')?'Duplicate Id':(String.valueOf(result.errors)).contains('Phone number cannot be blank')?'Phone number cannot be blank':(String.valueOf(result.errors)).contains('Phone number can be only 10 digits')?'Phone number can be only 10 digits and should begin with 6,7,8,9 only':(String.valueOf(result.errors)).contains('invalid date')?String.valueOf(result.errors).substringBetween('ge=',':')+':Invalid date':'Some error occurred';
                resLeadWrap.sfdc_lead_id = result.success == TRUE?result.getId():FailureUpsertedMap.get(failureExternalId[i]);
                resLeadWrap.cpt_lead_id = sfIdAndexternalIdMap.containsKey(result.id) ? sfIdAndexternalIdMap.get(result.id) : failureExternalId[i];
                System.debug('result.id'+ result.id + 'result.getId' + result.getId());
                resLeadWrapList.add(resLeadWrap); 
                i++;
            }
            
            
            
/*  System.debug('resLeadWrapListtttttttttt' + resLeadWrapList);
LeadPushCPT.CptResponseMessage resWrap = new LeadPushCPT.CptResponseMessage();
resWrap.status = 'Success';
resWrap.lead_result = resLeadWrapList;
String responseJson = System.JSON.serializePretty(resWrap);
res.responseBody = Blob.valueOf(responseJson); */
            
        } 
        
        //Added by Soumya for HI --Start
        System.debug('leadToInsert '+leadToInsert);
        if(!leadToInsert.isEmpty()){
            resultOfInsertedLeads = Database.insert(leadToInsert, FALSE);
        }
        
        System.debug('leadWithSfIDtoUpdate '+leadWithSfIDtoUpdate);
        if(!leadWithSfIDtoUpdate.isEmpty()){
            resultOfUpdatedLeads = Database.update(leadWithSfIDtoUpdate, FALSE);
        }
        System.debug('resultOfInsertedLeads '+resultOfInsertedLeads+'resultOfUpdatedLeads '+resultOfUpdatedLeads);
        
        for(Database.SaveResult result : resultOfInsertedLeads){
            LeadPushCPT.ResponseLeadobj resLeadWrap = new LeadPushCPT.ResponseLeadobj();
            resLeadWrap.status = result.success == TRUE ? 'Success' : 'Failed';
            if(result.success == false){
                System.debug('Lead Insert error: '+String.valueOf(result.errors));
            }
            
            // 26Nov2021:Sarthak:Start :: Error handling for upsertion
            String dbError = '';
            for(Database.Error err : result.getErrors()) {
                dbError += '[' + err.getMessage() + ']';
            }
            // 26Nov2021:Sarthak:End
            
            resLeadWrap.message = result.success == TRUE?'Inserted successfully!':(String.valueOf(result.errors)).contains('MISSING_ARGUMENT')?'CPT Id missing':(String.valueOf(result.errors)).contains('INVALID_EMAIL_ADDRESS')?'Invalid Email':(String.valueOf(result.errors)).contains('DUPLICATE_VALUE')?'Duplicate Id':(String.valueOf(result.errors)).contains('Phone number cannot be blank')?'Phone number cannot be blank':(String.valueOf(result.errors)).contains('Phone number can be only 10 digits')?'Phone number can be only 10 digits and should begin with 6,7,8,9 only':(String.valueOf(result.errors)).contains('invalid date')?String.valueOf(result.errors).substringBetween('ge=',':')+':Invalid date': dbError;
            resLeadWrap.sfdc_lead_id = result.success == TRUE?result.getId():NULL;
            resLeadWrapList.add(resLeadWrap); 
        }
        for(Database.SaveResult result : resultOfUpdatedLeads){
            LeadPushCPT.ResponseLeadobj resLeadWrap = new LeadPushCPT.ResponseLeadobj();
            resLeadWrap.status = result.success == TRUE ? 'Success' : 'Failed';
            if(result.success == false){
                System.debug('Lead Update error: '+String.valueOf(result.errors));
            }
            
            // 26Nov2021:Sarthak:Start :: Error handling for upsertion
            String dbError = '';
            for(Database.Error err : result.getErrors()) {
                dbError += '[' + err.getMessage() + ']';
            }
            // 26Nov2021:Sarthak:End
            
            resLeadWrap.message = result.success == TRUE?'Upserted successfully!':(String.valueOf(result.errors)).contains('MISSING_ARGUMENT')?'CPT Id missing':(String.valueOf(result.errors)).contains('INVALID_EMAIL_ADDRESS')?'Invalid Email':(String.valueOf(result.errors)).contains('It cant be scheduled today')?'It cannot be Schedule at this time':(String.valueOf(result.errors)).contains('Sunday cannot be chosen, also')?'Sunday cannot be chosen':(String.valueOf(result.errors)).contains('DUPLICATE_VALUE')?'Duplicate Id':(String.valueOf(result.errors)).contains('Phone number cannot be blank')?'Phone number cannot be blank':(String.valueOf(result.errors)).contains('Phone number can be only 10 digits')?'Phone number can be only 10 digits and should begin with 6,7,8,9 only' :(String.valueOf(result.errors)).contains('when status is not Valuator to be assigned')?'Invalid Status':(String.valueOf(result.errors)).contains('invalid date')?String.valueOf(result.errors).substringBetween('ge=',':')+':Invalid date':(String.valueOf(result.errors)).contains('Schedule Time Slot: bad value for restricted')?'Invalid Time Slot':(String.valueOf(result.errors)).contains(' You cannot edit this')?'You Cannot Edit This Record':(String.valueOf(result.errors)).contains('Referrer: data value too large:')?String.valueOf(result.errors)+':Referrer Field': dbError;
            // resLeadWrap.message = result.success == TRUE?'Updated successfully!':(String.valueOf(result.errors)).contains('MISSING_ARGUMENT')?'CPT Id missing':(String.valueOf(result.errors)).contains('INVALID_EMAIL_ADDRESS')?'Invalid Email':(String.valueOf(result.errors)).contains('DUPLICATE_VALUE')?'Duplicate Id':(String.valueOf(result.errors)).contains('Phone number cannot be blank')?'Phone number cannot be blank':(String.valueOf(result.errors)).contains('Phone number can be only 10 digits')?'Phone number can be only 10 digits and should begin with 6,7,8,9 only':(String.valueOf(result.errors)).contains('invalid date')?String.valueOf(result.errors).substringBetween('ge=',':')+':Invalid date':'Some error occurred';
            resLeadWrap.sfdc_lead_id = result.success == TRUE?result.getId():NULL;
            resLeadWrapList.add(resLeadWrap); 
        }
        //End
        
        
        if(!leadAndOppToUpsert.isEmpty()){
            for(Lead l : leadAndOppToUpsert)
            {
                failureExternalId1.add(l.external_cpt_id__c);
                if(l.Id != null)
                {
                    FailureUpsertedMap1.put(l.external_cpt_id__c,l.id);
                }
            }
            
            System.debug('failureExternalId1 before removing ' + failureExternalId1);
            System.debug('FailureUpsertedMap1 before removing' + FailureUpsertedMap1);
            
            Schema.SObjectField externalField = Lead.Fields.external_cpt_id__c;
            leadAndOppResult = Database.upsert(leadAndOppToUpsert,FALSE);
            
            for(Database.UpsertResult result: leadAndOppResult){
                
                if(result.isSuccess()){
                    leadIdSet1.add(result.id); 
                }
                //else 
                // resLeadWrap.message = result.success == TRUE?'Upserted successfully!':(String.valueOf(result.errors)).contains('MISSING_ARGUMENT')?'CPT Id missing':(String.valueOf(result.errors)).contains('INVALID_EMAIL_ADDRESS')?'Invalid Email':(String.valueOf(result.errors)).contains('It cant be scheduled today')?'It cannot be Schedule at this time':(String.valueOf(result.errors)).contains('Sunday cannot be chosen, also')?'Sunday cannot be chosen':(String.valueOf(result.errors)).contains('DUPLICATE_VALUE')?'Duplicate Id':(String.valueOf(result.errors)).contains('Phone number cannot be blank')?'Phone number cannot be blank':(String.valueOf(result.errors)).contains('Phone number can be only 10 digits')?'Phone number can be only 10 digits and should begin with 6,7,8,9 only' :(String.valueOf(result.errors)).contains('when status is not Valuator to be assigned')?'Invalid Status':(String.valueOf(result.errors)).contains('invalid date')?String.valueOf(result.errors).substringBetween('ge=',':')+':Invalid date':(String.valueOf(result.errors)).contains('Schedule Time Slot: bad value for restricted')?'Invalid Time Slot':(String.valueOf(result.errors)).contains(' You cannot edit this')?'You Cannot Edit This Record':(String.valueOf(result.errors)).contains('Referrer: data value too large:')?String.valueOf(result.errors)+':Referrer Field':'Some error occurred'; 
            } 
            
            System.debug('Lead ID successfully inserted' + leadIdSet1);
            
            for(Lead l : [select id,external_cpt_id__c from Lead where id IN :leadIdSet1]){
                sfIdAndexternalIdMap1.put(l.id, l.external_cpt_id__c);
                
                /*  for(Integer k=0; i<failureExternalId1.size(); i++ ) {
if(failureExternalId1[k] == l.external_cpt_id__c) {
failureExternalId1.remove(k);
if(FailureUpsertedMap1.containsKey(l.external_cpt_id__c)){
FailureUpsertedMap1.remove(l.external_cpt_id__c);
}
break;

}
} */
                
                for(String cptId : failureExternalId1){
                    if(cptId == l.external_cpt_id__c)
                    {
                        System.debug('cptId inside if' + cptId + 'external_cpt_id__c' + l.external_cpt_id__c);
                        cptId.remove(l.external_cpt_id__c);
                        System.debug('failureExternalId1 Inside if' + failureExternalId1);
                        
                    }
                    if(FailureUpsertedMap1.containsKey(l.external_cpt_id__c)){
                        FailureUpsertedMap1.remove(l.external_cpt_id__c);
                    }
                    
                } 
            } 
            System.debug('failureExternalId1 traced' + failureExternalId1);
            System.debug('FailureUpsertedMap1 traced' + FailureUpsertedMap1);
            
            LeadToOpportunityList = [select id,Vehicle_Category__c,FirstName,LastName,Phone,email,Address__c,evaluation_city__c,evaluation_state__c,registration_city__c,registration_state__c,
                                     Make__c,Valuator_Visit_Date_Time__c,Valuator_Assigned_Visit_Date__c,Valuator_Assigned_Visit__c,status__c,Area_Pincode__c,Seller_City__c,Seller_State__c,Model__c,Variant__c,Year__c,Kilometer__c,Total_Owner__c,Registration_Number__c,Color__c,LeadSource,Sub_Source__c,Inspect_Type__c,ICO_eligible_flag__c,ICO_Price__c,Lead_Flag__c, 
                                     inspected_date__c,qc_approved_date__c,Status,Valuation_Remarks__c,evaluator_name__c,evaluator_contact_number__c,evaluator_email__c,cpt_admin_name__c,HI_Preference__c,HI_Serviceable__c,RP_Dealer__c,
                                     cpt_admin_contact_number__c,evaluation_Name__c,Lead_Created_From__c,cpt_admin_email__c,auction_id__c,auction_start_date__c,auction_end_date__c,live_followup_date__c,Valuation_Schedule_Time_Slot__c,
                                     follwoup_remarks__c, CPT_Admin_Access_Location__c, Customer__c,WhatsApp_consent__c,Lead_Type__c,reject_date__c,reject_reason__c,RecordTypeId,Customer_Expected_Price__c,ibb_price__c,sold_out_on__c,deal_finalized_on__c,Followup_Lead_Created__c,
                                     CPT_Admin_Login_Id__c, CPT_Admin_UID__c, CPT_Admin_ZM_Name__c, Team_Lead__c, Assign_Type__c, Lead_Category__c, Autoinspekt__c, Seller_Price__c from lead where ID IN: leadIdSet1 AND Followup_Lead_Created__c = false ];
            System.debug('creating opp'+LeadToOpportunityList);
            System.debug('LeadToOpportunityList'+LeadToOpportunityList.size());
            if(LeadToOpportunityList.size() > 0){
                //Call Opportunity method for opportunity creation
                LeadTriggerHelper.createSellerOpportunity(LeadToOpportunityList);
            }
            
            for(Database.UpsertResult result: leadAndOppResult){
                LeadPushCPT.ResponseLeadobj resLeadWrap = new LeadPushCPT.ResponseLeadobj();
                resLeadWrap.status = result.success == TRUE ? 'Success' : 'Failed';
                System.debug('error: '+String.valueOf(result.errors));
                
                // 26Nov2021:Sarthak:Start :: Error handling for upsertion
                String dbError = '';
                for(Database.Error err : result.getErrors()) {
                    dbError += '[' + err.getMessage() + ']';
                }
                // 26Nov2021:Sarthak:End
                
                resLeadWrap.message = result.success == TRUE?'Upserted successfully!':(String.valueOf(result.errors)).contains('MISSING_ARGUMENT')?'CPT Id missing':(String.valueOf(result.errors)).contains('INVALID_EMAIL_ADDRESS')?'Invalid Email':(String.valueOf(result.errors)).contains('It cant be scheduled today')?'It cannot be Schedule at this time':(String.valueOf(result.errors)).contains('Sunday cannot be chosen, also')?'Sunday cannot be chosen':(String.valueOf(result.errors)).contains('DUPLICATE_VALUE')?'Duplicate Id':(String.valueOf(result.errors)).contains('Phone number cannot be blank')?'Phone number cannot be blank':(String.valueOf(result.errors)).contains('Phone number can be only 10 digits')?'Phone number can be only 10 digits and should begin with 6,7,8,9 only' :(String.valueOf(result.errors)).contains('when status is not Valuator to be assigned')?'Invalid Status':(String.valueOf(result.errors)).contains('invalid date')?String.valueOf(result.errors).substringBetween('ge=',':')+':Invalid date':(String.valueOf(result.errors)).contains('Schedule Time Slot: bad value for restricted')?'Invalid Time Slot':(String.valueOf(result.errors)).contains(' You cannot edit this')?'You Cannot Edit This Record':(String.valueOf(result.errors)).contains('Referrer: data value too large:')?String.valueOf(result.errors)+':Referrer Field': dbError;
                
                //  resLeadWrap.message = result.success == TRUE?'Upserted successfully!':(String.valueOf(result.errors)).contains('MISSING_ARGUMENT')?'CPT Id missing':(String.valueOf(result.errors)).contains('INVALID_EMAIL_ADDRESS')?'Invalid Email':(String.valueOf(result.errors)).contains('It cant be scheduled today')?'It cannot be Schedule at this time':(String.valueOf(result.errors)).contains('DUPLICATE_VALUE')?'Duplicate Id':(String.valueOf(result.errors)).contains('Phone number cannot be blank')?'Phone number cannot be blank':(String.valueOf(result.errors)).contains('Phone number can be only 10 digits')?'Phone number can be only 10 digits and should begin with 6,7,8,9 only' :(String.valueOf(result.errors)).contains('when status is not Valuator to be assigned')?'Invalid Status':(String.valueOf(result.errors)).contains('invalid date')?String.valueOf(result.errors).substringBetween('ge=',':')+':Invalid date':(String.valueOf(result.errors)).contains('Schedule Time Slot: bad value for restricted')?'Invalid Time Slot':(String.valueOf(result.errors)).contains(' You cannot edit this')?'You Cannot Edit This Record':(String.valueOf(result.errors)).contains('Referrer: data value too large:')?String.valueOf(result.errors)+':Referrer Field':'Some error occurred';
                resLeadWrap.sfdc_lead_id = result.success == TRUE?result.getId(): FailureUpsertedMap1.get(failureExternalId1[j]);
                resLeadWrap.cpt_lead_id = sfIdAndexternalIdMap1.containsKey(result.id) ? sfIdAndexternalIdMap1.get(result.id) : failureExternalId1[j];
                resLeadWrapList.add(resLeadWrap);   
                j++;
            }
            
            /* System.debug('resLeadWrapListtttttttttt' + resLeadWrapList);
LeadPushCPT.CptResponseMessage resWrap = new LeadPushCPT.CptResponseMessage();
resWrap.status = 'Success';
resWrap.lead_result = resLeadWrapList;
String responseJson = System.JSON.serializePretty(resWrap);
res.responseBody = Blob.valueOf(responseJson);    */
        }
        
        System.debug('resLeadWrapList '+resLeadWrapList);
        if(!resLeadWrapList.isEmpty()){
            LeadPushCPT.CptResponseMessage resWrap = new LeadPushCPT.CptResponseMessage();
            resWrap.status = 'Success';
            resWrap.lead_result = resLeadWrapList;
            String responseJson = System.JSON.serializePretty(resWrap);
            String requestJsonBody = System.JSON.serializePretty(leadObjectList);
            System.debug('****requestJsonBody*****' + requestJsonBody);
            System.debug('***responseJson*****' + responseJson);
            LogService.createApiLogs(Endpoint,requestJsonBody, responseJson,'Success','CptLeadUpsert'); 
            System.debug('responseBody: '+responseJson);
            res.responseBody = Blob.valueOf(responseJson);
        }
        if(isInserted == false)
        {
            JSONGenerator responseJSON = JSON.createGenerator(true);
            responseJSON.writeStartObject(); 
            responseJSON.writeStringField('status', 'Failed');
            responseJSON.writeStringField('Message', 'lead_created_from data is not correct');
            responseJSON.writeEndObject();
            res.responseBody = Blob.valueOf(responseJSON.getAsString());
        }
        System.debug('res.responseBody: '+res.responseBody);
        
    }
    
}