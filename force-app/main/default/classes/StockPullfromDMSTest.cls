@isTest
public class StockPullfromDMSTest {
    
    @testSetup
    public static void testSetup() {
         List<Get_API_Calls__c> gpList = new List<Get_API_Calls__c>();
        
        List<Email__c> emails = new List<Email__c>();
        emails.add(new Email__c(
            Name = 'Test',
            Person_Email__c = 'Test@mail.com'
        ));
        insert emails;
                
        // data endpoints
        Get_API_Calls__c gp1 = new Get_API_Calls__c();
        gp1.End_Point__c = 'DataSuccess';
        gp1.Name = 'Get Stock';
        gp1.Last_Synced_Time__c = System.today().addDays(-2);
        gpList.add(gp1);
        Get_API_Calls__c gp2 = new Get_API_Calls__c();
        gp2.End_Point__c = 'AuthSuccess';
        gp2.Name = 'Get Token';
        gp2.Last_Synced_Time__c = System.today().addDays(-2);
        gpList.add(gp2);
        insert gpList;
        
        // auth credentials
        GetAuthorizationToken__c ga = new GetAuthorizationToken__c();
        ga.Name = 'DealerStockDMS';
        ga.Username__c = 'Username__c';
        ga.Password__c = 'Password__c';
        insert ga;
        
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        accList.add(acc);
        insert accList;
    }
    
    @isTest
    public static void test1(){
       
        // set mock
        Test.setMock(HttpCalloutMock.class, new MockAll());
        
        test.startTest();
        StockPullfromDMS.getStockInfo();
        test.stopTest();
    }
    
    @isTest
    public static void test2() {
        Test.setMock(HttpCalloutMock.class, new MockAll());
        Get_API_Calls__c endpoint = [SELECT Id, End_Point__c FROM Get_API_Calls__c WHERE Name = 'Get Token' LIMIT 1];
        endpoint.End_Point__c = 'AuthFail';
        update endpoint;
        StockPullfromDMS.getStockInfo();
    }
    
    @isTest
    public static void test3() {
        Test.setMock(HttpCalloutMock.class, new MockAll());
        if(true) {
            Get_API_Calls__c endpoint = [SELECT Id, End_Point__c FROM Get_API_Calls__c WHERE Name = 'Get Token' LIMIT 1];
            endpoint.End_Point__c = 'AuthSuccess';
            update endpoint;
        }
        if(true) {
            Get_API_Calls__c endpoint = [SELECT Id, End_Point__c FROM Get_API_Calls__c WHERE Name = 'Get Stock' LIMIT 1];
            endpoint.End_Point__c = 'DataFail';
            update endpoint;
        }
        
        StockPullfromDMS.getStockInfo();
    }
    
    @isTest
    public static void test4() {
        Test.setMock(HttpCalloutMock.class, new MockAll());
        Get_API_Calls__c endpoint = [SELECT Id, End_Point__c FROM Get_API_Calls__c WHERE Name = 'Get Token' LIMIT 1];
        endpoint.End_Point__c = 'AuthNull';
        update endpoint;
        StockPullfromDMS.getStockInfo();
    }
    
    @isTest
    public static void test5() {
        Test.setMock(HttpCalloutMock.class, new MockAll());
        Get_API_Calls__c endpoint = [SELECT Id, End_Point__c FROM Get_API_Calls__c WHERE Name = 'Get Token' LIMIT 1];
        endpoint.End_Point__c = null;
        update endpoint;
        StockPullfromDMS.getStockInfo();
    }
    
