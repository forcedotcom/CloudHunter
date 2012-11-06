public with sharing class GameListController {

    public List<Game__c> gameList { get; set; }
    public boolean activeGames { get; set; }
    
    public GameListController() {
        gameList = [select Id, Name, (Select Id from Players__r where user__c = :UserInfo.getUserId()) from Game__c where Status__c = 'Active' ];
        if (gameList.isEmpty()) {
            activeGames = false;
        } else {
            activeGames = true;
        }
    }

  @RemoteAction
  public static String checkPlayerRecord(String gameId){
      List<Player__c> playerList = [select Id from Player__c where User__c = :UserInfo.getUserId() and Game__c = :gameId LIMIT 1];
      if (playerList.size() == 0) {
          Player__c player = new Player__c(Game__c = gameId, User__c = UserInfo.getUserId());
          insert player;
          return player.id;
      } else {
          return playerList[0].id;
      }
  }

  public PageReference redirectForSingleGame() {
      /* initialize the connection if the configuration dictates.*/
      GameListController.invokeCustomImpl();
      
      /* Check the # active games. If exactly 1, make sure the user has a player. */
      if (gameList.size() == 1) {
          Game__c g = gameList.get(0);
          Id playerId;
          if (g.Players__r == null || g.Players__r.size() == 0) {
              Player__c p = new Player__c(Game__c = g.id, User__c = UserInfo.getUserId());
              Database.insert(p);
              playerId = p.id;
          } else {
              playerId = g.Players__r.get(0).id;
          }
          PageReference redirectPage = Page.Player;
          redirectPage.getParameters().put('id',playerId);
          redirectPage.getParameters().put('P',playerId);
          redirectPage.getParameters().put('G',g.id);
          redirectPage.setRedirect(true);
          return redirectPage;
          
      } else {
          /* TODO: Should the zero and more than one result cases be handled differently? */
          return null;
      }
  }
    
    private static void invokeCustomImpl() {
        /* Check for a non-null custom setting value. */
        Cloud_Hunter_Settings__c c = Cloud_Hunter_Settings__c.getOrgDefaults();
        String className = c.Integration_Class_Name__c;
        if(className != null && !''.equals(className)) {
        
            //Get the Type corresponding to the class name 
            Type t = Type.forName(className);
        
            IntegrationIface connectionImpl = (IntegrationIface)t.newInstance();
            
            // Call the methods that have a custom implementation 
            connectionImpl.initializeUser();                
        }
    }
}