local modn = ...
print("Got name", modn)

local module = {}

local status_led
local wifiBlinkCounter = 0
local timer_blink
local _module_on_connect

local function turnWiFiLedOn()
    gpio.write(status_led, gpio.LOW)
end

local function turnWiFiLedOnOff()
    if status_led == nil then return end
    if gpio.read(status_led) == 1 then
        gpio.write(status_led, gpio.LOW)
    else
        gpio.write(status_led, gpio.HIGH)
    end
end

local function killall()
    print("ip now", wifi.sta.getip())
    if _module_on_connect then _module_on_connect() end
    package.loaded[modn] = nil
    collectgarbage()
    return
end

local function signalWiFiConnected()
    if status_led == nil then
        killall()
        return 
    end
    if wifiBlinkCounter >= 6 then
        wifiBlinkCounter = 0
        turnWiFiLedOn()
        timer_blink:unregister()
        timer_blink = nil
        killall()
        return
    elseif wifiBlinkCounter == 0 then
        timer_blink = tmr.create()
    end
    turnWiFiLedOnOff()
    wifiBlinkCounter = wifiBlinkCounter + 1
    timer_blink:alarm(150, tmr.ALARM_SINGLE, signalWiFiConnected)
end

function module.connect(ssid, pass, status_led_pin, _on_connect, _on_disconnect)
       
    if status_led_pin ~= nil then
        status_led = status_led_pin
        gpio.mode(status_led, gpio.OUTPUT)
    end
    _module_on_connect = _on_connect

    wifi.setmode(wifi.STATION)
    wifi_config = { ssid = ssid, 
                    pwd = pass, 
                    auto = true, 
                    save = false,
                    got_ip_cb = signalWiFiConnected,
                    disconnect_cb = _on_disconnect or turnWiFiLedOnOff
                }
    wifi.sta.config(wifi_config)
    wifi.sta.connect()
    
end

return module