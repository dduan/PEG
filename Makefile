all: test play

play: build
	@.build/debug/playground

build:
	@swift build

test:
	@swift test
