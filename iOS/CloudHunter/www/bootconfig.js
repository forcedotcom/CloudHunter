     
     
//-----------------------------------------------------------------
// Replace the values below with your own app configuration values.
//-----------------------------------------------------------------

// When debugMode is true, logToConsole() messages will be written to a
// "debug console" section of the page.
var debugMode = false;

// The client ID value specified for your remote access object that defines
// your application in Salesforce.
var remoteAccessConsumerKey = "<insert consumer key";

// The redirect URI value specified for your remote access object that defines
// your application in Salesforce.
var oauthRedirectURI = "insert redirect URL";

// The authorization/access scope(s) you wish to define for your application.
var oauthScopes = ["web","api"];

// The start data associated with the application.  Use SFHybridApp.LocalAppStartData for a "local"
// Cordova-based application, and SFHybridApp.RemoteAppStartData for a Visualforce-based
// application.  The default representations are below, or you can look at the data
// classes in SFHybridApp.js to see how you can further customize your options.
//var startData = new SFHybridApp.LocalAppStartData();  // Used for local REST-based "index.html" Cordova apps.
var startData = new SFHybridApp.RemoteAppStartData("/apex/GameList"); // Used for Visualforce-based apps.

// Whether the container app should automatically refresh our oauth session on app foreground
var autoRefreshOnForeground = true;

// Whether the container app should automatically refresh our oauth session periodically
var autoRefreshPeriodically = true;

//-----------------------------------------------------------------
// End configuration block
//-----------------------------------------------------------------
        
            

