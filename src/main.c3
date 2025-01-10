module c3calc;

import std::io;
import c3eval;

fn int main()
{
	//String test_input = "(-(((2+2)/8)^8)+(((2+2)/8)^8) + (8*8+5)) % (18*2 + (12*3-1))";
	String test_input = "atan(cos(sin(3.14/2)+7)+5) + (8*8+5)) % (18*2 + (12*3-1))";
	//String test_input = "deg_to_rad(180)";
	Result result = c3eval::evaluate(test_input, debug: false);
	if (result.is_floating)
	{
		io::printfn("%s = %f", test_input, result.fvalue);
	}
	else
	{
		io::printfn("%s = %d", test_input, result.value);
	}
	return 0;
}
