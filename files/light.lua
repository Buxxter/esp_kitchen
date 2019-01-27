local mname = ...
local module = {}
module.curState = 0
module.prevState = 1
module.callback = nil

function module.state(light_mode, pass_if_same)
    debug(mname .. ".state(" .. tostring(light_mode) .. ")")
    if pass_if_same then
        if light_mode == module.curState then return end
    end

    if light_mode == nil then
        module.curState = gpio.read(config.LAMP_HIGH) * 2 + gpio.read(config.LAMP_LOW)
        print(mname .. ".CurState=" .. module.curState)
        return module.curState
    end

    module.prevState = module.curState
    if light_mode == 1 then
        gpio.write(config.LAMP_HIGH, gpio.LOW)
        gpio.write(config.LAMP_LOW, gpio.HIGH)
    elseif light_mode == 2 then
        gpio.write(config.LAMP_HIGH, gpio.HIGH)
        gpio.write(config.LAMP_LOW, gpio.LOW)
    elseif light_mode == 3 then
        gpio.write(config.LAMP_HIGH, gpio.HIGH)
        gpio.write(config.LAMP_LOW, gpio.HIGH)
    else
        light_mode = 0
        gpio.write(config.LAMP_HIGH, gpio.LOW)
        gpio.write(config.LAMP_LOW, gpio.LOW)
    end
    module.curState = gpio.read(config.LAMP_HIGH) * 2 + gpio.read(config.LAMP_LOW)
    if module.callback then
        module.callback(module.curState)
    end
    return module.curState
end

function module.toggle()
    if module.curState == 0 then
        module.state(module.prevState)
    else
        module.all_off()
    end
end

function module.next_state()
    module.state(module.curState + 1)
end

function module.all_off()
    module.state(0)
end

function module.set_callback(cb)
    module.callback = cb
end

function module.init(cb)
    gpio.mode(config.LAMP_LOW, gpio.OUTPUT)
    gpio.mode(config.LAMP_HIGH, gpio.OUTPUT)
    gpio.mode(config.BTN_SWITCH, gpio.INPUT)
    module.all_off()
    module.set_callback(cb)
end

return module