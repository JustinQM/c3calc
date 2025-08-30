module ast;

import std::io;
import std::collections::list;
import lexer;
import calc_functions;

enum NodeType {
	NODE_INTEGER,
	NODE_FLOATING,
	NODE_BINOP,
	NODE_UNOP,
	NODE_FUNCTION
}

enum OperatorType {
	OP_ADD,
	OP_SUB,
	OP_MULT,
	OP_DIVIDE,
	OP_MOD,
	OP_POW,
	OP_NEGATE
}

struct ASTNode {
	NodeType type;
	union {
		int128 value;
		double fvalue;
		struct binop {
			OperatorType type;
			ASTNode* lhs;
			ASTNode* rhs;
		}
		struct unop {
			OperatorType type;
			ASTNode* rhs;
		}
		struct function {
			String symbol;
			List{ASTNode*} args;
		}
	}
}

faultdef TOKEN_TYPE_MISMATCH;
faultdef TOKEN_OUT_OF_BOUNDS;
faultdef TOKEN_OUT_OF_BOUNDS_PEEK;
faultdef TOKEN_INVALID_OPERATION;
faultdef EVALUATE_UNREACHABLE;
faultdef NONPAIRED_PAREN;
faultdef UNEXPECTED_TOKEN;


fn ASTNode* node_init_integer(int128 value)
{
	ASTNode* node = mem::new(ASTNode);
	node.type = NODE_INTEGER;
	node.value = value;
	return node;
}

fn ASTNode* node_init_double(double value)
{
	ASTNode* node = mem::new(ASTNode);
	node.type = NODE_FLOATING;
	node.fvalue = value;
	return node;
}

fn ASTNode* node_init_unop(OperatorType type, ASTNode* rhs)
{
	ASTNode* node = mem::new(ASTNode);
	node.type = NODE_UNOP;
	node.unop.type = type;
	node.unop.rhs = rhs;
	return node;
}

fn ASTNode* node_init_binop(OperatorType type, ASTNode* lhs, ASTNode* rhs)
{
	ASTNode* node = mem::new(ASTNode);
	node.type = NODE_BINOP;
	node.binop.type = type;
	node.binop.lhs = lhs;
	node.binop.rhs = rhs;
	return node;
}

fn ASTNode* node_init_function(String symbol)
{
	ASTNode* node = mem::new(ASTNode);
	node.type = NODE_FUNCTION;
	node.function.symbol = symbol;
	node.function.args.init(mem);
	return node;
}
fn void ASTNode.free_ast(&self)
{
	if (self.type == NODE_BINOP)
	{
		self.binop.lhs.free_ast();
		self.binop.rhs.free_ast();
	}
	else if (self.type == NODE_UNOP)
	{
		self.unop.rhs.free_ast();
	}
	else if (self.type == NODE_FUNCTION)
	{
		self.function.args.free();
	}
	free(self);
}

fn bool ASTNode.is_floating(&self)
{
	bool ret = false;
	if (self.type == NODE_UNOP)	
	{
		ret = self.unop.rhs.is_floating();	
		if(ret) return true;
	}
	else if (self.type == NODE_BINOP)
	{
		if (self.binop.type == OP_DIVIDE) 
		{
			if (self.binop.lhs.evaluate()!! % self.binop.rhs.evaluate()!! != 0)
			{
				return true;
			}
		}
		ret = self.binop.lhs.is_floating();
		if(ret) return true;
		ret = self.binop.rhs.is_floating();
		if(ret) return true;
	}
	else if (self.type == NODE_FLOATING) 
	{
		return true;
	}
	else if (self.type == NODE_FUNCTION)
	{
		List{int128} args_evaluated;
		args_evaluated.init(mem);
		defer(args_evaluated.free());
		if (self.function.args.len() > 0) //if we have args, evaluate them
		{
			foreach (ASTNode* arg: self.function.args)
			{
				ret = arg.is_floating();
				if (ret) return true;
				args_evaluated.push(arg.evaluate()!!);
			}
		}
		return calc_functions::is_function_floating{int128}(self.function.symbol, ...args_evaluated.array_view())!!;
	}
	return false;
}

struct Parser {
	Tokens tokens;
	bool floating;
	int current;
}

fn Token Parser.get_current_token(&self)
{
	return self.tokens.get_slice()[self.current];
}

fn void? Parser.advance(&self)
{
	if (self.current >= self.tokens.len - 1) return TOKEN_OUT_OF_BOUNDS?;
	self.current++;
}

