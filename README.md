WarningLights
=============

An Xcode plug-in that flashes your Philips Hue light bulbs different colours depending on the outcome of your build.

Installation
------------

To install Warning Lights, pull the repository and perform a build. A bundle is then compiled and stored at ~/Library/Application Support/Developer/Shared/Xcode/Plug-ins. On next launch, the plug-in will be active. Alternatively, use [Alcatraz][alcatraz].

Note: WarningLights requires the OS X 10.10 SDK and Yosemite to build.

Upgrading from 1.0
------------------

Warning Lights should retain your previous settings from v1.0. Simply follow the above installation instructions to get going.

Requirements
------------

This has only been tested to work with Xcode 5.0.2 or later.

The user is required to have access to a Philips Hue starter kit, and light bulb(s), otherwise the expected behaviour of the plug-in is determined to be rather pointless.

Usage
-----

On launch of a project, a new menu item will appear in the Project menu, titled Warning Lights. 

The submenu handles three states of operation:
  * No Philips Hue bridge has been located. The option to search for a bridge is shown.
  * A Philips Hue bridge has been found, but hasn't been authenticated for usage with Warning Lights. Choosing to authenticate will require the user to press the link button on the bridge within 30 seconds of the given authentication alert.
  * A Philips Hue bridge has been found, and authetnicated. Multiple lights can now be selected for use with Warning Lights.

Once configured, it is simple to select light flashes for varying build results. Hover over each toggle to get a description of the option.

<img src="https://raw.github.com/mitchellallison/WarningLights/master/WLMenu.png" alt="Warning Lights menu" height="400px"/>

[Alcatraz]: https://github.com/supermarin/Alcatraz

