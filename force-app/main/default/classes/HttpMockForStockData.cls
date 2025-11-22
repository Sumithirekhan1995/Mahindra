/*
 * Class for Mock Response - Stock Data
 * Added by swetha@warpdrivetech.in
*/
@isTest
public class HttpMockForStockData implements HttpCalloutMock {
    Integer statusCode;
    public HttpMockForStockData(Integer statusCode) {
        this.statusCode = statusCode;
    }
    public HttpResponse respond(HttpRequest req) {
        String json=		'{'+
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
		''+
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
		''+
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
		''+
		'    ]'+
		'}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Token', 'value');
        res.setBody(json);
        res.setStatusCode(statusCode);
        return res;
    }
}