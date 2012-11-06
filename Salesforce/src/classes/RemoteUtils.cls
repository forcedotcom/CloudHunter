/* Methods for calling out to a remote salesforce organization
   to read and write data. Primarily Chatter related but not exclusively. 
   Also contains functions using callouts that are required because of Chatter
   SObject API deficiencies. */
public class RemoteUtils {
    
    /* */
    public static Id copyRemoteProfilePhoto(Id userId, String photoUrl, String token) {
        
        /* Get the profile photo from the remote organization. */
        Blob photo = getPhotoFromURL(photoUrl,token);
        
        /* Create the file (content) record in the local org with the blob from the 
           remote org. */
        return createFileRecord(userId, photo);
    }
    
    /* Creates the chatter profile photo from the body of the specified document record Id
       for the given userId. */
    @future(callout=true)
    public static void createProfilePhoto(String token, Id fileId, String sid, String host) {
        
        Facebook_Connection_Settings__c userSettings = new Facebook_Connection_Settings__c(SetupOwnerId = UserInfo.getUserId());
        userSettings.Access_Token__c = token;
        
        HttpRequest req = new HttpRequest();
        String u = host + '/services/data/v25.0/chatter/users/me/photo?fileId=' + fileId;
        req.setEndpoint(u);

        req.setHeader('Authorization', 'OAuth ' + sid);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setMethod('POST');
        
        MyHttp h = MyHttp.getInstance();
        HttpResponse res = h.send(req);
        system.debug('HttpResonse.Status: ' + res.getStatus());
        system.debug('HttpResonse.StatusCode: ' + res.getStatusCode()); 
        system.debug('HttpResonse.Body: ' + res.getBody());    
        System.debug('CREATEPROFILEPHOTO RESPONSE: ' + res.getBody());
        
        /* Now mark the user as initialized. */
        if(res.getStatusCode() == 201) {
            userSettings.Initialized__c = true;
            userSettings.Photo_Id__c = fileId;
        }
        Database.upsertResult r = Database.upsert(userSettings);
        System.debug('USER SETTING UPSERT RESULT: ' + r);
    }
    
    /* Callout to the url to get the photo blobs. 
       TODO: Make this private when done testing. */
    public static Blob getPhotoFromURL(String URL, String token) {
        MyHttp h = MyHttp.getInstance();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL + token);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        if(res.getStatusCode() == 302) {
        	String redirectUrl = res.getHeader('Location');
            System.debug('redirectUrl: ' + redirectUrl);
            req.setEndpoint(redirectUrl);
            res = h.send(req);
        }
       
        System.debug('GETPHOTOFROMURL RESPONSE: ' + res.getBody());
        return res.getBodyAsBlob();
    }
    
    /* Creates a file record in the content schema as a holding spot 
       until a callout can be used to write the file to the user's 
       profile photo in a secondary step. The return ID is a ContentDocument
       record ID and NOT a ContentVersion.*/
    public static Id createFileRecord(Id userId, Blob file) { 
        ContentVersion v = new ContentVersion(FirstPublishLocationId = userId, 
                                              PathOnClient='/'+userId+'.jpeg', 
                                              Title = userId, 
                                              VersionData = file);
        Database.insert(v);
        return [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :v.id].ContentDocumentId;
    }
    
}