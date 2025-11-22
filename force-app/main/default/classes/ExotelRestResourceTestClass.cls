//Added by Aravindan

@isTest
public class ExotelRestResourceTestClass {
    
    public static testmethod void ExotelRestResourceTest()
    {
        
        /* RestRequest request = new RestRequest();
         request.requestUri ='https://mfcw--uat.my.salesforce.com/services/apexrest/leadupsert';
         request.httpMethod = 'POST';
         request.addHeader('Content-Type', 'application/json');
         request.requestBody = Blob.valueOf('{"status": "Working"}');
         RestContext.request = request;
         LeadPushToLMS.getLeadInfo(); */
        
        
        RestRequest request = new RestRequest();
         request.requestUri ='https://mfcw--uat.my.salesforce.com/services/apexrest/ExotelLead';
         request.httpMethod = 'GET';
         request.addHeader('Content-Type', 'application/json');
        request.params.put('CallFrom', '09958298880');
        request.params.put('CallSid', 'f416b28cadb6b39702ab425eb557145q');
        request.params.put('CallTo', '04471104395');
        request.params.put('CallType', 'completed');
        request.params.put('Created', 'Mon, 25 May 2020 15:14:26');
        request.params.put('DialCallDuration', '10');
        request.params.put('DialWhomNumber', '07353756342');
        request.params.put('Direction', 'incoming');
        request.params.put('EndTime', '1970-01-01 05:30:00');
        request.params.put('CurrentTime', '2020-05-25 17:49:12');
        request.params.put('DialCallStatus', 'completed');
        request.params.put('flow_id', '293541');
        request.params.put('From', '09818940509');
        request.params.put('Legs[0][Cause]', '1003');
        request.params.put('Legs[0][CauseCode]', 'NORMAL_CLEARING');
        request.params.put('Legs[0][Number]', '07353756342');
        request.params.put('Legs[0][OnCallDuration]', 'CallSid');
        request.params.put('Legs[0][Type]', 'single');
        request.params.put('OutgoingPhoneNumber', '07799740053');
        request.params.put('RecordingAvailableBy', 'Mon, 25 May 2020 17:54:12');
        request.params.put('RecordingUrl', 'https://s3-ap-southeast-1.amazonaws.com/exotelrecordings/mahindra7/68d9c78dda019426acaeef767b79145p.mp3');
        request.params.put('StartTime', '2020-05-25 17:48:10');
        request.params.put('tenant_id', '16184');
        request.params.put('To', '07799740053');
        RestContext.request = request;
        ExotelRestResource.getLead();
        
        
        
    }

}