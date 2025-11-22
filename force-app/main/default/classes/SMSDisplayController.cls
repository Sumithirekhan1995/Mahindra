public without sharing class SMSDisplayController {
 	@AuraEnabled
    public static List<SMSWrapper> getTemplate(String recId){
        List<SMSWrapper> tempWrapper = new List<SMSWrapper>();
        String recType = '';
        String moduleName = 'Sell Used Car';
        String myIdPrefix = recId.substring(0,3);
        if(myIdPrefix == '00Q')
        	recType = [Select Id,RecordType.Name from Lead Where Id =:recId].RecordType.Name;
        if(myIdPrefix == '006')
        	recType = [Select Id,RecordType.Name from Opportunity Where Id =:recId].RecordType.Name;
        
        if(recType == 'Seller' || recType == 'Seller Car'){
            moduleName = 'Sell Used Car';
        }else if(recType == 'Buyer Used Car'){
            moduleName = 'Buy Used Car';
        }
        else if(recType == 'Finance'){
            moduleName = 'Finance';
        }
        for(SMS_Template__c sms : [Select Id, Name, SMS_Body__c from SMS_Template__c Where IsActive__c  = true AND Module__c =:moduleName]){
            SMSWrapper tempSMS = new SMSWrapper();
            tempSMS.templateId = sms.Id;
            tempSMS.templateName = sms.Name;
            tempSMS.templateBody = sms.SMS_Body__c;
            tempWrapper.add(tempSMS);
        }
        System.debug('tempWrapper: '+tempWrapper);
        return tempWrapper;
    }
    
    @AuraEnabled
    public static List<ContactWrapper> getContacts(String recId){
        List<ContactWrapper> tempWrapper = new List<ContactWrapper>();
        Lead ld;
        Opportunity opp;
        String myIdPrefix = recId.substring(0,3);
        if(myIdPrefix == '00Q'){
        	ld = [Select Id,Name,Phone from Lead Where Id =:recId];
            ContactWrapper cw = new ContactWrapper();
            cw.contactName = ld.Name;
            cw.contactType = '(Customer)';
            cw.phoneNumber = ld.Phone;
            tempWrapper.add(cw);
        }
        if(myIdPrefix == '006'){
        	opp = [Select Id,Lead__r.Name,Lead__r.Phone,Customer_Phone__c,Dealer__c,Dealer__r.Name,Dealer__r.Phone from Opportunity Where Id =:recId];
            ContactWrapper cw = new ContactWrapper();
            cw.contactName = opp.Lead__r.Name;
            cw.contactType = '(Customer)';
            cw.phoneNumber = opp.Lead__r.Phone;
            tempWrapper.add(cw);
            
            if(opp != null && opp.Dealer__c != null){
                ContactWrapper dealer = new ContactWrapper();
                dealer.contactName = opp.Dealer__r.Name;
                dealer.contactType = '(Dealer)';
                dealer.phoneNumber = opp.Dealer__r.Phone;
                tempWrapper.add(dealer);
                for(Contact con : [Select Id,Name, Department ,Phone from Contact Where AccountId =: opp.Dealer__c]){
                    ContactWrapper tempCw = new ContactWrapper();
                    tempCw.contactName = con.Name;
                    tempCw.contactType = '(Dealer'+'-'+con.Department+')';
                    tempCw.phoneNumber = con.Phone;
                    tempWrapper.add(tempCw);
                }
            }
        }
        System.debug('tempWrapper: '+tempWrapper);
        return tempWrapper;
    }
    
    @AuraEnabled
    public static String createSMSLog(String recId, String templateId, String smsBody, String phoneNumber /*, Boolean sms, Boolean wa*/){
        System.debug('creating apex log');
        System.debug('cmp body: '+smsBody);
        String response = 'Success';
        SMS_Log__c smsLog = new SMS_Log__c();
        smsLog.SMS_Template__c = templateId;
        smsLog.SMS_Body__c = smsBody;
        smsLog.Send_To__c = phoneNumber;
        //smsLog.SMS__c = sms;
        //smsLog.Whatsapp__c = wa;
        String myIdPrefix = recId.substring(0,3);
        if(myIdPrefix == '00Q')
        	smsLog.Lead__c = recId;
        if(myIdPrefix == '006'){
            List<Opportunity> opps = new List<Opportunity>();
            opps = [Select Id,Lead__c,Dealer__c from Opportunity Where Id =:recId];
        	smsLog.Qualified_Lead__c = recId;
            if(opps.size() > 0 && opps[0].Lead__c != null){
                smsLog.Lead__c = opps[0].Lead__c;
            }
            if(opps.size() > 0 && opps[0].Dealer__c != null){
                smsLog.Dealer__c = opps[0].Dealer__c;
            }
        }
        System.debug('smslog '+smsLog);
           
        insert smsLog;
        return response;
    }
    
    public class SMSWrapper{
        @AuraEnabled 
        public String templateName;
        @AuraEnabled 
        public String templateBody;
        @AuraEnabled 
        public String templateId;
        
    }
    public class ContactWrapper{
        @AuraEnabled 
        public String contactName;
        @AuraEnabled 
        public String contactType;
        @AuraEnabled 
        public String phoneNumber;
        
    }
}