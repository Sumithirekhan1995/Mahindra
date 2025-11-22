public class UtilityClass {
    
    public static Map<String,String> getMapOfObjectApiNameAndLabel(){
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();    
        Map<String,String> objName = new Map<String,String>();
        for(Schema.SObjectType f : gd)
        {
            
                objName.put(f.getDescribe().getName(), f.getDescribe().getLabel());
     
        }
        return objName;
    }
       public static void lockRecords(List<ID> listBeLocked) {
        try { 
            Approval.LockResult[] lrList = Approval.lock(listBeLocked, false);
            for (Approval.LockResult lr : lrList) {
                if (lr.isSuccess() &&  !Test.isRunningTest()) {
                    System.debug('Successfully locked SObject with ID: ' + lr.getId());
                } else {
                    
                    String errorRecords = '';
                    System.debug('not locked');
                    for (Database.Error err : lr.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug(' Fields that affected this error: ' + err.getFields());
                        errorRecords = errorRecords + 'getStatusCode :: '+err.getStatusCode() + ': getMessage :: ' + err.getMessage() + ' Fields that affected this error: ' + err.getFields();
                    }    
                }
            }
        }
        Catch (Exception e) {
            System.debug('Error Message: ' + e.getMessage() + '\n LineNumber: ' + e.getLineNumber() + '\n Exception Type: ' + e.getTypeName() + '\n Cause: ' + e.getCause() + '\nStack Trace ' + e.getStackTraceString());
            
        }
    }
    public static void unLockRecords(List<ID> listBeLocked) {
        try { 
            Approval.UnLockResult[] lrList = Approval.unlock(listBeLocked, false);
            for (Approval.UnLockResult lr : lrList) {
                if (lr.isSuccess() &&  !Test.isRunningTest()) {
                    System.debug('Successfully locked SObject with ID: ' + lr.getId());
                } else {
                    
                    String errorRecords = '';
                    System.debug('not locked');
                    for (Database.Error err : lr.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug(' Fields that affected this error: ' + err.getFields());
                        errorRecords = errorRecords + 'getStatusCode :: '+err.getStatusCode() + ': getMessage :: ' + err.getMessage() + ' Fields that affected this error: ' + err.getFields();
                    }    
                }
            }
        }
        Catch (Exception e) {
            System.debug('Error Message: ' + e.getMessage() + '\n LineNumber: ' + e.getLineNumber() + '\n Exception Type: ' + e.getTypeName() + '\n Cause: ' + e.getCause() + '\nStack Trace ' + e.getStackTraceString());
            
        }
    }
}