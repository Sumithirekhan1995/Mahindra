@isTest
global class DealerPullfromDMSTest {
    global static testmethod void test1(){
        // fail API Log about scheduled task
        API_Log__c apiLog = new API_Log__c();
		apiLog.Response_Body__c = 'abc';
        apiLog.Tag__c = 'BatchProcessDealer_RetryJob';
        insert apiLog;
       
        
        // Test Active Dealer
        Account a = new Account();
        a.Name = 'Dealer_Test';
        a.Code__c = '1234555';
        a.Active__c = true;
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        insert a;
        
        // Email Alert records
        Email__c e = new Email__c();
        e.Name= 'test';
        e.Person_Email__c = 'test@g.co';
        insert e;
        
        // auth details
        GetAuthorizationToken__c listAuth = new GetAuthorizationToken__c();
        listAuth.Name = 'DealerStockDMS';
        listAuth.Username__c = 'Test';
        listAuth.Password__c = 'test';
        insert listAuth;
        
        // auth URLs
        Get_API_Calls__c listGetApiAuth = new Get_API_Calls__c();
        listGetApiAuth.Name = 'Get Token';
        listGetApiAuth.End_Point__c = 'GET_Token_URL';
        insert listGetApiAuth;
        
        // dealer GET URLs
        Get_API_Calls__c listGetApidealer = new Get_API_Calls__c();
        listGetApidealer.Name = 'Get Dealer';
        listGetApidealer.End_Point__c = 'GET_Fail_Dealer_URL';
        insert listGetApidealer;
        
        // mock Callout
        Test.setMock(HttpCalloutMock.class, new mockCallout());
        DealerPullfromDMS obj = new DealerPullfromDMS();
        Test.startTest();
        // success test
        obj.retry();
        API_Log__c apiLog1 = new API_Log__c();
		apiLog1.Response_Body__c = '1';
        apiLog1.Tag__c = 'BatchProcessDealer_RetryJob';
        insert apiLog1;
        obj.retry();
        
        // fail test
        listGetApidealer.End_Point__c = 'GET_Dealer_URL';
        update listGetApidealer;
       
        obj.getDealerAPI();
        
        // final Batch test
        DealerPullfromDMS.getDealerInfo();
        
        Test.stopTest();
    }
    
    global class mockCallout implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            // token
            if(req.getEndpoint().contains('GET_Token_URL')) {
                res.setHeader('Token', 'value');
                res.setStatusCode(200);
            }
            
            // fail dealer
            if(req.getEndpoint().contains('GET_Fail_Dealer_URL')) {
                res.setBody('{}');
                res.setStatusCode(500);
            } 
            
            // dealer data 
            if(req.getEndpoint().contains('GET_Dealer_URL')) {
                String json='{'+
                    '    "status": "SUCCESS",'+
                    '    "message": "",'+
                    '    "data": [{'+
                    '            "Code": "1004",'+
                    '            "Name": "V3 Car Kare",'+
                    '            "Address1": "Ram Nagar Colony,",'+
                    '            "Address2": "Gt Road,Mukerian Hoshiarpur",'+
                    '            "Pincode": "144211",'+
                    '            "City": "Mukerian",'+
                    '            "State": "Punjab",'+
                    '            "Mobile": "9876554100",'+
                    '            "Latitude": "31.6254242",'+
                    '            "Longitude": "74.84559579999996",'+
                    '            "PrincipleEmail": "v3carkare@gmail.com",'+
                    '            "SellingEmail": "v3carkare@gmail.com",'+
                    '			 "DealerSalesExecutives": ['+
                    '    			{'+
                    '			       "ExecutiveName": "MADHUR",'+
                    '			       "ExecutiveMobile": "9818724155"'+
                    '    			}'+
                    '			  ],'+
                    '			 "DealerProcurementExecutives": ['+
                    '			    {'+
                    '			       "ExecutiveName": "MADHUR",'+
                    '        		   "ExecutiveMobile": "9818724155"'+
                    '    			}'+
                    '			  ]'+
                    '        },'+
                    '        {'+
                    '            "Code": "1011",'+
                    '            "Name": "Jai Mata Di Automobiles",'+
                    '            "Address1": "NH2 Beside Road, Near Hero Showroom",'+
                    '            "Address2": "Pali Road, Dehri(Rohtas)",'+
                    '            "Pincode": "821307",'+
                    '            "City": "Rohtas ",'+
                    '            "State": "Bihar",'+
                    '            "Mobile": "8582087662",'+
                    '            "Latitude": "24.904552",'+
                    '            "Longitude": "84.193092",'+
                    '            "PrincipleEmail": "jmddehri@gmail.com",'+
                    '            "SellingEmail": "jmddehri@gmail.com",'+
                    '			 "DealerSalesExecutives": ['+
                    '    			{'+
                    '			       "ExecutiveName": "MADHUR",'+
                    '			       "ExecutiveMobile": "9818724155"'+
                    '    			}'+
                    '			  ],'+
                    '			 "DealerProcurementExecutives": ['+
                    '			    {'+
                    '			       "ExecutiveName": "MADHUR",'+
                    '        		   "ExecutiveMobile": "9818724155"'+
                    '    			}'+
                    '			  ]'+
                    '        }'+
                    '    ]'+
                    '}';
                res.setBody(json);
                res.setStatusCode(200);
            }
            return res;
        }
    }
}