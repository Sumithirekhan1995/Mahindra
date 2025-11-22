//Added by Aravindan

@isTest
public class reUsableMultiSelectLookupCtrlTestClass {
    
    public static testmethod void reUsableTest(){
        
        List<sObject> Obj = new List<sObject>();
     	reUsableMultiSelectLookupCtrl.fetchLookUpValues('searchKeyWord','Account',Obj,'Name');
        
    }

}