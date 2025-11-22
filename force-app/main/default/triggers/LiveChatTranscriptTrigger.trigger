trigger LiveChatTranscriptTrigger on LiveChatTranscript (after update) {
    
  LiveChatTranscriptTriggerHandler.updateLead(Trigger.new, Trigger.oldMap);

    
}