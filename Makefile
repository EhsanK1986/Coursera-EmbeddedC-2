#******************************************************************************
# Copyright (C) 2017 by Alex Fosdick - University of Colorado
#
# Redistribution, modification or use of this software in source or binary
# forms is permitted as long as the files maintain this copyright. Users are 
# permitted to modify this and use it to learn about the field of embedded
# software. Alex Fosdick and the University of Colorado are not liable for any
# misuse of this material. 
#
#*****************************************************************************

#------------------------------------------------------------------------------
# This is a makefile for two different targets
#
# Use: make [TARGET] [PLATFORM-OVERRIDES]
#
# Build Targets:
#      	<FILE>.o - Builds <FILE>.o object file
#	build - Builds and links all source files
#	all - Same as build
#	clean - Removes all generated files
#
# Platform Overrides:
#      	CPU - HOST, MSP432
#	ARCH - ARM
#	SPEC - nosys.specs
#
#------------------------------------------------------------------------------
include sources.mk

# compiler common flags
CFLAGS =	-Wall \
		-Werror \
		-g \
		-O0 \
		-std=c99
#name of the out files
BASENAME = c1m2
TARGET = $(BASENAME).out

#default platform
PLATFORM = HOST


# Platform chosing process
	ifeq ($(PLATFORM),HOST)
		CC = gcc #compiler
		CPPFLAGS = -DHOST $(INCLUDES) #preprocessing flags
		SIZE = size
	else ifeq ($(PLATFORM),MSP432)
		CC = arm-none-eabi-gcc #compiler
		LD = arm-none-eabi-ld
		LINKER_FILE = ../msp432p401r.lds
		LDFLAGS = -Wl,-Map=$(BASENAME).map -T $(LINKER_FILE)
		CPU = cortex-m4
		ARCH = armv7e-m
		CPPFLAGS = -DMSP432 $(INCLUDES) #preprocessing flags
		CFLAGS+=	-mcpu=$(CPU) \ #architecture specific flags
			-mthumb \
			-march=$(ARCH) \
			-mfloat-abi=hard \
			-mfpu=fpv4-sp-d16 \
			--specs=nosys.specs
		SIZE = arm-none-eabi-size
	endif

PPF = $(SOURCES:.c=.i) #preprocessing files
DPF = $(SOURCES:.c=.d) #dependency files
ASF = $(SOURCES:.c=.asm) #assembly files
OBJF = $(SOURCES:.c=.o) #object files



.PHONY: build compile-all clean

build: $(TARGET)

$(TARGET): $(OBJF)
	$(CC) $(OBJF) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) -o $@
	$(SIZE) $@

%.i: %.c
	$(CC) -E $< $(CFLAGS) $(CPPFLAGS) -o $@

%.asm: %.c
	$(CC) -S $< $(CFLAGS) $(CPPFLAGS) -o $@



%.o : %.c
	$(CC) -c $< $(CFLAGS) $(CPPFLAGS) -o $@

%.d: %c
	$(CC) -E -M $<  $(CPPFLAGS) -o $@

compile-all: $(OBJF)



clean:
	rm -f *.out *.map *.o *.asm *.i








