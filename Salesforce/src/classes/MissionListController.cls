public with sharing class MissionListController {

    public String gameId { get; set; }
    public String playerId { get; set; }
    public Boolean gameOver { get; set; }
    
    public class Mission{
        public Mission__c mission {get;set;}
        public boolean completed {get;set;}
        public Decimal pointsAwarded {get;set;}
        
        public Mission(Mission__c m){
            mission = m;
            completed = false;
        }
    }
    
    public MissionListController(){
        gameId = ApexPages.currentPage().getParameters().get('G');
        playerId = ApexPages.currentPage().getParameters().get('P');
        Game__c game = [SELECT End_date_Time__c FROM Game__c WHERE id = :gameId AND End_date_time__c > :datetime.now() ];
        if (game != null) {
            gameOver = false;
        } else {
            gameOver = true;
        }
        
    }

    @RemoteAction
    public static List<Mission> getMissionList(String gameId){
        List<Mission> missions = new List<Mission>();
        
        /* Secondary list to de-prioritize the completed missions. */
        List<Mission> completedMissions = new List<Mission>();
        
        Map<Id, Achievement__c> completedMissionAchievementIdMap = new Map<Id, Achievement__c>();
        
        /* TODO: condense the Achivement and Mission queries into one. */
        for (Achievement__c a : [SELECT Mission__c, Points_Awarded__c
                                   FROM Achievement__c 
                                  WHERE Player__r.Game__c = :gameId AND
                                        Player__r.User__c = :UserInfo.getUserId()]) {
            completedMissionAchievementIdMap.put(a.Mission__c, a);
        }
        
        /* Added filter for completed missions based on end datetime.*/
        for (Mission__c m : [SELECT Id, Description__c, Name, Current_Point_Value__c, Max_Point_Value__c, 
                                    Place__r.Location__Latitude__s, Place__r.Location__Longitude__s, Place__r.Address1__c, Place__r.Address2__c,
                                    Mission_Start_Time__c, Mission_Type__c
                               FROM Mission__c 
                              WHERE Mission_Start_Time__c < :datetime.now() AND 
                                    (Mission_End_Time__c > :datetime.now() OR
                                     Mission_End_Time__c = null) AND
                                    Game__c = :gameId 
                           ORDER BY Current_Point_Value__c DESC ]){
            Mission mission = new Mission(m);
            if (completedMissionAchievementIdMap.containsKey(m.Id)){
                mission.completed = true;
                mission.pointsAwarded = completedMissionAchievementIdMap.get(m.Id).Points_Awarded__c;
                completedMissions.add(mission);
            } else {
                missions.add(mission);
            }                               
        }
        
        /* Add all the completed missions to the end of the list. */
        missions.addAll(completedMissions);
        return missions;
    }    
}