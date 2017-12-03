# Boots
Wrapper for the Club Penguin flash client to make custom loading easier.

# How does it work?
Using Flash's various built-in amenities it:

* Sets up usage of `ExternalInterface` calls
* Creates a hook that is called every time a new SWF is loaded.
* Waits for the global client components to load (shell, engine, interface, crumbs, airtower, etc).
* Modifies various functions, static variables, etc after each component is loaded.

# What does it do?
By default:
* Gets rid of chat restrictions (case transformation, character restrictions, bumps up message length limit).
* Replaces the login server information with data of your own choosing.
* Sets up the game with your media server paths.

# What else can be done?
A few examples:
* You can modify the airtower as soon as it loads, meaning you can define custom messages and even reroute or remove default ones.
* You can modify the login process - skip world selection, auto-login, etc.
* You can modify crumbs on the fly. You can have the server define crumbs or even add new ones for individual players.
* Modify anything accessible from the `_global` or `_levelN` contexts.

# But I can decompile what I need to change, why use this?
A few different reasons:
* This requires no decompilation whatsoever.
* This is distributable, whereas any of Disney's SWFs are not.
* Tracking changes across loads of decompiled files is difficult, this consolidates them and makes it easier.
