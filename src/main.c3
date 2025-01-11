module c3calc;

import std::io;

import c3eval;
import rl;

fn int main()
{
	rl::init_window(800,600,"c3calc");
	defer(rl::close_window());

	rl::set_target_fps(60);

	while(!rl::window_should_close())
	{
		int key = rl::get_key_pressed();
		if(key)
		{
			io::printfn("Got Key Pressed: %d",key); //enums in c3... KeyboardKey.KEY_ONE.keycode ... wtf?
		}

		rl::begin_drawing();
		rl::end_drawing();
	}

	/*
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
	*/
	return 0;
}
