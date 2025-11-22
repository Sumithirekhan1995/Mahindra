public with sharing class VFController {
    public String inputOne{get;set;}
    public String inputTwo{get;set;}
    
    public List<Lead> leadList1{get;set;}
	//public List<Lead> leadList1; 
   /* public List<Lead> getLeadList(){
        return leadList1;
    }
    public void setLeadList(List<Lead> leadList){
        this.leadList1=leadList;
    }*/
    public VFController(){
        
        
    }
   
    
    public void submit(){
    Datetime dt1=Datetime.parse(inputOne);
        Datetime dt2=Datetime.parse(inputTwo);
       leadList1 = [Select id, FirstName, LastName, Phone,HI_Serviceable__c, Zone__c, Status, Status__c, Seller_City__c, Lead_Flag__c, Dealer__c, CreatedDate, LeadSource,  RecordTypeId, CTIDuplicate__c, LeadPushed__c from Lead where CreatedDate >= :dt1 And CreatedDate <= :dt2 And CTIDuplicate__c = false And LeadPushed__c = false  And (RecordTypeId = :LeadConstants.buyerLeadRecordTypeId OR (RecordTypeId = :LeadConstants.SellerLeadRecordTypeId And HI_Serviceable__c = '1')) Limit 1000 ];
        System.debug('Lead List'+leadlist1);
          
        System.debug(inputOne);
        System.debug(inputTwo);
       // return leadList1;
    }
    
    public void pushToElision()
    {
      //  ElisionBatchPush.init(Datetime.parse(inputOne),Datetime.parse(inputTwo));
    }
    
}