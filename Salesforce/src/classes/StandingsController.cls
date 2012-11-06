public class StandingsController {

    public List<Player__c> standingsList { get; set; }
    public String gameId { get; set; }
    public String remainingTime { get; set; }
    public Game__c game { get; set; }
    
    public StandingsController() {
        gameId = ApexPages.currentPage().getParameters().get('G');
        standingsList = new List<Player__c>([select Total_Points_Awarded__c, User__r.Name, User__r.CompanyName, User__r.FullPhotoUrl, Game__r.Time_Remaining__c, Game__r.End_Date_Time__c from Player__c where Game__c = :gameId ORDER BY Total_Points_Awarded__c DESC limit 20 ]);
        game = standingsList.get(0).Game__r;
        remainingTime = game.Time_Remaining__c;
    }
}