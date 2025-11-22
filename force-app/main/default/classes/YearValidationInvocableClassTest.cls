@isTest
public class YearValidationInvocableClassTest {

    public static testmethod void testmethod1(){
        YearValidationInvocableClass.TranscriptInput i = new YearValidationInvocableClass.TranscriptInput();
        i.Year = 2020;
        
        YearValidationInvocableClass.TranscriptInput i2 = new YearValidationInvocableClass.TranscriptInput();
        i2.Year = 2022;
        
        List<YearValidationInvocableClass.TranscriptInput> input = new List<YearValidationInvocableClass.TranscriptInput>();
        input.add(i);
        
        List<YearValidationInvocableClass.TranscriptInput> input2 = new List<YearValidationInvocableClass.TranscriptInput>();
        input2.add(i2);
        
        test.startTest();
        List<String> retVal = YearValidationInvocableClass.sendMakeAndModel(input);
        List<String> retVal2 = YearValidationInvocableClass.sendMakeAndModel(input2);
        test.stopTest();
    }
}