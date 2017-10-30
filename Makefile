all: test playground

playground: build
	@.build/debug/playground

build:
	@swift build

test:
	@swift test
