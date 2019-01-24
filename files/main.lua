-- GLOBAL VARIABLES --

--
local led_counter = 0

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
    print('hi')
    mqttc.connect()
    light.set_callback(publish_status)
    tmr_status:alarm(30000, tmr.ALARM_AUTO, publish_status)
end

function on_network_disconnect()
    blink(2)
    tmr_status:stop()
end

function publish_status(...)
    mqttc.publish("name", config.DEVICE_NAME)
    mqttc.publish("state", light.state())
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
    light.state(payload)
end



-- Configure
light.init()

mqttc.init(config.MQTT_HOST, config.MQTT_PORT, config.MQTT_CLIENTID, config.MQTT_MAINTOPIC)
mqttc.subscribe("state/set", disp_status)
mqttc.subscribe("state/get", publish_status)
mqttc.subscribe("reboot", node.restart)
mqttc.subscribe("restart", node.restart)
mqttc.subscribe("config/get", publish_config)
mqttc.subscribe("config/save", config.save_settings)
mqttc.subscribe("config/set", set_config)


network.connect(config.WIFI_SSID, config.WIFI_PASS, config.LED_STATUS, on_network_connect)


-- network.getwifi(on_network_connect)

-- tm.add_task(blink, 500, 3, true, "is_blink")
-- tm.start()

-- Button
-- deb.set(4, doshort4, domedium4, dolong4)
btn.set(config.BTN_SWITCH, light.next_state, light.all_off, node.restart)
btn.set(config.BTN_MAIN, light.next_state, light.all_off, node.restart)

-- load_lib("load_crontasks")
