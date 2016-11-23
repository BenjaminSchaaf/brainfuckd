import std.stdio;
import std.conv;
import std.range;
import std.algorithm;

import brainfuck : brainfuck;

const HELP_MESSAGE = "Usage: brainfuckd <source>";

const READ_BLOCK_SIZE = 4096;

version(unittest) {} else // Don't include when running unittests
void main(string[] args) {
    if (args.length != 2 || args[1] == "--help" || args[1] == "-h") {
        writeln(HELP_MESSAGE);
        return;
    }

    string sourceFile = args[1];
    auto source = File(sourceFile, "r").byChunk(READ_BLOCK_SIZE).joiner.array;
    auto input = lazyRange(() => stdin.byChunk(1)).joiner.map!(to!char);

    auto result = brainfuck(cast(char[])source, input);
    foreach (char chr; result) {
        write(chr);
    }
}

/// A range that lazily wraps another range
/// The wrapped range is only evaluated once needed
/// This can be used to avoid blocking IO until needed
struct LazyRange(R) if (isInputRange!R) {
    static assert(isInputRange!(LazyRange!(int[])));

    private {
        R _range;
        R delegate() lazyFn;
    }

    this(R delegate() lazyFn) {
        this.lazyFn = lazyFn;
    }

    @property bool empty() {
        return range.empty;
    }

    @property auto front() {
        return range.front;
    }

    void popFront() {
        range.popFront();
    }

    private @property ref R range() {
        if (lazyFn != null) {
            _range = lazyFn();
            lazyFn = null;
        }
        return _range;
    }
}

auto lazyRange(R)(R delegate() lazyFn) {
    return LazyRange!R(lazyFn);
}
