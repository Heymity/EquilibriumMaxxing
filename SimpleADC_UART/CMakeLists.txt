cmake_minimum_required(VERSION 3.13)

set(PICO_SDK_PATH ./../pico-sdk CACHE FILEPATH "Path to the pico SDK (IC-Mapeamento)")
set(PICO_BOARD pico CACHE STRING "Board type (IC-Mapeamento")
set(PICO_PLATAFORM rp2040 CACHE STRING "Plataform type")

include(pico_sdk_import.cmake)

project(SimpleADC_UART C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()

add_executable(SimpleADC_UART
	main.c
)

pico_enable_stdio_usb(SimpleADC_UART 1)
pico_add_extra_outputs(SimpleADC_UART)

target_link_libraries(SimpleADC_UART pico_stdlib
		pico_stdlib
		hardware_adc
		hardware_irq
		hardware_dma)
