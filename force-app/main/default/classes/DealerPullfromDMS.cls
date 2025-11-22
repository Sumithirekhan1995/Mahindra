/**
* LastModifiedDate 23Dec2021
* lastModifiedBy Sarthak
* Added batch functionality while upserting Contacts and Account Records
* 
* 
*/

public class DealerPullfromDMS implements Schedulable, Database.AllowsCallouts, Database.Batchable<sObject>  {
    
    public static void getDealerInfo() {
        Database.executebatch(new DealerPullfromDMS(), 200);
    }
    
    public void execute(SchedulableContext SC) {
        Database.executebatch(new DealerPullfromDMS(), 200);
    }
    
    public List<sObject> start(Database.BatchableContext context) {
        // getting data from API
        String dealerArrStr = getDealerAPI();
        
        // retrying
        if(dealerArrStr == null) {
            return new List<sObject>();
        }
        // proccessing 
        Map<String, Object> processedData = processData(dealerArrStr);
        List<sObject> recordArr = new List<sObject>();
        List<String> accCodeArr = new List<String>();
        if(processedData.get('Account') != null) {
            List<sObject> accountArr = (List<sObject>)processedData.get('Account');
            for(Account a : (List<Account>)accountArr) {
                if(a.Code__c != null) {
                    accCodeArr.add(a.Code__c);
                }
            }
            recordArr.addAll(accountArr);
        }
        if(processedData.get('Contact') != null) {
            recordArr.addAll((List<sObject>)processedData.get('Contact'));
        }
        
        // deactivation for dealer
        Id dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        List<Account> accArrToDeactivate = [SELECT Id, Active__c FROM Account WHERE RecordTypeId = :dealerRecordTypeId AND Code__c NOT IN :accCodeArr AND Active__c = true LIMIT 45000];
        if(!accArrToDeactivate.isEmpty()) {
            List<Account> accs = new List<Account>();
            for(Account a : accArrToDeactivate) {
                accs.add(new Account(
                    Id = a.Id,
                    Active__c = false
                ));
            }
            recordArr.addAll((List<sObject>)accs);
        }        
        return recordArr;
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> recordList) {
        List<Account> accountArr = new List<Account>();
        List<Contact> contactArr = new List<Contact>();
        for(sObject obj : recordList) {
            Schema.sObjectType objType = obj.getSObjectType();
            if(objType == Account.sObjectType) {
                accountArr.add((Account)obj);
            } else {
                contactArr.add((Contact)obj);
            }
        } 
        System.debug('accountArr: ' + accountArr.size());
        System.debug('contactArr: ' + contactArr.size());
        
        // upserting
        List<Database.UpsertResult> upsertResultArr = new List<Database.UpsertResult>();
        if(!accountArr.isEmpty()) {
            Database.UpsertResult[] result = Database.upsert(accountArr, Account.fields.Code__c, false);
            upsertResultArr.addAll(result);
        } 
        if(!contactArr.isEmpty()){
            Database.UpsertResult[] result = Database.upsert(contactArr, Contact.fields.Contact_External_Id__c, false);
            upsertResultArr.addAll(result);
        }
        
        Integer successCount = 0;
        Integer errorCount = 0;
        for(Database.UpsertResult res : upsertResultArr){
            if(res.isSuccess()) {
                successCount++;
                continue;
            }
            errorCount++;
            
            for(Database.Error err : res.getErrors()){
            }
        }
        System.debug('successCount: ' + successCount);
        System.debug('errorCount: ' + errorCount);
        
    } 
    
    public void finish(Database.BatchableContext BC) {
        AsyncApexJob apexJob = [Select TotalJobItems, Status From AsyncApexJob WHERE id = :BC.getJobId()];
        System.debug('apexJob: ' + apexJob);
        if(apexJob.TotalJobItems == 0) {
            System.debug('Retrying...');
            retry();
        }
    }
    
