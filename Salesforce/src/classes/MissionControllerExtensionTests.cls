/* Tests that primarily cover the MissionController class but include
   assertions for declarative logic, i.e. Workflow, RSFs, etc. */
@IsTest
public class MissionControllerExtensionTests {
    
    /* Validates the mission completion but asserts no feeditem was created. */
    static testmethod void completeCameraMissionTypeWithIntegrationTest() {
        
        String classname = 'IntegrationImplDONOTADDTOPACKAGE';
        /* This test should only run in an org with a class with the above name. */
        if([SELECT Count() FROM ApexClass WHERE Name = :classname]>0) {
            
            /* Initialize the custom Settings. */
            Cloud_Hunter_Settings__c s = new Cloud_Hunter_Settings__c(SetupOwnerId = UserInfo.getOrganizationId(), Integration_Class_Name__c = classname );
            TestUtils.initSettings(s);
            
            /* Create the game */
            Game__c g = new Game__c(Name = 'TEST_GAME');
            Database.insert(g);
            
            /* Create the player */
            Player__c p = TestUtils.createTestPlayer(g.id, TestConstants.USER_LICENSE_SALESFORCE);
            
            /* Create a mission */
            Mission__c m = new Mission__c(Target_User__c = UserInfo.getUserId(), Name = 'TEST_MISSION', Mission_Type__c = 'Camera', Max_Point_Value__c = 100, Mission_Start_Time__c = Datetime.now().addHours(-12),Game__c = g.id);
            Database.insert(m);
            
            /* Switch to run as the player */
            System.runAs(new User(Id = p.user__c)) {
                /* Invoke the completeCameraMissionType method */
                MissionControllerExtension.completeCameraMissionType('IMAGESTRING', m.id, g.id);            
            }
            
            /* Perform assertions:
                - Achievement is created
                - Achievement has the correct point total
                - Player has the correct total value
                - Attachment is created 
                - Achievement has the imagId 
                - Chatter post is created against the target user (failing for now) */
            
            /* Get the Mission back from the database with the formula value for the current points. */
            m = [SELECT Current_Point_Value__c, Target_User__c FROM Mission__c WHERE Id = :m.id];
            
            /* Get the player's updated info. */
            p = [SELECT Total_Points_Awarded__c, User__c FROM Player__c WHERE Id = :p.id];
            
            Achievement__c a = doCommonAchievementAssertions(m,p);
            
            /* Check for the Attachment */
            List<Attachment> atList = [SELECT Id FROM Attachment WHERE ParentId = :a.id AND ContentType = 'image/jpg'];
            System.assert(atList.size() == 1, 'Attachment was not created.');
            System.assertEquals(atList[0].id, a.Image_Id__c, 'Image ID on the achievement did not match the attachment ID.');
            
            /* The Following assertion refers to code that does not yet exist but was discussed. 
               The logic here assumes that the image taken by the camera for the mission will be posted
               to the wall of the user identified by the target userId on the mission. As a possible alternative to 
               either the attachment or the post to the target user's wall the logic could post the photo to the 
               wall of the mission record. */
            List<FeedItem> fList = new List<FeedItem>([SELECT Id FROM FeedItem WHERE ParentId = :m.Target_User__c AND Type = 'ContentPost' AND InsertedById = :p.user__c]);
            System.assert(fList.size() == 0, 'FeedItem list size should have been zero when org settings specify an integration class name. Settings value: ' + s); 
        }
    }

    /* Primary positive test for completing a camera mission and making
       sure points are awarded to the player. */
    static testmethod void completeCameraMissionTypeTest() {
        /* Initialize the custom Settings. */
        TestUtils.initSettings();
        
        /* Create the game */
        Game__c g = new Game__c(Name = 'TEST_GAME');
        Database.insert(g);
        
        /* Create the player */
        Player__c p = TestUtils.createTestPlayer(g.id, TestConstants.USER_LICENSE_SALESFORCE);
        
        /* Create a mission */
        Mission__c m = new Mission__c(Target_User__c = UserInfo.getUserId(), Name = 'TEST_MISSION', Mission_Type__c = 'Camera', Max_Point_Value__c = 100, Mission_Start_Time__c = Datetime.now().addHours(-12),Game__c = g.id);
        Database.insert(m);
        
        /* Switch to run as the player */
        System.runAs(new User(Id = p.user__c)) {
            /* Invoke the completeCameraMissionType method */
            MissionControllerExtension.completeCameraMissionType('IMAGESTRING', m.id, g.id);            
        }
        
        /* Perform assertions:
            - Achievement is created
            - Achievement has the correct point total
            - Player has the correct total value
            - Attachment is created 
            - Achievement has the imagId 
            - Chatter post is created against the target user (failing for now) */
        
        /* Get the Mission back from the database with the formula value for the current points. */
        m = [SELECT Current_Point_Value__c, Target_User__c FROM Mission__c WHERE Id = :m.id];
        
        /* Get the player's updated info. */
        p = [SELECT Total_Points_Awarded__c, User__c FROM Player__c WHERE Id = :p.id];
        
        Achievement__c a = doCommonAchievementAssertions(m,p);
        
        /* Check for the Attachment */
        List<Attachment> atList = [SELECT Id FROM Attachment WHERE ParentId = :a.id AND ContentType = 'image/jpg'];
        System.assert(atList.size() == 1, 'Attachment was not created.');
        System.assertEquals(atList[0].id, a.Image_Id__c, 'Image ID on the achievement did not match the attachment ID.');
        
        /* The Following assertion refers to code that does not yet exist but was discussed. 
           The logic here assumes that the image taken by the camera for the mission will be posted
           to the wall of the user identified by the target userId on the mission. As a possible alternative to 
           either the attachment or the post to the target user's wall the logic could post the photo to the 
           wall of the mission record. */
        List<FeedItem> fList = [SELECT Id FROM FeedItem WHERE ParentId = :m.Target_User__c AND Type = 'ContentPost' AND InsertedById = :p.user__c];
        System.assert(fList.size() == 1, 'FeedItem was not found.'); 
        
    }
    
