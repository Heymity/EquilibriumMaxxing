#include <stdlib.h>
#include <pico/stdlib.h>
#include <tusb.h>
#include <pico/stdio.h>
#include "hardware/gpio.h"
#include "hardware/adc.h"
#include "hardware/dma.h"
#include "hardware/irq.h"
#include "hardware/uart.h"
#include "hardware/pwm.h"

#define UART_ID uart1
#define BAUD_RATE 115200
#define DATA_BITS 8
#define STOP_BITS 1
#define PARITY UART_PARITY_NONE

#define UART_TX_PIN 4
#define UART_RX_PIN 5

#define ADC_FREQ 48000000
#define ADC_CHANNELS 2
#define ADC_CHANNEL_MASK ((1<<ADC_CHANNELS) - 1)
// This needs to be of form ADC_FREQ/(ADC_CHANNELS*n), where n is a integer.
// Max ADC sample rate is 500_000 samples/s. Channels are multiplexed
//#define ADC_CHANNEL_SAMPLE_RATE 10000
#define ADC_CHANNEL_SAMPLE_RATE 10000
#define ADC_CLKDIV ((ADC_FREQ / (ADC_CHANNELS*(float)ADC_CHANNEL_SAMPLE_RATE)) - 1)

#define PICO_DEFAULT_LED_PIN 25
//(500k/s)
// 500000	- 1s
// 5000		- 10ms
// 1000		- 2ms
#define NUM_BUFFERS 2
#define NUM_SAMPLES_PER_BUFFER 1500
#define NUM_BYTES_PER_BUFFER (NUM_SAMPLES_PER_BUFFER*sizeof(uint16_t))

static int dma_chan = -1;
static uint16_t adcBuffers[NUM_BUFFERS][NUM_SAMPLES_PER_BUFFER] = {{},{}};
static uint8_t dmaBufferIdx = 0;
static uint8_t lastDmaBufferIdx= -1;

typedef struct PWM_gpio {
	uint gpio;
	uint channel;
	uint slice;
	uint period;
	uint duty;
} PWM_gpio;

PWM_gpio r_left;
PWM_gpio g_left;
PWM_gpio b_left;

PWM_gpio r_right;
PWM_gpio g_right;
PWM_gpio b_right;

PWM_gpio* pwms[6];

int leverMax[2] = {0, 0};
int leverMin[2] = {4096, 4096};

void dma_handler();
void update_pwm();

int main() {
	stdio_init_all();
	printf("Initialized\n");

    uart_init(UART_ID, BAUD_RATE);

    gpio_set_function(UART_TX_PIN, GPIO_FUNC_UART);
    gpio_set_function(UART_RX_PIN, GPIO_FUNC_UART);
    uart_set_hw_flow(UART_ID, false, false);
    uart_set_format(UART_ID, DATA_BITS, STOP_BITS, PARITY);
	uart_set_fifo_enabled(UART_ID, true);

	b_left.gpio = 10;
	g_left.gpio = 11;
	r_left.gpio = 12;

	b_right.gpio = 23;
	g_right.gpio = 24;
	r_right.gpio = 25;

	pwms[0] = &r_left;
	pwms[1] = &g_left;
	pwms[2] = &b_left;
	pwms[3] = &r_right;
	pwms[4] = &g_right;
	pwms[5] = &b_right;

	for (int i = 0; i < 6; i++) {
		adc_gpio_init(pwms[i]->gpio);
		gpio_set_function(pwms[i]->gpio, GPIO_FUNC_PWM);
		pwms[i]->period = 256;
		pwms[i]->duty = 20;
		pwms[i]->slice = pwm_gpio_to_slice_num(pwms[i]->gpio);
		pwms[i]->channel = pwm_gpio_to_channel(pwms[i]->gpio);
		pwm_set_wrap(pwms[i]->slice, 255);

		pwm_set_chan_level(pwms[i]->slice, pwms[i]->channel, pwms[i]->duty);
		pwm_set_enabled(pwms[i]->slice, true);
	}

	adc_init();

	// Make sure GPIO is high-impedance, no pullups etc
	adc_gpio_init(26);
	adc_gpio_init(27);
	adc_gpio_init(28);
	adc_gpio_init(29);

	adc_select_input(0);
	/*
	    *This function sets which inputs are to be run through in round-robin mode. RP2040, RP2350 QFN-60: Value between 0
        and 0x1f (bit 0 to bit 4 for GPIO 26 to 29 and temperature sensor input respectively) RP2350 QFN-80: Value between 0
        and 0xff (bit 0 to bit 7 for GPIO 40 to 47 and temperature sensor input respectively)

		bitmask 0x1f -> 0001_1111
		temp sensor . 29 . 28 . 27 . 26
    */
	adc_set_round_robin(ADC_CHANNEL_MASK);
	adc_fifo_setup(
		true,    // Write each completed conversion to the sample FIFO
		true,    // Enable DMA data request (DREQ)
		1,       // DREQ (and IRQ) asserted when at least 1 sample present
		false,   // Error bit
		false     // Shift each sample to 8 bits when pushing to FIFO
	);

    adc_set_clkdiv(ADC_CLKDIV);

	// Set up the DMA to start transferring data as soon as it appears in FIFO
	dma_chan = dma_claim_unused_channel(true);
	dma_channel_config cfg = dma_channel_get_default_config(dma_chan);

	// Reading from constant address, writing to incrementing byte addresses
	channel_config_set_transfer_data_size(&cfg, DMA_SIZE_16);
	channel_config_set_read_increment(&cfg, false);
	channel_config_set_write_increment(&cfg, true);
	channel_config_set_irq_quiet(&cfg, false);

	// Pace transfers based on availability of ADC samples
	channel_config_set_dreq(&cfg, DREQ_ADC);

	dmaBufferIdx = 0;
	dma_channel_configure(dma_chan, &cfg,
		adcBuffers[dmaBufferIdx],    // dst
		&adc_hw->fifo,  // src
		NUM_SAMPLES_PER_BUFFER,  // transfer count
		false            // start immediately
	);

	dma_channel_set_irq0_enabled(dma_chan, true);

	// Configure the processor to run dma_handler() when DMA IRQ 0 is asserted
	irq_set_exclusive_handler(DMA_IRQ_0, dma_handler);
	irq_set_enabled(DMA_IRQ_0, true);

	dma_channel_start(dma_chan);

	adc_run(true);

	//gpio_init(PICO_DEFAULT_LED_PIN);
	//gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);
	//gpio_put(PICO_DEFAULT_LED_PIN, true);


#pragma clang diagnostic push
#pragma ide diagnostic ignored "EndlessLoop"
	while(true) {
		tight_loop_contents();
	}
#pragma clang diagnostic pop
}

