@isTest
public class CnBWebsiteLinkInvocableClassTest {
    
    public static testmethod void CnBWebsite(){
        CnbwebsiteLinkInvocableClass.TranscriptInput i1 = new  CnbwebsiteLinkInvocableClass.TranscriptInput();
        i1.TypeOfSelection = 'Budget';
        i1.Value = 'Under 1 lakh';
        CnbwebsiteLinkInvocableClass.TranscriptInput i2 = new  CnbwebsiteLinkInvocableClass.TranscriptInput();
        i2.TypeOfSelection = 'Budget';
        i2.Value = 'Under 2 lakh';
        CnbwebsiteLinkInvocableClass.TranscriptInput i3 = new  CnbwebsiteLinkInvocableClass.TranscriptInput();
        i3.TypeOfSelection = 'Budget';
        i3.Value = '2 - 5 Lakhs';
        CnbwebsiteLinkInvocableClass.TranscriptInput i4 = new  CnbwebsiteLinkInvocableClass.TranscriptInput();
        i4.TypeOfSelection = 'Budget';
        i4.Value = '5 - 8 Lakhs';
        CnbwebsiteLinkInvocableClass.TranscriptInput i5 = new  CnbwebsiteLinkInvocableClass.TranscriptInput();
        i5.TypeOfSelection = 'Budget';
        i5.Value = '8 - 10 Lakhs';
        
        CnbwebsiteLinkInvocableClass.TranscriptInput i6 = new  CnbwebsiteLinkInvocableClass.TranscriptInput();
        i6.TypeOfSelection = 'Fuel Type';
        i6.Value = 'Petrol';
        CnbwebsiteLinkInvocableClass.TranscriptInput i7 = new  CnbwebsiteLinkInvocableClass.TranscriptInput();
        i7.TypeOfSelection = 'Fuel Type';
        i7.Value = 'Diesel';
        
        CnbwebsiteLinkInvocableClass.TranscriptInput i8 = new  CnbwebsiteLinkInvocableClass.TranscriptInput();
        i8.TypeOfSelection = 'Car Type';
        i8.Value = 'Hatchback';
        CnbwebsiteLinkInvocableClass.TranscriptInput i9 = new  CnbwebsiteLinkInvocableClass.TranscriptInput();
        i9.TypeOfSelection = 'Car Type';
        i9.Value = 'Sedan';
        CnbwebsiteLinkInvocableClass.TranscriptInput i10 = new  CnbwebsiteLinkInvocableClass.TranscriptInput();
        i10.TypeOfSelection = 'Car Type';
        i10.Value = 'SUV';
       
        
        List< CnbwebsiteLinkInvocableClass.TranscriptInput> input1 = new List< CnbwebsiteLinkInvocableClass.TranscriptInput>();
        input1.add(i1);
        List< CnbwebsiteLinkInvocableClass.TranscriptInput> input2 = new List< CnbwebsiteLinkInvocableClass.TranscriptInput>();
        input2.add(i2);
        List< CnbwebsiteLinkInvocableClass.TranscriptInput> input3 = new List< CnbwebsiteLinkInvocableClass.TranscriptInput>();
        input3.add(i3);
        List< CnbwebsiteLinkInvocableClass.TranscriptInput> input4 = new List< CnbwebsiteLinkInvocableClass.TranscriptInput>();
        input4.add(i4);
        List< CnbwebsiteLinkInvocableClass.TranscriptInput> input5 = new List< CnbwebsiteLinkInvocableClass.TranscriptInput>();
        input5.add(i5);
        
        List< CnbwebsiteLinkInvocableClass.TranscriptInput> input6 = new List< CnbwebsiteLinkInvocableClass.TranscriptInput>();
        input6.add(i6);
        List< CnbwebsiteLinkInvocableClass.TranscriptInput> input7 = new List< CnbwebsiteLinkInvocableClass.TranscriptInput>();
        input7.add(i7);
        
        List< CnbwebsiteLinkInvocableClass.TranscriptInput> input8 = new List< CnbwebsiteLinkInvocableClass.TranscriptInput>();
        input8.add(i8);
        List< CnbwebsiteLinkInvocableClass.TranscriptInput> input9 = new List< CnbwebsiteLinkInvocableClass.TranscriptInput>();
        input9.add(i9);
        List< CnbwebsiteLinkInvocableClass.TranscriptInput> input10 = new List< CnbwebsiteLinkInvocableClass.TranscriptInput>();
        input10.add(i10);
        
        test.startTest();
        List<List<String>> returnVal1 = CnbwebsiteLinkInvocableClass.sendWebsiteLink(input1);
        List<List<String>> returnVal2 = CnbwebsiteLinkInvocableClass.sendWebsiteLink(input2);
        List<List<String>> returnVal3 = CnbwebsiteLinkInvocableClass.sendWebsiteLink(input3);
        List<List<String>> returnVal4 = CnbwebsiteLinkInvocableClass.sendWebsiteLink(input4);
        List<List<String>> returnVal5 = CnbwebsiteLinkInvocableClass.sendWebsiteLink(input5);
        
        List<List<String>> returnVal6 = CnbwebsiteLinkInvocableClass.sendWebsiteLink(input6);
        List<List<String>> returnVal7 = CnbwebsiteLinkInvocableClass.sendWebsiteLink(input7);
        
        List<List<String>> returnVal8 = CnbwebsiteLinkInvocableClass.sendWebsiteLink(input8);
        List<List<String>> returnVal9 = CnbwebsiteLinkInvocableClass.sendWebsiteLink(input9);
        List<List<String>> returnVal10 = CnbwebsiteLinkInvocableClass.sendWebsiteLink(input10);
        test.stopTest();
    }
}