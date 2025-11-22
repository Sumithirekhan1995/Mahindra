public class reUsableMultiSelectLookupCtrl {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList, String displayFieldAPIName) {
        String searchKey = '%' + searchKeyWord + '%';
        String fieldName = 'Name';
        
        if(displayFieldAPIName != null && displayFieldAPIName != ''){
            fieldName = displayFieldAPIName;
        }
        System.debug('fieldName' + fieldName);
        List < sObject > returnList = new List < sObject > ();
 
        List<string> lstExcludeitems = new List<string>();
        for(sObject item : ExcludeitemsList ){
            lstExcludeitems.add(item.id);
        }
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records  
        String sQuery = '';
        String dealerFilter = '';
        if(ObjectName == 'account'){
            String dealer = 'Dealer';
			dealerFilter = ' AND RecordType.Name=:'+dealer+' ';        
        }
        sQuery =  'select id, '+fieldName+' from ' +ObjectName + ' where '+fieldName+' LIKE: searchKey AND Id NOT IN : lstExcludeitems '+dealerFilter+' order by '+ fieldName +'';
        System.debug('sQuery' + sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
       
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        
        System.debug('returnList' + returnList);
        return returnList;
    }
}