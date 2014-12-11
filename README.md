GM-Networking Library By MiBShidobu
===

<center>[Steam Profile](http://steamcommunity.com/profiles/76561197967808946) &#x02016; [GitHub](https://github.com/MiBShidobu/GM-Networking) &#x02016; [Wiki](https://github.com/MiBShidobu/GM-Networking/wiki)</center>

## Description: ##
This addon provides an OOP wrapper and modeling solution for the net library, for simplified usage.

## Packaging: ##
Given that this is a multi-file library, it can be packed a few different ways with your addons as a dependency. No support will be provided if done in any way other than provided structure.

Note, this library *does* rely on [GM-Serialize](https://github.com/MiBShidobu/GM-Serialize) for serialization, if you repack this GM-Networking, use the local copy or an API compatible library/version.

## Developing For: ##
To expand upon the 'NetworkMessage' object, use FindMetaTable with the parameter 'NetworkMessage' and extend it would like any other metatable. You can do the same with the 'NetworkBuffer' and 'NetworkModel' objects aswell.

## Credits: ##
[MiBShidobu](http://steamcommunity.com/profiles/76561197967808946) - Main Developer