    /* Primary positive test for completing a scanner mission and making
       sure points are awarded to the player. */
    static testmethod void completeScanMissionTypeTest() {
        /* Initialize the custom Settings. */
        TestUtils.initSettings();
        
        /* Create the game */
        Game__c g = new Game__c(Name = 'TEST_GAME');
        Database.insert(g);
        
        /* Create the player */
        Player__c p = TestUtils.createTestPlayer(g.id, TestConstants.USER_LICENSE_SALESFORCE);
        
        /* Create a mission */
        Mission__c m = new Mission__c(Target_User__c = p.User__c, Name = 'TEST_MISSION', Mission_Type__c = TestConstants.MISSION_TYPE_SCANNER, Max_Point_Value__c = 100, Mission_Start_Time__c = Datetime.now().addHours(-12),Game__c = g.id);
        Database.insert(m);
        
        Decimal result;
        /* Switch to run as the player */
        System.runAs(new User(Id = p.user__c)) {
            /* Invoke the completeCameraMissionType method */
            result = MissionControllerExtension.completeScanMissionType(TestConstants.USER_QR_CODE_VALUE, m.id, g.id);            
        }
        
        System.assert(result != -1,'The result from the MissionControllerExtension.completeScanMissionType method should have been a non-negative value');
        
        /* Perform assertions:
            - Achievement is created
            - Achievement has the correct point total
            - Player has the correct total value */
        
        /* Get the Mission back from the database with the formula value for the current points. */
        m = [SELECT Current_Point_Value__c, Target_User__c FROM Mission__c WHERE Id = :m.id];
        
        /* Get the player's updated info. */
        p = [SELECT Total_Points_Awarded__c, User__c FROM Player__c WHERE Id = :p.id];
        
        Achievement__c a = doCommonAchievementAssertions(m,p);
    }
    
    /* Primary positive test for completing a scanner mission not related to a user and making
       sure points are awarded to the player. */
    static testmethod void completeNonUserScanMissionTypeTest() {
        /* Initialize the custom Settings. */
        TestUtils.initSettings();
        
        /* Create the game */
        Game__c g = new Game__c(Name = 'TEST_GAME');
        Database.insert(g);
        
        /* Create the player */
        Player__c p = TestUtils.createTestPlayer(g.id, TestConstants.USER_LICENSE_SALESFORCE);
        
        /* Create a mission */
        Mission__c m = new Mission__c(Non_User_Validation_Code__c = 'TESTNONUSERCODE', Name = 'TEST_MISSION', Mission_Type__c = TestConstants.MISSION_TYPE_SCANNER, Max_Point_Value__c = 100, Mission_Start_Time__c = Datetime.now().addHours(-12),Game__c = g.id);
        Database.insert(m);
        
        Decimal result;
        /* Switch to run as the player */
        System.runAs(new User(Id = p.user__c)) {
            /* Invoke the completeCameraMissionType method */
            result = MissionControllerExtension.completeScanMissionType('TESTNONUSERCODE', m.id, g.id);            
        }
        
        System.assert(result != -1,'The result from the MissionControllerExtension.completeScanMissionType method should have been a non-negative value');
        
        /* Perform assertions:
            - Achievement is created
            - Achievement has the correct point total
            - Player has the correct total value */
        
        /* Get the Mission back from the database with the formula value for the current points. */
        m = [SELECT Current_Point_Value__c, Target_User__c FROM Mission__c WHERE Id = :m.id];
        
        /* Get the player's updated info. */
        p = [SELECT Total_Points_Awarded__c, User__c FROM Player__c WHERE Id = :p.id];
        
        Achievement__c a = doCommonAchievementAssertions(m,p);
    }
    
