write-edid
==========

Created by Dr. Ace Jeangle (support@chalk-elec.com) 
based on script from Tom Kazimiers (https://github.com/tomka/write-edid)

Writes EDID information over a given I2C-Bus to a monitor.
**The scripts expects root permissions!**

You can find out the bus number with: 
```
ic2detect -l
```
Address 0x50 should be available as the EDID data goes there.

* Use **-h** (**--hexadecimal**) option to provide EDID file in text form written as hexadecimal numbers.
* Use **-b** (**--binary**) option to provide EDID file in binary form. This option is used by default if filename suffix is .bin
* Also, the **--binary** option is usable if the file is input on stdin.

Example
==========
```
sudo ./write-edid.sh 3 edid.bin
```
will write file with binary EDID data into I2C-Bus #3
