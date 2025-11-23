#!/bin/bash
cd "$(dirname "$0")"
iverilog -g2012 -o tb.out \
  equilibrium_maxxing_top_tb.v \
  equilibrium_maxxing.v \
  equilibrium_maxxing_fd.v \
  equilibrium_maxxing_uc.v \
  hexa7seg.v \
  GameComponents/level_register.v \
  GameComponents/jogo_controller.v \
  GameComponents/comparador_jogo.v \
  GameComponents/contador_m.v \
  GameComponents/contador_m_half.v \
  GameComponents/contador_m_invertible.v \
  GameComponents/contador_m_redux_invertible.v \
  GameComponents/random_led_controller.v \
  GameComponents/random_led_controller_fd.v \
  GameComponents/random_led_controller_uc.v \
  GameComponents/random_number.v \
  GameComponents/led_color_fader.v \
  GameComponents/led_color_mixxer.v \
  GameComponents/pendulum_input_mux.v \
  Simulator/pendulum_driver.v \
  Simulator/step_controller.v \
  ReceptorSerial/serial2alavanca.v \
  ReceptorSerial/rx_serial_8N1.v \
  ReceptorSerial/rx_serial_8N1_fd.v \
  ReceptorSerial/rx_serial_uc.v \
  ReceptorSerial/registrador_n.v \
  ReceptorSerial/deslocador_n.v \
  LED_WS2811/WS2811_array_controller.v \
  LED_WS2811/WS2811_array_controller_fd.v \
  LED_WS2811/WS2811_array_controller_uc.v \
  LED_WS2811/WS2811_serial.v \
  LED_WS2811/WS2811_serial_fd.v \
  LED_WS2811/WS2811_serial_uc.v \
  LED_WS2811/WS2811_rgb_wave_provider.v

if [ $? -eq 0 ]; then
  echo "Compilation successful. Running simulation..."
  vvp tb.out
else
  echo "Compilation failed."
  exit 1
fi
