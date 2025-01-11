module c3calc;

import std::io;

import c3eval;
import rl;

fn int main()
{
	rl::init_window(800,600,"c3calc");
	defer(rl::close_window());

	rl::set_target_fps(60);

	DString input;
	DString result;
	defer(input.free());
	defer(result.free());
	while(!rl::window_should_close())
	{
		int key = rl::get_char_pressed();
		while(key > 0)
		{
			input.append_char((char)key);
			key = rl::get_char_pressed();
		}
		if(rl::is_key_pressed(KeyboardKey.KEY_BACKSPACE.keycode) && input.len() >= 1)
		{
			input.delete(input.len()-1);
		}
		if(rl::is_key_pressed(KeyboardKey.KEY_ENTER.keycode))
		{
			result.clear();
			Result ret_val = c3eval::evaluate(input.str_view());
			if(ret_val.is_floating)
			{
				result.appendf("%f",ret_val.fvalue);
				io::printfn("%f",ret_val.fvalue);
			}
			else
			{
				result.appendf("%d",ret_val.value);
				io::printfn("%d",ret_val.value);
			}
		}

		rl::begin_drawing();
			rl::clear_background(Color{0,0,0,255});
			rl::draw_text(input.zstr_view(),200,200,18,Color{255,255,255,255});
			rl::draw_text(result.zstr_view(),200,400,18,Color{255,255,255,255});
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
