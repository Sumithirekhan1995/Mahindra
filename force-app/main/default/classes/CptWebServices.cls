@RestResource(urlMapping='/sellerleadcreate')
global class CptWebServices {
    
    @HttpPost
    global static void getTheLeadInfo(){
        System.debug('Entering Into the class');
        LeadPushCPT.LeadCptWrapper wrapperObj = new LeadPushCPT.LeadCptWrapper();
        RestRequest req;
        RestResponse res;
        req = RestContext.request;

        LogService.requestedFrom = req.remoteAddress; // 14Mar2022:Asif :: For capturing remote Address

        res = RestContext.response;
        res.statusCode = 200; 
        String Endpoint = req.requestURI;
        String responseJsonStr = req.requestBody.toString();
        System.debug('req JSON: '+responseJsonStr);
        wrapperObj = (LeadPushCPT.LeadCptWrapper)JSON.deserialize(responseJsonStr,LeadPushCPT.LeadCptWrapper.class);
        
        System.debug('wrapperObj' + wrapperObj);
        
        if(wrapperObj != null){
            
            CptLeadUpsert.UpsertLead(wrapperObj.data,res,Endpoint);
        } 
        
    }
}