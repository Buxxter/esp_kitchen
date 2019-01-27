-- GLOBAL VARIABLES --

--
local led_counter = 20

tmr_status = tmr.create()

-- init all globals
function load_lib(fname)
    if file.open(fname .. ".lc") then
        file.close()
        dofile(fname .. ".lc")
    else
        dofile(fname .. ".lua")
    end
    collectgarbage()
end

print(node.heap())

-- load_lib("gpio_defines")
config = require("config")
network = require("network")
light = require("light")
btn = require("buttons")
-- tm = require("taskman")
mqttc = require("mqttc")
-- rtc = nil

function on_network_connect()
    blink(3)
    mqttc.connect()
    light.set_callback(publish_status)
    tmr_status:alarm(30000, tmr.ALARM_AUTO, publish_status)
end

function on_network_disconnect()
    if led_counter == 0 then
        led_counter = 20
        blink(1)
    else
        led_counter = led_counter - 1
    end
    tmr_status:stop()
end

function publish_status(...)
    mqttc.publish("name", config.DEVICE_NAME)
    mqttc.publish("state", light.state())
    mqttc.publish("is_on", light.state() > 0 and 1 or 0)
    -- mqttc.publish("brightness", val2perc(light.state()))
    mqttc.publish("brightness", light.state())
    mqttc.publish_state()
end

function publish_config(...)
    for k,v in pairs(config) do
        local t = type(v)
        if t == "number" or t == "string" or t == "boolean" then
            mqttc.publish("config/" .. k, v)
        end
    end
end

function set_config(cl, payload)
    for k, v in string.gmatch(payload, "([_%w.]+)=([%S ]+)") do    
        config[k] = try_tonumber(v)
    end
end

function disp_status(cl, payload)
    light.state(payload, true)
end

function val2perc(val)
    local perc = 0
    if val == 0 then perc = 0
    elseif val == 1 then perc = 33
    elseif val == 2 then perc = 66
    elseif val == 3 then perc = 100
    else val = 0
    end
    return perc
end

function perc2val(perc)
    local val = 0
    if perc == 0 then val = 0
    elseif perc < 33 then val = 1
    elseif perc < 66 then val = 2
    elseif perc <= 100 then val = 3
    else val = nil
    end
    return val
end

function disp_status_percent(cl, payload)
    -- light.state(perc2val(payload))
    light.state(payload)
end


-- Configure
light.init()

mqttc.init(config.MQTT_HOST, config.MQTT_PORT, config.MQTT_CLIENTID, config.MQTT_MAINTOPIC)
-- will subscribe only for '/devices/[device_name]/set/#' topic
-- to prevent self-messaging
mqttc.subscribe("state", disp_status)
mqttc.subscribe("brightness", disp_status_percent)
mqttc.subscribe("reboot", node.restart)
mqttc.subscribe("restart", node.restart)

mqttc.subscribe("config", set_config) -- expecting payload="key=value"
mqttc.subscribe("get_state", publish_status)
mqttc.subscribe("get_config", publish_config)
mqttc.subscribe("save_config", config.save_settings) -- saving current settings

network.connect(config.WIFI_SSID, config.WIFI_PASS, on_network_connect, on_network_disconnect)


-- network.getwifi(on_network_connect)

-- tm.add_task(blink, 500, 3, true, "is_blink")
-- tm.start()

-- Button
-- deb.set(4, doshort4, domedium4, dolong4)
btn.set(config.BTN_SWITCH, light.next_state, light.all_off, node.restart)
btn.set(config.BTN_MAIN, light.next_state, light.all_off, node.restart)

-- load_lib("load_crontasks")
