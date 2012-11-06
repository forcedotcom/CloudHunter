/* This trigger simply sets the value of the Junction_Id__c 
   field which will cause a duplicate constraint violation. */
trigger BeforeInsert on Achievement__c (before insert) {
    for(Achievement__c a:Trigger.new) {
        a.Junction_Id__c = a.Player__c + ':' + a.Mission__c;
    }
}