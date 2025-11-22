public class OpportunitySelector {
	public static List<Opportunity> getAllOpportunityData(Set<Id> oppIds){
        Map<String, Schema.SObjectField> fieldMap = Opportunity.sObjectType.getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        for(String s : fieldMap.keySet()){
            fieldNames.add(s);
        }
		String soqlQuery = ' SELECT Lead_Dispatch__r.Lead__c, ' + string.join(fieldNames, ',') + ' FROM Opportunity Where Id =: oppIds';
        return Database.query(soqlQuery);
    }
}