public class ExotelCallSummaryTriggerHandler {
    public static void onAfterInsert(list<Exotel_Call_Summary__c> ecslist){
        list<Exotel_Call_Summary__c> ecsleadlist =new list<Exotel_Call_Summary__c>();
        
        for(Exotel_Call_Summary__c ecs : ecslist){
            ecsleadlist.add(ecs);
        }
        
        system.debug('ecsleadlist'+ecsleadlist);
        if(!ecsleadlist.isEmpty()){
            ExotelCallSummaryTriggerHelper.createLeadRecord(ecsleadlist);
        }         
    }
    
    public static void onAfterUpdate(List<Exotel_Call_Summary__c> newList, Map<Id, Exotel_Call_Summary__c> oldMap){
        Set<Id> exotelIds = new Set<Id>();
        for(Exotel_Call_Summary__c ecs : newList){
            if(ecs.Exotel_Callout__c != oldMap.get(ecs.Id).Exotel_callout__c && ecs.Exotel_Callout__c == true){
                exotelIds.add(ecs.Id);
            }
        }
        System.debug('exotelIds '+exotelIds);
        if(!exotelIds.isEmpty()){
            ExotelCallout.sendExotelInfo(exotelIds);
        }
    }
    
    @invocableMethod
    public static void callHelper(List<Id> exotel_ids){
        Set<Id> eIds = new Set<Id>();
        for(Id i : exotel_ids){
            eIds.add(i);
        }
        
        System.debug('Eids '+eIds);
        if(!eIds.isEmpty()){
            ExotelCallSummaryTriggerHelper.callExotelCallout(eIds);
        }
    }

}