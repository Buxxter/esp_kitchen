-- configure for 9600, 8N1, with echo
-- uart.setup(0, 19200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
tmr.delay(3000000)
if file.open("init_ota.lc") then
    file.close()
    dofile("init_ota.lc")
else
    dofile("init_ota.lua")
end

