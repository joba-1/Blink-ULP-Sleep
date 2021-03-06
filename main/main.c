/*
 * JoBa1 ESP32 ULP blink example
 *
 * Load and start an ULP programm, then go to sleep
 */

#include <stdio.h>         // printf(), fflush()
#include <unistd.h>        // usleep()
#include "esp_sleep.h"     // esp_sleep_enable_ulp_wakeup(), esp_deep_sleep_start()

#include "ulp-util.h"      // my ulp_init(), ulp_start(), ulp_get() and .globals


// Helper routine to convert 16-bit value to a bit string with dot separators
// Not required for blinking, just for the ULP - Main Core data exchange demo.

char *b2s( uint16_t val, char *buf, uint16_t dots ) {
  char *ptr = buf;
  for( uint16_t mask=1<<(16-1); mask; mask>>=1 ) {
    *(ptr++) = val & mask ? '1' : '0';
    if( dots & mask ) *(ptr++) = '.';
  }
  *ptr = '\0';
  return buf;
}


void app_main()
{
  uint16_t dots = BIT(4) + BIT(8) + BIT(12);
  char bins[16+3+1];

  printf("Hello Blink ULP!\n");

  uint32_t wakeups[] = {500*1000, 50*1000, 950*1000 };
  ulp_init(wakeups, sizeof(wakeups)/sizeof(*wakeups));
  ulp_start();

  printf("Started ULP.\n");

  {
    /*
    Demo of ULP copro updating values (here: status of gpuio pins),
    and main core receiving them and writing them to serial.
    This block is not required for ULP program to run,
    main core could go to deep sleep right away.
    */
    uint16_t was_gpios = 0;
    uint8_t awake_loops = 10;
    while(awake_loops--) {
      uint16_t gpios = ulp_get(ulp_gpios);
      if( gpios != was_gpios ) {
        printf("gpios: %s\n", b2s(gpios, bins, dots));
        was_gpios = gpios;
      }
      usleep(1000*1000);
    }
  }

  printf("Going to sleep now.\n");
  fflush(stdout);

  ESP_ERROR_CHECK( esp_sleep_enable_ulp_wakeup() );
  esp_deep_sleep_start();
}