    // retry Dealer Pull
    public void retry() {
        System.debug('DealerPullfromDMS.retry ::');
        final String JOB_NAME = 'DealerPullfromDMS_Retry'; // Job Name
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
                System.schedule(scheduleName, nextFireTime, new DealerPullfromDMS());
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
    
    // dealer pull api
    public String getDealerAPI() {
        System.debug('DealerPullfromDMS.getDealerAPI::');
        try {
            // getting endpoints
            List<Get_API_Calls__c> listGetApi = Get_API_Calls__c.getall().values();
            List<GetAuthorizationToken__c> listAuth = GetAuthorizationToken__c.getall().values();
            String username;
            String password;
            for(GetAuthorizationToken__c ga : listAuth){
                if(ga.Name == 'DealerStockDMS'){
                    username = ga.Username__c ;
                    password = ga.Password__c ;
                }
            }
            String dataEndPoint;
            String authEndPoint;
            for(Get_API_Calls__c gp: listGetApi) {
                if(gp.Name == 'Get Token') {
                    authEndPoint = gp.End_Point__c;
                } else if(gp.Name == 'Get Dealer') {
                    dataEndPoint = gp.End_Point__c; 
                }
            }
            // making Auth Call
            String headerKey = 'Authorization';
            String headerVal = 'BASIC ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password));
            HttpResponse authResponse = requestHander('POST', authEndPoint, null, headerKey, headerVal, 120000);
            System.debug('authResponse: ' + authResponse);
            
            if(authResponse.getStatusCode() != 200){
                System.debug('Failed At authResponse');
                LogService.createApiLogs(dataEndPoint, 'REQUEST_METHOD_GET', authResponse.getBody(), 'Failed', 'Dealer Auth API');
                FinanceLeadCallout.notifyError('Dealer Auth API', authResponse.getStatus() + ' ' + authResponse.getBody());
                return null;
            }
            String authToken = authResponse.getHeader('Token');             
            
            // making data call
            headerKey = 'Token';
            headerVal = authToken;
            HttpResponse dataResponse = requestHander('GET', dataEndPoint, null, headerKey, headerVal, 120000);
            System.debug('dataResponse: ' + dataResponse);
            
            if(dataResponse.getStatusCode() != 200){
                System.debug('Failed at Data Response');
                LogService.createApiLogs(dataEndPoint, 'REQUEST_METHOD_GET', dataResponse.getBody(), 'Failed', 'Dealer Pull API');
                FinanceLeadCallout.notifyError('Dealer Pull API', dataResponse.getStatus() + ' ' + dataResponse.getBody());
                return null;
            }
            
            // processing data
            return dataResponse.getBody();
        } catch(Exception e) {
            System.debug('CAUGHT_EXCEPTION ' + e);
            String exceptionMsg = 'EXCEPTION: Type: ' + e.getTypeName() + ', Message: ' + e.getMessage() + ', LineNumber: ' + e.getLineNumber();
            LogService.createApiLogs('DealerPull', 'REQUEST_METHOD_GET', exceptionMsg, 'Failed' ,  'Dealer Pull API');
            FinanceLeadCallout.notifyError('Dealer Pull', exceptionMsg);
            return null;
        }
    }
    
    // dealer/ contact objection creation helper
    public  Map<String, Object> processData(String dealerDataArrStr){
        System.debug('DealerPullfromDMS.processData::');
        DealerFromMFC dealerObjArr = (DealerFromMFC)JSON.deserialize(dealerDataArrStr, DealerFromMFC.class);
        
        List<Contact> ContactsSalesToUpsert = new List<Contact>();
        List<Account> DealersToUpsert = new List<Account>();
        
        Id dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        for (cls_data item: dealerObjArr.data) {
            Account dealer = new Account();
            
            dealer.Code__c = item.code;
            dealer.Name = item.name;
            dealer.BillingStreet = item.Address;
            dealer.BillingCity = item.City;
            dealer.BillingState = item.State;
            dealer.BillingPostalCode = item.Pincode;
            dealer.Phone = item.Mobile;
            dealer.Exotel_Landing_Number__c = item.ExotelNumber;
            
            // 16Nov2021:Sarthak:Start :: Adding new fields mappings
            dealer.SellingEmail__c = item.SellingEmail;
            
            dealer.Area_Manager_Name__c = item.AreaManagerName;
            dealer.Area_Manager_Email__c = item.AreaManagerEmail;
            dealer.Area_Manager_Mobile_Number__c = item.AreaManagerMobileNumber;
            dealer.Area_Manager_Zone__c = item.Zone;
            
            dealer.ZM_Name__c = item.ZMName;
            dealer.ZM_Email__c = item.ZMEmail;
            dealer.ZM_Mobile_Number__c = item.ZMMobileNumber;
            
            dealer.State_Head_Name__c  = item.SMName;
            dealer.State_Head_Email__c = item.StateHeadEmail;
            dealer.State_Head_Mobile_Number__c = item.StateHeadMobileNumber;
            // 16Nov2021:Sarthak:End
			
			
			// 25 july 2022 :: Rohit : Addin	g New Field :Map Store head and Ops head email ID from dealer API(CRM-843)	
            dealer.Store_Head_Email__c = item.SuperstoreManagerEmail;	
            dealer.Operations_Head_Email__c = item.OpsHeadEmail;	
             //25 july 2022 ::Rohit end
            
            dealer.Dealer_Email__c = item.Email;
            dealer.Dealer_Sales_Email__c = item.SellingEmail;
            dealer.RecordTypeId = dealerRecordTypeId;
            dealer.Active__c = true;
            
            Account dealerReference = new Account(
                Code__c = item.code
            );
            
            if(item.AreaManagerName != null && item.AreaManagerMobileNumber != null){
                Contact con = new Contact();
                con.Account = dealerReference;
                con.LastName = item.AreaManagerName;
                con.Phone = item.AreaManagerMobileNumber;
                con.Contact_External_Id__c = item.AreaManagerName + item.AreaManagerMobileNumber;
                con.Department = 'Area Manager';
                ContactsSalesToUpsert.add(con);
            }
            if(item.ZMName != null && item.ZMMobileNumber != null){
                Contact con = new Contact();
                con.Account = dealerReference;
                con.LastName = item.ZMName;
                con.Phone = item.ZMMobileNumber;
                con.Contact_External_Id__c = item.ZMName + item.ZMMobileNumber;
                con.Department = 'Zonal Manager';
                ContactsSalesToUpsert.add(con);
            }
            
            for(cls_DealerSalesExecutives c1 : item.DealerSalesExecutives){
                Contact con = new Contact();
                con.Account = dealerReference;
                con.LastName = c1.ExecutiveName;
                con.Phone = c1.ExecutiveMobile;
                con.Dealer_Code__c = item.code;
                con.Contact_External_Id__c = item.code + c1.ExecutiveMobile;
                con.Department = 'Sales';
                ContactsSalesToUpsert.add(con);
            }
            for(cls_DealerProcurementExecutives c2 : item.DealerProcurementExecutives){
                Contact con = new Contact();
                con.Account = dealerReference;
                con.LastName = c2.ExecutiveName;
                con.Phone = c2.ExecutiveMobile;
                con.Dealer_Code__c = item.code;
                con.Contact_External_Id__c = item.code + c2.ExecutiveMobile;
                con.Department = 'Procurement';
                ContactsSalesToUpsert.add(con);
                
            }
            DealersToUpsert.add(dealer);
        }
        Map<String, Object> processedData = new Map<String, Object>();
        processedData.put('Account', DealersToUpsert);
        processedData.put('Contact', ContactsSalesToUpsert);
        return processedData;
    }
    
    // http callout helper
    public  HttpResponse requestHander(String requestType,String requestUrl, String requestBody,String headerKey, String headerVal, Integer timeOut){
        System.debug('DealerPullfromDMS.requestHander::');
        System.debug('requestType: ' + requestType);
        System.debug('requestUrl: ' + requestUrl);
        System.debug('requestBody: ' + requestBody);
        System.debug('timeOut: ' + timeOut);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse response = new HttpResponse();
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
            response.setStatus('ExceptionHappened');
            response.setBody(exceptionMsg);
        }
        System.debug('HTTP_RESPONSE ' + response);
        return response;
    }
    
