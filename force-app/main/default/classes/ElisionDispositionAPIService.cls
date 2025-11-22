public class ElisionDispositionAPIService {
    
    public Wrap_ResBody updateRecord(Wrap_ReqBody reqBody) {
        Integer statusCode = 400;
        String message = 'No Operation Performed';
        try {
            
            // Validations
            if(String.isEmpty(reqBody.recordId) || (!reqBody.recordId.startsWith('00T'))) {
                //return new Wrap_ResBody(statusCode, 'Invalid recordId');
            }
            if(String.isEmpty(reqBody.disposition)) {
                return new Wrap_ResBody(statusCode, 'disposition Required');
            }
            if(String.isEmpty(reqBody.agent_id)) {
                return new Wrap_ResBody(statusCode, 'agent_id Required');
            }
            if(String.isEmpty(reqBody.list_id)) {
                return new Wrap_ResBody(statusCode, 'list_id Required');
            }
            if(String.isEmpty(reqBody.phone)) {
                return new Wrap_ResBody(statusCode, 'phone Required');
            }
            if(String.isEmpty(reqBody.campaign)) {
                return new Wrap_ResBody(statusCode, 'campaign Required');
            }
            if(String.isEmpty(reqBody.call_start_time)) {
                return new Wrap_ResBody(statusCode, 'call_start_time Required');
            }
            if(String.isEmpty(reqBody.call_end_time)) {
                return new Wrap_ResBody(statusCode, 'call_end_time Required');
            }
            if(String.isEmpty(reqBody.hangup_reason)) {
                return new Wrap_ResBody(statusCode, 'hangup_reason Required');
            }
            if(String.isEmpty(reqBody.call_count)) {
                return new Wrap_ResBody(statusCode, 'call_count Required');
            }
            
            // Updating Task
           
            if(reqBody.recordId != null && reqBody.recordId.startsWith('00T')) {
                String recordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('Elision').getRecordTypeId();
                List<Task> tRecArr = [SELECT Id, WhatId, WhoId, Elision_Campaign__c, Elision_Campaign__r.CampaignId_FollowUp__c, Elision_Campaign__r.Name from Task where Id = :reqBody.recordId AND RecordTypeId = :recordTypeId AND (WhatId != null OR WhoId != null ) LIMIT 1];
                
                List<Opportunity> oRecArr = new List<Opportunity>();
                List<Lead> lRecArr = new List<Lead>();
                Map<String, String> dispositionValMap = new Map<String, String>();

                if(tRecArr[0].WhatId != null )
                {
                    oRecArr = [SELECT Id, No_Response_Count__c FROM Opportunity WHERE Id = :tRecArr[0].WhatId LIMIT 1];
                }
                else if(tRecArr[0].WhoId != null)
                {
                    lRecArr = [SELECT Id, No_Response_Count__c, Customer__c FROM Lead WHERE Id = :tRecArr[0].WhoId LIMIT 1];
                }

                System.debug('RecArr: '+oRecArr);
                System.debug('RecArr: '+lRecArr);

                DateTime businessStartTime = Datetime.newInstanceGMT(System.now().year(), System.now().month(), System.now().day(), 3, 30, 0);
                DateTIme businessEndTime = businessStartTime.addHours(12);
                DateTime nextWorkingHourDT = businessStartTime.addDays(1);
                DateTime nextWorkingHourD = nextWorkingHourDT.addMinutes(-60 * 12);

                if(!oRecArr.isEmpty()) {
                    Opportunity oRec = new Opportunity();
                    oRec.Id =  oRecArr[0].Id;
                    oRec.No_Response_Count__c = oRecArr[0].No_Response_Count__c;
                    
                    dispositionValMap = getValueFromDisposition(reqBody.disposition, String.valueOf(oRec.No_Response_Count__c));
                    
                    if(dispositionValMap.get('status') != null) {
                        oRec.status__c = dispositionValMap.get('status');
                    }
                    if(dispositionValMap.get('noResponseCount') != null) {
                        oRec.No_Response_Count__c = Decimal.valueOf(dispositionValMap.get('noResponseCount'));
                    }
                    if(dispositionValMap.get('Stage') != null) {
                        oRec.StageName = dispositionValMap.get('Stage');
                    }
                    if(dispositionValMap.get('lostReason') != null) {
                        oRec.Lost_Reason__c = dispositionValMap.get('lostReason');
                    }
                    
                    // updating Opportunity
                    String upsertResultMessage = upsertHelper(new List<Opportunity>{oRec});
                    if(upsertResultMessage != null) {
                        return new Wrap_ResBody(500, upsertResultMessage);    
                    }
                    
                    List<Task> tRecToUpdateArr = new List<Task>();
                    // if No response then create new Task
                    if(oRec.status__c == 'No Response' && oRec.No_Response_Count__c < 5  ) {
                       

                        
                        // for new Task creation
                        Task tRecNew = new Task(); 
                        tRecNew.WhatId = oRec.Id;
                        tRecNew.Elision_Campaign__c = tRecArr[0].Elision_Campaign__c;
                        tRecNew.Campaign_Id__c = tRecArr[0].Elision_Campaign__r.CampaignId_FollowUp__c;
                        tRecNew.Campaign_Name__c = tRecArr[0].Elision_Campaign__r.Name;
                        tRecNew.Subject = 'Elision BUC Call';

                        if(System.now().addHours(2) >= businessStartTime && System.now().addHours(2) <= businessEndTime) { // In Businness Hour
            
                            tRecNew.Elision_Due_Date__c = System.now().addHours(2);
                            tRecNew.CallBack_Time__c = String.valueOf(System.now().addHours(2));
                            tRecNew.Elison_CallBack_Time__c = System.now().addHours(2);
                        }
                        else { // out Business Hour
                           
                                //isInBusinessHour = false;
                                DateTime elisionDueDate;
                                //followUp = false;
                                elisionDueDate = nextWorkingHourDT.addHours(2);
                                //elisionDueDate = elisionDueDate.addHours(1);

                                tRecNew.Elision_Due_Date__c = elisionDueDate; 
                                tRecNew.CallBack_Time__c = String.valueOf(elisionDueDate);
                                tRecNew.Elison_CallBack_Time__c = elisionDueDate;
                            
                        }
                        tRecNew.RecordTypeId = recordTypeId;
                        tRecToUpdateArr.add(tRecNew);
                    }
                    
                    // updating old Task
                    Task oldTask = getTaskMapFromDisp(reqBody);
                    oldTask.Id = reqBody.recordId;
                    oldTask.Status = 'Completed';
                    oldTask.Subject = 'Elision Call ' + String.valueOf(DateTime.now());
                    tRecToUpdateArr.add(oldTask);
                    
                    // insert new and updating old task Task
                    upsertResultMessage = upsertHelper(tRecToUpdateArr);
                    if(upsertResultMessage != null) {
                        return new Wrap_ResBody(500, upsertResultMessage);    
                    }
                    
                    statusCode = 200;
                }
                else if(!lRecArr.isEmpty()){
                    Lead lRec = new Lead();
                    lRec.Id =  lRecArr[0].Id;
                    lRec.No_Response_Count__c = lRecArr[0].No_Response_Count__c;
                    
                    dispositionValMap = getValueFromDisposition(reqBody.disposition, String.valueOf(lRec.No_Response_Count__c));
                    
                    if(dispositionValMap.get('status') != null) {
                        lRec.status__c = dispositionValMap.get('status');
                    }
                    if(dispositionValMap.get('noResponseCount') != null) {
                        lRec.No_Response_Count__c = Decimal.valueOf(dispositionValMap.get('noResponseCount'));
                    }
                    if(dispositionValMap.get('Stage') != null) {
                        lRec.Status = dispositionValMap.get('Stage');
                    }
                    if(dispositionValMap.get('lostReason') != null) {
                        lRec.Lost_Reason__c = dispositionValMap.get('lostReason');
                    }
                    
                    // updating Opportunity
                    String upsertResultMessage = upsertHelper(new List<Lead>{lRec});
                    if(upsertResultMessage != null) {
                        return new Wrap_ResBody(500, upsertResultMessage);    
                    }
                    
                    List<Task> tRecToUpdateArr = new List<Task>();
                    // if No response then create new Task
                    if(lRec.status__c == 'No Response' && lRec.No_Response_Count__c < 5  ) {
                        // for new Task creation
                        Task tRecNew = new Task(); 
                        tRecNew.WhoId = lRec.Id;
                        tRecNew.Elision_Campaign__c = tRecArr[0].Elision_Campaign__c;
                        tRecNew.Campaign_Id__c = tRecArr[0].Elision_Campaign__r.CampaignId_FollowUp__c;
                        tRecNew.Campaign_Name__c = tRecArr[0].Elision_Campaign__r.Name;
                        tRecNew.Subject = 'Elision BUC Call';

                        if(System.now().addHours(2) >= businessStartTime && System.now().addHours(2) <= businessEndTime) { // In Businness Hour
            
                            tRecNew.Elision_Due_Date__c = System.now().addHours(2);
                            tRecNew.CallBack_Time__c = String.valueOf(System.now().addHours(2));
                            tRecNew.Elison_CallBack_Time__c = System.now().addHours(2);
                        }
                        else { // out Business Hour
                           
                                //isInBusinessHour = false;
                                DateTime elisionDueDate;
                                //followUp = false;
                                elisionDueDate = nextWorkingHourDT.addHours(2);
                                //elisionDueDate = elisionDueDate.addHours(1);

                                tRecNew.Elision_Due_Date__c = elisionDueDate; 
                                tRecNew.CallBack_Time__c = String.valueOf(elisionDueDate);
                                tRecNew.Elison_CallBack_Time__c = elisionDueDate;
                            
                        }
                        tRecNew.RecordTypeId = recordTypeId;
                        tRecToUpdateArr.add(tRecNew);
                        
                    }
                    
                    // updating old Task
                    Task oldTask = getTaskMapFromDisp(reqBody);
                    oldTask.Id = reqBody.recordId;
                    oldTask.Status = 'Completed';
                    oldTask.Subject = 'Elision Call ' + String.valueOf(DateTime.now());
                    tRecToUpdateArr.add(oldTask);
                    
                    // insert new and updating old task Task
                    upsertResultMessage = upsertHelper(tRecToUpdateArr);
                    if(upsertResultMessage != null) {
                        return new Wrap_ResBody(500, upsertResultMessage);    
                    }
                    
                    statusCode = 200;
                }
                
            }  else {
                
                // create new Task
                Task newTask = getTaskMapFromDisp(reqBody);
                newTask.Status = 'Completed';
                newTask.Subject = 'Elision Call ' + String.valueOf(DateTime.now());
                
                // getting Last Modified lead record with same phone
                List<Lead> lRecArr = [SELECT Id FROM Lead WHERE Phone = :newTask.Phone__c AND (RecordTypeId = :LeadConstants.buyerLeadRecordTypeId OR RecordTypeId = :LeadConstants.SellerLeadRecordTypeId) ORDER BY LastModifiedDate DESC LIMIT 1];
                if(!lRecArr.isEmpty()) {
                    newTask.WhoId = lRecArr[0].Id;
                }
                
                // inserting lead
                String upsertResultMessage = upsertHelper(new List<Task>{newTask});
                if(upsertResultMessage != null) {
                    return new Wrap_ResBody(500, upsertResultMessage);    
                }
                statusCode = 200;
            }
            
            return new Wrap_ResBody(statusCode, statusCode == 200 ? 'Disposition Record Added' : message);            
            
        } catch(Exception e) {
            System.debug('Exception ' + e.getTypeName() + ' : ' + e.getMessage());
            return new Wrap_ResBody(500, e.getTypeName() + ' : [' + e.getMessage() + ']');            
        }
    }
    
    public String upsertHelper(List<sObject> recArr) {
        String resMsg = '';
        try {
            List<Database.UpsertResult> upsertResult = Database.upsert(recArr, false); 
            for(Database.UpsertResult upsertResultItem : upsertResult) {
                System.debug('Database.UpsertResult: ' + upsertResultItem);
                
                List<String> dbErrorArr = new List<String>();
                for(Database.Error err : upsertResultItem.getErrors()) {
                    dbErrorArr.add(err.getMessage());
                }
                resMsg = upsertResultItem.isSuccess() ? null : String.join(dbErrorArr, ',');
            }
        } catch(Exception e) {
            resMsg = e.getTypeName() + ' : ' + e.getMessage();
        }
        return resMsg;
    }
    
    public Task getTaskMapFromDisp(Wrap_ReqBody reqBody) {
        Task tRec = new task();
        tRec.disposition__c = reqBody.disposition;
        tRec.agent_FullName__c = reqBody.agent_FullName;
        tRec.agent_id__c = reqBody.agent_id;
        tRec.Campaign_Name__c = reqBody.campaign;
        tRec.Call_Duration__c = reqBody.call_duration;
        tRec.Call_Start_Time__c = DateTime.valueOf(reqBody.call_start_time);
        tRec.Call_End_Time__c = DateTime.valueOf(reqBody.call_end_time);
        tRec.HangUp_Reason__c = reqBody.hangup_reason;
        tRec.list_id__c = reqBody.list_id;
        tRec.call_type__c = reqBody.call_type;
        tRec.recording_link__c = reqBody.recording_link;
        tRec.talktime__c = reqBody.talktime;
        tRec.vendor_lead_code__c = reqBody.vendor_lead_code;
        tRec.Disposition_Discription__c = reqBody.disposition_discription;
        tRec.CallBack_Time__c = reqBody.callback_time;
        tRec.Phone__c = reqBody.phone;
        
        return tRec;
    }
    
    public Map<String, String> getValueFromDisposition(String disposition, String noResponseCount) {
        Map<String, String> valueMap = new Map<String, String>();
        String status, stage, lostReason;
        Integer noResponseCountInt = String.isEmpty(noResponseCount) ? 0 : Integer.valueOf(noResponseCount);
        List<String> noResponseDispArr = new List<String>();
        noResponseDispArr.add('N');
        noResponseDispArr.add('NR');
        noResponseDispArr.add('NOOS');
        noResponseDispArr.add('RINGIN');
        noResponseDispArr.add('SO');
        noResponseDispArr.add('TEMPOS');
        noResponseDispArr.add('NBUSY');
        noResponseDispArr.add('AB');
        noResponseDispArr.add('NA');
        noResponseDispArr.add('DROP');
        noResponseDispArr.add('ADC');
        noResponseDispArr.add('LRERR');
        
        if(noResponseDispArr.contains(disposition)) {
            status = 'No Response';
            noResponseCountInt += 1;
            
            if(noResponseCountInt >= 5) {
                lostReason = 'No response after 5 attempts';
                status = 'Lost';
            }
        } else {
            noResponseCountInt = 0;
        }
        
        
        valueMap.put('status', status);
        valueMap.put('stage', stage);
        valueMap.put('lostReason', lostReason);
        valueMap.put('noResponseCount',String.valueOf(noResponseCountInt));
        return valueMap;
    }
    
    // Wrapp Reqbody
    public class Wrap_ReqBody {
        String disposition;
        String agent_id;
        String agent_FullName;
        String list_id;
        String call_duration;
        String recording_link;
        String vendor_lead_code;
        String phone;
        String campaign;
        String all_lead_details;
        String call_start_time;
        String call_end_time;
        String hangup_reason;
        String call_type;
        String talktime;
        String call_count;
        String callback_time;
        String disposition_discription;
        String recordId;
        String objectIdentifier;
    }
    
    // Wrap ResBody
    public class Wrap_ResBody {
        Integer status;
        String message;
        public Wrap_ResBody(Integer status, String message) {
            this.status = status;
            this.message = message;
        }
    }
    
}