local M = {
    client = nil,
    _host = nil,
    _port = 1883,
    _client_id = "sonoff",
    online = 0,
    _callbacks = {}
}

local function handle_mqtt_error(client, reason)
    M.online = 0
    print("MQTT : " .. M._client_id .. " disconnected from ", M._host, "(reason: ", tostring(reason), ")")
    if wifi.sta.status() == wifi.STA_GOTIP then
        tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, M.connect)
    end
end

local function on_message(cl, topic, pl)
    print('MQTT : Topic ', topic, ' with payload ', pl)
    if pl~=nil and M._callbacks[topic] then
		M._callbacks[topic](m, try_tonumber(pl))
	end
end

function M.publish(topic, pl)
	if M.client == nil or topic == nil or pl == nil then
		print('mqtt isn\'t connected')
		return false
    end
    if topic == "" then tp = M._topic else tp = M._topic .. '/' .. topic end
	return M.client:publish(tp, pl, 0, 0, function (m)
		print('MQTT->: ' .. topic .. ' ' .. pl)
	end)
end

function M.publish_state()
    M.publish("heap", node.heap())
    M.publish("chipid", node.chipid())
    local ip, netmask, gw = wifi.sta.getip()
    M.publish("ip", ip)
    M.publish("netmask", netmask)
    M.publish("gateway", gw)
    M.publish("uptime", tmr.time())    
end

function M.subscribe(subtopic, f)
    M._callbacks[M._topic .. "/" .. subtopic] = f
end

function M.connect(cb)
    M.client:connect(M._host, M._port, 0, 0, 
        function (cl)
            print('MQTT : ' .. M._client_id .. " connected to " .. M._host .. " on port : " .. M._port)
            M.online = 1
            M.client:subscribe(M._topic .. "/#", 0, 
                function (m)
                    print('MQTT : subscribed to ', M._topic) 
                end)
            if cb then cb(cl) end
        end, 
        handle_mqtt_error)
end

function M.init(host, port, client_id, main_topic, callbacks)
    M.client = mqtt.Client(M._client_id, 60)
    if host then M._host = host end
    if port then M._port = port end
    if client_id then M._client_id = client_id end
    if main_topic then M._topic = main_topic end
    if callbacks then M._callbacks = callbacks end

    M.client:lwt("/lwt", M._client_id .. " died !", 0, 0)
    M.client:on("message", on_message)
    -- M.connect()
end

return M