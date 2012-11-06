@IsTest
public class TestConstants {    
    public static final string USER_LICENSE_SALESFORCE          = 'Salesforce';
    public static final string USER_LICENSE_SALESFORCE_PLATFORM = 'Salesforce Platform';
    public static final Map<String, String> PLAYER_PERMSET_NAME_MAP = new Map<String,String>{TestConstants.USER_LICENSE_SALESFORCE => 'Cloud_Hunter_salesforce', TestConstants.USER_LICENSE_SALESFORCE_PLATFORM => 'Cloud_Hunter_platform'};
    public static final string PERMISSION_SET_ADMIN             = 'Cloud_Hunter_Admin';
    public static final string USER_QR_CODE_VALUE               = 'QR_CODE_00000000000000';
    public static final Decimal GEO_LATITUDE                    = 39.825955;
    public static final Decimal GEO_LONGITUDE                   = -86.183166;
    public static final String MISSION_TYPE_SCANNER             = 'Scanner';
    public static final String MISSION_TYPE_CHECKIN             = 'Check-in';
    public static final String MISSION_TYPE_CAMERA              = 'Camera';
    public static final String MISSION_TYPE_SIGNATURE           = 'Signature';
}