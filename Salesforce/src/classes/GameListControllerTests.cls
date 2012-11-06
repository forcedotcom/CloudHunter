@IsTest
public class GameListControllerTests {
    
    static testmethod void checkPlayerRecordZeroPlayersExistTest() {
        TestUtils.initSettings();
        
        Game__c g = new Game__c(Name = 'TEST_GAME', Status__c = 'Active');
        
        /* Insert the game */
        Database.insert(g);
        
        /* Create a user object for use with runas. */
        User u = TestUtils.createTestUserObject(TestConstants.USER_LICENSE_SALESFORCE);
        
        System.runAs(u) {
            /* Call the checkPlayerRecord method. */
            String playerId = GameListController.checkPlayerRecord(g.id);
            
            /* Query for the player__c record. */
            Player__c p = [SELECT Id FROM Player__c WHERE Game__c = :g.id AND User__c = :UserInfo.getUserId()];
            
            System.assertEquals(playerId, p.id, 'Player__c ID from the checkPlayerRecord method when there was a player existing did not match the id of the player created.');
        }
    }
    
    static testmethod void checkPlayerRecordOnePlayerExistsTest() {
        TestUtils.initSettings();
        
        Game__c g = new Game__c(Name = 'TEST_GAME', Status__c = 'Active');
        
        /* Insert the game */
        Database.insert(g);
        
        Player__c p = TestUtils.createTestPlayer(g.id, TestConstants.USER_LICENSE_SALESFORCE);
        
        System.runAs(new User(Id = p.User__c)) {
            /* Call the checkPlayerRecord method. */
            String playerId = GameListController.checkPlayerRecord(g.id);
            
            /* Query for the player__c record. */
            Player__c pl = [SELECT Id FROM Player__c WHERE Game__c = :g.id AND User__c = :UserInfo.getUserId()];
            
            System.assertEquals(playerId, pl.id, 'Player__c ID from the checkPlayerRecord method when there was no player existing did not match the id of the player created.');
        }
    }

    /* This test covers the instance methods and the constructor of the GameListController class.*/
    static testmethod void instanceMultipleGamesTest() {
        
        TestUtils.initSettings();
        
        List<Game__c> gameList = new List<Game__c>();
        
        /* Create 5 games */
        for(Integer i=0;i<5;i++) {
            Game__c g = new Game__c(Name = 'Game_' + i, Start_Date_Time__c = Datetime.now().addHours(-2), Status__c = 'Active');
            gameList.add(g);
        }
        
        /* set the first game to completed status */
        gameList.get(0).Status__c = 'Completed';
        
        /* Insert the games */
        Database.insert(gameList);
        
        /* Create the players */
        List<Player__c> playerList = TestUtils.createTestPlayers(gameList,TestConstants.USER_LICENSE_SALESFORCE);
        
        /* Create a user object for use with runas. All players have the same user referenceId so picking any one should do.*/
        User u = new User(Id = playerList.get(1).user__c);
        
        System.runAs(u) {
            /* Call the constructor. */
            GameListController glc = new GameListController();
            
            /* Verify the size of the gamelist is as expected per the completed game. */
            System.assertEquals(4, glc.gameList.size(), 'Size of the gamelist from the gamelistcontroller instance was not correct.');
            
            /* with more than one game the redirect should be null */
            PageReference pr = glc.redirectForSingleGame();
            System.assert(pr == null, 'The page reference was not null as expected. PageReference: ' + pr);
        }
    }
    
    /* This test covers the instance methods and the constructor of the GameListController class.*/
    static testmethod void instanceSingleGameTest() {
        
        TestUtils.initSettings();
        Game__c g = new Game__c(Name = 'TEST_GAME', Status__c = 'Active');
        
        /* Insert the game */
        Database.insert(g);
        
        /* Create the player */
        Player__c p = TestUtils.createTestPlayer(g.id,TestConstants.USER_LICENSE_SALESFORCE);
        
        /* Create a user object for use with runas. */
        User u = new User(Id = p.user__c);
        
        System.runAs(u) {
            /* Call the constructor. */
            GameListController glc = new GameListController();
            
            /* Verify the size of the gamelist is as expected per the single game. */
            System.assertEquals(1, glc.gameList.size(), 'Size of the gamelist from the gamelistcontroller instance was not correct.');
            
            /* with exactly one active game the redirect should not be null */
            PageReference pr = glc.redirectForSingleGame();
            System.assert(pr != null, 'The page reference was unexpectedly null. PageReference: ' + pr);
            
            Id playerId = pr.getParameters().get('id');
            System.assertEquals(playerId, p.id, 'PlayerID value from the parameters of the pagereference returned from the redirectforsinglegame method did not match.');
        }
    }
    
    static testmethod void instanceSingleGameZeroPlayersTest() {
        
        TestUtils.initSettings();
        Game__c g = new Game__c(Name = 'TEST_GAME', Status__c = 'Active');
        
        /* Insert the game */
        Database.insert(g);
        
        /* Create a user object for use with runas. */
        User u = TestUtils.createTestUserObject(TestConstants.USER_LICENSE_SALESFORCE);
        
        System.runAs(u) {
            /* Call the constructor. */
            GameListController glc = new GameListController();
            
            /* Verify the size of the gamelist is as expected per the single game. */
            System.assertEquals(1, glc.gameList.size(), 'Size of the gamelist from the gamelistcontroller instance was not correct.');
            
            /* with exactly one active game the redirect should not be null */
            PageReference pr = glc.redirectForSingleGame();
            System.assert(pr != null, 'The page reference was unexpectedly null. PageReference: ' + pr);
            
            Player__c p = [SELECT Id FROM Player__c WHERE Game__c = :g.id AND User__c = :u.id];
            
            /* assert the request params required by the profile page and navigation elements. */
            System.assertEquals(p.id, pr.getParameters().get('id'),'PlayerID value from the parameters (id) of the pagereference returned from the redirectforsinglegame method did not match. Params:' + pr.getParameters());
            System.assertEquals(p.id, pr.getParameters().get('P'),'PlayerId value from the parameters (P) returned from the redirectforsinglegame method did not match. Params: ' + pr.getParameters());
            System.assertEquals(g.id, pr.getParameters().get('G'),'GameId value from the parameters (G) returned from the redirectforsinglegame method did not match. Params: ' + pr.getParameters());
        }
    }
    
    static testmethod void instanceZeroGamesTest() {
        TestUtils.initSettings();
        
        /* Create a user object for use with runas. */
        User u = TestUtils.createTestUserObject(TestConstants.USER_LICENSE_SALESFORCE);
        
        System.runAs(u) {
            /* Call the constructor. */
            GameListController glc = new GameListController();
            
            /* Verify the size of the gamelist is as expected per the single game. */
            System.assertEquals(0, glc.gameList.size(), 'Size of the gamelist from the gamelistcontroller instance was not correct.');
            
            /* with zero active games the redirect should not be null */
            PageReference pr = glc.redirectForSingleGame();
            System.assert(pr == null, 'The page reference was not null as expected. PageReference: ' + pr);
            
        }
    }
}