    // wrapper classes
    public class DealerFromMFC{
        public String status;	
        public String message;	
        public cls_data[] data;
        
        public DealerFromMFC parse(String json){
            return (DealerFromMFC) System.JSON.deserialize(json, DealerFromMFC.class);
        }
    }
    class cls_Data {	
        public String Code;	
        public String Name;	
        public String Address;	
        public String ContactName;	
        public String Pincode;	
        public String City;	
        public String State;	
        public String Mobile;	
        public String DealerContact;	
        public String Latitude;	
        public String Longitude;	
        public String Email;	
        public String SellingEmail;	
        public String AreaManagerName;
        public String AreaManagerMobileNumber;
        public String ZMName;
        public String ZMMobileNumber;
        public String ExotelNumber;
        
        // 16Nov2021:Sarthak:Start
        public String AreaManagerEmail;
        public String Zone;
        public String ZMEmail;
        public String StateHeadEmail;
        public String SMName;
        public String StateHeadMobileNumber;
        // 16Nov2021:Sarthak:End

        // 25July2022:Rohit:Start :: Adding New Field :Map Store head and Ops head email ID from dealer API(CRM-843)
        public string SuperstoreManagerEmail;
        public string OpsHeadEmail;
        // 25July2022:Rohit:End

        public cls_DealerSalesExecutives[] DealerSalesExecutives;	
        public cls_DealerProcurementExecutives[] DealerProcurementExecutives;	
    }	
    class cls_DealerSalesExecutives {	
        public String ExecutiveName;	
        public String ExecutiveMobile;	
    }	
    class cls_DealerProcurementExecutives {	
        public String ExecutiveName;	
        public String ExecutiveMobile;	
    }
    
}