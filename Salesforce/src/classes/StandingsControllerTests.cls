@IsTest
public class StandingsControllerTests {
    
    static testmethod void basicInstanceTest() {
        /* Initialize the custom Settings. */
        TestUtils.initSettings();
        
        /* Create the game */
        Game__c g = new Game__c(Name = 'TEST_GAME', Status__c = 'Active');
        Database.insert(g);
        
        List<Player__c> pList = TestUtils.createTestPlayersForOneGame(g.id, 20, TestConstants.USER_LICENSE_SALESFORCE);
        
        PageReference p = Page.Standings;
        p.getParameters().put('G',g.id);
        Test.setCurrentPageReference(p);        
        
        StandingsController con = new StandingsController();
        
        System.assertEquals(pList.size(), con.standingsList.size(),'The size of players created for the game did not equal the standingslist from the controller.');
        
    }

}