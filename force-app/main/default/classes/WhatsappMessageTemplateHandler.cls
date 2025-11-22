/*CRM-1105 Pankaj Kumar 16-03-2023 Start*/
public class WhatsappMessageTemplateHandler {
	public static String FB_Message_6646737 = 'Hi {{1}}, 👋\nWelcome to car&bike! \n\n*{{2}} is one of our favourites too.* Our auto champions will reach out to you shortly for further assistance.📲 \n\nMeanwhile, get acquainted with your dream car with our comprehensive inspection report - {{3}} \n\n*What\'s more? Reserve it & make it exclusively yours for 48 hours and avail up to 2 years of warranty!*😊🚙\n\nTeam car&bike';
    public static String NoResponse_6646704 = 'Hi {{1}},👋\nWe tried contacting you to understand your interest in buying a car but could not reach you. \n\nWe understand you might have a busy schedule!😊\n\n*You can give us a call back at 9606045096 and we would be happy to assist you further.* 📲\n\nTeam car&bike';
    /*CRM-1106 Pankaj Kumar 23-03-2023 Start*/
    public static String Walkin_Alert_6646765 = 'Hi {{1}}, 👋\n\nWe eagerly await your presence at {{2}} to test drive {{3}}. 😊\n\nWe have also curated flexible finance options to craft a seamless buying experience for you.\n\n📍 *Here\'s the location of our dealership -  {{4}}*\n📲 *For queries, call our customer care at 9606045096*\n\nSee you soon!\n\nTeam car&bike';
    /*CRM-1106 Pankaj Kumar 23-03-2023 End*/
    /*CRM-1110 Pankaj Kumar 23-03-2023 Start*/
    public static String TDScheduled_6646756 = 'Dear Customer, \n\nThank you for booking a test drive for {{1}} with us! It is scheduled with {{2}}. 🚙\n\n*For any queries, you can reach us at 9606045096. See you soon!* 📲😊\n\nTeam car&bike';
    /*CRM-1110 Pankaj Kumar 23-03-2023 End*/
    /*CRM-1124 Pankaj Kumar 23-03-2023 Start*/
    public static String Sold_Msg_6602534 = '*Hi {{1}}*  👋\nWe could just play it cool, but that wouldn’t be honest. Truth is, we are THRILLED you chose us while purchasing your dream car.  \n\nWe\'d love to know about your experience below so that we can serve you better!\n\n*Select Excellent for 9 or 10*😍\n*Select Good for 7 or 8*😀\n*Select Bad for 1 to 6* 😢';
    /*CRM-1124 Pankaj Kumar 23-03-2023 End*/
    /*CRM-1111 Pankaj Kumar 29-03-2023 Start*/
    public static String WalkinRegister_6567878 = 'Hi {{1}} 👋. \n\nThank you for visiting the car&bike {{2}} Store. Did you enjoy your experience at the store?😊';
    /*CRM-1111 Pankaj Kumar 29-03-2023 End*/
    
    public static Map<Id,String> getOppMsgMap(Map<Id, Opportunity> oppWhatsapMsgMap, String tempName, Map<Id,Account> dealerMap){
        Map<Id,String> oppIdToMsgMap = new Map<Id,String>();
        if(String.isEmpty(tempName) || oppWhatsapMsgMap.isEmpty()){
            return null;
        }
        if(tempName == 'FB_Message_6646737'){
            oppIdToMsgMap = getOppMsgMapForFB_Message_6646737(oppWhatsapMsgMap);
        }
        /*CRM-1107 Pankaj Kumar 16-03-2023 Start*/
        if(tempName == 'NoResponse_6646704'){
            oppIdToMsgMap = getOppMsgMapForNoResponse_6646704(oppWhatsapMsgMap);
        }
        /*CRM-1107 Pankaj Kumar 16-03-2023 End*/
        /*CRM-1106 Pankaj Kumar 23-03-2023 Start*/
        if(tempName == 'Walkin_Alert_6646765'){
            oppIdToMsgMap = getOppMsgMapForWalkin_Alert_6646765(oppWhatsapMsgMap, dealerMap);
        }
        /*CRM-1106 Pankaj Kumar 23-03-2023 End*/
        /*CRM-1110 Pankaj Kumar 23-03-2023 Start*/
        if(tempName == 'TDScheduled_6646756'){
            oppIdToMsgMap = getOppMsgMapForTDScheduled_6646756(oppWhatsapMsgMap);
        }
        /*CRM-1110 Pankaj Kumar 23-03-2023 End*/
        /*CRM-1124 Pankaj Kumar 23-03-2023 Start*/
        if(tempName == 'Sold_Msg_6602534'){
            oppIdToMsgMap = getOppMsgMapForSold_Msg_6602534(oppWhatsapMsgMap);
        }
        /*CRM-1124 Pankaj Kumar 23-03-2023 End*/
        /*CRM-1111 Pankaj Kumar 29-03-2023 Start*/
        if(tempName == 'WalkinRegister_6567878'){
            oppIdToMsgMap = getOppMsgMapForWalkinRegister_6567878(oppWhatsapMsgMap);
        }
        /*CRM-1111 Pankaj Kumar 29-03-2023 End*/
        return oppIdToMsgMap;
    }
    
