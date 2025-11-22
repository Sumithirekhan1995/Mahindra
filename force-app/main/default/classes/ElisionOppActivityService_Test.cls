@isTest
public class ElisionOppActivityService_Test {
    
    
    public static testmethod void ElisionOppActivityService(){
        
        List<Account> accList = new List<Account>{
            new Account(Name = 'Test Account1',Code__c = '4203',RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId()),
                new Account(Name = 'Test Account2',Code__c = '4365',RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId()),
                new Account(Name = 'Test Account3',Code__c = '4408',RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId()),
                new Account(Name = 'Test Account4',Code__c = '4310',RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId()),
                new Account(Name = 'Test Account5',Code__c = '4449',RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId(), Dealer_Role__c = 'Focus Cluster RD', BillingCity = 'Delhi'),
                new Account(Name = 'Test Account6',Code__c = '4311',RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId(), Dealer_Role__c = 'Focus Cluster RD', BillingCity = 'Kottayam'),
                new Account(Name = 'Test Account7',Code__c = '4312',RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId(), Dealer_Role__c = 'Focus Cluster RD', BillingCity = 'Nagpur')

                };
                    
        insert accList;
        
        List<Elision_Campaign__c> ellisionList=new List<Elision_Campaign__c>{
            new Elision_Campaign__c(Name = 'HI Procurement1',Elision_Campaign_Category__c = 'HI Procurement'),
                new Elision_Campaign__c(Name = 'HI Procurement2',Elision_Campaign_Category__c = 'General BUC - Others', isActive__c = true),
                new Elision_Campaign__c(Name = 'HI Procurement3',Elision_Campaign_Category__c = 'General BUC - South', isActive__c = true),
                new Elision_Campaign__c(Name = 'HI Procurement4',Elision_Campaign_Category__c = 'Ecomm PaymentFailed', isActive__c = true),
                new Elision_Campaign__c(Name = 'HI Procurement5',Elision_Campaign_Category__c = 'Superstore M2All - North', isActive__c = true),
                new Elision_Campaign__c(Name = 'HI Procurement6',Elision_Campaign_Category__c = 'NCR Cluster - Microsite', Dealer__c = '4449,4450,4310,4475,242', isActive__c = true),
                new Elision_Campaign__c(Name = 'HI Procurement7',Elision_Campaign_Category__c = 'Kerala Cluster - Microsite', Dealer__c = '4311 , 4445 , 4325', isActive__c = true),
                new Elision_Campaign__c(Name = 'HI Procurement8',Elision_Campaign_Category__c = 'Maharashtra Cluster - Microsite', Dealer__c = '4312 , 4203 , 4455 , 2453 , 2117 , 4402', isActive__c = true),
                new Elision_Campaign__c(Name = 'HI Procurement9',Elision_Campaign_Category__c = 'NCR Cluster', Dealer__c = '4449,4450,4310,4475,242', City__c = 'Dadri,Delhi,Faridabad,Ghaziabad,Gurugram,Noida', isActive__c = true),
                new Elision_Campaign__c(Name = 'HI Procurement10',Elision_Campaign_Category__c = 'Kerala Cluster', Dealer__c = '4311 , 4445 , 4325', City__c = 'Kannur,Kollam,Kottayam,Ottapalam,Palai,Palakkad,Pathanamthitta,Thiruvananthapuram,Thodupuzha', isActive__c = true),
                new Elision_Campaign__c(Name = 'HI Procurement11',Elision_Campaign_Category__c = 'Maharashtra Cluster', Dealer__c = '4312 , 4203 , 4455 , 2453 , 2117 , 4402', City__c = 'Ahmedpur,Nagpur,Nashik,Navi Mumbai,Padgha,Pune,Rahata,Shrirampur,Solapur,Thane', isActive__c = true)
                
                };
                    insert ellisionList;
        
        Lead lRec = new Lead();
        lRec.LastName = 'Test';
        lRec.Phone = '8400123412';
        lRec.Alternate_Mobile_Number__c = lRec.Phone;
        lRec.Seller_State__c = 'Uttar Pradesh';
        lRec.Seller_City__c = 'Allahabad';
        lRec.Dealer_Code__c = '3936';
        lRec.Lead_Type__c = LeadConstants.BuyerConstant;
        lRec.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
        lRec.LeadSource = 'Advertisement';
        lRec.Bypass_validation__c = false;
        
        insert lRec;
        
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Opportunity' and Name = 'Buyer Used Car'].Id;
        
        List<Opportunity> oList = new List<Opportunity>{
            new Opportunity(name = 'Test Girish1',Status__c = 'New',StageName = 'New',Lead_Flag__c = 'Reserve',CloseDate = Date.today(),lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId,Dealer__c = accList[0].Id),
                new Opportunity(name = 'Test Girish2',Status__c = 'New',StageName = 'New',Lead_Flag__c = 'uc_testdrive',CloseDate = Date.today(),lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId),
                new Opportunity(name = 'Test Girish9',Status__c = 'New',LeadSource = 'MFC-Chat',StageName = 'New',CloseDate = Date.today(),lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId),
                new Opportunity(name = 'Test Girish3',Status__c = 'New',StageName = 'New',Lead_Flag__c = 'PaymentFailed',CloseDate = Date.today(),lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId),
                new Opportunity(name = 'Test Girish10',Status__c = 'New',LeadSource = 'Exotel',StageName = 'New',Lead_Flag__c = 'PaymentFailed',CloseDate = Date.today(),lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId),
                new Opportunity(name = 'Test Girish2',Status__c = 'New',LeadSource = 'MFC-Chat',StageName = 'New',Lead_Flag__c = 'uc_testdrive',CloseDate = Date.today(),lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId),
                new Opportunity(name = 'Test Girish4',Status__c = 'New',StageName = 'New', Lead_Flag__c = 'LeadFlagNew', CloseDate = Date.today(),lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId,Dealer__c = accList[1].Id),
                new Opportunity(name = 'Test Girish5',Status__c = 'New',StageName = 'New', Lead_Flag__c = 'LeadFlagNew', CloseDate = Date.today(),lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId,Dealer__c = accList[2].Id),
                new Opportunity(name = 'Test Girish6',Status__c = 'New',StageName = 'New',CloseDate = Date.today(),lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId),
                new Opportunity(name = 'Test Girish7',Status__c = 'New',StageName = 'New',Lead_Flag__c = 'PaymentPending',CloseDate = Date.today(),lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId),
                new Opportunity(name = 'Test Girish8',Status__c = 'New',StageName = 'New',CloseDate = Date.today(),lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId,Area_State__c='Karnataka'),
                new Opportunity(name = 'Test Girish9',Status__c = 'New',StageName = 'New',CloseDate = Date.today(), Lead_Category__C = 'CNB MS',Lead_Flag__c= 'inspection report', lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId,Area_State__c='Karnataka'),
                new Opportunity(name = 'Test Girish16',Status__c = 'New',StageName = 'New',CloseDate = Date.today(), Lead_Category__C = 'CNB MS', lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId,Area_State__c='Karnataka',Dealer__c = accList[4].Id),
                new Opportunity(name = 'Test Girish11',Status__c = 'New',StageName = 'New',CloseDate = Date.today(), Lead_Category__C = 'CNB MS', lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId,Area_State__c='Karnataka',Dealer__c = accList[5].Id),
                new Opportunity(name = 'Test Girish12',Status__c = 'New',StageName = 'New',CloseDate = Date.today(), Lead_Category__C = 'CNB MS', lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId,Area_State__c='Karnataka',Dealer__c = accList[6].Id),
                new Opportunity(name = 'Test Girish13',Status__c = 'New',StageName = 'New',CloseDate = Date.today(), lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId,Area_State__c='Karnataka',Dealer__c = accList[4].Id),
                new Opportunity(name = 'Test Girish14',Status__c = 'New',StageName = 'New',CloseDate = Date.today(), lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId,Area_State__c='Karnataka',Dealer__c = accList[5].Id),
                new Opportunity(name = 'Test Girish15',Status__c = 'New',StageName = 'New',CloseDate = Date.today(), lead__c = lRec.Id,RecordTypeId = OpportunityConstants.buyerOppRecordTypeId,Area_State__c='Karnataka',Dealer__c = accList[6].Id)

                };
                    insert oList;
        
        Task tRec = new Task();       
        tRec.WhatId = oList[0].Id;
        tRec.Elision_Campaign__c = ellisionList[0].Id;
        //tRec.Campaign_Id__c = isInBusinessHour ? ellisionList[0].Campaign_Id_WH__c : ellisionList[0].Campaign_Id_NWH__c;
        tRec.Campaign_Name__c = ellisionList[0].Name;
        tRec.Subject = 'Elision BUC Call';
        //tRec.Elision_Due_Date__c = elisionDueDate;
        tRec.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Elision').getRecordTypeId();
        insert tRec;
        
    }
     
}