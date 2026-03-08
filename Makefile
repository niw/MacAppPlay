.DEFAULT_GOAL := install

PACKAGE_DIR := MacAppPlay
SKILL_SCRIPTS_DIR := Skills/mac-app-play/scripts
BINARY_NAME := mac_app_play
BUILD_CONFIG := release

SWIFT_BUILD_FLAGS := -c $(BUILD_CONFIG) --package-path $(PACKAGE_DIR)


.PHONY: resolve
resolve:
	swift package resolve --package-path $(PACKAGE_DIR)

.PHONY: build
build: resolve
	swift build $(SWIFT_BUILD_FLAGS)

$(SKILL_SCRIPTS_DIR):
	mkdir -p $@

.PHONY: install
install: build $(SKILL_SCRIPTS_DIR)
	cp "$$(swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/$(BINARY_NAME)" $(SKILL_SCRIPTS_DIR)/$(BINARY_NAME)

.PHONY: clean
clean:
	swift package clean --package-path $(PACKAGE_DIR)
	rm -f $(SKILL_SCRIPTS_DIR)/$(BINARY_NAME)
