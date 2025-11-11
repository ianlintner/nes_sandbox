# Makefile for NES Cat Mecha Shmup

# Tools
CA65 = ca65
LD65 = ld65

# Flags
CAFLAGS = -t nes
LDFLAGS = -C nes.cfg

# Target
TARGET = catmecha.nes

# Source files
SOURCES = main.s
OBJECTS = $(SOURCES:.s=.o)

# Default target
all: $(TARGET)

# Link the NES ROM
$(TARGET): $(OBJECTS)
	$(LD65) $(LDFLAGS) -o $@ $^

# Assemble source files
%.o: %.s
	$(CA65) $(CAFLAGS) -o $@ $<

# Clean build artifacts
clean:
	rm -f $(OBJECTS) $(TARGET)

# Phony targets
.PHONY: all clean
