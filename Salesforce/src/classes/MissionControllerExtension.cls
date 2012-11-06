public with sharing class MissionControllerExtension {

    public String gameId { get; set; }
    public String playerId { get; set; }
  
    public MissionControllerExtension(ApexPages.StandardController stdController){
        gameId = ApexPages.currentPage().getParameters().get('G');
        playerId = ApexPages.currentPage().getParameters().get('P');
    }

    /* The PhoneGap JS libraries depend on the target OS - Android vs iOS. 
	   In this function, we determine the mobile platform that is invoking
	   this VF page via the 'User-Agent' HTTP header and then dynamically 
	   inject the platform appropriate JS file using VF Dynamic Components.
	*/
    public Component.Apex.IncludeScript getPhoneGapJS() {
        String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
        Component.Apex.IncludeScript jsScript; 
        if (userAgent.contains('iPhone') || userAgent.contains('iPad')){
            jsScript = new Component.Apex.IncludeScript();
            jsScript.expressions.value = '{!URLFOR($Resource.PhoneGap1_8_1_iOS)}';
        }else if (userAgent.contains('Android')){
            jsScript = new Component.Apex.IncludeScript();
            jsScript.expressions.value = '{!URLFOR($Resource.PhoneGap1_8_1_Android)}';
        }        
        return jsScript;
    }
    
    /* The PhoneGap JS library for the Bar Code scanning plugin depend on the target OS - Android vs iOS. 
	   In this function, we determine the mobile platform that is invoking
	   this VF page via the 'User-Agent' HTTP header and then dynamically 
	   inject the platform appropriate JS file using VF Dynamic Components.
	*/
    public Component.Apex.IncludeScript getBarCodeScannerJS() {
        String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
        Component.Apex.IncludeScript jsScript; 
        if (userAgent.contains('iPhone') || userAgent.contains('iPad')){
            jsScript = new Component.Apex.IncludeScript();
            jsScript.expressions.value = '{!URLFOR($Resource.BarCodeScanneriOS)}';
        }else if (userAgent.contains('Android')){
            jsScript = new Component.Apex.IncludeScript();
            jsScript.expressions.value = '{!URLFOR($Resource.BarCodeScannerAndroid)}';
        }        
        return jsScript;
    }

    /*JS Remoting function invoked from the VF page to complete a Camera type Mission*/
    @RemoteAction
    public static Decimal completeCameraMissionType(String imageData, String missionId, String gameId) {
        Mission__c mission = [select target_user__c, target_user__r.name from Mission__c where id = :missionId limit 1];
        //Create a new Achievement record for the Player.
        Achievement__c completedMission = completeMission(gameId, missionId);
        
        //Add the picture as an Attachment to the Achievement record
        Attachment a = new Attachment (ParentId = completedMission.Id,
                                       Body = EncodingUtil.base64Decode(imageData),
                                       ContentType = 'image/jpg',
                                       Name = 'PhoneImage');
        insert a;
        completedMission.image_Id__c = a.Id;
        update completedMission;
        
        /*Post the Achievement to Chatter. If the Mission has a Target User, the update will be posted to the Target User's Chatter feed.
		 Otherwise, it will be posted to the Player's Chatter feed.
		*/
        List<String> argList = new List<String>();
        argList.add(completedMission.Mission__r.Name);
        argList.add(String.valueOf(completedMission.Points_Awarded__c.intValue()));
        argList.add(mission.target_user__r.name);
        if (mission.target_user__c != null){
            postAchievement2Chatter(String.format(Label.PostMessage_Camera_User,argList), mission.target_user__c, EncodingUtil.base64Decode(imageData), 'PhoneImage.png');            
        }else {
            postAchievement2Chatter(String.format(Label.PostMessage_Camera,argList), UserInfo.getUserId(), EncodingUtil.base64Decode(imageData), 'PhoneImage.png');
        }
        return completedMission.Points_Awarded__c;
    }

    /*JS Remoting function invoked from the VF page to complete a Scan type Mission*/
    @RemoteAction
    public static Decimal completeScanMissionType(String scannedCode, String missionId, String gameId) {
        Mission__c mission = [select target_user__c, target_user__r.name, target_user__r.qr_code__c, Non_User_Validation_Code__c from Mission__c where id = :missionId limit 1];
        
        /*If the Mission has a Target User set, then the scanned QR/Bar Code has to match the value
		 of the QR_Code__c field on the Target User record.*/
        if (mission.target_user__r != null && mission.target_user__r.qr_code__c != null){
            if (scannedCode == mission.target_user__r.qr_code__c) {
                //Create a new Achievement record for the Player.
                Achievement__c completedMission = completeMission(gameId, missionId);
                if (completedMission.Points_Awarded__c != null) {
                    List<String> argList = new List<String>();
                    argList.add(completedMission.Mission__r.Name);
                    argList.add(String.valueOf(completedMission.Points_Awarded__c.intValue()));
                    argList.add(mission.target_user__r.name);
                    
                    //Post the Achievement to Target Usre's Chatter Feed. 
                    postAchievement2Chatter(String.format(Label.PostMessage_Scan_User,argList),mission.target_user__c, null, null);
                    return completedMission.Points_Awarded__c;
                } else {
                    System.debug('Error Point Value:'+completedMission.Points_Awarded__c);
                    return -1;
                }
            } else {
                //Scanned value does not match the Target User's QR Code. Mission failed.
                return -1;
            }
        } else {
            /*The Mission does not have a Target User. Instead, the scanned code has to match the value of 
			  the Non_User_Validation_Code__c field on the Mission record*/
            if (mission.Non_User_Validation_Code__c != null) {
               if (scannedCode == mission.Non_User_Validation_Code__c ){
                    Achievement__c completedMission = completeMission(gameId, missionId);
                    if (completedMission.Points_Awarded__c != null) {
                        
                        List<String> argList = new List<String>();
                        argList.add(completedMission.Mission__r.Name);
                        argList.add(String.valueOf(completedMission.Points_Awarded__c.intValue()));
                        argList.add(mission.target_user__r.name);
                        System.debug('Point Value:'+completedMission.Points_Awarded__c.intValue());
                        postAchievement2Chatter(String.format(Label.PostMessage_Scan,argList),UserInfo.getUserId(), null, null);
                        return completedMission.Points_Awarded__c;
                    } else {
                        System.debug('Error Point Value:'+completedMission.Points_Awarded__c);
                        return -1;
                    }
               } else {
                   	//Scanned value does not match the Non_User_Validation_Code__c value. Mission failed. 
                    return -1;
               }
            }
            return -1;
        }
    }

    /*JS Remoting function invoked from the VF page to complete a Check-in type Mission*/
    @RemoteAction
    public static Decimal completeCheckInMissionType(Decimal lat, Decimal lon, String missionId, String game) {
        System.debug(Logginglevel.INFO, 'Current location:'+lat+','+lon);
        /*Check-in type Missions have to have an associated Place record. The Place custom object uses the new
		Winter '13 Geo-location feature to geocode (i.e. lat/long) the location of the expected check-in point. The
		Distance_Tolerance__c field on the Place object captures how proximity radius of a successful check-in*/
        Mission__c mission = [select place__c, place__r.Distance_Tolerance__c, place__r.Location__latitude__s, 
                              place__r.Location__longitude__s, place__r.name from Mission__c where id = :missionId limit 1];

        System.debug(Logginglevel.INFO, 'Place location:'+mission.place__r.Location__latitude__s+','+mission.place__r.Location__longitude__s);
        if (mission.place__r != null && mission.place__r.Location__latitude__s != null){
            /*Using the new DISTANCE and GEOLOCATION functions in SOQL, determine if the user's current co-ordinates are within
			  an acceptable distance (i.e. Distance_Tolerance__c) of the Check-in location.*/
            String soql = 'select id from Place__c '+
                          'where DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'km\') <' + mission.place__r.Distance_Tolerance__c/1000 +
                          ' and id=\''+mission.place__c+'\'';
            List<Place__c> nearbyPlaces = Database.query(soql);
            if (nearbyPlaces.size() == 1){
                Achievement__c completedMission = completeMission(game, missionId);
                List<String> argList = new List<String>();
                argList.add(completedMission.Mission__r.Name);
                argList.add(String.valueOf(completedMission.Points_Awarded__c.intValue()));
                argList.add(mission.place__r.name);

                postAchievement2Chatter(String.format(Label.PostMessage_Check_in,argList),
                                        UserInfo.getUserId(), null, null);
                return completedMission.Points_Awarded__c;
            }
            else{
                return -1;
            }
        }        
        return -1;
    }
    
    /*JS Remoting function invoked from the VF page to complete a Signature type Mission. The captures signature
	is passed to this function as a Base64 encoded SVG image.*/
    @RemoteAction
    public static Decimal completeSignatureMissionType(String signature, String missionId, String gameId) {
        System.debug(Logginglevel.INFO, 'Mission ID:'+missionId);
        System.debug(Logginglevel.INFO, 'Game ID:'+gameId);
        System.debug(Logginglevel.INFO, 'Signature:'+signature);
        Mission__c mission = [select target_user__c, target_user__r.name from Mission__c where id = :missionId limit 1];
        System.debug(Logginglevel.INFO, mission.target_user__c);
        Achievement__c completedMission = completeMission(gameId, missionId);
        Attachment a = new Attachment (ParentId = completedMission.Id,
                                       Body = EncodingUtil.base64Decode(signature),
                                       ContentType = 'image/svg+xml;base64',
                                       Name = 'SignatureImage');
        Database.insert(a);
        completedMission.image_Id__c = a.Id;
        Database.update(completedMission);
        
        List<String> argList = new List<String>();
        argList.add(completedMission.Mission__r.Name);
        argList.add(String.valueOf(completedMission.Points_Awarded__c.intValue()));
        argList.add(mission.target_user__r.name);
        
        postAchievement2Chatter(String.format(Label.PostMessage_Signature_User,argList),mission.target_user__c, EncodingUtil.base64Decode(signature), 'SignatureImage.png');

        return completedMission.Points_Awarded__c;
    }
    
    private static Achievement__c completeMission(String gameId, String missionId){
        Id playerId = [select id from Player__c where User__c = :UserInfo.getUserId()
                       and Game__c = :gameId limit 1].Id;
        Achievement__c a = new Achievement__c(Player__c = playerId, Mission__c = missionId);
        Database.insert(a);
        a = [select id, Mission__r.Name, Player__c, Mission__c, Points_Awarded__c from Achievement__c where id=:a.Id limit 1];
        return a;
    }
    
    private static void postAchievement2Chatter(String message, String userId, Blob file, String fileName){
        
        /* Check for a non-null custom setting value. */
        Cloud_Hunter_Settings__c c = Cloud_Hunter_Settings__c.getOrgDefaults();
        String className = c.Integration_Class_Name__c;
        if(className != null && !''.equals(className)) {
        
            //Get the Type corresponding to the class name 
            Type t = Type.forName(className);
        
            IntegrationIface connectionImpl = (IntegrationIface)t.newInstance();
            
            // post to the remote org.  
            connectionImpl.postToChatter(message, userId, file, fileName);
                
        } else {
    
            FeedItem fItem = new FeedItem();
            fItem.ParentId = userId; 
            fItem.Body = message; 
            if (file != null && fileName != null){
                fItem.Type = 'ContentPost'; 
                fItem.ContentFileName = fileName;
                fItem.ContentData = file;
                
            } else{
                fItem.Type = 'TextPost'; 
            }
            
            insert fItem; 
        }
    }
}