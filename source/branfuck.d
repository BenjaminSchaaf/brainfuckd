///
module brainfuck;

import std.conv;
import std.stdio;
import std.range;
import std.string;
import std.algorithm;
import std.exception;

/// Brainfuck source must be a bidirectional range of characters
template isBrainfuckSource(R) {
    enum isBrainfuckSource = isBidirectionalRange!R &&
                             is(ElementEncodingType!R == char);
}

/// Brainfuck input must be a input range of characters
template isBrainfuckInput(I) {
    enum isBrainfuckInput = isInputRange!I && is(ElementEncodingType!I == char);
}

/**
 * Brainfuck Range. Takes a bidirectional source range, and an input range, and
 * outputs the result of interpreting the source as brainfuck.
 *
 * This range is an input range of ubyte
 */
struct Brainfuck(S, I) if (isBrainfuckSource!S && isBrainfuckInput!I) {
    static assert(isInputRange!(Brainfuck!(char[], char[])));

    private {
        S source;
        size_t sourceLoc;

        size_t ptr;
        ubyte[] stack;

        I input;
        ubyte output;
    }

    @disable this();

    this(S source, I input) {
        this.source = source;
        this.input = input;
        popFront();
    }

    @property bool empty() {
        return sourceLoc >= source.length;
    }

    @property ubyte front() {
        return output;
    }

    void popFront() {
        while (!empty) {
            auto command = nextCommand();

            switch (command) {
                case '>':
                    ptr++;
                    break;
                case '<':
                    ptr--;
                    break;
                case '+':
                    data++;
                    break;
                case '-':
                    data--;
                    break;
                case '.':
                    output = data;
                    return;
                case ',':
                    data = dropOne(input).front.to!ubyte;
                    break;
                case '[':
                    if (data == 0) findNext(1, '[', ']');
                    break;
                case ']':
                    if (data != 0) findNext(-1, ']', '[');
                    break;
                default:
                    break;
            }
        }
    }

    private @property auto ref data() {
        if (ptr >= stack.length) {
            stack.length = ptr + 1;
        }
        return stack[ptr];
    }

    private @property auto nextCommand() {
        auto command = source[sourceLoc];
        sourceLoc++;
        return command;
    }

    /**
     * Find the next matching `decr` of a `incr`-`decr` pair,
     * in the direction of `dir`
     */
    private void findNext(ptrdiff_t dir, char incr, char decr) {
        size_t stack = 0;
        sourceLoc += dir * 2;

        while (true) {
            enforce(sourceLoc < source.length);
            enforce(sourceLoc >= 0);

            auto command = source[sourceLoc];
            sourceLoc += dir;

            if (command == incr) {
                stack++;
            } else if (command == decr) {
                if (stack == 0) {
                    source.popFront();
                    return;
                }
                stack--;
            }
        }
    }
}

/// Convinience function for creating a Branfuck range.
auto brainfuck(S, I)(S source, I input) if (isBrainfuckSource!S &&
                                            isBrainfuckInput!I) {
    return Brainfuck!(S, I)(source, input);
}

unittest {
    auto helloWorld = "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++
                       ..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.";

    auto result = brainfuck(helloWorld.to!(char[]), "".to!(char[]));
    assert(result.array == "Hello World!");
}
