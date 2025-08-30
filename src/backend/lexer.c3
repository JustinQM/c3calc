module lexer;

import std::io;
import std::collections::list;

const char[*] VALID_OPERATORS = {'+','-','*','/','%','^'};
const int MAXIMUM_TOKENS = 2056;

enum TokenType {
	INTEGER,
	FLOATING,
	OPERATOR,
	FUNCTION,
	COMMA,
	OPEN_PAREN,
	CLOSE_PAREN,
	END,
	UNKNOWN,
}

faultdef MAXIMUM_TOKENS_REACHED;
faultdef INVALID_NUMBER_PARSED;
faultdef INVALID_STRING_PARSED;

struct Token {
	TokenType type;
	String value;
}

struct Tokens {
	Token[MAXIMUM_TOKENS] tokens;
	int len;
}

fn void? Tokens.push(&self, Token token)
{
	if (self.len - 1 >= MAXIMUM_TOKENS) return MAXIMUM_TOKENS_REACHED?;
	self.tokens[self.len] = token;
	self.len++;
}

fn Token[] Tokens.get_slice(&self)
{
	return self.tokens[..self.len-1];
}

fn String char_to_string(char c)
{
	DString ret;
	defer(ret.free());
	ret.append(c);
	return ret.copy_str(mem);
}

fn bool contains_char(char c, char[] array)
{
	foreach (char test: array)
	{
		if(c == test) return true;
	}

	return false;
}

fn Token? tokenize_string(String input, int* i)
{
	Token token = {};
	DString string;
	defer (string.free());

	token.type = FUNCTION;

	if (!input[*i].is_alpha() && !(input[*i] == '_')) return INVALID_STRING_PARSED?;

	while (*i < input.len && (input[*i].is_alpha() || input[*i] == '_'))
	{
		string.append(input[*i]);
		*i = *i + 1;
	}
	*i = *i - 1; //rewind one due to over read in while loop
	token.value = string.copy_str(mem); //TODO: leaks currently
	return token;
}

fn Token? tokenize_number(String input, int* i)
{
	Token token = {};
	DString number;
	defer (number.free());

	if (input[*i] == '-')
	{
		number.append('-');
		*i = *i + 1;
	}

	token.type = INTEGER;

	if (!input[*i].is_digit()) return INVALID_NUMBER_PARSED?;

	while (*i < input.len && (input[*i].is_digit() || input[*i] == '.'))
	{
		if (input[*i] == '.' && !contains_char('.',number.tcopy_str()))
		{
			token.type = FLOATING;
		}
		number.append(input[*i]);
		*i = *i + 1;
	}
	token.value = number.copy_str(mem); //TODO: leaks currently
	return token;
}

fn Tokens lexer(String input)
{
	//remove whitespace
	if (input.contains(" "))
	{
		DString new;
		defer new.free();
		foreach (char c : input)
		{
			if (c != ' ')
			{
				new.append(c);
			}
		}
		input = new.copy_str(mem);
	}

	Tokens tokens = {.len = 0};

	int i = 0;
	while (i < input.len)
	{
		Token token = {};
		if(input[i].is_digit())
		{
			token = tokenize_number(input ,&i)!!;
			tokens.push(token)!!;
			continue;
		}
		else if (contains_char(input[i],&VALID_OPERATORS))
		{
			if (input[i] == '-') //negative number check && negation check
			{
				//negation
				if (i + 1 < input.len && input[i+1] == '(')
				{
					token.type = OPERATOR;
					token.value = char_to_string(input[i]);
					tokens.push(token)!!;
					i++;
					continue;
				}
				//negative number
				else if (i == 0 || (!input[i-1].is_digit() && input[i-1] != ')') )
				{
					//consume - and create number
					token = tokenize_number(input,&i)!!;
					tokens.push(token)!!;
					continue;
				}
			}

			//subtraction
			token.type = OPERATOR;
			token.value = char_to_string(input[i]);
			tokens.push(token)!!;
		}
		else if (input[i] == '(')
		{
			token.type = OPEN_PAREN;
			token.value = char_to_string(input[i]);
			tokens.push(token)!!;
		}
		else if (input[i] == ')')
		{
			token.type = CLOSE_PAREN;
			token.value = char_to_string(input[i]);
			tokens.push(token)!!;
		}
		else if (input[i].is_alpha())
		{
			token = tokenize_string(input,&i)!!;
			tokens.push(token)!!;
		}
		else if (input[i] == ',')
		{
			token.type = COMMA;
			token.value = char_to_string(input[i]);
			tokens.push(token)!!;
		}
		else
		{
			token.type = UNKNOWN;
			token.value = char_to_string(input[i]);
			tokens.push(token)!!;
		}
		i++;
	}

	tokens.push((Token){.type = END, .value = "END"})!!;

	return tokens;
}
