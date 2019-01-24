-- Default values
local module = {
    WIFI_SSID="Manuna", 
    WIFI_PASS="QWEdsa321!", 
    DEVICE_NAME="kitchen", 
    LED_STATUS = 7,
    MQTT_HOST = '192.168.14.32',
    MQTT_PORT = 1883,
    LAMP_LOW = 4,
    LAMP_HIGH = 6,
    BTN_MAIN = 3,
    BTN_SWITCH = 2,
    err="", 
    debug="1"}

module.MQTT_MAINTOPIC = "/devices/" .. module.DEVICE_NAME
module.MQTT_CLIENTID = module.DEVICE_NAME

local led_counter = 0

function try_tonumber(val)
    return tonumber(val) or val
end

function module.load_settings()
    if (file.open("settings.txt","r")) then
        local sF = file.read()
        --print("setting: "..sF)
        file.close()
        for k, v in string.gmatch(sF, "([_%w.]+)=([%S ]+)") do    
            module[k] = try_tonumber(v)
            print(k .. ": " .. v)
        end
        if module.debug == "1" and not file.open("debug") then
            file.open("debug", "w")
            file.close()
        elseif module.debug ~= "1" then
            file.remove("debug")
        end
    end
end

function module.save_settings(sErr)
    if (sErr) then
        module.err = sErr
    end
    file.remove("settings.txt")
    file.open("settings.txt","w+")
    for k, v in pairs(module) do
        local t = type(module[k])
        if t == "number" or t == "string" or t == "boolean" then
            file.writeline(k .. "=" .. v)
        end
    end                
    file.close()
    collectgarbage()
end

local function status_toggle()
    if gpio.read(config.LED_STATUS) == 1 then
        gpio.write(config.LED_STATUS, gpio.LOW)
    else
        gpio.write(config.LED_STATUS, gpio.HIGH)
    end
end

local function blink_few_times()
    if led_counter <= 0 then
        return
    end
    status_toggle()
    led_counter = led_counter - 1
    tmr.create():alarm(500, tmr.ALARM_SINGLE, blink_few_times)
end

function blink(times)
    if module.LED_STATUS == nil then return end
    led_counter = times * 2
    blink_few_times()
end

-- Alarms



-- GPIO0   =   3
-- GPIO1   =   10
-- GPIO2   =   4
-- GPIO3   =   9
-- GPIO4   =   2
-- GPIO5   =   1
-- GPIO9   =   11
-- GPIO10  =   12
-- GPIO12  =   6
-- GPIO13  =   7
-- GPIO14  =   5
-- GPIO15  =   8
-- GPIO16  =   0


-- Confirmation message
module.load_settings()
-- module.save_settings()

if module.LED_STATUS then
    gpio.mode(module.LED_STATUS, gpio.OUTPUT)
end

print("\nGlobal variables loaded...\n")

return module
