PROJECT_NAME="Made By Me"
GIT_HASH=$(shell git rev-parse HEAD | cut -c 1-8)
SOURCE_DIR=src/

server:
	@echo $(PROJECT_NAME) - $(GIT_HASH)
	@hugo server -s $(SOURCE_DIR) -D --noHTTPCache --forceSyncStatic

check:
	@echo $(PROJECT_NAME) - $(GIT_HASH)
	@hugo -s $(SOURCE_DIR) --printPathWarnings --printUnusedTemplates --panicOnWarning

build:
	@echo $(PROJECT_NAME) - $(GIT_HASH)
	@hugo -s $(SOURCE_DIR) --minify --printPathWarnings --printUnusedTemplates --panicOnWarning

clear:
	@echo $(PROJECT_NAME) - $(GIT_HASH)
	@rm -rf $(SOURCE_DIR)public
