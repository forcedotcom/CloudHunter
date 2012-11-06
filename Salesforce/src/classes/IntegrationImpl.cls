public class IntegrationImpl implements IntegrationIface {
    
    /* Utilize */
    public Id initializeUser() {
        /* current user's id */
        Id userId = UserInfo.getUserId();
        
        /* Get the facebook access token */
        String token = Auth.AuthToken.getAccessToken(Facebook_Connection_Settings__c.getOrgDefaults().Auth_Provider_Id__c, Facebook_Connection_Settings__c.getOrgDefaults().Auth_Provider_Name__c);
        System.debug('token:'+token);
        System.debug('userid:'+userId);
        
        Facebook_Connection_Settings__c userSettings = Facebook_Connection_Settings__c.getValues(userId);	    
                
        /* copy the photos to the local org. If user not initialized.  */
        if(userSettings == null || !userSettings.Initialized__c ) {
            
            /* Get the photo from the urls in the remote user and copy to a file 
               in the local org. */
            String facebookPhotoUrl = 'https://graph.facebook.com/me/picture?type=large&access_token=';
            Id fileId = RemoteUtils.copyRemoteProfilePhoto(userId, facebookPhotoUrl, token);
            
            /* Finally callout to put the file on the profile in the local org. This 
               will be processed asynchronously because:
                    1) Prior methods invoked above establish transactions which block callouts
                    2) Chatter photo processing is asynchronous anyway. */
            RemoteUtils.createProfilePhoto(token, fileId, UserInfo.getSessionID(), Facebook_Connection_Settings__c.getOrgDefaults().My_Domain__c);
            
            return fileId;
        }       
        
        return null;
    }

    public void postToChatter(String message, String userId, Blob file, String fileName) {
        /*TODO: Initial implementation will not post to Facebook */
        //if(!Facebook_Connection_Settings__c.getOrgDefaults().Disable_Chatter_Posting__c) {
        //    RemoteUtils.postToChatter(message, userId, file, fileName);   
        //}
    }
}