/* Interface containing the integration methods for deployment.*/
public interface IntegrationIface {

    Id initializeUser();
    
    /* posts a message to chatter in the remote organization. The user ID here should be
       the userId for the user in the local organization. It's up to the integration to 
       perform the mapping. */
    void postToChatter(String message, String userId, Blob file, String fileName);
    
}