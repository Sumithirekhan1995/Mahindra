@isTest
public class MakeAndModelInvocableClassTest {

    public static testmethod void testmethod1(){
        String Model = 'Maruti Suzuki';
        Integer counter = 2;
        MakeAndModelInvocableClass.MakeAndModelWrapper i =new MakeAndModelInvocableClass.MakeAndModelWrapper(Model, counter);
        i.counter = 2;
        i.Model = 'Maruti Suzuki';
        
        
        MakeAndModelInvocableClass.TranscriptInput i1 = new MakeAndModelInvocableClass.TranscriptInput();
        i1.BuyOrSellCarType = 'Buy a Used Car';
        i1.City = 'Bangalore';
        i1.TypesOfSelection = 'Budget';
        i1.Values = '4 - 6 lakhs';
        i1.FuelType = 'Petrol';
        
        MakeAndModelInvocableClass.TranscriptInput i2 = new MakeAndModelInvocableClass.TranscriptInput();
        i2.BuyOrSellCarType = 'Buy a Used Car';
        i2.City = 'Bangalore';
        i2.TypesOfSelection = 'Budget';
        i2.Values = '2 - 4 Lakhs';
        i2.FuelType = 'Petrol';
        
        MakeAndModelInvocableClass.TranscriptInput i3 = new MakeAndModelInvocableClass.TranscriptInput();
        i3.BuyOrSellCarType = 'Buy a Used Car';
        i3.City = 'Bangalore';
        i3.TypesOfSelection = 'Budget';
        i3.Values = '6 - 8 Lakhs';
        i3.FuelType = 'Petrol';
        
        MakeAndModelInvocableClass.TranscriptInput i8 = new MakeAndModelInvocableClass.TranscriptInput();
        i8.BuyOrSellCarType = 'Buy a Used Car';
        i8.City = 'Bangalore';
        i8.TypesOfSelection = 'Budget';
        i8.Values = '8 - 10 Lakhs';
        i8.FuelType = 'Petrol';
        
        MakeAndModelInvocableClass.TranscriptInput i9 = new MakeAndModelInvocableClass.TranscriptInput();
        i9.BuyOrSellCarType = 'Buy a Used Car';
        i9.City = 'Bangalore';
        i9.TypesOfSelection = 'Budget';
        i9.Values = '10+ Lakhs';
        i9.FuelType = 'Petrol';
        
        
        MakeAndModelInvocableClass.TranscriptInput i4 = new MakeAndModelInvocableClass.TranscriptInput();
        i4.BuyOrSellCarType = 'Buy a Used Car';
        i4.City = 'Bangalore';
        i4.TypesOfSelection = 'CarType';
        i4.Values = 'Sedan';
        i4.FuelType = 'Petrol';
        
        MakeAndModelInvocableClass.TranscriptInput i5 = new MakeAndModelInvocableClass.TranscriptInput();
        i5.BuyOrSellCarType = 'Buy a Used Car';
        i5.City = 'Bangalore';
        i5.TypesOfSelection = 'CarType';
        i5.Values = 'Hatchback';
        i5.FuelType = 'Petrol';
        
        MakeAndModelInvocableClass.TranscriptInput i6 = new MakeAndModelInvocableClass.TranscriptInput();
        i6.BuyOrSellCarType = 'Buy a Used Car';
        i6.City = 'Bangalore';
        i6.TypesOfSelection = 'CarType';
        i6.Values = 'SUV';
        i6.FuelType = 'Petrol';
        
        MakeAndModelInvocableClass.TranscriptInput i7 = new MakeAndModelInvocableClass.TranscriptInput();
        i7.BuyOrSellCarType = 'Buy a Used Car';
        i7.City = 'Bangalore';
        i7.TypesOfSelection = 'CarType';
        i7.Values = 'SUV';
        i7.FuelType = 'Diesel';
        
        MakeAndModelInvocableClass.TranscriptInput i10 = new MakeAndModelInvocableClass.TranscriptInput();
        i10.BuyOrSellCarType = 'Sell a Used Car';
        i10.City = 'Bangalore';
        i10.TypesOfSelection = 'CarType';
        i10.Values = 'SUV';
        i10.FuelType = 'Diesel';
        
        List<MakeAndModelInvocableClass.TranscriptInput> input1 = new List<MakeAndModelInvocableClass.TranscriptInput>();
        input1.add(i1);
        
        List<MakeAndModelInvocableClass.TranscriptInput> input2 = new List<MakeAndModelInvocableClass.TranscriptInput>();
        input2.add(i2);
        
        List<MakeAndModelInvocableClass.TranscriptInput> input3 = new List<MakeAndModelInvocableClass.TranscriptInput>();
        input3.add(i3);
        
        List<MakeAndModelInvocableClass.TranscriptInput> input4 = new List<MakeAndModelInvocableClass.TranscriptInput>();
        input4.add(i4);
        
        List<MakeAndModelInvocableClass.TranscriptInput> input5 = new List<MakeAndModelInvocableClass.TranscriptInput>();
        input5.add(i5);
        
        List<MakeAndModelInvocableClass.TranscriptInput> input6 = new List<MakeAndModelInvocableClass.TranscriptInput>();
        input6.add(i6);
        
        List<MakeAndModelInvocableClass.TranscriptInput> input7 = new List<MakeAndModelInvocableClass.TranscriptInput>();
        input7.add(i7);
        
        List<MakeAndModelInvocableClass.TranscriptInput> input8 = new List<MakeAndModelInvocableClass.TranscriptInput>();
        input8.add(i8);
        
        List<MakeAndModelInvocableClass.TranscriptInput> input9 = new List<MakeAndModelInvocableClass.TranscriptInput>();
        input9.add(i9);
        
        List<MakeAndModelInvocableClass.TranscriptInput> input10 = new List<MakeAndModelInvocableClass.TranscriptInput>();
        input10.add(i10);
        
        test.startTest();
        List<List<String>> retVal1 = MakeAndModelInvocableClass.sendMakeAndModel(input1);
        List<List<String>> retVal2 = MakeAndModelInvocableClass.sendMakeAndModel(input2);
        List<List<String>> retVal3 = MakeAndModelInvocableClass.sendMakeAndModel(input3);
        List<List<String>> retVal4 = MakeAndModelInvocableClass.sendMakeAndModel(input4);
        List<List<String>> retVal5 = MakeAndModelInvocableClass.sendMakeAndModel(input5);
        List<List<String>> retVal6 = MakeAndModelInvocableClass.sendMakeAndModel(input6);
        List<List<String>> retVal7 = MakeAndModelInvocableClass.sendMakeAndModel(input7);
        List<List<String>> retVal8 = MakeAndModelInvocableClass.sendMakeAndModel(input8);
        List<List<String>> retVal9 = MakeAndModelInvocableClass.sendMakeAndModel(input9);
        List<List<String>> retVal10 = MakeAndModelInvocableClass.sendMakeAndModel(input10);
        test.stopTest();
    }
    
