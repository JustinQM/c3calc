module c3calc;

import std::io;

import c3eval;
import rl;

fn int main()
{
	const int WINDOW_WIDTH = 600;
	const int WINDOW_HEIGHT = 900;
	const int PADDING = WINDOW_WIDTH/10;

	rl::init_window(WINDOW_WIDTH,WINDOW_HEIGHT,"c3calc");
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
			Result ret_val = c3eval::evaluate(input.str_view(), debug: false);
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
		//Screen Math
		Vector2 screen_pos = Vector2{PADDING,PADDING};
		Vector2 screen_size = Vector2{WINDOW_WIDTH-PADDING*2,WINDOW_HEIGHT/2-PADDING};
		Color screen_color = Color{216,238,179,255};

		//Text
		Color text_color = Color{0,0,0,255};
		int text_size = 24;
		int text_screen_padding = 5;

		//DRAW LOOP
		rl::begin_drawing();
			rl::draw_fps(0,0);
			rl::clear_background(Color{0,0,0,255});

			rl::draw_rectange_v(screen_pos,screen_size,screen_color);

			rl::draw_text(input.zstr_view(), (CInt)screen_pos.x + text_screen_padding, (CInt)screen_pos.y,text_size,text_color);
			rl::draw_text(result.zstr_view(), (CInt)screen_pos.x + text_screen_padding, (CInt)screen_pos.y+text_size,text_size,text_color);
		rl::end_drawing();
	}

	/*
	//String test_input = "(-(((2+2)/8)^8)+(((2+2)/8)^8) + (8*8+5)) % (18*2 + (12*3-1))";
	String test_input = "atan(cos(sin(3.14/2)+7)+5) + (8*8+5)) % (18*2 + (12*3-1))";
	*/
	return 0;

}
