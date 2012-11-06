public class IdentityUtils {
    
    /* Persist the refresh token for posting back to the remote org. */
    public static void saveToken(Id userId, String token) {
        System.debug('IN SAVE TOKEN');
        Facebook_Connection_Settings__c userSettings = Facebook_Connection_Settings__c.getValues(userId);
        System.debug('SETTINGS: ' + userSettings);
        if(userSettings == null) { userSettings = new Facebook_Connection_Settings__c(SetupOwnerId = userId); }
        userSettings.Access_Token__c = token;
        Database.upsertResult r = Database.upsert(userSettings);
        System.debug('RESULT: ' + r);
    }
    
    /* TODO: fill out this method using the sample code from Chuck. */
    public static String encryptToken(String unencryptedToken) {
        String encryptedToken = unencryptedToken;
        return encryptedToken;
    }
    
    /* TODO: fill out this method using the sample code from Chuck. */
    public static String decryptToken(String encryptedToken) {
        String decryptedToken = encryptedToken;
        return decryptedToken;
    }
    
    /* TODO: Calculate the alias for the user. */
    public static String getAlias(String firstname, String lastname) {
        String alias;
        Integer maxlastnamelength = 7;
        if(firstname != null && !''.equals(firstname)) { alias = firstname.substring(0,1); }
        else { 
            alias = '';
            maxlastnamelength = 8; 
        }
       
        if(lastname.length() > maxlastnamelength) { alias += lastname.substring(0,maxlastnamelength);}
        else { alias += lastname;}
            
        return alias;
    }
}