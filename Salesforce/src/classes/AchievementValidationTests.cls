@IsTest
public class AchievementValidationTests {
    /* There should never be more than one achievement record for a given user and a given mission. */
    static testmethod void duplicateAchievementPerInsertTest() {
    
        /* Initialize custom settings. */
        TestUtils.initSettings();
        
        /* Create a game */
        Game__c g = new Game__c(Name = 'TEST_GAME', Status__c = 'Active');
        Database.insert(g);
              
        /* Create a user for use as the target. */ 
        User u = TestUtils.createTestUserObject(TestConstants.USER_LICENSE_SALESFORCE);
        
        /* Create a mission */
        Mission__c m = new Mission__c(Target_User__c = u.id, Name = 'TEST_MISSION', Game__c = g.id, Max_Point_Value__c = 100, Mission_Type__c = TestConstants.MISSION_TYPE_SIGNATURE);
        Database.insert(M);
        
        /* Create a player */
        Player__c p = TestUtils.createTestPlayer(g.id,TestConstants.USER_LICENSE_SALESFORCE);
        
        Achievement__c a1 = new Achievement__c(player__c = p.id, mission__c = m.id);
        Achievement__c a2 = a1.clone();
        
        List<Achievement__c> aList = new List<Achievement__c>();
        aList.add(a1);
        aList.add(a2);
            
        try {
            Database.insert(aList);
            System.assert(false,'Rules should prevent two or more achievements being created with the same player and mission values.');
        } catch (System.DMLException e) {
            System.assertEquals(StatusCode.DUPLICATE_VALUE,e.getDMLType(0),'StatusCode on the DML Exception was not returned as expected.');
        }
    }
    
    static testmethod void oneAndOnlyOneAchievementTest() {
        /* Initialize custom settings. */
        TestUtils.initSettings();
        
        /* Create a game */
        Game__c g = new Game__c(Name = 'TEST_GAME', Status__c = 'Active');
        Database.insert(g);
        
        /* Create a user for use as the target. */ 
        User u = TestUtils.createTestUserObject(TestConstants.USER_LICENSE_SALESFORCE);
        
        /* Create a mission */
        Mission__c m = new Mission__c(Target_User__c = u.id, Name = 'TEST_MISSION', Game__c = g.id, Max_Point_Value__c = 100, Mission_Type__c = TestConstants.MISSION_TYPE_SIGNATURE);
        Database.insert(M);
        
        /* Create a player */
        Player__c p = TestUtils.createTestPlayer(g.id,TestConstants.USER_LICENSE_SALESFORCE);
        
        Achievement__c a1 = new Achievement__c(player__c = p.id, mission__c = m.id);
        Achievement__c a2 = a1.clone();
        Database.insert(a1);
        System.assert(a1.id != null, 'No ID means this insert failed.');
            
        try {
            Database.insert(a2);
            System.assert(false,'Rules should prevent a second achievement with the same player and mission values as an existing one from being created.');
        } catch (System.DMLException e) {
            System.assertEquals(StatusCode.DUPLICATE_VALUE,e.getDMLType(0),'StatusCode on the DML Exception was not returned as expected.');
        }
    }
    
    /* Achievements should not be create-able on for games that have ended. 
       for this validation testing the definition of "ended" is when the current
       time has passed the End_Date_Time__c value on the Game. */
    static testmethod void expiredGameTimeAchievementTest() {
        /* */
        /* Initialize custom settings. */
        TestUtils.initSettings();
        
        /* Create a game */
        Game__c g = new Game__c(Name = 'TEST_GAME', Status__c = 'Active', Start_Date_Time__c = DateTime.now().addDays(-2), End_Date_Time__c = DateTime.now().addMinutes(-5));
        Database.insert(g);
        
        /* Create a user for use as the target. */ 
        User u = TestUtils.createTestUserObject(TestConstants.USER_LICENSE_SALESFORCE);
        
        /* Create a mission */
        Mission__c m = new Mission__c(Target_User__c = u.id, Name = 'TEST_MISSION', Game__c = g.id, Max_Point_Value__c = 100, Mission_Type__c = TestConstants.MISSION_TYPE_SIGNATURE);
        Database.insert(M);
        
        /* Create a player */
        Player__c p = TestUtils.createTestPlayer(g.id,TestConstants.USER_LICENSE_SALESFORCE);
        
        /* Create the achievement on the mission related to the expired game. */
        Achievement__c a = new Achievement__c(player__c = p.id, mission__c = m.id);
        
        try{
            Database.insert(a);
            System.assert(false,'Insert of an Achievement__c record under an expired game should have failed.');
        } catch(System.DMLException e) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDMLType(0),'StatusCode on the DML Exception was not returned as expected.');
        }
    }
    
    /* assert that a mission can not be completed after the mission end time has past. */
    static testmethod void expiredMissionTimeAchievementTest() {
        /* Initialize custom settings. */
        TestUtils.initSettings();
        
        /* Create a game */
        Game__c g = new Game__c(Name = 'TEST_GAME', Status__c = 'Active', Start_Date_Time__c = DateTime.now().addDays(-2), End_Date_Time__c = DateTime.now().addMinutes(-5));
        Database.insert(g);
        
        /* Create a user for use as the target. */ 
        User u = TestUtils.createTestUserObject(TestConstants.USER_LICENSE_SALESFORCE);
        
        /* Create a mission */
        Mission__c m = new Mission__c(Mission_Start_Time__c = Datetime.now().addDays(-3), Mission_End_Time__c = Datetime.now().addHours(-1),Target_User__c = u.id, Name = 'TEST_MISSION', Game__c = g.id, Max_Point_Value__c = 100, Mission_Type__c = TestConstants.MISSION_TYPE_SIGNATURE);
        Database.insert(M);
        
        /* Create a player */
        Player__c p = TestUtils.createTestPlayer(g.id,TestConstants.USER_LICENSE_SALESFORCE);
        
        /* Create the achievement on the mission related to the expired game. */
        Achievement__c a = new Achievement__c(player__c = p.id, mission__c = m.id);
        
        try{
            Database.insert(a);
            System.assert(false,'Insert of an Achievement__c record under an expired mission should have failed.');
        } catch(System.DMLException e) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDMLType(0),'StatusCode on the DML Exception was not returned as expected.');
        }
    }
}