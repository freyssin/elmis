-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 - 2019 ScalAgent Distributed Technologies

-- load credentials, 'ssid' and 'pwd'
dofile("config_net.lua")

function run()
  dofile("startup.lua")
end

function connect()
  print("Connecting to WiFi access point...")
  wifi.setmode(wifi.STATION)
  wifi.sta.config(wifi_cfg)

  tmr.create():alarm(1000, tmr.ALARM_AUTO, function(cb_timer)
    if wifi.sta.getip() == nil then
      print ("Waiting for IP address..")
    else
      cb_timer:unregister()
      print ("WiFi mode: ", wifi.getmode ())
      print ("MAC address: ", wifi.ap.getmac ())
      print("Chip ID: ", node.chipid())
      print("Heap Size: ", node.heap(),'\n')
      print ("IP address: ", wifi.sta.getip ())
      print ("WIFI Connected")

      run()
    end
  end)
end

print("You have 3 seconds to abort\nWaiting...")
tmr.create():alarm(3000, tmr.ALARM_SINGLE, connect)

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
 print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
 T.BSSID.."\n\tChannel: "..T.channel)
 end)

 wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
 print("\n\tSTA - DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
 T.BSSID.."\n\treason: "..T.reason)
 end)

 wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
 print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
 T.netmask.."\n\tGateway IP: "..T.gateway)
 end)
