/*
 * Class created by Deepali
 * Purpose: To provide log records for capturing exceptions and providing info about error records 
*/
public class LogService {
    
    // 14Mar2022:Asif:Start :: For capturing 
    public static String requestedFrom;
    // 14Mar2022:Asif:End

    //added by Deepali
    //Purpose: To insert log records with tag and, error message and source info
    public static void insertGenericErrorLog(Exception e,String source,String category){
       Log__c log = new Log__c();
        log.Tag__c = category;
        String msg = 'Error Message: ' + e.getMessage() + '\n LineNumber: ' + e.getLineNumber() + '\n Exception Type: ' + e.getTypeName() + '\n Cause: ' + e.getCause() + '\nStack Trace ' + e.getStackTraceString();
        log.message__c = msg;
        log.Source__c=source;
        insert log;        
    }  
    
    //added by Deepali
    //Purpose: To insert log records with tag and, error message, source and error records info
    public static void insertGenericErrorLog(Exception e,String source,String category, String errorRecords){
        Log__c log = new Log__c();
        log.Tag__c = category;
        String msg = 'Error Message: ' + e.getMessage() + '\n LineNumber: ' + e.getLineNumber() + '\n Exception Type: ' + e.getTypeName() + '\n Cause: ' + e.getCause() + '\nStack Trace ' + e.getStackTraceString();
        log.message__c = msg;
        log.Source__c=source;
        log.Error_Records__c = errorRecords;
        insert log;        
    }  
  
    
    //Purpose: To insert api log records with Endpoint, Request Body, Response Body, Status and tag info
    //For Call out
    public static void createApiLogs(String endPoint,String requestBody,String responseBody,String status,String tag){
        API_Log__c apiLog=new API_Log__c();
        apiLog.Endpoint__c= endPoint;
        apiLog.Request_Body__c=requestBody;
        apiLog.Response_Body__c=responseBody;
        if(responseBody.contains('Fail') || responseBody.contains('Error') || responseBody.contains('error') || responseBody.contains('Attempt to de-reference')){
            apiLog.Status__c= 'Failed';
        }else{
            apiLog.Status__c= 'Success';
        }
        apiLog.Tag__c = tag;
        apiLog.Requested_From__c = requestedFrom; // 14Mar2022:Asif :: For capturing IP of Client

        Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.allowFieldTruncation = true;
        System.debug('LogService.createApiLogs apiLog :: ' + apiLog);
		Database.insert(apiLog, dmo);
      //  insert apiLog;
    }
    
    
    public static API_Log__c createApiLogs(String endPoint,String requestBody,String responseBody,String status,String tag,String leadId,Boolean isInsert){
        System.debug('LogService.createApiLogs :: ');
        List<API_Log__c> apiInsertList = new List<Api_Log__c>();
        API_Log__c apiLog=new API_Log__c();
        if(leadId !=null) {
            if(leadId.startsWith('00Q')) {
                apiLog.Lead__c = leadId;
                system.debug('leadId'+leadId);
                system.debug('This is lead Id');
            } else if(leadId.startsWith('006')) {
                apiLog.Opportunity__c = leadId;
                system.debug('OppId'+leadId);
                system.debug('This is Opportunity Id');
            }
        }

        apiLog.Endpoint__c= endPoint;
        apiLog.Request_Body__c=requestBody;
        apiLog.Response_Body__c=responseBody;
        if((responseBody.contains('Fail') || responseBody.contains('Error') || responseBody.contains('error') || responseBody.contains('Attempt to de-reference')) && status == null){
            apiLog.Status__c= 'Failed';
        }else{
            apiLog.Status__c= status;
        }
        apiLog.Tag__c = tag;
        apiLog.Requested_From__c = requestedFrom; // 14Mar2022:Asif :: For capturing IP of Client
        
        System.debug('apiLog.Lead__c :' + apiLog.Lead__c);
        System.debug('apiLog.Opportunity__c :' + apiLog.Opportunity__c);
        if(isInsert){
            apiInsertList.add(apiLog);
            createApiLogs(apiInsertList);
        } else {
            return apiLog;
        }
        return apiLog;
    }  
    
    public static Api_Log__c createApiLogs(String failedRec, String Status, String tag){
        Api_Log__c api = new Api_Log__c();
        api.Response_Body__c = failedRec;
        api.Status__c = 'Failed';
        api.Tag__c = tag;
        return api;
    }
    
    //Added By Aravindan
    public static void createApiLogs(List<API_Log__c>  ApiList){
        System.debug('inserting into DB apiLog.size :'+ ApiList.size());
        System.debug('Logs : ' + ApiList);
        if(ApiList.size() > 0){
            Database.insert(ApiList,False);
            System.debug('_APILog_INSERTED_');
        }
    }
    
}