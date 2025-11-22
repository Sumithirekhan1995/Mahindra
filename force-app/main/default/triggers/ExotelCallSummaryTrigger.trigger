/* purpose: To create a new lead after exotel call summary record is created */

trigger ExotelCallSummaryTrigger on Exotel_Call_Summary__c (after insert)
{ 
    if(trigger.isAfter && trigger.isInsert) {
        ExotelCallSummaryTriggerHandler.onAfterInsert(Trigger.new);
    }
}