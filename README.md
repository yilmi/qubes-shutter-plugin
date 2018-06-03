# qubes-shutter-plugin
Plugin for shutter to send screenshots to Qubes AppVM's

## Install

- Copy the script `QubesSendTo.pm` to `/usr/share/shutter/resources/system/upload_plugins/upload/`
- Make it executable `sudo chmod o+x /usr/share/shutter/resources/system/upload_plugins/upload/`
- Restart shutter (make sure to quit from the tray icon)


If you have any trouble you clear shutter's cache `shutter --clear_cache`

For example, install can be done from dom0 with following commands: 
```BASH
sudo bash -c 'qvm-run -p YOUR_VM "cat PATH/TO/SCRIPT/QubesSendTo.pm" > /usr/share/shutter/resources/system/upload_plugins/upload/QubesSendTo.pm'

sudo chmod o+x /usr/share/shutter/resources/system/upload_plugins/upload/QubesSendTo.pm
```