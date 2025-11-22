/*
 * Class created by Deepali
 * Purpose: To keep all constants associated with Lead in one class
*/
public class LeadConstants {
    
    //Added by Deepali
    //to get Lead recordtypeId 
    public static Id buyerLeadRecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Buyer_Used_Car').getRecordTypeId();
    public static Id financeLeadRecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Finance').getRecordTypeId();
    public static Id SellerLeadRecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Seller').getRecordTypeId(); 
    public static Id ElvLeadRecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('ELV').getRecordTypeId();
    public static Id CnBLeadRecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('New_Car').getRecordTypeId();
    public static Id BSELeadRecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('BSE').getRecordTypeId();
    public static Id CnBBikeLeadRecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('New_Bike').getRecordTypeId();
    public static Id FinanceChatRecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Finance_Chat').getRecordTypeId();
    public static Id AutofinRecordtyeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Autofin').getRecordTypeId();
    public static Id SellerElvQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Seller_ELV' LIMIT 1].Id;
    public static Id SellerPiQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Seller_PI' LIMIT 1].Id;
    
    // Implement for Android Application for lead opp insert LMS callout 
   // public static Boolean isFromLeadupsert = false;  // sumit for android
   // public static Boolean isFromAura = false;  // sumit for android

    
    //Lead Status constants
    public static String leadStatus_Qualified = 'Dealer/Stock Assigned';
    public static String LeadStatus = 'Valuator to be assigned';
    public static String Lead_Status_Assigned = 'Assigned';
    
    public static Boolean fireLMSApiFromLead = TRUE;
    public static Boolean fireFinApiFromLead = TRUE;
    

    public static String LEAD_STATUS_DEALER_STOCK_ASSIGNED = 'Dealer/Stock Assigned';
    public Static String LEAD_STATUS_QUALIFIED = 'Qualified';
    public Static String LEAD_STATUS_LOST = 'Lost';
    public Static String LEAD_STATUS_NOT_INTERESTED = 'No Intent / Not interested';
    public Static String LEAD_STATUS_INVALIED_LEAD = 'Invalid Lead';
    
    public static String Lead_Status_del = 'Delivered';
    public static String Lead_Status_Evaluated = 'Evaluated';
    
    //Lead Type Constants
    
    public Static String SellerConstant = 'Seller';
    Public Static String BuyerConstant = 'USEDCARSALES';
    Public Static String ProcurementConstant = 'PROCUREMENT';
    Public Static String LEAD_TYPE_FINANCE = 'FINANCE';
    public Static String LEAD_TYPE_SELLER = 'Seller';
    Public Static String LEAD_TYPE_BUYER = 'Buyer Used Car';
    Public Static String LEAD_TYPE_CNB = 'CnB-Car';
    Public Static String LEAD_TYPE_CNB_BIKE = 'CnB-Bike';
    Public Static String LEAD_TYPE_BSE = 'BSE';
    
    Public Static String NcdConstants = 'NCD';
    Public Static String NonNcdConstants = 'NON-NCD';
    Public Static String CptConstants = 'CPT';
    
    
    //Finance Lead Status Constants
    Public Static String StatusInProcess = 'In Process';
    Public Static String StatusLoggedIn = 'Logged In';
 
}