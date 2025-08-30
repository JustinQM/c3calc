module calc_functions {Type};

import std::math;
import calc_faults;

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

fn bool? is_function_floating(String symbol, Type... args)
{
	switch(symbol)
	{
		case "sqrt":
		{
			if (args.len != 1) return calc_faults::INCORRECT_ARG_COUNT?;
			Type result = sqrt(args[0]);
			if (result * result != args[0]) return true;
		}
		case "abs":
		{
			return false;
		}
		case "log":
		{
			if (args.len != 2) return calc_faults::INCORRECT_ARG_COUNT?;
			Type result = log(args[0],args[1]);
			if (i128pow((int128)args[1],(int128)result) != args[0]) return true;
		}
		case "sin":
		case "cos":
		case "tan":
		case "asin":
		case "acos":
		case "atan":
		case "deg_to_rad":
		{
			return true; //technically there is edge cases where these functions can be int 128... but i don't care
		}
		default:
			return false;
	}
	return false;
}

fn Type? call_function(String symbol, Type... args)
{
	switch(symbol)
	{
		case "sqrt": 
		{
			if (args.len != 1) return calc_faults::INCORRECT_ARG_COUNT?;
			return sqrt(args[0]);
		}
		case "abs":
		{
			if (args.len != 1) return calc_faults::INCORRECT_ARG_COUNT?;
			return abs(args[0]);
		}
		case "log":
		{
			if (args.len != 2) return calc_faults::INCORRECT_ARG_COUNT?;
			return log(args[0],args[1]);
		}
		case "sin":
		{
			if (args.len != 1) return calc_faults::INCORRECT_ARG_COUNT?;
			return sin(args[0]);
		}
		case "cos":
		{
			if (args.len != 1) return calc_faults::INCORRECT_ARG_COUNT?;
			return cos(args[0]);
		}
		case "tan":
		{
			if (args.len != 1) return calc_faults::INCORRECT_ARG_COUNT?;
			return tan(args[0]);
		}
		case "asin":
		{
			if (args.len != 1) return calc_faults::INCORRECT_ARG_COUNT?;
			return asin(args[0]);
		}
		case "acos":
		{
			if (args.len != 1) return calc_faults::INCORRECT_ARG_COUNT?;
			return acos(args[0]);
		}
		case "atan":
		{
			if (args.len != 1) return calc_faults::INCORRECT_ARG_COUNT?;
			return atan(args[0]);
		}
		case "deg_to_rad":
		{
			if (args.len != 1) return calc_faults::INCORRECT_ARG_COUNT?;
			return deg_to_rad(args[0]);
		}

	}

	return calc_faults::INVALID_FUNCTION_SYMBOL?;
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

fn Type cos(Type x)
{
	return (Type)math::cos((double)x); //why does this have to be casted?
}

fn Type tan(Type x)
{
	return (Type)math::tan(x);
}

fn Type asin(Type x)
{
	return (Type)math::asin(x);
}

fn Type acos(Type x)
{
	return (Type)math::acos(x);
}

fn Type atan(Type x)
{
	return (Type)math::atan(x);
}

fn Type deg_to_rad(Type x)
{
	return (Type)math::deg_to_rad(x);
}
