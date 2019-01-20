-- GLOBAL VARIABLES --
CRONTABLE = {}
--


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
-- load_lib("config")
config = require("config")
-- network = require("getwifi")
tm = require("taskman")
mqttc = nil
rtc = nil
-- cronutil = require("cronutil")
-- crontab = require("crontab")

-- cronutil.debug = false
-- crontab.init()

function on_network_connect()
    print('hi')
end

-- Configure
-- network.connect(config.WIFI_SSID, config.WIFI_PASS, config.LED_STATUS, on_network_connect)



function blink()
    if gpio.read(config.LED_STATUS) == 1 then
        gpio.write(config.LED_STATUS, gpio.LOW)
    else
        gpio.write(config.LED_STATUS, gpio.HIGH)
    end
end

gpio.mode(config.LED_STATUS, gpio.OUTPUT)
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid = 'iPhone Buxxter', pwd = 'nkxukm5vjf96u', auto = false, save = false})

-- network.getwifi(on_network_connect)

tm.add_task(blink, 500, 3, true, "is_blink")
tm.start()

-- tm.add_task(network.connect('iPhone Buxxter', 'nkxukm5vjf96u', config.LED_STATUS, on_network_connect), 10000)

-- Button
--load_lib('button')               -- call for new created button Module

-- load_lib("load_crontasks")