    /* Primary positive test for completing a checkin mission and making
       sure points are awarded to the player. */
    static testmethod void completeCheckInMissionTypeTest() {
        /* Initialize the custom Settings. */
        TestUtils.initSettings();
        
        /* Create the game */
        Game__c g = new Game__c(Name = 'TEST_GAME');
        Database.insert(g);
        
        /* Create the player */
        Player__c p = TestUtils.createTestPlayer(g.id, TestConstants.USER_LICENSE_SALESFORCE);
        
        /* Create a place for the user to checkin. */
        Place__c pl = new Place__c(Name = 'TEST_PLACE', Location__Latitude__s = TestConstants.GEO_LATITUDE, 
                                   Location__Longitude__s = TestConstants.GEO_LONGITUDE, Distance_Tolerance__c = 100,
                                   Address1__c = '10 Main', Postal_Code__c = '00000');
        Database.insert(pl);
        
        /* Create a mission */
        Mission__c m = new Mission__c(Place__c = pl.id, Name = 'TEST_MISSION', Mission_Type__c = 'Check-in', Max_Point_Value__c = 100, Mission_Start_Time__c = Datetime.now().addHours(-12),Game__c = g.id);
        Database.insert(m);
        
        Decimal result;
        /* Switch to run as the player */
        System.runAs(new User(Id = p.user__c)) {
            /* Invoke the completeCameraMissionType method */
            result = MissionControllerExtension.completeCheckinMissionType(TestConstants.GEO_LATITUDE, TestConstants.GEO_LONGITUDE, m.id, g.id);            
        }
        
        System.assert(result != -1,'The result from the MissionControllerExtension.completeCheckinMissionType method should have been non-negative.');
                
        /* Get the Mission back from the database with the formula value for the current points. */
        m = [SELECT Current_Point_Value__c, Target_User__c FROM Mission__c WHERE Id = :m.id];
        
        /* Get the player's updated info. */
        p = [SELECT Total_Points_Awarded__c, User__c FROM Player__c WHERE Id = :p.id];
        
        Achievement__c a = doCommonAchievementAssertions(m,p);
    }
    
    /* Primary positive test for completing a signature capture mission and making
       sure points are awarded to the player. */
    static testmethod void completeSignatureMissionTypeTest() {
        /* Initialize the custom Settings. */
        TestUtils.initSettings();
        
        /* Create the game */
        Game__c g = new Game__c(Name = 'TEST_GAME');
        Database.insert(g);
        
        /* Create the player */
        Player__c p = TestUtils.createTestPlayer(g.id, TestConstants.USER_LICENSE_SALESFORCE);
        
        /* Create a mission */
        Mission__c m = new Mission__c(Name = 'TEST_MISSION', Target_User__c = UserInfo.getUserId(), Mission_Type__c = 'Signature', Max_Point_Value__c = 100, Mission_Start_Time__c = Datetime.now().addHours(-12),Game__c = g.id);
        Database.insert(m);
        
        /* Switch to run as the player */
        System.runAs(new User(Id = p.user__c)) {
            /* Invoke the completeCameraMissionType method */
            MissionControllerExtension.completeSignatureMissionType('SIGNATURE', m.id, g.id);            
        }
                
        /* Get the Mission back from the database with the formula value for the current points. */
        m = [SELECT Current_Point_Value__c, Target_User__c FROM Mission__c WHERE Id = :m.id];
        
        /* Get the player's updated info. */
        p = [SELECT Total_Points_Awarded__c, User__c FROM Player__c WHERE Id = :p.id];
        
        Achievement__c a = doCommonAchievementAssertions(m,p);   
        
        /* Check for the Attachment */
        List<Attachment> atList = [SELECT Id FROM Attachment WHERE ParentId = :a.id AND ContentType like 'image/%'];
        System.assert(atList.size() == 1, 'Attachment was not created.');
        System.assertEquals(atList[0].id, a.Image_Id__c, 'Image ID on the achievement did not match the attachment ID.');
    }
    
