/*
JoBa1 ESP32 ULP blink example using sleep

Simple ULP program that initializes a gpio pin, toggles it high/low
and then sleeps until the next gpio level change is due
*/

#include "soc/soc_ulp.h"      // for WRITE_RTC_REG
#include "soc/rtc_io_reg.h"   // for RTC_GPIO_*
#include "soc/rtc_cntl_reg.h" // for RTC_CNTL_*

.global entry           // ulp start address used by main core program
.global gpios           // Demo: tell main core our view on gpio pins

.set    gpio_2, 12      // gpio pin 2 is rtc pin 12

.bss

gpios:  .long 0         // Demo: value storing gpio pin status

.text

entry:

  // Config Pad 2 as digital gpio with output, input and unlocked
  // Next line might be needed for some pads, but not for #2
  // WRITE_RTC_REG(RTC_IO_TOUCH_PAD2_REG, RTC_IO_TOUCH_PAD2_TO_GPIO_S, 1, 1)
  WRITE_RTC_REG(RTC_IO_TOUCH_PAD2_REG, RTC_IO_TOUCH_PAD2_MUX_SEL_S, 1, 1)
  WRITE_RTC_REG(RTC_GPIO_OUT_REG, RTC_GPIO_OUT_DATA_S + gpio_2, 1, 1)
  WRITE_RTC_REG(RTC_IO_TOUCH_PAD2_REG, RTC_IO_TOUCH_PAD2_FUN_IE_S, 1, 1)
  WRITE_RTC_REG(RTC_IO_TOUCH_PAD2_REG, RTC_IO_TOUCH_PAD2_HOLD_S, 1, 0)

  // We want to wake up by timers
  WRITE_RTC_REG(RTC_CNTL_STATE0_REG, RTC_CNTL_ULP_CP_SLP_TIMER_EN_S, 1, 1)

  READ_RTC_FIELD (RTC_GPIO_IN_REG, RTC_GPIO_IN_NEXT)
  move  r1, gpios       // Demo: store gpio bit status at exported
  st    r0, r1, 0       // Demo: address, not required for blinking
  and   r0, r0, BIT(12)
  jump  on, eq

off:
  WRITE_RTC_REG(RTC_GPIO_ENABLE_W1TC_REG, RTC_GPIO_ENABLE_W1TC_S + gpio_2, 1, 1)
  sleep 2               // only works while main core is awake :(
  jump  exit

on:
  WRITE_RTC_REG(RTC_GPIO_ENABLE_W1TS_REG, RTC_GPIO_ENABLE_W1TS_S + gpio_2, 1, 1)
  sleep 1               // only works while main core is awake :(

exit:
  WRITE_RTC_REG(RTC_IO_TOUCH_PAD2_REG, RTC_IO_TOUCH_PAD2_HOLD_S, 1, 1)
  halt

