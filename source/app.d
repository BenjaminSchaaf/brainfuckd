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
    auto source = File(sourceFile, "r").byChunk(READ_BLOCK_SIZE).joiner.array.to!(char[]);
    auto input = stdin.byChunk(READ_BLOCK_SIZE).joiner.map!(to!char);

    auto result = brainfuck(source, input);
    write(cast(char[])result.array);
}