    private static Map<Id,String> getOppMsgMapForFB_Message_6646737(Map<Id, Opportunity> oppWhatsapMsgMap){
        Map<Id,String> oppIdToMsgMap = new Map<Id,String>();
        for(Id oppId : oppWhatsapMsgMap.keySet()){
            String msg = FB_Message_6646737;
            msg = msg.replace('{{1}}', oppWhatsapMsgMap.get(oppId).Name);
            msg = msg.replace('{{2}}', (oppWhatsapMsgMap.get(oppId).Interested_Make__c + ' ' + oppWhatsapMsgMap.get(oppId).Interested_Model__c));
            msg = msg.replace('{{3}}', ('https://www.carandbike.com/used-car/mfc-stock-id-' + oppWhatsapMsgMap.get(oppId).Stock_Id__c));
            oppIdToMsgMap.put(oppId,msg);
        }
        return oppIdToMsgMap;
    }
    /*CRM-1107 Pankaj Kumar 16-03-2023 Start*/
    private static Map<Id,String> getOppMsgMapForNoResponse_6646704(Map<Id, Opportunity> oppWhatsapMsgMap){
        Map<Id,String> oppIdToMsgMap = new Map<Id,String>();
        for(Id oppId : oppWhatsapMsgMap.keySet()){
            String msg = NoResponse_6646704;
            msg = msg.replace('{{1}}', oppWhatsapMsgMap.get(oppId).Name);
            oppIdToMsgMap.put(oppId,msg);
        }
        return oppIdToMsgMap;
    }
    /*CRM-1107 Pankaj Kumar 16-03-2023 End*/
    /*CRM-1106 Pankaj Kumar 23-03-2023 Start*/
    private static Map<Id,String> getOppMsgMapForWalkin_Alert_6646765(Map<Id, Opportunity> oppWhatsapMsgMap, Map<Id,Account> dealerMap){
        Map<Id,String> oppIdToMsgMap = new Map<Id,String>();
        for(Id oppId : oppWhatsapMsgMap.keySet()){
            String msg = Walkin_Alert_6646765;
            msg = msg.replace('{{1}}', oppWhatsapMsgMap.get(oppId).Name);
            msg = msg.replace('{{2}}', oppWhatsapMsgMap.get(oppId).DealerName__c);
            msg = msg.replace('{{3}}', (oppWhatsapMsgMap.get(oppId).Interested_Make__c + ' ' + oppWhatsapMsgMap.get(oppId).Interested_Model__c));
            msg = msg.replace('{{4}}', dealerMap.get(oppWhatsapMsgMap.get(oppId).Dealer__c).Dealer_Address_Map_Link__c);
            oppIdToMsgMap.put(oppId,msg);
        }
        return oppIdToMsgMap;
    }
    /*CRM-1106 Pankaj Kumar 23-03-2023 End*/
    /*CRM-1110 Pankaj Kumar 23-03-2023 Start*/
    private static Map<Id,String> getOppMsgMapForTDScheduled_6646756(Map<Id, Opportunity> oppWhatsapMsgMap){
        Map<Id,String> oppIdToMsgMap = new Map<Id,String>();
        for(Id oppId : oppWhatsapMsgMap.keySet()){
            String msg = TDScheduled_6646756;
            msg = msg.replace('{{1}}', (oppWhatsapMsgMap.get(oppId).Interested_Make__c + ' ' + oppWhatsapMsgMap.get(oppId).Interested_Model__c));
            msg = msg.replace('{{2}}', oppWhatsapMsgMap.get(oppId).DealerName__c);
            oppIdToMsgMap.put(oppId,msg);
        }
        return oppIdToMsgMap;
    }
    /*CRM-1110 Pankaj Kumar 23-03-2023 End*/
    /*CRM-1124 Pankaj Kumar 23-03-2023 Start*/
    private static Map<Id,String> getOppMsgMapForSold_Msg_6602534(Map<Id, Opportunity> oppWhatsapMsgMap){
        Map<Id,String> oppIdToMsgMap = new Map<Id,String>();
        for(Id oppId : oppWhatsapMsgMap.keySet()){
            String msg = Sold_Msg_6602534;
            msg = msg.replace('{{1}}', oppWhatsapMsgMap.get(oppId).Name);
            oppIdToMsgMap.put(oppId,msg);
        }
        return oppIdToMsgMap;
    }
    /*CRM-1124 Pankaj Kumar 23-03-2023 End*/
    /*CRM-1111 Pankaj Kumar 29-03-2023 Start*/
    private static Map<Id,String> getOppMsgMapForWalkinRegister_6567878(Map<Id, Opportunity> oppWhatsapMsgMap){
        Map<Id,String> oppIdToMsgMap = new Map<Id,String>();
        for(Id oppId : oppWhatsapMsgMap.keySet()){
            String msg = WalkinRegister_6567878;
            msg = msg.replace('{{1}}', oppWhatsapMsgMap.get(oppId).Name);
            msg = msg.replace('{{2}}', oppWhatsapMsgMap.get(oppId).Dealer_City__c);
            oppIdToMsgMap.put(oppId,msg);
        }
        return oppIdToMsgMap;
    }
    /*CRM-1111 Pankaj Kumar 29-03-2023 End*/
}
/*CRM-1105 Pankaj Kumar 16-03-2023 End*/