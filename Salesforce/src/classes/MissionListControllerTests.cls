@IsTest
public class MissionListControllerTests {
    
    /* This basic test asserts that a list of missions with some completed 
       and some not completed is returned as expected. */
    static testmethod void getMissionListTest() {
        /* Initialize the custom Settings. */
        TestUtils.initSettings();
        
        /* Create the game */
        Game__c g = new Game__c(Name = 'TEST_GAME', End_Date_Time__c = Datetime.now().addDays(2));
        Database.insert(g);
        
        /* Create the player */
        Player__c p = TestUtils.createTestPlayer(g.id, TestConstants.USER_LICENSE_SALESFORCE);
        
        /* Create 3 missions */
        List<Mission__c> mList = new List<Mission__c>();
        for(Integer i=0;i<3;i++) {
            Mission__c m = new Mission__c(Name = 'TEST_MISSION_' + i, Mission_Type__c = 'Camera', Max_Point_Value__c = 100, Mission_Start_Time__c = Datetime.now().addHours(-12),Game__c = g.id);
            mList.add(m);
        }
        
        Database.insert(mList);
        
        /* Create an achievement for the first mission. */
        Achievement__c a = new Achievement__c(Mission__c = mList.get(0).id, player__c = p.id);
        Database.insert(a);
        
        ApexPages.PageReference pr = Page.MissionList;
        pr.getParameters().put('G',g.id);
        pr.getParameters().put('P',p.id);
        
        Test.setCurrentPage(pr);
        MissionListController c = new MissionListController();
        
        System.assertEquals(g.id,c.gameId,'Parameter G was not set to the game id in the controller.');
        System.assertEquals(p.id,c.playerID,'Parameter P was not set to the player id in the controller.');        
        
        List<MissionListController.Mission> missionList = new List<MissionListController.Mission>();
        /* Switch to run as the player */
        System.runAs(new User(Id = p.user__c)) {
            /* Invoke the completeCameraMissionType method */
            missionList = MissionListController.getMissionList(g.id);            
        }
        
        System.assertEquals(mList.size(), missionList.size(), 'Size of the list of Mission__c records did not match the size of the list of MissionController.Mission objects from the remote controller method.');
        for(MissionListController.Mission m:missionList) {
            if(a.Mission__c == m.mission.id) { System.assert(m.completed, 'Completed property on the MissionController.Mission object was not true for the completed mission. '); }
            else { System.assert(!m.completed, 'Completed property on the MissionControllerExtension.Mission object was true for an incompleted mission. ');}
        }
    }

}