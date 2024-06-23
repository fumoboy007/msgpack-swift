# Developing `msgpack-swift`

## Automated Tests

### Prerequisites

The `MessagePackTests` target depends on the `MessagePackReferenceImplementation` [package](https://github.com/fumoboy007/MessagePackReferenceImplementation). That package requires the following software to be available in the [`PATH`](https://en.wikipedia.org/wiki/PATH_(variable)):
- [`pkg-config`](https://www.freedesktop.org/wiki/Software/pkg-config/)
- [`msgpack-c`](https://github.com/msgpack/msgpack-c)

#### Installing Prerequisites on Ubuntu

```console
$ sudo apt install pkg-config libmsgpack-dev
```

#### Installing Prerequisites on macOS

```console
$ brew install pkg-config msgpack
```

### Running the Tests Locally

The tests can be run either from an IDE or from the command line.

#### `MessagePackTests` Target

Some tests require specific environments:
- Some tests require the release configuration; otherwise, they would run too slowly.
- Some tests require a minimum amount of memory to be available. 

If the environment is not suitable for a given test, that test will be marked as skipped.

#### `Benchmarks` Target

The target should generally be built using the release configuration, though it can also be built using the debug configuration to see the unoptimized performance.
