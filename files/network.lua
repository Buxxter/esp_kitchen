local modn = ...
-- print("Got name", modn)
local module = {}

function module.connect(ssid, pass, _on_connect, _on_disconnect)
       
    local function killall()
        print("ip now", wifi.sta.getip())
        if _on_connect then _on_connect() end
        package.loaded[modn] = nil
        collectgarbage()
        return
    end
    
    wifi.setmode(wifi.STATION)
    wifi.sta.config({   ssid = ssid, 
                        pwd = pass, 
                        auto = true, 
                        save = false,
                        got_ip_cb = killall,
                        disconnect_cb = _on_disconnect
                    })
    wifi.sta.connect()
    
end

return module