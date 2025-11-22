@isTest
public class UtilityClassTest {
    static testmethod void utilitytest(){
        List<Id> listofIdstoBlock = new List<Id>();
        Lead l = new Lead();
        //l.Dealer__c = A.Id;
        //l.Product__c = P.Id;
        l.FirstName = 'Thejas';
        l.LastName = 'Anchan';
        l.Phone = '8123567890';
        l.Email ='thejas@gmail.com';
        l.Status = 'Follow Up';
        l.LeadSource = 'Other';
        l.RecordTypeId = LeadConstants.buyerLeadRecordTypeId ;
        insert l;
        
        l.status ='Follow up' ;
        update l;
        
        listofIdstoBlock.add(l.Id);
     
        
        UtilityClass.getMapOfObjectApiNameAndLabel();
        UtilityClass.lockRecords(listofIdstoBlock);
        UtilityClass.unLockRecords(listofIdstoBlock);
        
    }

}