    public class MockAll implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(req.getEndpoint().contains('AuthSuccess')) {
                res.setHeader('Token', 'value');
                res.setStatusCode(200);
            } else if(req.getEndpoint().contains('AuthFail')) {
                res.setStatusCode(500);
            } if(req.getEndpoint().contains('AuthNull')) {
                res.setStatusCode(200);
            } else if(req.getEndpoint().contains('Exception')) {
                res.setStatusCode(200);
                res.setHeader('Token', 'value');
            } else if(req.getEndpoint().contains('DataFail')) {
                res.setStatusCode(500);
            } else if(req.getEndpoint().contains('DataSuccess')) {
                res.setStatusCode(200);
                String json='{'+
                    '    "Stocks": [{'+
                    '           "ActualDealerName": "Favourite Cars",'+
                    '           "MobileNo": "8893663747",'+
                    '           "Email": "favouritecars968@gmail.com",'+
                    '           "PrincipleEmail": "help.mfcwl@mahindra.com",'+
                    '           "ID": "375152",'+
                    '           "Make": "MARUTI SUZUKI",'+
                    '           "Model": "SWIFT",'+
                    '           "Variant": "VDI",'+
                    '           "PostedDate": "2019-12-20",'+
                    '           "ModifiedDate": "2020-01-14",'+
                    '			"Manufacturing_Date":"2010-02-01T00:00:00",'+
                    '           "BodyType": "HATCHBACK",'+
                    '           "ModelYear": "2007",'+
                    '           "ModelMonth": "12",'+
                    '           "RegistrationNumber": "KL29A707",'+
                    '           "RegistrationCity": "Aluva",'+
                    '           "NoOfOwners": "2",'+
                    '           "Insurance": "NA",'+
                    '           "ExpectedPrice": "200000",'+
                    '           "Kilometer": "112000",'+
                    '           "Fuel": "DIESEL",'+
                    '           "Color": "Brown",'+
                    '           "Comment": "",'+
                    '           "MFCDealerCode": "1035",'+
                    '           "MFCDealerAddress": "182/1A, Peruvaram, N. Paravoor, Opposite to Kallarakkal Temple, Peruvaram Ernakulam",'+
                    '           "MFCDealerCity": "Ernakulam",'+
                    '           "MFCDealerState": "Kerala",'+
                    '           "Pincode": "683513",'+
                    '           "certified": "no",'+
                    '           "Photos": {'+
                    '               "Photo": [{'+
                    '                       "Sn": "1",'+
                    '                       "Cover": false,'+
                    '                       "Text": "photo_url>"'+
                    '                   },'+
                    '                   {'+
                    '                       "Sn": "2",'+
                    '                       "Cover": false,'+
                    '                       "Text": "</photo_url><photo_url>"'+
                    '                   },'+
                    '                   {'+
                    '                       "Sn": "3",'+
                    '                       "Cover": false,'+
                    '                       "Text": "</photo_url><photo_url>"'+
                    '                   },'+
                    '                   {'+
                    '                       "Sn": "4",'+
                    '                       "Cover": false,'+
                    '                       "Text": "</photo_url><photo_url>"'+
                    '                   },'+
                    '                   {'+
                    '                       "Sn": "5",'+
                    '                       "Cover": false,'+
                    '                       "Text": "</photo_url><photo_url>"'+
                    '                   },'+
                    '                   {'+
                    '                       "Sn": "6",'+
                    '                       "Cover": false,'+
                    '                       "Text": "</photo_url><photo_url>"'+
                    '                   },'+
                    '                   {'+
                    '                       "Sn": "7",'+
                    '                       "Cover": false,'+
                    '                       "Text": "</photo_url><photo_url>"'+
                    '                   },'+
                    '                   {'+
                    '                       "Sn": "8",'+
                    '                       "Cover": false,'+
                    '                       "Text": "</photo_url>"'+
                    '                   }'+
                    '               ],'+
                    '               "Count": "8"'+
                    '           }'+
                    '       },'+
                    '        {'+
                    '           "ActualDealerName": "Favourite Cars",'+
                    '           "MobileNo": "8893663747",'+
                    '           "Email": "favouritecars968@gmail.com",'+
                    '           "PrincipleEmail": "help.mfcwl@mahindra.com",'+
                    '           "ID": "375150",'+
                    '           "Make": "MARUTI SUZUKI",'+
                    '           "Model": "SWIFT",'+
                    '           "Variant": "VDI",'+
                    '           "PostedDate": "2019-12-20",'+
                    '           "ModifiedDate": "2020-01-14",'+
                    '			"Manufacturing_Date":"2010-02-01T00:00:00",'+
                    '           "BodyType": "HATCHBACK",'+
                    '           "ModelYear": "2007",'+
                    '           "ModelMonth": "12",'+
                    '           "RegistrationNumber": "KL29A707",'+
                    '           "RegistrationCity": "Aluva",'+
                    '           "NoOfOwners": "2",'+
                    '           "Insurance": "NA",'+
                    '           "ExpectedPrice": "200000",'+
                    '           "Kilometer": "112000",'+
                    '           "Fuel": "DIESEL",'+
                    '           "Color": "Brown",'+
                    '           "Comment": "",'+
                    '           "MFCDealerCode": "1035",'+
                    '           "MFCDealerAddress": "182/1A, Peruvaram, N. Paravoor, Opposite to Kallarakkal Temple, Peruvaram Ernakulam",'+
                    '           "MFCDealerCity": "Ernakulam",'+
                    '           "MFCDealerState": "Kerala",'+
                    '           "Pincode": "683513",'+
                    '           "certified": "yes",'+
                    '            "Photos": {'+
                    '               "Photo": [{'+
                    '                       "Sn": "1",'+
                    '                       "Cover": false,'+
                    '                       "Text": "photo_url>"'+
                    '                   },'+
                    '                   {'+
                    '                       "Sn": "2",'+
                    '                       "Cover": false,'+
                    '                       "Text": "</photo_url><photo_url>"'+
                    '                   },'+
                    '                   {'+
                    '                       "Sn": "3",'+
                    '                       "Cover": false,'+
                    '                       "Text": "</photo_url><photo_url>"'+
                    '                   },'+
                    '                   {'+
                    '                       "Sn": "4",'+
                    '                       "Cover": false,'+
                    '                       "Text": "</photo_url><photo_url>"'+
                    '                   },'+
                    '                   {'+
                    '                       "Sn": "5",'+
                    '                       "Cover": false,'+
                    '                       "Text": "</photo_url><photo_url>"'+
                    '                   },'+
                    '                   {'+
                    '                       "Sn": "6",'+
                    '                       "Cover": false,'+
                    '                       "Text": "</photo_url><photo_url>"'+
                    '                   },'+
                    '                   {'+
                    '                       "Sn": "7",'+
                    '                       "Cover": false,'+
                    '                       "Text": "</photo_url><photo_url>"'+
                    '                   },'+
                    '                   {'+
                    '                       "Sn": "8",'+
                    '                       "Cover": false,'+
                    '                       "Text": "</photo_url>"'+
                    '                   }'+
                    '               ],'+
                    '               "Count": "8"'+
                    '           }'+
                    '       }'+
                    '    ]'+
                    '}';
                res.setBody(json);
            }
            return res;
        }
    }
    
}