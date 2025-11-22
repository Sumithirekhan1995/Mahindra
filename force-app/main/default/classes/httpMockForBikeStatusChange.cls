@isTest
global class httpMockForBikeStatusChange implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(' {"status_code":200,"response":{"data":{"success":"Marketing status updated."}}}');
        res.setStatusCode(200);
        return res;
    }

}