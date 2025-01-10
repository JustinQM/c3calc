module c3eval;

import lexer;
import ast;
import std::io;

struct Result
{
	bool is_floating;
	union {
		int128 value;
		double fvalue;
	}
}

fn Result evaluate(String f, bool debug = false)
{
	Tokens tokens = lexer::lexer(f);
	if (debug)
	{
		io::printfn("[TOKENS]");
		foreach(Token token: tokens.get_slice())
		{
			io::printfn("%s : %s", token.type, token.value);
		}
	}

	Parser parser = {.tokens = tokens, .current = 0};
	ASTNode* ast = parser.parse()!!;

	if (debug) 
	{
		io::printfn("[AST]");
		ast.print();
		io::printfn("\n");
	}

	defer(ast.free_ast());
	if (ast.is_floating())
	{
		return Result{.is_floating = true, .fvalue = ast.evaluatef()!!};
	}
	else
	{
		return Result{.is_floating = false, .value = ast.evaluate()!!};
	}
}
