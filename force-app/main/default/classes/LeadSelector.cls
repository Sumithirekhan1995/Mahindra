public class LeadSelector {
    
    public static List<Lead> getAllLeadData(Set<Id> leadIds){
        Map<String, Schema.SObjectField> fieldMap = Lead.sObjectType.getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        for(String s : fieldMap.keySet()){
            fieldNames.add(s);
        }
		String soqlQuery = ' SELECT ' + string.join(fieldNames, ',') + ' FROM  Lead Where Id =: leadIds';
        return Database.query(soqlQuery);
    }
		
}