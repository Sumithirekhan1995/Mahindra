/*
 * Class for Mock Response - Auth Data
 * Added by swetha@warpdrivetech.in
*/
public class HttpMockForAuthData implements HttpCalloutMock {
    private Integer statusCode;
    public HttpMockForAuthData(Integer statusCode) {
        this.statusCode = statusCode;
    }
	public HttpResponse respond(HttpRequest req) {
        String json = 'Authorized';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Authorization', 'value');
        res.setBody(json);
        res.setStatusCode(statusCode);
        return res;
    }
}