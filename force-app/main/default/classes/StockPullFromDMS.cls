global class StockPullFromDMS  implements Database.AllowsCallouts, Schedulable {
    
    global void execute(SchedulableContext sc) {
        getStockInfo();
    }
    
    // 10Nov2021:Sarthak:Start 
    /*
* Added Retry Funcationality.
* Using API_Log__c Object to have record of previous scheduled JobId and retryCount 
* 		(because every time Scheduled job has new context which initialises all new static variable as well.), 
* 		to query again after next retry and ABORT previous job, have retry counts track.
*/
    
    public static Boolean isSuccess = false;
    public static final Integer RETRY_LIMIT = 2;
    public static final Integer RETRY_DELAY_MIN = 2;
    public static final String apiLogTag = 'StockPullFromDMS_RetryJob';
    
    public static void finalize(){
        System.debug('StockPullFromDMS.finalize ::');
        final String JOB_NAME = 'StockPullfromDMS_Retry'; // Job Name
        try {
            final Integer RETRY_DELAY_MIN = 2;
            final Integer RETRY_LIMIT = 2;
            Integer retryCount = 0;
            // Aborting previous jobs            
            for(CronTrigger c : Database.query('SELECT Id, CronJobDetail.Name from CronTrigger WHERE CronJobDetail.Name LIKE \'%' + JOB_NAME + '%\'')) {
                String cronJobName = c.CronJobDetail.Name;
                retryCount = Integer.valueOf(cronJobName.split('__')[0].replaceAll(JOB_NAME + '_',''));
                System.abortJob(c.Id);
            }
            retryCount++;
            
            // Rescheduling 
            if(RETRY_LIMIT >= retryCount) {
                System.debug('Retrying ' + retryCount + '/' + RETRY_LIMIT);
                System.debug('Rescheduled again after ' + RETRY_DELAY_MIN + ' min');
                String hour = String.valueOf(Datetime.now().hour());
                String min = String.valueOf(Datetime.now().minute() + RETRY_DELAY_MIN); 
                String ss = String.valueOf(Datetime.now().second());
                
                //parse to cron expression
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                String scheduleName = JOB_NAME +'_' + retryCount + '__' + DateTime.now().addMinutes(RETRY_DELAY_MIN).format('YYYYMMddHHmmss');
                System.debug('scheduleName: ' + scheduleName);
                System.schedule(scheduleName, nextFireTime, new StockPullFromDMS());
            } else {
                System.debug('Retry Limit Exceeded');
            }
            
        } catch(Exception e) {
            System.debug('Exception: ' + e);
            for(CronTrigger c : Database.query('SELECT Id from CronTrigger WHERE CronJobDetail.Name LIKE \'%' + JOB_NAME + '%\'')) {
                System.abortJob(c.Id);
            }
        } 
    }
    // 10Nov2021:Sarthak:End
    
    @future(Callout = true)
    public static void getStockInfo() {
        System.debug('StockPullFromDMS.getStockInfo ::');
        String query;
        String EndPoint;
        String AuthEndPoint;
        Datetime startDate;
        Datetime endDate;
        String username;
        String password;
        String headerType;
        Blob headerValue;
        String headerContent;
        String Token;
        String uniqueCode;
        
        try {
            List<Get_API_Calls__c> listGetApi = Get_API_Calls__c.getall().values();
            List<GetAuthorizationToken__c> listAuth = GetAuthorizationToken__c.getall().values();
            
            // 11Oct2021:Sarthak:Start
            if(listGetApi.size() == 0 || listAuth.size() == 0) {
                isSuccess = false;
                finalize();
                return;
            }
            // 11Oct2021:Sarthak:End
            
            for(GetAuthorizationToken__c ga : listAuth){
                if(ga.Name == 'DealerStockDMS'){
                    username = ga.Username__c ;
                    password = ga.Password__c ;
                }
            }
            for(Get_API_Calls__c gp: listGetApi) {
                if(gp.Name == 'Get Token') {
                    AuthEndPoint = gp.End_Point__c;
                }
                if(gp.Name == 'Get Stock') {
                    EndPoint = gp.End_Point__c; 
                } 
            }
            
            //Get Auth Token in the first Callout
            headerType = 'Authorization';
            headerValue = Blob.valueOf(username + ':' + password);
            headerContent = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            
            // 11Oct2021:Sarthak:Start
            HttpResponse responseToken = requestHander('POST', AuthEndPoint, null, headerType, headerContent, 120000);
            if(responseToken.getStatusCode() != 200){
                LogService.createApiLogs(AuthEndPoint, 'REQUEST_METHOD_GET', responseToken.getBody(), 'Failed', 'Stock Auth API');
                FinanceLeadCallout.notifyError('Stock Auth API', 'AuthResponse Status [' + responseToken.getStatus() + '] Body [' + responseToken.getBody() + ']');
                
                isSuccess = false;
                finalize();
                return;
            }
            System.debug('StockAuth ResponseBody ' + responseToken.getBody());

            // 11Oct2021:Sarthak:End
            Token = responseToken.getHeader('Token');
           
            // 11Oct2021:Sarthak:Start
            if(Token == null) {
                LogService.createApiLogs(AuthEndPoint, 'REQUEST_METHOD_GET', 'AuthToken : ' + Token, 'Failed', 'Stock Auth API');
                FinanceLeadCallout.notifyError('Stock Auth API', 'AuthToken: ' + Token + ' AuthResponse Body [' + responseToken.getBody() + ']');
                
                isSuccess = false;
                finalize();
                return;
            }
            // 11Oct2021:Sarthak:End
            
            headerType = 'Token';
            headerContent = Token;
            
            // if auth success making actual call for Stock
            
            // gen unique code
            String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
            uniqueCode = EncodingUtil.convertToHex(hash);
            system.debug('uniqueCode ' + uniqueCode);
            
            if(startDate != null){
                EndPoint += '?dateStamp=' + startDate.year() + '-' + startDate.month() + '-' + startDate.day();
            }
            // 11Oct2021:Sarthak:Start
            HttpResponse response = requestHander('GET', EndPoint, null, headerType, headerContent, 120000);
            if(response.getStatusCode() != 200){
                LogService.createApiLogs(EndPoint, 'REQUEST_METHOD_GET', response.getBody(), 'Failed', 'Stock Pull API');
                FinanceLeadCallout.notifyError('Stock Pull API', 'StockPull Status: [' + response.getStatus() + '] Body [' +  response.getBody() + ']');
                
                isSuccess = false;
                finalize();
                return;
            }
            System.debug('Stock Pull ' + response.getBody());
            // 11Oct2021:Sarthak:Start
            
            System.debug('Stock ResponseBody ' + response.getBody());
            isSuccess = DealerStockProcessController.processStockData(response, uniqueCode);
            if(isSuccess) {
                finalize();
            }
            
        } catch(Exception e) {
            
            // 11Oct2021:Sarthak:Start
            System.debug('CAUGHT_EXCEPTION ' + e);
            String exceptionMsg = 'EXCEPTION: Type: ' + e.getTypeName() + ', Message: ' + e.getMessage() + ', LineNumber: ' + e.getLineNumber();
            LogService.createApiLogs(EndPoint, 'REQUEST_METHOD_GET', exceptionMsg, 'Failed' ,  'Stock Pull API');
            FinanceLeadCallout.notifyError('StockPullFromDMS', exceptionMsg);
            isSuccess = false;
            if(isSuccess) {
                finalize();
            }
            // 11Oct2021:Sarthak:End
        } 
    }
    
    // 11Oct2021:Sarthak:Start
    public static HttpResponse requestHander(String requestType,String requestUrl, String requestBody,String headerKey, String headerVal, Integer timeOut){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse response = null;
        try{
            req.setMethod(requestType);
            req.setEndpoint(requestUrl);
            req.setTimeout(timeOut);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Content-Length', '0');
            req.setHeader('Accept', 'application/json');
            req.setHeader(headerKey, headerVal);
            if(requestBody != null){
                req.setBody(requestBody);
            }
            if(timeOut != null){
                req.setTimeout(timeOut);
            }
            response = h.send(req);           
        } catch(Exception e) {
            System.debug('CAUGHT_EXCEPTION');
            String exceptionMsg = 'EXCEPTION: Type: ' + e.getTypeName() + ', Message: ' + e.getMessage() + ', LineNumber: ' + e.getLineNumber();
            System.debug('exceptionMsg: ' + exceptionMsg);
            response.setStatusCode(500);
            response.setStatus('CAUGHT_EXCEPTION');
            response.setBody(exceptionMsg);
        }
        System.debug('HTTP_RESPONSE ' + response);
        return response;
    }
    // 11Oct2021:Sarthak:End
}