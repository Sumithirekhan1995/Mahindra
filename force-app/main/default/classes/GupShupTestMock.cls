@isTest
global class GupShupTestMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
     	System.assertEquals('GET', req.getMethod());
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('success | 918123565859 | 4154116409096626228-107148400282911674');
        res.setStatusCode(200);
        return res;
    }

}