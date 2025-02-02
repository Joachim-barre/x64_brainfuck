BUILDDIR=build
PROG=$(BUILDDIR)/prog
OBJS=$(BUILDDIR)/main.o

LD=gcc
LDFLAGS=-no-pie

ASM=nasm
ASMFLAGS=-f elf64

all: $(PROG)

.PHONY: clean run

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/%.o: src/%.asm | $(BUILDDIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(PROG): $(OBJS) | $(BUILDDIR)
	$(LD) $(LDFLAGS) $(OBJS) -o $(PROG)

clean:
	rm -r $(BUILDDIR)

run: $(PROG)
	chmod +x $(PROG) && ./$(PROG)

