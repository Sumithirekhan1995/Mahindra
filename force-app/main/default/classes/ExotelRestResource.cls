/**
 * @File Name          : ExotelRestResource.cls
 * @Description        : 
 * @Author             : Kunal
 * @Group              : 
 * @Last Modified By   : Kunal
 * @Last Modified On   : 13/04/2020, 12:26:23 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    13/04/2020           Kunal              Initial Version
**/
@RestResource(urlMapping='/ExotelLead')
global class ExotelRestResource {
   
   
    @HttpGet
    global static void getLead(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        System.debug('URL: '+req.requestURI);
        Map <String, String> reqparams = req.params;
        System.debug('reqparams: '+reqparams) ;
        Exotel_Call_Summary__c ecs = new Exotel_Call_Summary__c();
        for(String strKey : reqparams.keySet()){
            System.debug(strKey +' : '+reqparams.get(strKey));
            if(strKey == 'CallFrom')
            	ecs.CallFrom__c = reqparams.get(strKey);
            if(strKey == 'CallSid')
                ecs.CallSid__c = reqparams.get(strKey);
            if(strKey == 'CallTo')
            	ecs.CallTo__c = reqparams.get(strKey);
            if(strKey == 'CallType')
            	ecs.CallType__c = reqparams.get(strKey);
            if(strKey == 'Created')
            	ecs.Created__c = reqparams.get(strKey);
            if(strKey == 'CurrentTime')
            	ecs.CurrentTime__c = reqparams.get(strKey);
            if(strKey == 'DialCallDuration')
            	ecs.DialCallDuration__c = reqparams.get(strKey);
            if(strKey == 'DialCallStatus')
            	ecs.DialCallStatus__c = reqparams.get(strKey);
            if(strKey == 'DialWhomNumber')
            	ecs.DialWhomNumber__c = reqparams.get(strKey);
            if(strKey == 'Direction')
            	ecs.Direction__c = reqparams.get(strKey);
            if(strKey == 'EndTime')
            	ecs.EndTime__c = reqparams.get(strKey);
            if(strKey == 'flow_id')
            	ecs.Flow_Id__c = reqparams.get(strKey);
            if(strKey == 'From')
            	ecs.From__c = reqparams.get(strKey);
            if(strKey == 'Legs[0][Cause]')
            	ecs.Legs_0_Cause__c = reqparams.get(strKey);
            if(strKey == 'Legs[0][CauseCode]')
            	ecs.Legs_0_CauseCode__c = reqparams.get(strKey);
            if(strKey == 'Legs[0][Number]')
            	ecs.Legs_0_Number__c = reqparams.get(strKey);
            if(strKey == 'Legs[0][OnCallDuration]')
            	ecs.Legs_0_OnCallDuration__c = reqparams.get(strKey);
            if(strKey == 'Legs[0][Type]')
            	ecs.Legs_0_Type__c = reqparams.get(strKey);
            if(strKey == 'OutgoingPhoneNumber')
            	ecs.OutgoingPhoneNumber__c = reqparams.get(strKey);
            if(strKey == 'RecordingAvailableBy')
            	ecs.RecordingAvailableBy__c = reqparams.get(strKey);
            if(strKey == 'RecordingUrl')
            	ecs.RecordingUrl__c = reqparams.get(strKey);
            if(strKey == 'StartTime')
            	ecs.StartTime__c = reqparams.get(strKey);
            if(strKey == 'tenant_id')
            	ecs.Tenant_Id__c = reqparams.get(strKey);
            if(strKey == 'To')
            	ecs.To__c = reqparams.get(strKey);
           ecs.Schedule_Action__c = system.now().addMinutes(5).addHours(-1);
        }
        insert ecs;  
    }
}