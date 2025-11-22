@isTest
public class TaskTriggerTest {
    
    @isTest
    public static void taskMethod1(){
        
        List<Group> gList = [select Id from Group LIMIT 1];
        Lead lea = new Lead();
        lea.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
        lea.LastName = 'Zoya Khan';
        lea.Phone = '9538078909';
        
        lea.LeadSource = 'Advertisement';
        insert lea;
        
        Task t = new Task();
        t.WhoId = lea.Id;
        insert t;
        
        t.Call_Status__c = 'Fail';
        update t;
        
        if(true) {
            List<AssignmentRule> assignmentRuleArr = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Lead' AND Active = true LIMIT 1];
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            if(!assignmentRuleArr.isEmpty()) {
                AssignmentRule objAssignmentRule = new AssignmentRule();
                objAssignmentRule = assignmentRuleArr[0];
                dmlOpts.assignmentRuleHeader.assignmentRuleId= objAssignmentRule.id;
            }            
            Lead lRec = new Lead();
            lRec.LastName = 'Test';
            lRec.Phone = '8400123412';
            lRec.Alternate_Mobile_Number__c = lRec.Phone;
            lRec.Lead_For__c = 'New Car';
            lRec.Given_For__c = 'New';
            lRec.Agreement_Number__c = '12345';
            lRec.Area_State__c = 'Uttar Pradesh';
            lRec.Area_City__c = 'Allahabad';
            lRec.Lead_Type__c = LeadConstants.LEAD_TYPE_FINANCE;
            lRec.RecordTypeId = LeadConstants.financeLeadRecordTypeId;
            lRec.LeadSource = 'Advertisement';
            lRec.Status__c = 'Hot';
            lRec.App_Status__c = 'Hot';
            lRec.setOptions(dmlOpts);
            insert lRec;
            
            Task tRec = new Task();
            tRec.WhoId = lRec.Id;
            insert tRec;
            
            tRec.Call_Status__c = 'Fail';
            update tRec;
        }
        
        // t.CallDisposition = 'Cold';
        // t.Call_Status__c = 'Not Connected';
        // update t;
        
    }
}