@isTest
public class FindMakeModelCityNamesTest {

    public static testmethod void testmethod1(){
        FindModelName.TranscriptInput i =new FindModelName.TranscriptInput();
        i.modelName = 'Bolero';
        
        List<FindModelName.TranscriptInput> input = new List<FindModelName.TranscriptInput>();
        input.add(i);
        
        test.startTest();
        List<String> retVal = FindModelName.findModelName(input);
        test.stopTest();
    }
    
    public static testmethod void testmethod2(){
        FindMakeName.TranscriptInput i =new FindMakeName.TranscriptInput();
        i.makeName = 'MAruti Suzuki';
        
        List<FindMakeName.TranscriptInput> input = new List<FindMakeName.TranscriptInput>();
        input.add(i);
        
        test.startTest();
        List<String> retVal = FindMakeName.findMakeName(input);
        test.stopTest();
    }
    
    public static testmethod void testmethod3(){
        FindCityName.TranscriptInput i =new FindCityName.TranscriptInput();
        i.CityName = 'Bangalore';
        
        List<FindCityName.TranscriptInput> input = new List<FindCityName.TranscriptInput>();
        input.add(i);
        
        test.startTest();
        List<String> retVal = FindCityName.findCityName(input);
        test.stopTest();
    }
}