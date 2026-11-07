BIN_DIR := $(HOME)/bin
AGENT := $(HOME)/Library/LaunchAgents/com.fernandotcl.logiback.plist

logiback: main.swift
	swiftc -O -o $@ main.swift

install: logiback
	mkdir -p $(BIN_DIR) $(dir $(AGENT))
	cp logiback $(BIN_DIR)/logiback
	sed 's|@BIN@|$(BIN_DIR)/logiback|' com.fernandotcl.logiback.plist > $(AGENT)
	launchctl bootout gui/$$(id -u) $(AGENT) 2>/dev/null || true
	launchctl bootstrap gui/$$(id -u) $(AGENT)

uninstall:
	launchctl bootout gui/$$(id -u) $(AGENT) 2>/dev/null || true
	rm -f $(AGENT) $(BIN_DIR)/logiback

clean:
	rm -f logiback

.PHONY: install uninstall clean
