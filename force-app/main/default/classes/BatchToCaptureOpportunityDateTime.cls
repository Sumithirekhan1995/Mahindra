global class BatchToCaptureOpportunityDateTime implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id, Warranty_end_date__c, Warr_EndDate__c, Warranty_start_date__c, warr_startdate__c, Warranty_Punched_Date__c,'+
            'Warr_PunchedDate__c from opportunity where Warranty_end_date__c != null or Warranty_start_date__c != null or Warranty_Punched_Date__c != null';
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        for(Opportunity o : oppList) {        
            if(o.Warranty_End_Date__c != null){
               if(Pattern.matches('[0-9]{1,2}/[0-9]{1,2}/[0-9]{4} [0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2} [a-zA-Z]{2}',o.Warranty_End_Date__c)){
                	List<String> mainStr = o.Warranty_End_Date__c.split(' ');
                	List<String> timeStr = mainStr[1].split(':');
                	String d1 = mainStr[0]+', '+timeStr[0]+':'+timeStr[1]+' '+mainStr[2];
                	system.debug('dstr '+d1);
                	DateTime dt1 = DateTime.parse(d1);
                	system.debug('d'+dt1);
                   o.Warr_EndDate__c = dt1;
            	}else if(Pattern.matches('[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}',o.Warranty_End_Date__c)){
                    //convert the 30-06-2019 - dd-mm-yyyy to datetime, mm/dd/yyyy
                    List<String> sre = o.Warranty_End_Date__c.split('-');
                    Datetime dt = Datetime.newInstance(Integer.valueOf(sre[2]), Integer.valueOf(sre[1]), Integer.valueOf(sre[0]));
                    o.Warr_EndDate__c = dt;
                }
            }
            if(o.Warranty_Start_Date__c != null){
                if(Pattern.matches('[0-9]{1,2}/[0-9]{1,2}/[0-9]{4} [0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2} [a-zA-Z]{2}',o.Warranty_start_Date__c)){
                    List<String> mainStr1 = o.Warranty_Start_Date__c.split(' ');
                    List<String> timeStr1 = mainStr1[1].split(':');
                    String d2 = mainStr1[0]+', '+timeStr1[0]+':'+timeStr1[1]+' '+mainStr1[2];
                    system.debug('dstr '+d2);
                    DateTime dt2 = DateTime.parse(d2);
                    system.debug('d'+dt2);
                    o.Warr_StartDate__c = dt2;
                }
                 else if(Pattern.matches('[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}',o.Warranty_Start_Date__c)){
                    //convert the 30-06-2019 - dd-mm-yyyy to datetime, mm/dd/yyyy
                    List<String> sre1 = o.Warranty_Start_Date__c.split('-');
                    Datetime dt1 = Datetime.newInstance(Integer.valueOf(sre1[2]), Integer.valueOf(sre1[1]), Integer.valueOf(sre1[0]));
                    o.Warr_StartDate__c = dt1;
                 }
            }
            if(o.Warranty_Punched_Date__c != null){
                if(Pattern.matches('[0-9]{1,2}/[0-9]{1,2}/[0-9]{4} [0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2} [a-zA-Z]{2}',o.Warranty_Punched_Date__c)){
                    List<String> mainStr2 = o.Warranty_Punched_Date__c.split(' ');
                    List<String> timeStr2 = mainStr2[1].split(':');
                    String d3 = mainStr2[0]+', '+timeStr2[0]+':'+timeStr2[1]+' '+mainStr2[2];
                    system.debug('dstr '+d3);
                    DateTime dt3 = DateTime.parse(d3);
                    system.debug('d'+dt3);
                    o.Warr_PunchedDate__c = dt3;
                }
                 else if(Pattern.matches('[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}',o.Warranty_Punched_Date__c)){
                    //convert the 30-06-2019 - dd-mm-yyyy to datetime, mm/dd/yyyy
                    List<String> sre2 = o.Warranty_Punched_Date__c.split('-');
                    Datetime dt2 = Datetime.newInstance(Integer.valueOf(sre2[2]), Integer.valueOf(sre2[1]), Integer.valueOf(sre2[0]));
                    o.Warr_PunchedDate__c = dt2;
                 }
            }
        }
        try {
            list<Database.SaveResult> dr = Database.update(oppList, false);
            
        } catch(Exception e) {
            System.debug(e);
        }
    } 
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Executed Successfully');
        
    }
}