     public static testmethod void testmethod2(){
         Account acc = new Account();
        acc.RecordTypeId = AccountConstants.dealerAccountRecordTypeId;
        acc.Name = 'Suzuki motors';
        acc.BillingCity = 'Bangalore';
        insert acc;

         product2 p = new product2();
        p.Name = 'Maruti Suzuki';
        p.Expected_Price__c = 200000;
        p.Make__c = 'Maruti Suzuki';
        p.Model__c = 'Bolero';
        p.Dealer_Name__c = acc.Id;
         p.Fuel__c = 'Petrol';
        insert p;
        
         
        String Model = 'Maruti Suzuki';
        Integer counter = 2;
        InvocableClassForMakeAndModel.MakeAndModelWrapper i =new InvocableClassForMakeAndModel.MakeAndModelWrapper(Model, counter);
        i.counter = 2;
        i.Model = 'Maruti Suzuki';
        
        
        InvocableClassForMakeAndModel.TranscriptInput i1 = new InvocableClassForMakeAndModel.TranscriptInput();
        i1.BuyOrSellCarType = 'Buy a Used Car';
        i1.City = 'Bangalore';
        i1.TypesOfSelection = 'Budget';
        i1.Values = '4 - 6 lakhs';
        i1.makemodelSelection = 'Maruti Suzuki';
        
        InvocableClassForMakeAndModel.TranscriptInput i2 = new InvocableClassForMakeAndModel.TranscriptInput();
        i2.BuyOrSellCarType = 'Buy a Used Car';
        i2.City = 'Bangalore';
        i2.TypesOfSelection = 'Budget';
        i2.Values = '2 - 4 Lakhs';
        
        InvocableClassForMakeAndModel.TranscriptInput i3 = new InvocableClassForMakeAndModel.TranscriptInput();
        i3.BuyOrSellCarType = 'Buy a Used Car';
        i3.City = 'Bangalore';
        i3.TypesOfSelection = 'Budget';
        i3.Values = '6 - 8 Lakhs';
        
        InvocableClassForMakeAndModel.TranscriptInput i8 = new InvocableClassForMakeAndModel.TranscriptInput();
        i8.BuyOrSellCarType = 'Buy a Used Car';
        i8.City = 'Bangalore';
        i8.TypesOfSelection = 'Budget';
        i8.Values = '8 - 10 Lakhs';
        
        InvocableClassForMakeAndModel.TranscriptInput i9 = new InvocableClassForMakeAndModel.TranscriptInput();
        i9.BuyOrSellCarType = 'Buy a Used Car';
        i9.City = 'Bangalore';
        i9.TypesOfSelection = 'Budget';
        i9.Values = '10+ Lakhs';

        
        
        InvocableClassForMakeAndModel.TranscriptInput i4 = new InvocableClassForMakeAndModel.TranscriptInput();
        i4.BuyOrSellCarType = 'Buy a Used Car';
        i4.City = 'Bangalore';
        i4.TypesOfSelection = 'CarType';
        i4.Values = 'Sedan';
        
        InvocableClassForMakeAndModel.TranscriptInput i5 = new InvocableClassForMakeAndModel.TranscriptInput();
        i5.BuyOrSellCarType = 'Buy a Used Car';
        i5.City = 'Bangalore';
        i5.TypesOfSelection = 'CarType';
        i5.Values = 'Hatchback';
        
        InvocableClassForMakeAndModel.TranscriptInput i6 = new InvocableClassForMakeAndModel.TranscriptInput();
        i6.BuyOrSellCarType = 'Buy a Used Car';
        i6.City = 'Bangalore';
        i6.TypesOfSelection = 'CarType';
        i6.Values = 'SUV';

        
        InvocableClassForMakeAndModel.TranscriptInput i7 = new InvocableClassForMakeAndModel.TranscriptInput();
        i7.BuyOrSellCarType = 'Buy a Used Car';
        i7.City = 'Bangalore';
        i7.TypesOfSelection = 'CarType';
        i7.Values = 'SUV';
        
        InvocableClassForMakeAndModel.TranscriptInput i10 = new InvocableClassForMakeAndModel.TranscriptInput();
        i10.BuyOrSellCarType = 'Sell a Used Car';
        i10.City = 'Bangalore';
        i10.TypesOfSelection = 'CarType';
        i10.Values = 'SUV';
         
         InvocableClassForMakeAndModel.TranscriptInput i16 = new InvocableClassForMakeAndModel.TranscriptInput();
        i16.BuyOrSellCarType = 'Sell a Used Car';
        i16.City = 'Bangalore';
        i16.TypesOfSelection = 'CarType';
        i16.Values = 'XUV';
         
        InvocableClassForMakeAndModel.TranscriptInput i11 = new InvocableClassForMakeAndModel.TranscriptInput();
        i11.BuyOrSellCarType = 'Sell a Used Car';
        i11.City = 'Bangalore';
        i11.TypesOfSelection = 'Fuel Type';
        i11.Values = 'Petrol';
         
        InvocableClassForMakeAndModel.TranscriptInput i12 = new InvocableClassForMakeAndModel.TranscriptInput();
        i12.BuyOrSellCarType = 'Sell a Used Car';
        i12.City = 'Bangalore';
        i12.TypesOfSelection = 'Fuel Type';
        i12.Values = 'Diesel';
         
        InvocableClassForMakeAndModel.TranscriptInput i13 = new InvocableClassForMakeAndModel.TranscriptInput();
        i13.BuyOrSellCarType = 'Sell a Used Car';
        i13.City = 'Bangalore';
        i13.TypesOfSelection = 'Kms Driven';
        i13.Values = '10,000 to 50,000 Kms';
         
        InvocableClassForMakeAndModel.TranscriptInput i14 = new InvocableClassForMakeAndModel.TranscriptInput();
        i14.BuyOrSellCarType = 'Sell a Used Car';
        i14.City = 'Bangalore';
        i14.TypesOfSelection = 'Kms Driven';
        i14.Values = '50,000 to 90,000 Kms';
        
         InvocableClassForMakeAndModel.TranscriptInput i15 = new InvocableClassForMakeAndModel.TranscriptInput();
        i15.BuyOrSellCarType = 'Sell a Used Car';
        i15.City = 'Bangalore';
        i15.TypesOfSelection = 'Kms Driven';
        i15.Values = '90,000+ Kms';
        
        List<InvocableClassForMakeAndModel.TranscriptInput> input1 = new List<InvocableClassForMakeAndModel.TranscriptInput>();
        input1.add(i1);
        
        List<InvocableClassForMakeAndModel.TranscriptInput> input2 = new List<InvocableClassForMakeAndModel.TranscriptInput>();
        input2.add(i2);
        
        List<InvocableClassForMakeAndModel.TranscriptInput> input3 = new List<InvocableClassForMakeAndModel.TranscriptInput>();
        input3.add(i3);
        
        List<InvocableClassForMakeAndModel.TranscriptInput> input4 = new List<InvocableClassForMakeAndModel.TranscriptInput>();
        input4.add(i4);
        
        List<InvocableClassForMakeAndModel.TranscriptInput> input5 = new List<InvocableClassForMakeAndModel.TranscriptInput>();
        input5.add(i5);
        
        List<InvocableClassForMakeAndModel.TranscriptInput> input6 = new List<InvocableClassForMakeAndModel.TranscriptInput>();
        input6.add(i6);
        
        List<InvocableClassForMakeAndModel.TranscriptInput> input7 = new List<InvocableClassForMakeAndModel.TranscriptInput>();
        input7.add(i7);
        
        List<InvocableClassForMakeAndModel.TranscriptInput> input8 = new List<InvocableClassForMakeAndModel.TranscriptInput>();
        input8.add(i8);
        
        List<InvocableClassForMakeAndModel.TranscriptInput> input9 = new List<InvocableClassForMakeAndModel.TranscriptInput>();
        input9.add(i9);
        
        List<InvocableClassForMakeAndModel.TranscriptInput> input10 = new List<InvocableClassForMakeAndModel.TranscriptInput>();
        input10.add(i10);
        
        List<InvocableClassForMakeAndModel.TranscriptInput> input11 = new List<InvocableClassForMakeAndModel.TranscriptInput>();
        input11.add(i11);
         
        List<InvocableClassForMakeAndModel.TranscriptInput> input12 = new List<InvocableClassForMakeAndModel.TranscriptInput>();
        input12.add(i12); 
         
         List<InvocableClassForMakeAndModel.TranscriptInput> input13 = new List<InvocableClassForMakeAndModel.TranscriptInput>();
        input13.add(i13);
         
         List<InvocableClassForMakeAndModel.TranscriptInput> input14 = new List<InvocableClassForMakeAndModel.TranscriptInput>();
        input14.add(i14);
         
         List<InvocableClassForMakeAndModel.TranscriptInput> input15 = new List<InvocableClassForMakeAndModel.TranscriptInput>();
        input15.add(i15);
         
         List<InvocableClassForMakeAndModel.TranscriptInput> input16 = new List<InvocableClassForMakeAndModel.TranscriptInput>();
        input16.add(i16);
         
         
         
        test.startTest();
        List<List<String>> retVal1 = InvocableClassForMakeAndModel.setTranscriptValues(input1);
        List<List<String>> retVal2 = InvocableClassForMakeAndModel.setTranscriptValues(input2);
        List<List<String>> retVal3 = InvocableClassForMakeAndModel.setTranscriptValues(input3);
        List<List<String>> retVal4 = InvocableClassForMakeAndModel.setTranscriptValues(input4);
        List<List<String>> retVal5 = InvocableClassForMakeAndModel.setTranscriptValues(input5);
        List<List<String>> retVal6 = InvocableClassForMakeAndModel.setTranscriptValues(input6);
        List<List<String>> retVal7 = InvocableClassForMakeAndModel.setTranscriptValues(input7);
        List<List<String>> retVal8 = InvocableClassForMakeAndModel.setTranscriptValues(input8);
        List<List<String>> retVal9 = InvocableClassForMakeAndModel.setTranscriptValues(input9);
        List<List<String>> retVal10 = InvocableClassForMakeAndModel.setTranscriptValues(input10);
         List<List<String>> retVal11 = InvocableClassForMakeAndModel.setTranscriptValues(input11);
         List<List<String>> retVal12 = InvocableClassForMakeAndModel.setTranscriptValues(input12);
         List<List<String>> retVal13 = InvocableClassForMakeAndModel.setTranscriptValues(input13);
         List<List<String>> retVal14 = InvocableClassForMakeAndModel.setTranscriptValues(input14);
         List<List<String>> retVal15 = InvocableClassForMakeAndModel.setTranscriptValues(input15);
         List<List<String>> retVal16 = InvocableClassForMakeAndModel.setTranscriptValues(input16);
        test.stopTest();
    }
    
    
}