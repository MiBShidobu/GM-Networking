GM-Networking Library By MiBShidobu
===

<center>[Steam Profile](http://steamcommunity.com/profiles/76561197967808946) &#x02016; [GitHub](https://github.com/MiBShidobu/GM-Networking) &#x02016; [Wiki](https://github.com/MiBShidobu/GM-Networking/wiki)</center>

## Description: ##
This addon provides an OOP wrapper and modeling solution for the net library, for simplified usage.

## Packaging: ##
Given that this is a multi-file library, it can be packed a few different ways with your addons as a dependency. You just have your users come here and download the zip, and uploading it as an addon. And if your addon loads before, just calling include("autorun/gm-networking.lua"). Or, package the lua/gm-networking/ files into a folder and just 'AddCSLuaFile/include'ing them and only using the files with the relavent API.

Note, this addon *does* rely on [GM-Serialize](https://github.com/MiBShidobu/GM-Serialize) for 'NetworkMessage' and 'NetworkBuffer' functionality. It doesn't need to load before, but it does need to be loaded at runetime. You can use the copy located at lua/gm-networking/library/gm-serialize.lua, or get a fresh copy from the repo, IF the api is still compatible.

When just picking apart API files of GM-Networking that you use for repackaging into your addon, make sure you have all the files that rely on one another.
```
>network_namespace.lua
-->network_message.lua (network.CallMessage in RPC functionality)
---->network_buffer.lua (^)

>network_message.lua
-->network_buffer.lua ('NetworkBuffer' functionality)
-->network_namespace.lua (namespace declaration)

>network_buffer.lua
-->network_namespace.lua (namespace declaration)
---->network_message.lua (^)

>network_model.lua
-->network_namespace.lua (namespace declaration)

>network_variables.lua
-->network_namespace.lua (namespace declaration)
-->network_message.lua ('NetworkMessage' functionality)

>network_stream.lua
-->network_namespace.lua (namespace declaration)
-->network_buffer.lua ('NetworkBuffer' functionality)
```


## Developing For: ##
To expand upon the 'NetworkMessage' object, use FindMetaTable with the parameter 'NetworkMessage' and extend it would like any other metatable. You can do the same with the 'NetworkBuffer' and 'NetworkModel' objects aswell.

## Credits: ##
[MiBShidobu](http://steamcommunity.com/profiles/76561197967808946) - Main Developer<br />
In-line credits - Developers who constructed a function or single bits of code I'm using, credited in-line at their functions. ... if I can remember them...