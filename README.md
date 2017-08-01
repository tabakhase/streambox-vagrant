## TAB_Streambox

VirtualMachine with NginxRTMP+encoders for capturecardless-dualPC streaming managed via Vagrant and a simple config file.
 by Tabakhase

### ???:
The Idea here is that:
- you keep your OBS/Xsplit with overlays/alerts and so on on the gaming-PC, but from there stream "ultraHQ (1080p60fps @ 50.000kbit range)" using QuickSync to another PC.
- On the "other PC" TAB_Streambox is running and crunches your input down to 'streamable bandwith' with ffmpeg
- all settings (bandwith, res, fps, streamkey, cpucount...) are wrapped into the "vagrant.local.yml" configfile.


### Requires:
- [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant](https://www.vagrantup.com/downloads.html)
- encoding-rig needs to have AMD-V or VT-x enabled!


### HowTo-Setup:
- Install above listed requirements and download this Repository.
- clone&rename the file "vagrant.local-sample.yml" to "vagrant.local.yml" and open it with a TextEditor (Notepad)
- configure your streamkey by un-commenting the line '#twitch_streamkey: ' to 'twitch_streamkey: "live_1234_abcd"'
- and have a look at the other settings inside this file, the CPU-count and your "stream settings to twitch" are all managed in there!
- run "DO_POWERON" to setup the VirtualMachine (the first time will take quite a bit of time for installing)


### HowTo-Ussage:
- run "DO_POWERON" to start the machine (the first time will take quite a bit of time for installing)
- run "GET_DETAILS" to recive the settings to be used in your OBS/xSplit/whatever
- GET_DETAILS-example: ![Screenshot of GET_DETAILS](https://i.imgur.com/2FUM2OM.png)
- depending on the streamkey you use it can stream or only run a local teststream in your browser/VLC
- **stream!**
- when you are done, just run "DO_SHUTDOWN" to power-off the VirtualMachine
- there are a few other helpers (GET_LOGS, GET_PERFORMANCE...) - play around :P, there is "nothing you can break"


### HowTo-Uninstall:
- run "DO_UNINSTALL" - this will delete the VirtualMachine (~2GB)
- then just delete this whole folder and you are done.


