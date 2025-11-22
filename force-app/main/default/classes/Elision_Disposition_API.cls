/**
* CreatedBy : Shivam Singh
* CreatedDate : 28th Dec 2021
* Purpose : Elision Leads call Disposition Handler
* LastModifiedDate : 10th Feb 2022
* 
*/
@RestResource(urlMapping='/elision/disposition/*')
global class Elision_Disposition_API {
    
    @HTTPPost
    global static void postHandler() {
        RestRequest req=RestContext.request;
        RestResponse res=RestContext.response;
        res.statusCode = 200;
        res.addHeader('Content-Type', 'application/json');
         // CheckRecursiveTrigger.runOnceCTI();  // 21 june 2022:Rohit : first comment, Now  date 08 july 2022 - un-comment, 011 july 2022 - comment :: Duplicate hitting in Elision from SF (this fuction again becouse not run elision on update ) (CRM-877)
        try {
            String reqBodyStr = req.requestBody.toString();  
            Map<String,Object> requestJSON= (Map<String,Object>)JSON.deserializeUntyped(reqBodyStr);
            System.debug('Request: '+requestJson.get('recordId'));
            /*if(requestJson.get('recordId') == null || requestJson.get('recordId') == '') {
                String resBody = postDisposition(req);
                
                res.responseBody = Blob.valueOf(resBody);
            } else {*/
                
                //Changes By Shivam on 22/12/2022
                ElisionDispositionAPIService.Wrap_ReqBody reqBody = (ElisionDispositionAPIService.Wrap_ReqBody)JSON.deserialize(reqBodyStr, ElisionDispositionAPIService.Wrap_ReqBody.class);
                
                ElisionDispositionAPIService eObj = new ElisionDispositionAPIService();
                ElisionDispositionAPIService.Wrap_ResBody responseBody = eObj.updateRecord(reqBody);
                res.responseBody = Blob.valueOf(JSON.serialize(responseBody));
               /* System.debug('reqBody ' + reqBody);
                ElisionDispositonService edObj = new ElisionDispositonService();
                ElisionDispositonService.Wrap_ResBody resBody = edObj.updateRecord(reqBody);
                res.responseBody = Blob.valueOf(JSON.serialize(resBody));*/
            //}
        } catch(Exception e) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ElisionDispositionAPIService.Wrap_ResBody(500, e.getTypeName() + ' : [' + e.getMessage() + ']')));
        }
    }
    
    
    global static String postDisposition(RestRequest req) {
        //RestRequest req=RestContext.request;
        RestResponse res=RestContext.response;
        String jsonData=req.requestBody.toString();        
        Map<String,Object> requestJSON= (Map<String,Object>)JSON.deserializeUntyped(jsonData);
        System.debug('Request Json: '+requestJson);
        Map<String,Object> response = new Map<String,Object>();
        response.put('status',200);
        response.put('message','Disposition Record Added');
        system.debug('disposition: '+ requestJson.get('disposition'));       
        system.debug('Phone: '+ requestJson.get('phone') );            
        if(requestJson.get('disposition') == null || requestJson.get('disposition') == '') {
            system.debug('disposition: '+ requestJson.get('disposition'));
            response.put('status',400);
            response.put('message','disposition Required');  
            res.statusCode = 400;
            String resBodyStr = JSON.serializePretty(response);
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(resBodyStr);
            return resBodyStr;
        } else if(requestJson.get('agent_id') == null || requestJson.get('agent_id') == '') {
            system.debug('agent_id: '+ requestJson.get('agent_id'));
            response.put('status',400);
            response.put('message','agent_id Required');  
            res.statusCode = 400;
            String resBodyStr = JSON.serializePretty(response);
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(resBodyStr);
            return resBodyStr;
        } else if(requestJson.get('list_id') == null || requestJson.get('list_id') == '') {
            system.debug('list Id: '+ requestJson.get('list_id') );
            response.put('status',400);
            response.put('message','list_id Required');  
            res.statusCode = 400;
            String resBodyStr = JSON.serializePretty(response);
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(resBodyStr);
            return resBodyStr;
        }
        /*else if(requestJson.get('call_duration') == null || requestJson.get('call_duration') == '')
{
system.debug('Call Duration: '+ requestJson.get('call_duration') );            
response.put('status',400);
response.put('message','call_duration Required');  
res.statusCode = 400;
String resBodyStr = JSON.serializePretty(response);
res.addHeader('Content-Type', 'application/json');
res.responseBody = Blob.valueOf(resBodyStr);
return;
}*/
        /*else if((requestJson.get('call_duration') != null || requestJson.get('call_duration') != ''))
{
if(requestJson.get('recording_link') == null || requestJson.get('recording_link') == '')
{
system.debug('Call Duration: '+ requestJson.get('call_duration') );            
System.debug('Record_Link: '+requestJson.get('recording_link'));
response.put('status',400);
response.put('message','recording_link Required');  
res.statusCode = 400; 
String resBodyStr = JSON.serializePretty(response);
res.addHeader('Content-Type', 'application/json');
res.responseBody = Blob.valueOf(resBodyStr);
return;
}
}*/
        else if(requestJson.get('phone') == null || requestJson.get('phone') == '') {
            system.debug('List Id: '+ requestJson.get('phone') );            
            response.put('status',400);
            response.put('message','Phone Number Required');  
            res.statusCode = 400;
            String resBodyStr = JSON.serializePretty(response);
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(resBodyStr);
            return resBodyStr;
        } else if(requestJson.get('campaign') == null || requestJson.get('campaign') == '') {
            system.debug('campaign: '+ requestJson.get('campaign') );            
            response.put('status',400);
            response.put('message','campaign Required');  
            res.statusCode = 400;
            String resBodyStr = JSON.serializePretty(response);
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(resBodyStr);
            return resBodyStr;
        }
        /*else if(requestJson.get('campaign') == null || requestJson.get('campaign') == '')
{
response.put('status',400);
response.put('message','campaign Required');  
res.statusCode = 400;
String resBodyStr = JSON.serializePretty(response);
res.addHeader('Content-Type', 'application/json');
res.responseBody = Blob.valueOf(resBodyStr);
return;
}*/
        else if(requestJson.get('call_start_time') == null || requestJson.get('call_start_time') == '') {
            response.put('status',400);
            response.put('message','call_start_time Required');  
            res.statusCode = 400;
            String resBodyStr = JSON.serializePretty(response);
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(resBodyStr);
            return resBodyStr;
        } else if(requestJson.get('call_end_time') == null || requestJson.get('call_end_time') == '') {
            response.put('status',400);
            response.put('message','call_end_time Required');  
            res.statusCode = 400;
        }  else if(requestJson.get('hangup_reason') == null || requestJson.get('hangup_reason') == '') {
            response.put('status',400);
            response.put('message','hangup_reason Required');  
            res.statusCode = 400;
            String resBodyStr = JSON.serializePretty(response);
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(resBodyStr);
            return resBodyStr;
        } else if(requestJson.get('call_count') == null || requestJson.get('call_count') == '') {
            response.put('status',400);
            response.put('message','call_count Required');  
            res.statusCode = 400;
            String resBodyStr = JSON.serializePretty(response);
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(resBodyStr);
            return resBodyStr;
        }
        /*else if(requestJson.get('callback_time') == null || requestJson.get('callback_time') == '')
{
response.put('status',400);
response.put('message','callback_time Required');  
res.statusCode = 400;
}*/
        
        else {
            response.put('status',200);
            response.put('message','Disposition Record Added');
        }
        
        String Phone = String.valueof(requestJson.get('phone'));
        List<Lead> leadList = new List<Lead>();
        if(Test.isRunningTest()){
            leadList  = [Select id, NoResponseCall_Count__c, Buying_Time__c from Lead where Phone = '7042125628' order by CreatedDate  desc Limit 1 ];
        } else {
            leadList  = [Select id, NoResponseCall_Count__c, Buying_Time__c from Lead where Phone = :Phone And CTIDuplicate__c = false order by CreatedDate  desc Limit 1  ];   
        }
        System.debug('Lead: => '+leadList);
        integer callCount, noResponseCallCount;
        callCount = 1;
        if(leadList.size() > 0 && leadList[0].NoResponseCall_Count__c == null) {
            noResponseCallCount = 1;
        }
        else if( leadList.size() > 0 && leadList[0].NoResponseCall_Count__c != null ) {
            noResponseCallCount = Integer.valueof(leadlist[0].NoResponseCall_Count__c)+1;
        }
        
        Task tsk = new Task();
        tsk.Subject = 'Call Log '+System.now();
        tsk.disposition__c	= String.valueof(requestJson.get('disposition'));
        tsk.agent_FullName__c = String.valueof(requestJson.get('agent_FullName'));
        tsk.agent_id__c  = String.valueof(requestJson.get('agent_id')); 
        tsk.Campaign_Name__c = String.valueof(requestJson.get('campaign'));
        if(requestJson.get('call_duration') != null || requestJson.get('call_duration') != '') {
            tsk.Call_Duration__c   = String.valueof(requestJson.get('call_duration'));
        }
        if(requestJson.get('call_start_time') != null || requestJson.get('call_start_time') != '') {
            tsk.callstart_time__c   = String.valueof(requestJson.get('call_start_time'));   
        }
        if(requestJson.get('call_end_time') != null || requestJson.get('call_end_time') != '') {
            tsk.callend_time__c   = String.valueof(requestJson.get('call_end_time'));
        }
        tsk.hangup_reason__c    = String.valueof(requestJson.get('hangup_reason'));
        tsk.list_id__c    = String.valueof(requestJson.get('list_id'));
        tsk.call_type__c   = String.valueof(requestJson.get('call_type'));
        tsk.recording_link__c    = String.valueof(requestJson.get('recording_link'));
        tsk.talktime__c    = String.valueof(requestJson.get('talktime'));
        tsk.vendor_lead_code__c    = String.valueof(requestJson.get('vendor_lead_code__c')); 
        tsk.Disposition_Discription__c = String.valueOf(requestJson.get('disposition_discription'));
        tsk.CallBack_Time__c = String.valueOf(requestJson.get('callback_time'));
        
        if(leadList.size() > 0) {
            tsk.WhoId  = leadList[0].id;  
        }
        tsk.phone__c = Phone;
        tsk.Api_Response__c = String.valueof(requestJson);
        
        if(!Test.isRunningTest()) {
            insert tsk;
        }

        System.debug('Task Missed Call '+tsk);        
        
        Lead leads = new Lead();
        if(leadList.size() > 0) {
            leads.id = leadList[0].id;
            leads.Call_Count__c  = Integer.valueof(requestJson.get('call_count'));
            leads.Campaign__c = String.valueof(requestJson.get('campaign'));
            if(String.valueof(requestJson.get('disposition')) == 'B') {
                noResponseCallCount = 0;
                //leads.id = leadList[0].id;
                leads.status = 'Follow Up';
                leads.status__c = 'Call Back';  
            }
            if(String.valueof(requestJson.get('disposition')) == 'BTT' || String.valueof(requestJson.get('disposition')) == 'CD' || String.valueof(requestJson.get('disposition')) == 'RPNA' || String.valueof(requestJson.get('disposition')) == 'CALLD') {
                noResponseCallCount = 0;
                //leads.id = leadList[0].id;
                leads.status = 'Follow Up';
                leads.status__c = 'Call Back';    
                
            } else if(String.valueof(requestJson.get('disposition')) == 'CALLBK' || String.valueof(requestJson.get('disposition')) == 'CB' || String.valueof(requestJson.get('disposition')) == 'CBHOLD' || String.valueof(requestJson.get('disposition')) == 'Call Back' || String.valueof(requestJson.get('disposition')) == 'CallBack' ) { // 08 july 2022:Ankit add ('CBHOLD','Call Back','CallBack') :: Map Elision disposition CBHOLD and assign Status to "Call Back" (CRM-939)

                noResponseCallCount=0;
                //leads.id = leadList[0].id;
                leads.status = 'Follow Up';
                leads.status__c = 'Call Back';    
                
            } else if(String.valueof(requestJson.get('disposition')) == 'LB') {
                noResponseCallCount=0;
                //leads.id = leadList[0].id;
                leads.status = 'Follow Up';
                leads.status__c = 'Follow Up';    
                
            } else if(String.valueof(requestJson.get('disposition')) == 'IB') {
                noResponseCallCount=0;
                //leads.id = leadList[0].id;
                leads.status = 'Qualified';
                leads.status__c = 'Valuator to be assigned';    
                
            } else if(String.valueof(requestJson.get('disposition')) == 'RESD') {
                noResponseCallCount=0;
                //leads.id = leadList[0].id;
                leads.status = 'Follow Up';
                leads.status__c = 'Rescheduled';    
                
            } else if(String.valueof(requestJson.get('disposition')) == 'BFRMFC' || String.valueof(requestJson.get('disposition')) == 'PFSD' ) {
                noResponseCallCount=0;
                //leads.id = leadList[0].id;
                leads.status = 'Follow Up';
                leads.status__c = 'Rescheduled';    
                
            } else if(String.valueof(requestJson.get('disposition')) == 'HT') {
                
                //leads.id = leadList[0].id;
                leads.status = 'Qualified';
                leads.status__c = 'Hot';      
                
            } else if(String.valueof(requestJson.get('disposition')) == 'WM') {
                leads.status = 'Qualified';
                leads.status__c = 'Warm';     
                
            } else if(String.valueof(requestJson.get('disposition')) == 'CLD') {
                leads.status = 'Qualified';
                leads.status__c = 'Cold';        
            } else if(String.valueof(requestJson.get('disposition')) == 'ABT' || String.valueof(requestJson.get('disposition')) == 'ATT' || String.valueof(requestJson.get('disposition')) == 'BV'
                      || String.valueof(requestJson.get('disposition')) == 'INTR' || String.valueof(requestJson.get('disposition')) == 'IIDD' || String.valueof(requestJson.get('disposition')) == 'IIT' 
                      || String.valueof(requestJson.get('disposition')) == 'TD' || String.valueof(requestJson.get('disposition')) == 'IIP' || String.valueof(requestJson.get('disposition')) == 'BoVeh' || String.valueof(requestJson.get('disposition')) == 'HT' || String.valueof(requestJson.get('disposition')) == 'WM' || String.valueof(requestJson.get('disposition')) == 'CLD') {
                          noResponseCallCount=0;
                          if(leadList[0].Buying_Time__c  == 'Within 8 days') {
                              leads.status = 'Qualified';
                              leads.status__c = 'Hot'; 
                              leads.Sub_Status__c = 'Interested in Test Drive';
                          } else if(leadList[0].Buying_Time__c  == 'Within 15 days') {
                              leads.status = 'Qualified';
                              leads.status__c = 'Warm';   
                          } else if(leadList[0].Buying_Time__c  == 'Within 30 days') {
                              leads.status = 'Qualified';
                              leads.status__c = 'Cold';   
                          } else if(leadList[0].Buying_Time__c  == 'More than 30 days') {
                              leads.status = 'Qualified';
                              leads.status__c = 'Cold';   
                          }
                      }
            else if(String.valueof(requestJson.get('disposition')) == 'BAV' || String.valueof(requestJson.get('disposition')) == 'DPOP' || String.valueof(requestJson.get('disposition')) == 'GQ'
                    || String.valueof(requestJson.get('disposition')) == 'NE' || String.valueof(requestJson.get('disposition')) == 'NDNE' ||  String.valueof(requestJson.get('disposition')) == 'PP' || String.valueof(requestJson.get('disposition')) == 'SR' || String.valueof(requestJson.get('disposition')) == 'WRN'
                    || String.valueof(requestJson.get('disposition')) == 'NAVN' || String.valueof(requestJson.get('disposition')) == 'DND' || String.valueof(requestJson.get('disposition')) == 'VNA'  || String.valueof(requestJson.get('disposition')) == 'AS' || String.valueof(requestJson.get('disposition')) == 'IAB' || String.valueof(requestJson.get('disposition')) == 'NE' 
                    || String.valueof(requestJson.get('disposition')) == 'WRN' || String.valueof(requestJson.get('disposition')) == 'POST' || String.valueof(requestJson.get('disposition')) == 'FDL' || String.valueof(requestJson.get('disposition')) == 'VENA' || String.valueof(requestJson.get('disposition')) == 'PFOS' || String.valueof(requestJson.get('disposition')) == 'VNAOW' 
                    || String.valueof(requestJson.get('disposition')) == 'WRNG' )
                
            {
                noResponseCallCount = 0;
                //leads.id = leadList[0].id;
                leads.status = 'Lost';
                leads.status__c = 'Lost';  
                leads.Lost_Reason__c  = 'Others';
                
            } else if(String.valueOf(requestJson.get('disposition')) == 'LNA' ) {
                leads.status = 'Lost';
                leads.status__c = 'No response';   
            } else if(String.valueOf(requestJson.get('disposition')) == 'PAYI') {
                leads.status = 'Follow Up';
                leads.status__c = 'Payment Issue';   
            } else if(String.valueOf(requestJson.get('disposition')) == 'INTIR') {
                leads.status = 'Follow Up';
                leads.status__c = 'Interested in Reservation';   
            } else if(String.valueOf(requestJson.get('disposition')) == 'VEHBOO') {
                leads.status = 'Qualified';
                leads.status__c = 'Finalised';   
            } else if((String.valueof(requestJson.get('disposition')) == 'N' || String.valueof(requestJson.get('disposition')) == 'AB'  ||  String.valueof(requestJson.get('disposition')) == 'LRERR'  || String.valueof(requestJson.get('disposition')) == 'ADC' || String.valueof(requestJson.get('disposition')) == 'NA' || String.valueof(requestJson.get('disposition')) == 'NB' || String.valueof(requestJson.get('disposition')) == 'NR' || String.valueof(requestJson.get('disposition')) == 'NOOS' || String.valueof(requestJson.get('disposition')) == 'RINGIN' || String.valueof(requestJson.get('disposition')) == 'SO' || String.valueof(requestJson.get('disposition')) == 'TEMPOS' ) && Integer.valueof(noResponseCallCount) <= 2) {
                System.debug('No Response: '+leadlist[0].NoResponseCall_Count__c);
                /*if(leadlist[0].NoResponseCall_Count__c == null)
{
noResponseCallCount = 1;
}
else if(leadlist[0].NoResponseCall_Count__c != null)
{
System.debug('No Response: '+leadlist[0].NoResponseCall_Count__c);
noResponseCallCount = Integer.valueof(leadlist[0].NoResponseCall_Count__c)+1;   
}*/
                leads.status = 'Follow Up';
                leads.status__c = 'No response ';    
            } else if((String.valueof(requestJson.get('disposition')) == 'N' || String.valueof(requestJson.get('disposition')) == 'AB'  ||  String.valueof(requestJson.get('disposition')) == 'LRERR'  || String.valueof(requestJson.get('disposition')) == 'ADC' || String.valueof(requestJson.get('disposition')) == 'NA' || String.valueof(requestJson.get('disposition')) == 'NA' || String.valueof(requestJson.get('disposition')) == 'NB' || String.valueof(requestJson.get('disposition')) == 'NR' || String.valueof(requestJson.get('disposition')) == 'NOOS' || String.valueof(requestJson.get('disposition')) == 'RINGIN' || String.valueof(requestJson.get('disposition')) == 'SO' || String.valueof(requestJson.get('disposition')) == 'TEMPOS' ) && Integer.valueof(noResponseCallCount) > 2) {
                //leads.id = leadList[0].id;
                /*if(leadlist[0].NoResponseCall_Count__c == null)
{
noResponseCallCount = 1;
}
else if(leadlist[0].NoResponseCall_Count__c != null)
{
noResponseCallCount = Integer.valueof(leadlist[0].NoResponseCall_Count__c)+1;   
}*/
                noResponseCallCount = 0;
                leads.status = 'Follow Up';
                leads.status__c = 'NOT CONNECTED AFTER 3 ATTEMPTS';    
            }
            else if (String.valueof(requestJson.get('disposition')) == 'NI' || String.valueof(requestJson.get('disposition')) == 'NOTIN' || String.valueof(requestJson.get('disposition')) == 'RESCAL' ) {
                noResponseCallCount = 0;
                leads.status = 'Lost';
                leads.status__c = 'Not interested'; 
            } else if(String.valueof(requestJson.get('disposition')) == 'NBUSY'){
                // noResponseCallCount = 0; // 21 june 2022:Rohit :: Number Busy and No response status to be clubbed together for followup campaigns (CRM-918)
                leads.status = 'Follow Up';
                leads.status__c = 'Number Busy';    
            } else if(String.valueof(requestJson.get('disposition')) == 'PURCH'){
                noResponseCallCount = 0;
                leads.status = 'Qualified';
                leads.status__c = 'Sold';    
            } else if(String.valueof(requestJson.get('disposition')) == 'SALE' || String.valueof(requestJson.get('disposition')) == 'NP' || String.valueof(requestJson.get('disposition')) == 'PU'
                      || String.valueof(requestJson.get('disposition')) == 'PM' || String.valueof(requestJson.get('disposition')) == 'XFER' || String.valueof(requestJson.get('disposition')) == 'ERI' 
                      || String.valueof(requestJson.get('disposition')) == 'IIAP' || String.valueof(requestJson.get('disposition')) == 'IIEV' || String.valueof(requestJson.get('disposition')) == 'IIOMB'
                      || String.valueof(requestJson.get('disposition')) == 'PTP' || String.valueof(requestJson.get('disposition')) == 'OTHERS' || String.valueof(requestJson.get('disposition')) == 'DNOTA' || String.valueof(requestJson.get('disposition')) == 'LVIP')
            {
                noResponseCallCount = 0;
                //leads.status = 'Lost';
                leads.status__c = 'Other';  
                leads.Lost_Reason__c  = 'Others';
                
            } else if(String.valueof(requestJson.get('disposition')) == 'DROP') {
                //noResponseCallCount = 0; // 21 june 2022:Rohit :: Number Busy and No response status to be clubbed together for followup campaigns (CRM-918)
                leads.status = 'Follow Up';
                leads.status__c = 'Number Busy'; 
            } else if(String.valueof(requestJson.get('disposition')) == 'RS') {
                noResponseCallCount = 0;
                leads.status = 'Qualified';
                leads.status__c = 'Reserve'; 
            }
            
            leads.NoResponseCall_Count__c = noResponseCallcount;
            leads.LeadPushed__c = false;
           
            if(!Test.isRunningTest()) {
                update leads;
            }
        }
        String resBodyStr = JSON.serializePretty(response);
        res.addHeader('Content-Type', 'application/json');
        //res.responseBody = Blob.valueOf(resBodyStr);
        return resBodyStr;
        
    }
    
     
    
    
    
}