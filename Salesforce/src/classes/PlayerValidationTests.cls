/* Tests enforcing the validation rules around the player object. */
@IsTest
public class PlayerValidationTests {
    
    /* There should only be one player for a given combination of game and 
       user. In other words, a user can not have two players for the same game. 
       NOTE: there is an exception to this potentially as for scale testing of 
             the player object it may be advantageous to conditionally relax this 
             constraint. */
    static testmethod void oneAndOnlyOnePlayer() { }
    
    /* Players should not be allowed to be created against games which are not 
       active, specifically where the Status__c field value is "Active". */
    static testmethod void createPlayerForActiveGamesOnly() {}
}