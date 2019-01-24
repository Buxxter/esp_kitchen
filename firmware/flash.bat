echo "erasing flash..."
echo off
esptool.py --port COM7 --after no_reset erase_flash
echo "finished... Writing HEX"
echo "Enter to a boot mode and hit Enter"
pause
esptool.py --port COM7 --after hard_reset write_flash 0x0 nodemcu-master-8-modules-2019-01-06-14-02-10-integer.bin --flash_mode dio
echo "finished..."
pause
echo on