void __not_in_flash_func(dma_handler()) {
	static uint64_t lastInvokedTime = 0;
	if (!dma_channel_get_irq0_status(dma_chan)) return;

	lastDmaBufferIdx = dmaBufferIdx;
	if (++dmaBufferIdx >= NUM_BUFFERS) dmaBufferIdx = 0;
	dma_hw->ints0 = 1u << dma_chan;

	dma_channel_set_write_addr(dma_chan, adcBuffers[dmaBufferIdx], true);
	//printf("ADC FIFO has %d elements  | ", adc_fifo_get_level());
	const uint64_t tmp = lastInvokedTime;
	lastInvokedTime = to_us_since_boot(get_absolute_time());
	//printf("DMA IRQ Triggered, deltaT = %llu ms (%llu us), expected to be %f mas | " , (lastInvokedTime- tmp)/1000, lastInvokedTime - tmp, NUM_SAMPLES_PER_BUFFER/(ADC_CHANNELS * (ADC_CHANNEL_SAMPLE_RATE/1000.0f)));

	// Clear the interrupt request.

    int firstAdc = ((-((int)adc_get_selected_input() - NUM_SAMPLES_PER_BUFFER)) % ADC_CHANNELS);
    long sum[ADC_CHANNELS] = {0, 0};
    for (int i = 0; i < NUM_SAMPLES_PER_BUFFER; i++) {
        sum[(firstAdc + i) % ADC_CHANNELS] += adcBuffers[lastDmaBufferIdx][i];
    }

    for (int i = 0; i < ADC_CHANNELS; i++) {
        sum[i] = (sum[i] * ADC_CHANNELS) / NUM_SAMPLES_PER_BUFFER;
       //sum[i] -= (0x0FFF / 2);
		if (sum[i] < 1000) sum[i] = 1000;
		if (sum[i] > 3200) sum[i] = 3200;

    	if (sum[i] > leverMax[i]) leverMax[i] = sum[i];
    	if (sum[i] < leverMin[i]) leverMin[i] = sum[i];
    }
	//long sum = 0;
	//for (int i = 0; i < NUM_SAMPLES_PER_BUFFER; i++) {
		//sum += adcBuffers[lastDmaBufferIdx][i];
		//adcBuffers[lastDmaBufferIdx][i] |= 0b1111 << 12;
//		adcBuffers[lastDmaBufferIdx][i] = __builtin_bswap16(adcBuffers[lastDmaBufferIdx][i]);
	//}
	//printf("ADC FIFO has %d elements  | \n", adc_fifo_get_level());
	//

    printf("Avg: %ld\n", sum[0]);
    printf("Avg: %ld\n", sum[1]);
    printf("Last: %d\n", adcBuffers[lastDmaBufferIdx][0]);
    printf("Last: %d\n", adcBuffers[lastDmaBufferIdx][1]);

	int16_t remapped[] = {0, 0};
	for (int i = 0; i < ADC_CHANNELS; i++) {
		remapped[i] = ((float)((uint16_t)sum[i] - leverMax[i]) / ((float)(leverMax[i] - leverMin[i])) * 600) + 300;
		//remapped[i] = (((uint16_t)(sum[i] < 0 ? -sum[i] : sum[i])) - 0xFFF/2) / 4;
	}

	//remapped[1] = 0;
	printf("Remapped: %d\n", remapped[0]);
	printf("Remapped: %d\n", remapped[1]);


	uint64_t sample_time = lastInvokedTime- tmp;
	uint8_t header[] = {
		// Preamble - 4 bytes
		'D', 'A', 'T', 'A',
        (uint8_t)   remapped[0] & 0xff,
        (uint8_t) ((remapped[0] >> 8) & 0xff),
        (uint8_t)   remapped[1] & 0xff,
        (uint8_t) ((remapped[1] >> 8) & 0xff),
		/* Timestamp - 8 bytes (12 bytes total) - Little Endian
		(uint8_t) lastInvokedTime & 0xff,
		(uint8_t) ((lastInvokedTime >> 8) & 0xff),
		(uint8_t) ((lastInvokedTime >> 16) & 0xff),
		(uint8_t) ((lastInvokedTime >> 24) & 0xff),
		(uint8_t) ((lastInvokedTime >> 32) & 0xff),
		(uint8_t) ((lastInvokedTime >> 40) & 0xff),
		(uint8_t) ((lastInvokedTime >> 48) & 0xff),
		(uint8_t) ((lastInvokedTime >> 56) & 0xff),
		// First two bytes refer to channel ? - 1 byte (13 bytes total)
		(uint8_t) ((-((int)adc_get_selected_input() - NUM_SAMPLES_PER_BUFFER)) % ADC_CHANNELS),
		// Number of channels - 1 byte (14 bytes)
		ADC_CHANNELS,
		// Packet Length - 2 bytes (16 bytes total)
		(uint8_t) ((NUM_BYTES_PER_BUFFER) & 0xff),
		(uint8_t) ((NUM_BYTES_PER_BUFFER >> 8) & 0xff),
		// Sample Time - 4 bytes (20 bytes total)
		(uint8_t) ((sample_time) & 0xff),
		(uint8_t) ((sample_time >> 8) & 0xff),
		(uint8_t) ((sample_time >> 16) & 0xff),
		(uint8_t) ((sample_time >> 24) & 0xff)*/
	};
    uart_write_blocking(UART_ID, header, sizeof(header));

	// 252, 126, 0  t= 1
	// 0, 195, 255  t= 0

	uint8_t r_interpolated;
	uint8_t g_interpolated;
	uint8_t b_interpolated;

	if (remapped[0] > 0) {
		//const float t = ((float)(sum[0] - 2048) / 2048.0f);
		const float t = ((float)(remapped[0]) / 500.0f);

		r_interpolated = (uint8_t) (252.0 * t);
		g_interpolated = (uint8_t) (126.0 * t);
		b_interpolated = (uint8_t) (0 * t);
	} else {
		//const float t = 1.0f - ((float)(sum[0]) / 2048.0f);
		const float t = ((float)(-remapped[0]) / 500.0f);

		r_interpolated = (uint8_t) (0.0* t);
		g_interpolated = (uint8_t) (195.0 * t);
		b_interpolated = (uint8_t) (255.0 * t);
	}
	r_left.duty = r_interpolated;
	g_left.duty = g_interpolated;
	b_left.duty = b_interpolated;


	//if (sum[1] > 2048) {
	if (remapped[1] > 0) {
		//const float t = ((float)(sum[1] - 2048) / 2048.0f);
		const float t = ((float)(remapped[1]) / 500.0f);

		r_interpolated = (uint8_t) (252.0 * t);
		g_interpolated = (uint8_t) (126.0 * t);
		b_interpolated = (uint8_t) (0 * t);
	} else {
		//const float t = 1.0f - ((float)(sum[1]) / 2048.0f);
		const float t = ((float)(-remapped[1]) / 500.0f);

		r_interpolated = (uint8_t) (0.0* t);
		g_interpolated = (uint8_t) (195.0 * t);
		b_interpolated = (uint8_t) (255.0 * t);
	}

	r_right.duty = r_interpolated;
	g_right.duty = g_interpolated;
	b_right.duty = b_interpolated;

	update_pwm();

	//tud_cdc_n_write(1, header, sizeof(header));
	//tud_cdc_n_write_flush(1);
	//tud_cdc_n_write(1, "START MESSAGE ----------", 24);
	//tud_cdc_n_write(1, adcBuffers[lastDmaBufferIdx], NUM_BYTES_PER_BUFFER);
	//tud_cdc_n_write(1, " ------ END MESSAGE\n\r", 21);
	//tud_cdc_n_write_flush(1);

	//tud_cdc_n_write(0, prev_buffer, NUM_SAMPLES);

}

void update_pwm() {
	//printf("%d, %d, %d - %d, %d, %d\n", r_left.duty,g_left.duty,b_left.duty, r_right.duty, g_right.duty, b_right.duty);

	for (int i = 0; i < 6; i++) {
		//printf("%d\n", pwms[i]->duty);
		pwm_set_chan_level(pwms[i]->slice, pwms[i]->channel, pwms[i]->duty);
		pwm_set_enabled(pwms[i]->slice, true);
	}
}