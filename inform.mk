
# Makefile for InForm-PE

# Determine the operating system
ifeq ($(OS),)
	ifeq ($(shell uname -s),Linux)
		OS := Linux
	endif
	ifeq ($(shell uname -s),Darwin)
		OS := macOS
	endif
endif

# If OS is still not set, default to Windows
ifeq ($(OS),)
	OS := Windows_NT
endif

# Check if OS is one of the expected values
ifeq ($(filter $(OS),Linux macOS Windows_NT),)
$(error OS must be set to 'Linux', 'macOS', or 'Windows_NT')
endif

$(info OS: $(OS))

# Set platform-specific variables
ifeq ($(OS),Windows_NT)
	RM := del /Q
	EXTENSION := .exe
else
	RM := rm -fr
	EXTENSION :=
endif

# Set default values or use user-provided ones
QB64PE_PATH ?= ../qb64pe

# Set QB64-PE flags
QB64PE_FLAGS := -x -w -e

# Set QB64-PE command
QB64PE := $(QB64PE_PATH)/qb64pe$(EXTENSION)

.PHONY: all clean release

all: UiEditor$(EXTENSION) InForm/UiEditorPreview$(EXTENSION) InForm/vbdos2inform$(EXTENSION)

UiEditor$(EXTENSION) : InForm/UiEditor.bas
	$(QB64PE) $(QB64PE_FLAGS) $< -o $@

InForm/UiEditorPreview$(EXTENSION) : InForm/UiEditorPreview.bas
	$(QB64PE) $(QB64PE_FLAGS) $< -o $@

InForm/vbdos2inform$(EXTENSION) : InForm/vbdos2inform.bas
	$(QB64PE) $(QB64PE_FLAGS) $< -o $@

clean:
ifeq ($(OS),Windows_NT)
	$(RM) UiEditor$(EXTENSION) InForm\UiEditorPreview$(EXTENSION) InForm\vbdos2inform$(EXTENSION)
else
	$(RM) UiEditor$(EXTENSION) InForm/UiEditorPreview$(EXTENSION) InForm/vbdos2inform$(EXTENSION)
endif

# Add release-specific flag
release: QB64PE_FLAGS += -f:OptimizeCppProgram=true
release: all
