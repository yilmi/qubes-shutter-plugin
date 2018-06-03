# qubes-shutter-plugin
Plugin for shutter to send screenshots to Qubes AppVM's

## Install

- Copy the script `QubesSendTo.pm` to `/usr/share/shutter/resources/system/upload_plugins/upload/`
- Make it executable `sudo chmod o+x /usr/share/shutter/resources/system/upload_plugins/upload/`
- Restart shutter (make sure to quit from the tray icon)


If you have any trouble you clear shutter's cache `shutter --clear_cache`

From dom0 you can copy the script using the following command: 
`sudo bash -c 'qvm-run -p YOUR_VM "cat PATH/TO/SCRIPT/QubesSendTo.pm" > /usr/share/shutter/resources/system/upload_plugins/upload/QubesSendTo.pm'`