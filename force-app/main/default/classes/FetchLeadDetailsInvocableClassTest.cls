@isTest
public class FetchLeadDetailsInvocableClassTest {

    public static testmethod void test1(){
        Lead lea = new Lead();
        lea.LastName = 'Test';
        lea.Phone = '9538019768';
        lea.RecordTypeId = LeadConstants.buyerLeadRecordTypeId;
        lea.leadsource = 'MFC-Chat';
        insert lea;
        
        Opportunity objOpp = new Opportunity();
        objOpp.Name = 'Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = System.today();
        objOpp.Lead__c = lea.Id;
        insert objOpp;
        
        LiveChatVisitor liv = new LiveChatVisitor();
        insert liv;
        
         LiveChatTranscript livchat = new LiveChatTranscript();
        //livchat.Name = 'Test Demo';
        livchat.LeadId = lea.Id;
        livchat.first_Name__c = 'Test';
        livchat.Last_Name__c = 'Demo';
        livchat.Phone__c = '9876532560';
        livchat.LiveChatVisitorId = liv.Id;
        insert livchat;
        
        FetchLeadDetailsInvocableClass.TranscriptInput t = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t.routableID = livchat.id;
        t.inputType = 'CITY';
        t.inputValue = 'Bangalore';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t1 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t1.routableID = livchat.id;
        t1.inputType = 'BUDGET';
        t1.inputValue = '300000';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t2 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t2.routableID = livchat.id;
        t2.inputType = 'CAR TYPE';
        t2.inputValue = 'Sedan';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t3 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t3.routableID = livchat.id;
        t3.inputType = 'FUEL';
        t3.inputValue = 'Petrol';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t4 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t4.routableID = livchat.id;
        t4.inputType = 'KMS';
        t4.inputValue = 'Less than 10,000 Kms';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t5 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t5.routableID = livchat.id;
        t5.inputType = 'MANUFACTURE YEAR';
        t5.inputValue = '123333';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t6 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t6.routableID = livchat.id;
        t6.inputType = 'MODEL';
        t6.inputValue = 'xyz';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t7 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t7.routableID = livchat.id;
        t7.inputType = 'MAKE';
        t7.inputValue = 'abc';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t8 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t8.routableID = livchat.id;
        t8.inputType = 'DATE TIME';
        t8.inputdtValue = system.now();
        
        FetchLeadDetailsInvocableClass.TranscriptInput t9 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t9.routableID = livchat.id;
        t9.inputType = 'AGENT';
        t9.inputValue = 'true';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t10 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t10.routableID = livchat.id;
        t10.inputType = 'INSPECTED DATE';
        t10.inputDTValue = System.now();
        t10.inputValue = '10 AM - 11 AM';
        
         FetchLeadDetailsInvocableClass.TranscriptInput t11 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t11.routableID = livchat.id;
        t11.inputType = 'TRANSFER AGENT';
        t11.inputValue = 'true';
        
         FetchLeadDetailsInvocableClass.TranscriptInput t12 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t12.routableID = livchat.id;
        t12.inputType = 'STAGE ENTERED';
        //t12.inputValue = '12 PM - 1 PM';
        
         FetchLeadDetailsInvocableClass.TranscriptInput t13 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t13.routableID = livchat.id;
        t13.inputType = 'STARTED CONVERSATION';
        //t13.inputValue = '1 PM - 2 PM';
        
         FetchLeadDetailsInvocableClass.TranscriptInput t14 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t14.routableID = livchat.id;
        t14.inputType = 'ENDED CONVERSATION';
        //t14.inputValue = '3 PM - 4 PM';
        
        
        FetchLeadDetailsInvocableClass.TranscriptInput t15 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t15.routableID = livchat.id;
        t15.inputType = 'KMS';
        t15.inputValue = 'Less than 50,000 Kms';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t16 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t16.routableID = livchat.id;
        t16.inputType = 'KMS';
        t16.inputValue = 'More than 50,000 Kms';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t17 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t17.routableID = livchat.id;
        t17.inputType = 'INSPECTED DATE';
        t17.inputDTValue = System.now();
        t17.inputValue = '11 AM - 12 PM';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t18 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t18.routableID = livchat.id;
        t18.inputType = 'INSPECTED DATE';
        t18.inputDTValue = System.now();
        t18.inputValue = '12 PM - 1 PM';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t19 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t19.routableID = livchat.id;
        t19.inputType = 'INSPECTED DATE';
        t19.inputDTValue = System.now();
        t19.inputValue = '2 PM - 3 PM';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t20 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t20.routableID = livchat.id;
        t20.inputType = 'INSPECTED DATE';
        t20.inputDTValue = System.now();
        t20.inputValue = '3 PM - 4 PM';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t21 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t21.routableID = livchat.id;
        t21.inputType = 'INSPECTED DATE';
        t21.inputDTValue = System.now();
        t21.inputValue = '4 PM - 5 PM';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t22 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t22.routableID = livchat.id;
        t22.inputType = 'INSPECTED DATE';
        t22.inputDTValue = System.now();
        t22.inputValue = '5 PM - 6 PM';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t23 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t23.routableID = livchat.id;
        t23.inputType = 'INSPECTED DATE';
        t23.inputDTValue = System.now();
        t23.inputValue = '6 PM - 7 PM';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t24 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t24.routableID = livchat.id;
        t24.inputType = 'INSPECTED DATE';
        t24.inputDTValue = System.now();
        t24.inputValue = '10 AM - 11 AM';
        
        FetchLeadDetailsInvocableClass.TranscriptInput t25 = new FetchLeadDetailsInvocableClass.TranscriptInput();
        t25.routableID = livchat.id;
        t25.inputType = 'KMS';
        t25.inputValue = 'More than 50,000 Kms';
        
        
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input1 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input1.add(t);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input2 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input2.add(t1);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input3 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input3.add(t2);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input4 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input4.add(t3);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input5 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input5.add(t4);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input6 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input6.add(t5);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input7 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input7.add(t6);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input8 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input8.add(t7);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input9 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input9.add(t8);
        
        /*List<FetchLeadDetailsInvocableClass.TranscriptInput> input10 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input8.add(t9);*/
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input14 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input9.add(t10);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input10 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input10.add(t12);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input11 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input11.add(t13);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input12 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input12.add(t14);
        
         List<FetchLeadDetailsInvocableClass.TranscriptInput> input13 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input13.add(t15);
        
         List<FetchLeadDetailsInvocableClass.TranscriptInput> input16 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input16.add(t17);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input17 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input17.add(t18);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input18 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input18.add(t19);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input19 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input19.add(t20);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input20 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input20.add(t21);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input21 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input21.add(t22);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input22 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input22.add(t23);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input23 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input23.add(t24);
        
        List<FetchLeadDetailsInvocableClass.TranscriptInput> input24 = new List<FetchLeadDetailsInvocableClass.TranscriptInput>();
        input24.add(t25);
        
        test.startTest();
        FetchLeadDetailsInvocableClass.saveLeadDetails(input1);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input2);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input3);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input4);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input5);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input6);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input7);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input8);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input10);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input11);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input12);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input13);
        //FetchLeadDetailsInvocableClass.saveLeadDetails(input15);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input16);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input17);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input18);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input19);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input20);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input21);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input22);
        FetchLeadDetailsInvocableClass.saveLeadDetails(input23);
        test.stopTest();
            
            
            
    }
}