    /* Main test to make sure that the proper veriosn of PhoneGap (i.e iOS vs Android) is inserted into the page dom
    depending on the user-agent HTTP header*/
    static testmethod void testDynamicVFComponents() {
        
        /* Initialize the custom Settings. */
        TestUtils.initSettings();
        
        /* Create the game */
        Game__c g = new Game__c(Name = 'TEST_GAME');
        Database.insert(g);
        
        /* Create the player */
        Player__c p = TestUtils.createTestPlayer(g.id, TestConstants.USER_LICENSE_SALESFORCE);
        
        /* Create a mission */
        Mission__c m = new Mission__c(Target_User__c = UserInfo.getUserId(), Name = 'TEST_MISSION', Mission_Type__c = 'Camera', Max_Point_Value__c = 100, Mission_Start_Time__c = Datetime.now().addHours(-12),Game__c = g.id);
        Database.insert(m);
        
        ApexPages.StandardController c = new ApexPages.StandardController(m);
        
        Test.setCurrentPage(Page.Mission);
        MissionControllerExtension contr = new MissionControllerExtension(c);
        
        //Simulate that the page is being invoked from an iPhone
        ApexPages.currentPage().getHeaders().put('User-Agent', 'iPhone');
        
        //Invoke the dynamic PhoneGapJS VF component
        Component.Apex.IncludeScript phoneGapJS = contr.getPhoneGapJS();
        System.assertEquals(phoneGapJS.expressions.value,'{!URLFOR($Resource.PhoneGap1_8_1_iOS)}','iOS version of PhoneGap JS was not included');

        //Invoke the dynamic Bar Code Scanner VF component
        Component.Apex.IncludeScript barCodeJS = contr.getBarCodeScannerJS();
        System.assertEquals(barCodeJS.expressions.value,'{!URLFOR($Resource.BarCodeScanneriOS)}','iOS version of Bar Code JS was not included');

        //Simulate that the page is being invoked from an Android phone
        ApexPages.currentPage().getHeaders().put('User-Agent', 'Android');
        
        //Invoke the dynamic PhoneGapJS VF component
        phoneGapJS = contr.getPhoneGapJS();
        System.assertEquals(phoneGapJS.expressions.value,'{!URLFOR($Resource.PhoneGap1_8_1_Android)}','Android version of PhoneGap JS was not included');

        //Invoke the dynamic Bar Code Scanner VF component
        barCodeJS = contr.getBarCodeScannerJS();
        System.assertEquals(barCodeJS.expressions.value,'{!URLFOR($Resource.BarCodeScannerAndroid)}','Android version of Bar Code JS was not included');

    }
    
    static Achievement__c doCommonAchievementAssertions(Mission__c m, Player__c p) {
        /* Get the expected achievement result. */
        List<Achievement__c> aList = [SELECT Id, Points_Awarded__c, Image_Id__c FROM Achievement__c WHERE Player__c = :p.id AND Mission__c = :m.id];
        System.assert(aList.size() == 1, 'The Achievement was NOT created as expected.');
        Achievement__c a = aList[0];
        System.assertEquals(a.Points_Awarded__c, m.Current_Point_Value__c, 'Points awarded on the achievement did not match the current point value on the mission.');
        
        System.assertEquals(p.Total_Points_Awarded__c, a.Points_Awarded__c, 'Total points on Player did not match the points awarded for the achievement. ');
        
        /* Update the max point value on the mission to be lower (causing formula to have a different current value on the mission)
           and do a negative test to be sure the score does not change on either the achievement or the player. */
        Double oldMissionPointValue = m.Current_Point_Value__c;
        m.Max_Point_Value__c = oldMissionPointValue / 2;
        Database.update(m);
        Double newMissionPointValue = [SELECT Current_Point_Value__c FROM Mission__c WHERE Id = :m.id].Current_Point_Value__c;
        System.assert(oldMissionPointValue != newMissionPointValue, 'Old and new current mission point values were the same after dropping the value from 100 to 50 and updating the mission.');
        
        Double oldPlayerPointValue = p.Total_Points_Awarded__c;
        p = [SELECT Total_Points_Awarded__c, User__c FROM Player__c WHERE Id = :p.id];
        System.assertEquals(p.Total_Points_Awarded__c, oldPlayerPointValue, 'The total points on the player changed after updating the mission max point value.');
        
        Double oldAchivementPointValue = a.Points_Awarded__c;
        a = [SELECT Points_Awarded__c FROM Achievement__c WHERE Id = :a.id];
        System.assertEquals(a.Points_Awarded__c, oldAchivementPointValue, 'The points awarded on the achievement changed after updating the mission max point value.');
        
        /* Finally, touch the Achievement and make sure the point value remains the same. */
        Database.update(a);
        a = [SELECT Points_Awarded__c, Image_Id__c FROM Achievement__c WHERE Id = :a.id];
        System.assertEquals(a.Points_Awarded__c, oldAchivementPointValue, 'The points awarded on the achievement changed after updating the achievement following a change to the mission max point value.');
        
        return a;
    }
    
    /* Users should not be able to scan their own badge. */
    static testmethod void checkScanTargetUserNotRunningUserTest(){}
    
    /* Employees should not be able to scan their own badge. */
    static testmethod void checkScanTargetEmployeeNotSelfTest() {}
    
    
}