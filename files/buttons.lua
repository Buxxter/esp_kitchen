--[[
 Источник: https://igorkandaurov.com/2017/06/23/%d0%bc%d0%be%d0%b4%d1%83%d0%bb%d1%8c-%d0%b0%d0%bd%d1%82%d0%b8%d0%b4%d1%80%d0%b5%d0%b1%d0%b5%d0%b7%d0%b3%d0%b0-%d0%b4%d0%bb%d1%8f-esp-8266/

 -- Загружаем модуль
deb = require("debMod")
-- И запускаем в работу одной строкой на каждую кнопку
deb.set(3, doshort, domedium, dolong)
deb.set(4, doshort4, domedium4, dolong4)
 
-- Иные варианты применения
-- Можно использовать одну или несколько кнопок

deb.set(3, doshort) -- только кнопка, сколько не жми
deb.set(3, doshort, nil, dolong) -- здесь короткое(оно же среднее)  или длинное
deb.set(3, doshort, domedium) -- здесь длинное дублирует среднее
deb.set(4, doshort, dolong4) -- здесь пересечение функций на разных кнопках (вместе с предыдущей строкой)

]]


do
local function setnew (pin)
    return {}
end
local M = {}
M.set = function(pin, short, med, long)
    gpio.mode(pin, gpio.INPUT, gpio.PULLUP)
    local o = setnew ()
    o.buttonPin = pin
    o.cycle = 0
    o.startcount = false
    o.gotpress = false
    o.doshort = short
    o.domedium = med or o.doshort
    o.doendcycle = long or o.domedium
    o.startpin = function(self)
        -- gpio.trig(self.buttonPin, "down")
        gpio.trig(self.buttonPin, "down",function (level, when, eventcount)
            if self.gotpress == false then
                self.gotpress = true
                local endflag = false
                local function exitnow(buf)
                    tmr.stop(buf); tmr.unregister( buf)
                    if not endflag then
                        if self.cycle < 20 then self.doshort()
                        else self.domedium() end
                    end
                    self.cycle, self.gotpress, self.startcount = 0, false, false
                end
                local buf = tmr.create()
                buf:alarm(50, 1, function()
                    if gpio.read(self.buttonPin) == 0 then
                        self.cycle = self.cycle + 1
                    else
                        if not self.startcount then
                            self.cycle = self.cycle - 1
                            if self.cycle < 0 then exitnow(buf) end
                        else
                            exitnow(buf)
                        end
                    end
                    if self.cycle > 3 then self.startcount = true end
                    if self.cycle > 50 and not endflag then
                        endflag = true; self.doendcycle()
                    end
                end)
            end
        end)
    end
    return o:startpin()
end
return M
end