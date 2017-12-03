import flash.external.ExternalInterface;

System.security.allowDomain("*");

var PENGUIN = null;
var DEBUG = false;

function toggleDebug() {
	DEBUG = !DEBUG;
}

function log(msg:String) {
	ExternalInterface.call("console.log", "[LOADER]: "+msg);
}

function containerFound(container, loginServer:String, loginPort) {
	// This is called every time a new frame is entered after we do setup - we use it to find out if all the client components are loaded
	
	with (container) {
		// Make sure all of these are loaded before proceeding
		// If they aren't, we just return
		if (!GLOBAL_CRUMBS || !AIRTOWER || !SHELL || !LOCAL_CRUMBS) {
			return;
		}
		
		if (DEBUG) {
			log("Crumbs, airtower, and shell loaded.");
		}
		
		// Turns off Disney's analytics in the shell
		SHELL.analytics = false;
		
		if (DEBUG) {
			log("Analytics disabled.");
		}
		
		// Tell the airtower to use our login server information
		AIRTOWER.LOGIN_IP = loginServer;
		AIRTOWER.LOGIN_PORT_EVEN = loginPort;
		AIRTOWER.LOGIN_PORT_ODD = loginPort;
	}
	
	System.security.allowDomain.call(_level1, "*");
	_root.onEnterFrame = hookChat;
}

function hookChat() {
	with(PENGUIN) {
		if(!INTERFACE || !ENGINE) {
			return;
		}
		
		// Remove all the chat restrictions
		
		INTERFACE.convertToSafeCase = function(text) {
			return text;
		};

		INTERFACE.DOCK.chat_mc.chat_input.maxChars = 4096;
	  
		LOCAL_CRUMBS.lang.chat_restrict = "a-z A-Z z-A !-} ?!.,;:`´-_/\\(){}=&$§\"=?@\'*+-ßäöüÄÖÜ#?<>\n\t";
		
		if (DEBUG) {
			log("Chat unrestricted.");
		}
	}
	
	if (DEBUG) {
		log("We're done! Removing frame hook.");
	}
	
	delete _root.onEnterFrame;
}

function startup(loginServer:String, loginPort, mediaUrl:String) {
	// This sets up all the mediaserver loading we have to do in the future
	_global.baseURL = mediaUrl;
	
	// Load CP
	loadMovieNum(mediaUrl + "play/v2/client/load.swf", 1);
	
	// Every time we get a new frame (presumably from a new SWF being loaded)
	_root.onEnterFrame = function () {
		// See what CP has loaded so far in _level1
		for (var movies in _level1) {
			if (typeof(_level1[movies]) == "movieclip") {
				// CP has loaded its first actual SWF - now we can start doing other things
				if (DEBUG) {
					log("Bootstrapping Club Penguin");
				}
				
				// Required for some of their hybrid AS2/AS3 code, normally done from club_penguin.swf(?)
				// But we're doing magic so we'll do it ourselves!
				// These can be changed to meet your specific needs (such as language) but are set for normal, AS2 CP.
				_level1.bootLoader.messageFromAS3({
					type: "setEnvironmentData", 
					data: {
						clientPath: mediaUrl + "play/v2/client/", 
						contentPath: mediaUrl + "play/v2/content/", 
						gamesPath: mediaUrl + "play/v2/games/", 
						connectionID: "frozen", 
						language: "en",
						basePath: "",
						affiliateID: "0"
					}
				});
				
				// Now we need to watch and wait for the AS2 client to load its dependencies
				// Includes things like the engine, interface, airtower, and crumbs
				_root.onEnterFrame = function() {
					if (_level1.shellContainer.DEPENDENCIES_FILENAME) {
						containerFound(PENGUIN = _level1.shellContainer, loginServer, loginPort);
					}
				}
			}
		}
	};
}

ExternalInterface.addCallback("toggleDebug", null, toggleDebug);

// Bind the JS call of "startup" to the swf to our above startup function
ExternalInterface.addCallback("startup", null, startup);

// First thing that happens when our SWF gets loaded
// It will call the JS function "loadCP", which should grab all the data it needs (media server URL, login server info) and call startup in our SWF.
log("Starting up");
ExternalInterface.call("loadCP");