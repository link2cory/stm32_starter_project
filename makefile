###############################################################################
# Basic Makefile template for stm32 projects using the cube HAL
#
# Author: Cory Perkins
###############################################################################
VERBOSE = 0

USE_FREERTOS = 1
FREERTOS_DIR = FreeRTOS

# application name
TARGET     = blinky

# STM32 Cube HAL Directory
CUBE_DIR   = cube

# Include search paths
INCLUDES       = -Isrc
INCLUDES      += -Isrc/include
VPATH          = ./src

# Sources
SRCS           = main.c

# MCU Board
BOARD_UC      = STM32F4xx-Nucleo
BOARD_LC      = stm32f4xx_nucleo

# MCU Family
MCU_FAMILY = stm32f4xx
MCU_LC     = stm32f4xx
MCU_MC     = STM32F401xE
MCU_UC     = STM32F401VEHx

# Example project directory is used for extracting some source files
LDFILE      = $(CUBE_DIR)/Projects/STM32F401RE-Nucleo/Examples/GPIO/GPIO_IOToggle/SW4STM32/$(BOARD_UC)/$(MCU_UC)_FLASH.ld
################################################################################
# Do not edit past this line!
################################################################################
################################################################################
# STM32 CUBE HAL Definitions
################################################################################
BSP_DIR        = $(CUBE_DIR)/Drivers/BSP/$(BOARD_UC)
HAL_DIR        = $(CUBE_DIR)/Drivers/STM32F4xx_HAL_Driver
CMSIS_DIR      = $(CUBE_DIR)/Drivers/CMSIS
DEV_DIR        = $(CMSIS_DIR)/Device/ST/STM32F4xx

VPATH          += $(BSP_DIR)
VPATH          += $(HAL_DIR)/Src
VPATH          += $(DEV_DIR)/Source/

SRCS          += system_$(MCU_FAMILY).c
SRCS          += stm32f4xx_hal.c
SRCS          += stm32f4xx_it.c
SRCS          += stm32f4xx_hal_msp.c
SRCS          += stm32f4xx_hal_rcc.c
SRCS          += stm32f4xx_hal_rcc_ex.c
SRCS          += stm32f4xx_hal_cortex.c
SRCS          += stm32f4xx_hal_gpio.c
SRCS          += stm32f4xx_hal_pwr_ex.c
SRCS          += $(BOARD_LC).c

INCLUDES      += -I$(BSP_DIR)
INCLUDES      += -I$(CMSIS_DIR)/Include
INCLUDES      += -I$(DEV_DIR)/Include
INCLUDES      += -I$(HAL_DIR)/Inc

# Libraries
LIBS        = -L$(CMSIS_DIR)/Lib

###############################################################################
# Toolchain Definitions
###############################################################################
PREFIX  = arm-none-eabi
CC      = $(PREFIX)-gcc
AR      = $(PREFIX)-ar
OBJCOPY = $(PREFIX)-objcopy
OBJDUMP = $(PREFIX)-objdump
SIZE    = $(PREFIX)-size
GDB     = $(PREFIX)-gdb

DEFINES       = -D$(MCU_MC) -DUSE_HAL_DRIVER

# Compiler flags
CFLAGS     = -Wall -g -std=c99 -Os
CFLAGS    += -mlittle-endian -mcpu=cortex-m4 -march=armv7e-m -mthumb
CFLAGS    += -mfpu=fpv4-sp-d16 -mfloat-abi=hard
CFLAGS    += -ffunction-sections -fdata-sections
CFLAGS    += $(INCLUDES)
CFLAGS    += $(DEFINES)

# Linker Flags
LDFLAGS    = -Wl,--gc-sections -Wl,-Map=$(TARGET).map $(LIBS) -T$(LDFILE)

OBJECTS    = $(addprefix obj/,$(SRCS:.c=.o))
DEPS       = $(addprefix dep/,$(SRCS:.c=.d))

###############################################################################
# FreeRTOS Definitions
###############################################################################
ifeq ($(USE_FREERTOS), 1)
	INCLUDES     += -I$(FREERTOS_DIR)/include
	SRCS         += cmsis_os.c
	SRCS         += croutine.c
	SRCS         += event_groups.c
	SRCS         += heap_2.c
	SRCS         += list.c
	SRCS         += port.c
	SRCS         += queue.c
	SRCS         += stream_buffer.c
	SRCS         += tasks.c
	SRCS         += timers.c
	VPATH        += $(FREERTOS_DIR)
	DEFINES      += -DUSE_RTOS_SYSTICK
endif
################################################################################
# OpenOCD
################################################################################
OCD        = openocd
OCD_DIR    = /usr/share/openocd/scripts
OCDFLAGS   = -f board/st_nucleo_f4.cfg
################################################################################
# Misc
################################################################################
ifeq ($(VERBOSE), 0)
	Q = @
endif
###############################################################################
# Rules
###############################################################################
.PHONY: all program clean

all: $(TARGET).bin

dirs: dep obj
dep obj:
	@echo "[MKDIR]   $@"
	$Qmkdir -p $@

obj/%.o : %.c | dirs
	@echo "[CC]      $(notdir $<)"
	$Q$(CC) $(CFLAGS) -c -o $@ $< -MMD -MF dep/$(*F).d

$(TARGET).bin: $(TARGET).elf
	@echo "[OBJCOPY] $(TARGET).bin"
	$Q$(OBJCOPY) -O binary $< $@

$(TARGET).elf: $(OBJECTS)
	@echo "[LD]      $(TARGET).elf"
	$Q$(CC) $(CFLAGS) $(LDFLAGS) startup_$(MCU_LC).s $^ -o $@
	@echo "[OBJDUMP] $(TARGET).lst"
	$Q$(OBJDUMP) -St $(TARGET).elf > $(TARGET).lst
	@echo "[SIZE]    $(TARGET).elf"
	$(SIZE) $(TARGET).elf

program: all
	$(OCD) -s $(OCD_DIR) $(OCDFLAGS) -c "program $(TARGET).elf verify reset exit"

clean:
	@echo "[RM]      $(TARGET).bin"; rm -f $(TARGET).bin
	@echo "[RM]      $(TARGET).elf"; rm -f $(TARGET).elf
	@echo "[RM]      $(TARGET).map"; rm -f $(TARGET).map
	@echo "[RM]      $(TARGET).lst"; rm -f $(TARGET).lst
	@echo "[RMDIR]   obj"          ; rm -fr obj/
	@echo "[RMDIR]   dep"          ; rm -fr dep/
