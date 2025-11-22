//Added by Aravindan

@isTest
public class ContactTriggerTestClass {
    
    public static testmethod void testContact()
    {
        Contact c = new Contact();
        c.FirstName = 'PraveenL';
        c.LastName = 'louis';
        c.Email = 'pl@gmail.com';
        insert c;
        c.Email = 'pLouis@gmail.com';
        update c;
    }

}