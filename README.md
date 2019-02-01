# ULP blink and sleep

Me trying to make an esp32 blink via ULP and even ULP sleeping most of the time.

## Build - Flash - Monitor
* Prepare shell to use ESP-IDF (see my [Blink-ULP repo](https://github.com/joba-1/Blink-ULP/blob/master/README.md) for details)
```
. ~/esp32/env.sh
```

* Fetch and build this example, flash it and open serial console (adapt ESPPORT and ESPBAUD to your setup. Can be configured in sdkconfig file)
```
mkdir /tmp/blink-$$ && \
cd /tmp/blink-$$ && \
git clone https://github.com/joba-1/Blink-ULP-Sleep.git && \
cd Blink-ULP-Sleep && \
make -j8 flash monitor ESPPORT=/dev/ttyUSB0 ESPBAUD=115200

```
A led connected to gnd (kathode) and gpio2 (anode) should blink now.
After 10s the blink pattern changes when main core goes to sleep

Exit the monitor with [Ctrl]-] (which is [Strg]-[Alt-Gr]-] on german keyboard)

JoBa1
