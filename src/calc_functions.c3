module calc_functions(<Type>);

import std::math;

fault FunctionFault {
	INVALID_FUNCTION_SYMBOL,
	INCORRECT_ARG_COUNT,
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

fn bool! is_function_floating(String symbol, Type... args)
{
	switch(symbol)
	{
		case "sqrt":
		{
			if (args.len != 1) return FunctionFault.INCORRECT_ARG_COUNT?;
			Type result = sqrt(args[0]);
			if (result * result != args[0]) return true;
		}
		case "abs":
		{
			return false;
		}
		case "log":
		{
			if (args.len != 2) return FunctionFault.INCORRECT_ARG_COUNT?;
			Type result = log(args[0],args[1]);
			if (i128pow((int128)args[1],(int128)result) != args[0]) return true;
		}
		case "sin":
		{
			return true; //technically if x == PI or x == PI/2 it can be an int but EH
		}
		default:
			return false;
	}
	return false;
}

fn Type! call_function(String symbol, Type... args)
{
	switch(symbol)
	{
		case "sqrt": 
		{
			if (args.len != 1) return FunctionFault.INCORRECT_ARG_COUNT?;
			return sqrt(args[0]);
		}
		case "abs":
		{
			if (args.len != 1) return FunctionFault.INCORRECT_ARG_COUNT?;
			return abs(args[0]);
		}
		case "log":
		{
			if (args.len != 2) return FunctionFault.INCORRECT_ARG_COUNT?;
			return log(args[0],args[1]);
		}
		case "sin":
			if (args.len != 1) return FunctionFault.INCORRECT_ARG_COUNT?;
			return sin(args[0]);
	}

	return FunctionFault.INVALID_FUNCTION_SYMBOL?;
}

fn Type sqrt(Type x)
{
	return (Type)math::sqrt(x);
}

fn Type abs(Type x)
{
	return (Type)math::abs(x);
}

fn Type log(Type x, Type base)
{
	return (Type)math::log(x,base);
}

fn Type sin(Type x)
{
	return (Type)math::sin(x);
}
