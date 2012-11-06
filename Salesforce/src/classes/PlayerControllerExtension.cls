public class PlayerControllerExtension {

    public Integer rankNumber { get; set; }
    public String placeSuffix { get; set; }
    private final Player__c currentPlayer;
    
    public PlayerControllerExtension(ApexPages.StandardController stdController){
        this.currentPlayer = (Player__c)stdController.getRecord();
        System.debug(Logginglevel.INFO,'currentPlayerTotal:'+currentPlayer.Total_Points_Awarded__c);
        
        /* TODO: Test this for scale. We may need to add a limit clause on this and just say rank is "1000+" to keep
                 this responsive and really, does the player ranked 21,989 care much to know that vs. they aren't in
                 the top 1k? -AW */
        rankNumber = [SELECT Count() 
                        FROM Player__c 
                       WHERE Game__c = :currentPlayer.Game__c AND 
                             Total_Points_Awarded__c > :currentPlayer.Total_Points_Awarded__c ];
        System.debug(Logginglevel.INFO,'rankNumber:'+rankNumber);
        rankNumber = rankNumber + 1;
        System.debug(Logginglevel.INFO,'rankNumber2:'+rankNumber);
        if ((math.mod(rankNumber, 10) == 1) && (rankNumber <> 11) ) {
            placeSuffix = 'st';
        } else if ((math.mod(rankNumber, 10) == 2) && (rankNumber <> 12) ) {
            placeSuffix = 'nd';
        } else if ((math.mod(rankNumber, 10) == 3) && (rankNumber <> 11) ) {
            placeSuffix = 'rd';
        } else {
            placeSuffix = 'th';
        }
        System.debug(Logginglevel.INFO,'placeSuffix:'+placeSuffix);
    }
    
}