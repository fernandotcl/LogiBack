BIN_DIR ?= /usr/local/bin
SUDO ?= sudo
AGENT := $(HOME)/Library/LaunchAgents/com.fernandotcl.logiback.plist

logiback: main.swift
	swiftc -O -o $@ main.swift

install: logiback
	$(SUDO) install -d $(BIN_DIR)
	$(SUDO) install -m 755 logiback $(BIN_DIR)/logiback
	mkdir -p $(dir $(AGENT))
	sed 's|@BIN@|$(BIN_DIR)/logiback|' com.fernandotcl.logiback.plist > $(AGENT)
	launchctl bootout gui/$$(id -u) $(AGENT) 2>/dev/null || true
	launchctl bootstrap gui/$$(id -u) $(AGENT)

uninstall:
	launchctl bootout gui/$$(id -u) $(AGENT) 2>/dev/null || true
	rm -f $(AGENT)
	$(SUDO) rm -f $(BIN_DIR)/logiback

clean:
	rm -f logiback

.PHONY: install uninstall clean
