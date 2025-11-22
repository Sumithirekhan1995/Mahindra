public without sharing class SMSDisplayControllerWarranty {
    @AuraEnabled
   public static List<SMSWrapper> getTemplate(String recId){
    System.debug('Record ID for SendEmail: '+recId);

       List<SMSWrapper> tempWrapper = new List<SMSWrapper>();       
       for(SMS_Template__c sms : [Select Id, Name, SMS_Body__c from SMS_Template__c Where IsActive__c  = true AND Module__c = 'Buy Used Car Warranty']){
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
       //String myIdPrefix = recId.substring(0,3);
       Warranty__c warranty = [Select Id, FollowUp_Lead__c, Name,Customer_Phone__c from Warranty__c Where Id =: recId];

        //System.debug ('Follow up lead: '+ warranty.FollowUp_Lead__c);
        ContactWrapper cw = new ContactWrapper();
        cw.contactName = warranty.Name;
        cw.contactType = '(Customer)';
        cw.phoneNumber = warranty.Customer_Phone__c;
        tempWrapper.add(cw);

        // if(warranty.FollowUp_Lead__c != null){
        //     Opportunity fLead = [select id, Name, Customer_Phone__c from Opportunity where id =: warranty.FollowUp_Lead__c];
        //     ContactWrapper cw2 = new ContactWrapper();
        //     cw2.contactName = fLead.Name;
        //     cw2.contactType = '(Customer)';
        //     cw2.phoneNumber = fLead.Customer_Phone__c;
        //     tempWrapper.add(cw2);
        // }       
       System.debug('tempWrapper: '+tempWrapper);
       return tempWrapper;
   }
   
   @AuraEnabled
   public static String createSMSLog(String recId, String templateId, String smsBody, String phoneNumber /*, Boolean sms, Boolean wa*/){
       System.debug('creating apex log');
       System.debug('cmp body: '+smsBody);
       system.debug('Phone: '+phoneNumber);
       String response = 'Success';
       
        Warranty__c w = [Select Id,FollowUp_Lead__c from Warranty__c where Id =: recId];
       //String FollowUpId = w.FollowUp_Lead__c; //Sachin (11-OCT-2022)::CRM-1000
       //Opportunity opp = [select Id,Lead__c from opportunity where Id =:FollowUpId];//Sachin (11-OCT-2022)::CRM-1000
       //Lead LeadID = [select Id from Lead where Id =: opp.Lead__c];//Sachin (11-OCT-2022)::CRM-1000
      
        System.debug('Warrantty ID: '+w.id);
       

       
       
       SMS_Log__c smsLog = new SMS_Log__c();
       smsLog.SMS_Template__c = templateId;
       smsLog.Warranty__c = w.id;
       smsLog.SMS_Body__c = smsBody;
       smsLog.Send_To__c = phoneNumber;       
             
       insert smsLog;
       System.debug('smslog '+smsLog);
       
       
       //smsLog.SMS__c = sms;
       //smsLog.Whatsapp__c = wa;
       /*
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
          
       insert smsLog;*/
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