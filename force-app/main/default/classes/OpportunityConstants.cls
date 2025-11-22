/*
 * Class created by Deepali
 * Purpose: To keep all constants associated with Lead in one class
*/
public class OpportunityConstants {
    
    //Added by Deepali
    //Opportunity Stage constants
    public static String OpportunityStage_NeedAnalysis = 'Needs Analysis';
    public static String OpportunityStage_Qualification = 'Qualification';
    public static final String Status_ValuatorToBeAssigned = 'Valuator to be assigned';
    public static final String Status_Rescheduled = 'Rescheduled';
    public static final String Status_Assigned = 'Assigned';
    
    /*CRM-1105 Start*/
    public static final String Lead_Flag_Getseller = 'getseller';
    /*CRM-1105 End*/
    
    public static Id buyerOppRecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('Buyer_Used_Car').getRecordTypeId();
    public static Id sellerCarRecordTypeID =  Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('Seller_Car').getRecordTypeId();
	public Static Id financeRecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('Finance').getRecordTypeId();
    public Static Id CnBRecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('New_Car').getRecordTypeId();
    public Static Id BSERecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('BSE').getRecordTypeId();
    public Static Id CnBBikeRecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('New_Bike').getRecordTypeId();
    public static Id ElvCarRecordTypeID =  Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('ELV').getRecordTypeId();

    public static Boolean isFromAPI = false;

}