fn Token? Parser.peek(&self)
{
	if (self.current + 1 >= self.tokens.len - 1) return TOKEN_OUT_OF_BOUNDS_PEEK?;
	return self.tokens.get_slice()[self.current+1];
}


fn ASTNode*? Parser.parse_primary(&self)
{
	Token token = self.get_current_token();

	if (token.type == INTEGER)
	{
		self.advance()!!;
		int128 value = token.value.to_int128()!!;
		return node_init_integer(value);
	}
	else if (token.type == FLOATING)
	{
		self.advance()!!;
		self.floating = true;
		double value = token.value.to_double()!!;
		return node_init_double(value);
	}
	else if (token.type == OPEN_PAREN)
	{
		self.advance()!!;
		ASTNode* expression = self.parse_AS()!; //solve inner expression by starting recursion over
		if (self.get_current_token().type != CLOSE_PAREN && self.get_current_token().type != COMMA)
		{
			return NONPAIRED_PAREN?;	
		}
	
		if (self.get_current_token().type != COMMA) //only advance if not a comma. Function code will advance
		{
			self.advance()!!;
		}
		return expression;
	}
	else if (token.type == OPERATOR && token.value == "-" && self.peek()!.value == "(") //negation
	{
		self.advance()!!;
		ASTNode* rhs = self.parse_primary()!;
		return node_init_unop(OP_NEGATE,rhs);
	}
	else if (token.type == FUNCTION)
	{
		self.advance()!!;
		ASTNode* func_node = node_init_function(token.value);
		ASTNode* arg = self.parse_primary()!;
		while (self.get_current_token().type == COMMA)
		{
			self.advance()!!;
			func_node.function.args.push(arg);
			arg = self.parse()!; //call back to begining to parse more args
		}
		/*if(self.get_current_token().type == CLOSE_PAREN)
		{
			self.advance()!!;
		}*/
		func_node.function.args.push(arg);
		return func_node;
	}
	
	return UNEXPECTED_TOKEN?;
}

fn ASTNode*? Parser.parse_Ex(&self)
{
	ASTNode* lhs = self.parse_primary()!;

	Token token = self.get_current_token();
	while (token.type == OPERATOR && (token.value == "^"))
	{
		self.advance()!!;
		ASTNode* rhs = self.parse_Ex()!;
		lhs = node_init_binop(OP_POW, lhs, rhs);
		token = self.get_current_token();
	}

	return lhs;
}

fn ASTNode*? Parser.parse_MD(&self)
{
	ASTNode* lhs = self.parse_Ex()!;

	Token token = self.get_current_token();
	while (token.type == OPERATOR && (token.value == "*" || token.value == "/" || token.value == "%"))
	{
		self.advance()!!;
		ASTNode* rhs = self.parse_Ex()!;
		OperatorType type = token.value == "*" ? OP_MULT : OP_DIVIDE;
		if (token.value == "%") type = OP_MOD;
		lhs = node_init_binop(type, lhs, rhs);
		token = self.get_current_token();
	}

	return lhs;
}

fn ASTNode*? Parser.parse_AS(&self)
{
	ASTNode* lhs = self.parse_MD()!;

	Token token = self.get_current_token();
	while (token.type == OPERATOR && (token.value == "+" || token.value == "-"))
	{
		self.advance()!!;
		ASTNode* rhs = self.parse_MD()!;
		OperatorType type = token.value == "+" ? OP_ADD : OP_SUB;
		lhs = node_init_binop(type,lhs,rhs);
		token = self.get_current_token();
	}

	return lhs;
}

fn ASTNode*? Parser.parse(&self)
{
	ASTNode* result = self.parse_AS()!; //start the chain
	return result;
}

fn int128 i128pow(int128 base, int128 exp)
{
	int128 result = 1;
	if (exp < 0) {
		base = 1 / base;
		exp = -exp;
	}

	for (int i = 0; i < exp; i++) result = result * base;

	return result;
}

fn double fpow(double base, double exp)
{
	double result = 1;
	if (exp < 0) {
		base = 1 / base;
		exp = -exp;
	}

	for (int i = 0; i < exp; i++) result = result * base;

	return result;
}

