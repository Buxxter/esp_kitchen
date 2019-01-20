local module = {}

function module.save_setting(name, value)
    file.open(name .. '.sav', 'w') -- you don't need to do file.remove if you use the 'w' method of writing
    file.writeline(value)
    file.close()
end

function module.load_setting(name, default_val)
    if (file.open(name .. '.sav')~=nil) then
        result = string.sub(file.readline(), 1, -2) -- to remove newline character
        file.close()
        return result
    else
        return default_val
    end
end

function module.read_setting_num(name)
    return tonumber(module.read_setting(name))
end


module.DEVICE_NAME = "device_name_here"

local WIFI_DEFAULT_SSID = "Manuna"
local WIFI_DEFAULT_PASS = "QWEdsa321!"

module.LED_STATUS = 4

-- WiFi
module.WIFI_SSID = module.load_setting('WIFI_SSID', WIFI_DEFAULT_SSID)
module.WIFI_PASS = module.load_setting('WIFI_PASS', WIFI_DEFAULT_PASS)

WIFI_DEFAULT_SSID = nil
WIFI_DEFAULT_PASS = nil

-- Alarms

-- MQTT
-- res, module.MQTT_CLIENTID = module.load_setting('MQTT_CLIENTID')
-- if not res then module.MQTT_CLIENTID = module.DEVICE_NAME end

-- res, module.MQTT_HOST = module.load_setting('MQTT_HOST')
-- if not res then module.MQTT_HOST = '192.168.14.32' end
-- module.MQTT_PORT = 1883
-- module.MQTT_MAINTOPIC = "/devices/" .. module.MQTT_CLIENTID

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
print("\nGlobal variables loaded...\n")

return module
