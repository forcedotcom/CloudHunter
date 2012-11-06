/* Class that mimics the standard HTTP class but incorporates
   a switch for setting the response in a test. */
public class MyHttp {
    
    /* Static variable containing the current instance. */
    private static MyHttp instance;
    public static MyHttp getInstance() {
        if(instance == null) { instance = new MyHttp(); }
        return instance;
    }

    /* Exception for use when a caller tries to set the 
       mockResponse outside of test context. */
    public class IllegalContextException extends Exception {}
    final Http h;
    Integer index;
    List<HttpResponse> mockResponseList;
    
    /* Method for setting multiple responses in a multi-callout method
       invocation. */
    public void setMockResponseList(List<HttpResponse> resList) {
        if(Test.isRunningTest()) { mockResponseList = resList; }
        else { throw new IllegalContextException('You can not set the mockResponse outside of a test.'); }
    }
    
    /* Make the ctor private so callers have to go through 
       the getInstance route. */
    private MyHttp() {
        h     = new Http();
        index = 0;
    }
    
    public HttpResponse send(HttpRequest req) {
        HttpResponse res;
        if(Test.isRunningTest() && mockResponseList != null && mockResponseList.size() > 0) { 
            res = mockResponseList.get(index);
            index++;
        }
        else { res = h.send(req); }
        
        return res;
    }
}