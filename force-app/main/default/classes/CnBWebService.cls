/*
 * Webservice Class for Lead CnB
 * Last Modified by Soumya on 06/10/2020
*/

@RestResource(urlMapping='/cnbleadupsert')
global class CnBWebService {
    
    @HttpPost
    global static void getTheLeadInfo(){
        System.debug('Entering Into the class');
        CnBLeadWrapperClass wrapperObj = new CnBLeadWrapperClass();
        RestRequest req;
        RestResponse res;
        req = RestContext.request;

        LogService.requestedFrom = req.remoteAddress; // 14Mar2022:Asif :: For capturing remote Address

        res = RestContext.response;
        res.statusCode = 200; 
        String Enpoint = req.requestURI;
        String responseJsonStr = req.requestBody.toString();
        system.debug('responseJsonStr '+responseJsonStr);
        wrapperObj = (CnBLeadWrapperClass)JSON.deserialize(responseJsonStr,CnBLeadWrapperClass.class);
        
        System.debug('wrapperObj' + wrapperObj);
        
        if(wrapperObj != null){
            
            CnBLeadUpsert.upsertCnBLead(wrapperObj.data,res,Enpoint);
            System.debug('rest response' + res.responseBody.toString());
        } 
        
    }
}