@isTest
public class WebsiteLinkInvocableClassTest {

    public static testmethod void testmethod1(){
        WebsiteLinkInvocableClass.TranscriptInput i = new WebsiteLinkInvocableClass.TranscriptInput();
        i.City = 'Bangalore';
        
        List<WebsiteLinkInvocableClass.TranscriptInput> input = new List<WebsiteLinkInvocableClass.TranscriptInput>();
        input.add(i);
        
        test.startTest();
        List<List<String>> returnVal = WebsiteLinkInvocableClass.sendWebsiteLink(input);
        test.stopTest();
    }
}