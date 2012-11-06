@IsTest
public class TestUtils {
    
    private static string USER_NAME_FOR_TESTS = 'A7@TEST9999.apex';
    
    /* Initializes the custom settings. Data siloing of tests requires custom settings 
       be generated with the test data. */
    public static void initSettings() {
        initSettings(new Cloud_Hunter_Settings__c(SetupOwnerId = UserInfo.getOrganizationId()));
    }
    
    /* Initializes the custom settings. Data siloing of tests requires custom settings 
       be generated with the test data. */
    public static void initSettings(Cloud_Hunter_Settings__c c) {
        System.runAs(new User(Id = UserInfo.getUserId())) { Database.insert(c); }
    }
    
    /* Utility method for creating a test player. This method
       will also create a dummy user with the expected profile */
    public static Player__c createTestPlayer(Id gameId, String userLicense) {
        List<Game__c> gameList = new List<Game__c>();
        gameList.add(new Game__c(Id = gameId));
        
        return createTestPlayers(gameList, userLicense).get(0);
    }
    
    public static User createTestUserObject(String userLicense) {
        /* Get a unique username from the constant so each time this method is called a new username will 
           be generated. */
        USER_NAME_FOR_TESTS = 'A' + USER_NAME_FOR_TESTS;
        
        /* Get a profile for the specified licensetype. */
        Profile p = [SELECT Id FROM Profile WHERE UserLicense.name = :userLicense LIMIT 1]; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', 
                          LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName=USER_NAME_FOR_TESTS);
        
        u.QR_Code__c = TestConstants.USER_QR_CODE_VALUE;
    
        //assign the appropriate permset.
        System.runas(new User(Id = UserInfo.getUserId())) {
            Database.insert(u);
            PermissionSet ps = [Select id from PermissionSet where UserLicense.name = :userLicense and name = :TestConstants.PLAYER_PERMSET_NAME_MAP.get(userLicense)];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = u.id);
            Database.insert(psa);
        }
        
        return u;
    }

    public static List<Player__c> createTestPlayers(List<Game__c> gameList, String userLicense) {
        
        User u = createTestUserObject(userLicense);
        
        List<Player__c> playerList = new List<Player__c>();
        
        for(Game__c g:gameList) {
            Player__c pl = new Player__c(User__c = u.id, Game__c = g.Id);
            playerList.add(pl);
        }
        Database.insert(playerList);
        return playerList;
    }
    
    public static List<Player__c> createTestPlayersForOneGame(Id gameId, Integer num, String userLicense) { 
        /* Get a profile for the specified licensetype. */
        Profile p = [SELECT Id FROM Profile WHERE UserLicense.name = :userLicense LIMIT 1]; 
        
        List<User> uList = new List<User>();
        for(Integer i=0;i<num;i++) {
            User u = new User(Alias = i+'_std', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', 
                              LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName=i + USER_NAME_FOR_TESTS);
            uList.add(u);                
        }
        
        //assign the appropriate permset.
        System.runas(new User(Id = UserInfo.getUserId())) {
            Database.insert(uList);
            PermissionSet ps = [Select id from PermissionSet where UserLicense.name = :userLicense and name = :TestConstants.PLAYER_PERMSET_NAME_MAP.get(userLicense)];
            
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for(User u:uList) {
                PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = u.id);
                psaList.add(psa);
            }
            Database.insert(psaList);
        }
         
        List<Player__c> playerList = new List<Player__c>();
        
        for(User u:uList) {
            Player__c pl = new Player__c(User__c = u.id, Game__c = gameId);
            playerList.add(pl);
        }
        Database.insert(playerList);
        return playerList;
    }

    /* Returns the specified number of player__c records for a given game
       in rank order for testing playercontrollerextension or other scenarios
       that need users, players, missions and achievements to be created. */
    public static List<Player__c> createRankedPlayersForOneGame(Id gameId, Integer num, String userLicense) {
        
        /* Create the players */
        List<Player__c> pList = createTestPlayersForOneGame(gameId, num, userLicense);
        
        /* Create a lists for missions and achievements.  */
        List<Mission__c> mList = new List<Mission__c>();
        List<Achievement__c> aList = new List<Achievement__c>();
        
        Integer points = 100;
        for(Player__c p:pList) {
            mList.add(new Mission__c(Target_User__c = UserInfo.getUserId(), Name = 'TEST_MISSION' + points, Mission_Type__c = 'Camera', Max_Point_Value__c = points, Mission_Start_Time__c = Datetime.now().addHours(-12),Game__c = gameId));
            /* drop a point so ranking will be deterministic. */
            points--;
        }
        
        /* Insert the list of missions. */
        Database.insert(mList);
        
        /* Loop to create achievement via pairing players and missions. */
        for(Integer i=0;i<mList.size();i++) {
            aList.add(new Achievement__c(Player__c = pList.get(i).id, Mission__c = mList.get(i).id));
        }
        
        /* Create the achievements. */
        Database.insert(aList);
        
        return pList;
    }
}