/* Test methods for validation of Place records. */
@IsTest
public class PlaceValidationTests {
    
    /* Deletion of a place must be blocked until all check-in missions are either changed
       to have a different type or are also removed. */
    static testmethod void placeDeleteTest() {
        List<SObject> insertList = new List<SObject>();
        
        /* Create a game */
        Game__c g = new Game__c(Name = 'TEST_GAME');
        insertList.add(g);
        
        /* Create a place */
        Place__c p = new Place__c(Name = 'TEST_PLACE', Location__Latitude__s = TestConstants.GEO_LATITUDE, 
                                   Location__Longitude__s = TestConstants.GEO_LONGITUDE, Distance_Tolerance__c = 100,
                                   Address1__c = '10 Main', Postal_Code__c = '00000');
        insertList.add(p);
        
        /* Insert the game and place. */
        Database.insert(insertList);
        
        /* Create a mission of type checkin  */
        Mission__c m = new Mission__c(Place__c = p.id, Name = 'TEST_MISSION', Mission_Type__c = TestConstants.MISSION_TYPE_CHECKIN, Max_Point_Value__c = 100, Mission_Start_Time__c = Datetime.now().addHours(-12),Game__c = g.id);
        Database.insert(m);
        
        /* Now try to delete the place. */
        try {
            Database.delete(p);
            System.assert(false, 'deletion of a place that is tied to a check-in mission succeeded. Check the deletion event handling defined on the lookup Mission__c.Place__c.');
        } catch(System.DMLException e) {
            System.assertEquals(StatusCode.DELETE_FAILED,e.getDMLType(0),'StatusCode on the DML Exception was not returned as expected. Enforcement expected here is from the flag on the Lookup field Mission__c.Place__c.');
        }
    }
}