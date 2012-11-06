/* These tests assure the proper logic is enforced on the various mission types. */
@IsTest
public class MissionValidationTests {

    /* Scanner type missions should always have a target_user__c and the 
       related user should have a non-null qrcode field value. */
    static testmethod void scannerTypeValidationTest() {
        /* Create the game */
        Game__c g = new Game__c(Name = 'TEST_GAME');
        Database.insert(g);
        
        /* Create a scanner type mission without a target user. */
        Mission__c m = new Mission__c(Name = 'TEST_MISSION', Mission_Type__c = TestConstants.MISSION_TYPE_SCANNER, Max_Point_Value__c = 100, Mission_Start_Time__c = Datetime.now().addHours(-12),Game__c = g.id);
        try{
            Database.insert(m);
            System.assert(false,'Insert of a new scanner mission succeeded without a target user value. This is required and needs to be enforced.');
        } catch(System.DMLException e) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDMLType(0),'StatusCode on the DML Exception was not returned as expected.');
        }
        
        /* TODO: need to apply qrcode logic once confirmation on the approach is identified. -AW
        /* Get a profile for the specified licensetype. 
        Profile p = [SELECT Id FROM Profile WHERE UserLicense.name = :TestConstants.USER_LICENSE_SALESFORCE LIMIT 1]; 
        
        /* Create a user without a qrcode field value. 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', 
                          LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName=TestConstants.USER_NAME_FOR_TESTS);
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Database.insert(u);
        }
        
        /* Update the mission record with the target user value 
           
        m.Target_User__c = u.id;
        try {
            Database.insert(m);
            System.assert(false,'Insert of a scanner mission succeeded with a target user value pointing to a user without a QR code value.');
        } catch(System.DMLException e) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDMLType(0),'StatusCode on the DML Exception was not returned as expected.');
        }
        */
    }
    
    /* Signature type missions should always have a target_user__c */
    static testmethod void signatureTypeValidationTest() {
        /* Create the game */
        Game__c g = new Game__c(Name = 'TEST_GAME');
        Database.insert(g);
        
        /* Create a signature type mission without a target user. */
        Mission__c m = new Mission__c(Name = 'TEST_MISSION', Mission_Type__c = TestConstants.MISSION_TYPE_SIGNATURE, Max_Point_Value__c = 100, Mission_Start_Time__c = Datetime.now().addHours(-12),Game__c = g.id);
        try{
            Database.insert(m);
            System.assert(false,'Insert of a new signature mission succeeded without a target user value. This is required and needs to be enforced.');
        } catch(System.DMLException e) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION,e.getDMLType(0),'StatusCode on the DML Exception was not returned as expected.');
        }
    }
    
    /* Check-in type missions should always have a Place__c value. This is currently enforced
       by virtue of the look up field having a required attribute which also prevents 
       deletion of any place that has */
    static testmethod void checkinTypeValidationTest() { 
        /* Create the game */
        Game__c g = new Game__c(Name = 'TEST_GAME');
        Database.insert(g);
        
        /* Create a mission */
        Mission__c m = new Mission__c(Name = 'TEST_MISSION', Mission_Type__c = TestConstants.MISSION_TYPE_CHECKIN, Max_Point_Value__c = 100, Mission_Start_Time__c = Datetime.now().addHours(-12),Game__c = g.id);
        try {
            Database.insert(m);
            System.assert(false, 'Insert of a check-in mission succeeded without a specified place.');
        } catch(System.DMLException e) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION,e.getDMLType(0),'StatusCode on the DML Exception was not returned as expected.');
        }
    }
}