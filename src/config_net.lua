
-- load credentials, 'ssid' and 'pwd'
-- https://nodemcu.readthedocs.io/en/master/en/modules/wifi/#wifistaconfig 
-- Called in init.lua

--connect to Access Point (DO NOT save config to flash)
station_cfg={}
station_cfg.ssid="Your SSID"
station_cfg.pwd="Your pwd"
station_cfg.save=false

