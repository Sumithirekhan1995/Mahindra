public class AccountSelector {
	public static List<Account> getAllAccountData(Set<Id> accIds){
        Map<String, Schema.SObjectField> fieldMap = Account.sObjectType.getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        for(String s : fieldMap.keySet()){
            fieldNames.add(s);
        }
		String soqlQuery = ' SELECT ' + string.join(fieldNames, ',') + ' FROM Account Where Id =: accIds';
        return Database.query(soqlQuery);
    }
}