fn void ASTNode.print(&self)
{
	if (self.type == NODE_INTEGER)
	{
		io::printf("%d	",self.value);
	}
	else if (self.type == NODE_FLOATING)
	{
		io::printf("%f	",self.fvalue);
	}
	else if (self.type == NODE_BINOP) {
		switch (self.binop.type)
		{
			case OP_ADD: io::printf("+");
			case OP_SUB: io::printf("-");
			case OP_DIVIDE: io::printf("/");
			case OP_MULT: io::printf("*");
			case OP_MOD: io::printf("%%");
			case OP_POW: io::printf("^");
			default: return;
		}
		io::printf("\n");
		self.binop.lhs.print();
		self.binop.rhs.print();
	}
	else if (self.type == NODE_UNOP) {
		switch (self.unop.type)
		{
			case OP_NEGATE: io::printf("-");
			default: return;
		}
		io::printf("\n");
		self.unop.rhs.print();
	}
	else if (self.type == NODE_FUNCTION)
	{
		io::printf("%s",self.function.symbol);
		io::printf("\n");
		if (self.function.args.len() > 0) //if we have args, evaluate them
		{
			foreach (ASTNode* arg: self.function.args)
			{
				arg.print();
			}

		}
	}
}

fn int128? ASTNode.evaluate(&self)
{
	if (self.type == NODE_INTEGER) {
		return self.value;
	} 

	/*this below code is only for checking that the evaluation would be floating
	if you return this evaluation after the floating point cast
	then the answer will be wrong.

	To protect against this, a wrapper has been created inside evalulator.c3	
	check the is_floating boolean in the Result struct inside the wrapper to show the correct result
	*/
	else if (self.type == NODE_FLOATING) {
		return (int128)self.fvalue;
	}


	else if (self.type == NODE_BINOP) {
		int128 lhs = self.binop.lhs.evaluate()!!;
		int128 rhs = self.binop.rhs.evaluate()!!;
		switch (self.binop.type)
		{
			case OP_ADD: return lhs + rhs;
			case OP_SUB: return lhs - rhs;
			case OP_DIVIDE: return lhs / rhs;
			case OP_MULT: return lhs * rhs;
			case OP_MOD: return lhs % rhs;
			case OP_POW: return i128pow(lhs,rhs);
			default: return UNEXPECTED_TOKEN?;
		}
	}
	else if (self.type == NODE_UNOP) {
		int128 rhs = self.unop.rhs.evaluate()!!;
		switch (self.unop.type)
		{
			case OP_NEGATE: return -1 * rhs;
			default: return UNEXPECTED_TOKEN?;
		}
	}

	else if (self.type == NODE_FUNCTION)
	{
		List{int128} args_evaluated;
		args_evaluated.init(mem);
		defer(args_evaluated.free());
		if (self.function.args.len() > 0) //if we have args, evaluate them
		{
			foreach (ASTNode* arg: self.function.args)
			{
				args_evaluated.push(arg.evaluate()!!);
			}

		}

		return calc_functions::call_function{int128}(self.function.symbol, ...args_evaluated.array_view());
	}

	return EVALUATE_UNREACHABLE?;
}

fn double? ASTNode.evaluatef(&self)
{
	if (self.type == NODE_INTEGER) {
		return (double)self.value;
	} 
	else if (self.type == NODE_FLOATING) {
		return self.fvalue;
	}


	else if (self.type == NODE_BINOP) {
		double lhs = self.binop.lhs.evaluatef()!!;
		double rhs = self.binop.rhs.evaluatef()!!;
		switch (self.binop.type)
		{
			case OP_ADD: return lhs + rhs;
			case OP_SUB: return lhs - rhs;
			case OP_DIVIDE: return lhs / rhs;
			case OP_MULT: return lhs * rhs;
			case OP_MOD: return lhs % rhs;
			case OP_POW: return fpow(lhs,rhs);
			default: return UNEXPECTED_TOKEN?;
		}
	}
	else if (self.type == NODE_UNOP) {
		double rhs = self.unop.rhs.evaluatef()!!;
		switch (self.unop.type)
		{
			case OP_NEGATE: return -1 * rhs;
			default: return UNEXPECTED_TOKEN?;
		}
	}
	else if (self.type == NODE_FUNCTION)
	{
		//get the function table
		List{double} args_evaluated;
		args_evaluated.init(mem);
		defer(args_evaluated.free());
		if (self.function.args.len() > 0) //if we have args, evaluate them
		{
			foreach (ASTNode* arg: self.function.args)
			{
				args_evaluated.push(arg.evaluatef()!!);
			}

		}

		return calc_functions::call_function{double}(self.function.symbol, ...args_evaluated.array_view());

	}

	return EVALUATE_UNREACHABLE?;
}
