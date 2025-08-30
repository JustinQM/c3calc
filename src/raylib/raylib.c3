module rl;

//Basic
extern fn void init_window(CInt width, CInt height, char* title) @extern("InitWindow");
extern fn void close_window() @extern("CloseWindow");
extern fn bool window_should_close() @extern ("WindowShouldClose");


// Input-related functions: keyboard
extern fn bool is_key_pressed(CInt key) @extern("IsKeyPressed");             // Check if a key has been pressed once
extern fn bool is_key_pressed_repeat(CInt key) @extern("IsKeyPressedRepeat");        //. Check if a key has been pressed again
extern fn bool is_key_down(CInt key) @extern("IsKeyDown");		  //. Check if a key is being pressed
extern fn bool is_key_released(CInt key) @extern("IsKeyReleased"); //. Check if a key has been released once
extern fn bool is_key_up(CInt key) @extern("IsKeyUp");           //. Check if a key is NOT being pressed
extern fn CInt get_key_pressed() @extern("GetKeyPressed");      //. Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty
extern fn CInt get_char_pressed() @extern("GetCharPressed");     //. Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty
extern fn void set_exit_key(CInt key) @extern("SetExitKey");     //. Set a custom key to exit program (default is ESC)

// Timing-related functions
extern fn void set_target_fps(CInt fps) @extern("SetTargetFPS");                                 // Set target FPS (maximum)
extern fn float get_frame_time() @extern("GetFrameTime");                                   // Get time in seconds for last frame drawn (delta time)
extern fn double get_time() @extern("GetTime");                                       // Get elapsed time in seconds since InitWindow()
extern fn CInt get_fps() @extern("GetFPS");                                           // Get current FPS

// Drawing-related functions
extern fn void clear_background(Color color) @extern("ClearBackground");                          // Set background color (framebuffer clear color)
extern fn void begin_drawing() @extern("BeginDrawing");                                    // Setup canvas (framebuffer) to start drawing
extern fn void end_drawing() @extern("EndDrawing");                                      // End canvas drawing and swap buffers (double buffering)
extern fn void begin_mode_2D(Camera2D camera) @extern("BeginMode2D");                          // Begin 2D mode with custom camera (2D)
extern fn void end_mode_2D() @extern("EndMode2D");                                       // Ends 2D mode with custom camera
extern fn void begin_mode_3D(Camera3D camera) @extern("BeginMode3D");                          // Begin 3D mode with custom camera (3D)
extern fn void end_mode_3D() @extern("EndMode3D");                                       // Ends 3D mode and returns to default 2D orthographic mode
extern fn void begin_texture_mode(RenderTexture2D target) @extern("BeginTextureMode");              // Begin drawing to render texture
extern fn void end_texture_mode() @extern("EndTextureMode");                                  // Ends drawing to render texture
extern fn void begin_shader_mode(Shader shader) @extern("BeginShaderMode");                        // Begin custom shader drawing
extern fn void end_shader_mode() @extern("EndShaderMode");                                   // End custom shader drawing (use default shader)
extern fn void begin_blend_mode(CInt mode) @extern("BeginBlendMode");                              // Begin blending mode (alpha, additive, multiplied, subtract, custom)
extern fn void end_blend_mode() @extern("EndBlendMode");                                    // End blending mode (reset to default: alpha blending)
extern fn void begin_scissor_mode(CInt x, CInt y, CInt width, CInt height) @extern("BeginScissorMode"); // Begin scissor mode (define screen area for following drawing)
extern fn void end_scissor_mode() @extern("EndScissorMode");                                  // End scissor mode
//extern fn void begin_vr_stereo_mode(VrStereoConfig config) @extern("BeginVrStereoMode");              // Begin stereo rendering (requires VR simulator)
//extern fn void end_vr_stereo_mode() @extern("EndVrStereoMode");                                 // End stereo rendering (requires VR simulator)

// Font loading/unloading functions
extern fn Font get_font_default() @extern("GetFontDefault");                                                            // Get the default Font
extern fn Font load_font(char *fileName) @extern("LoadFont");                                                  // Load font from file into GPU memory 
extern fn Font load_font_ex(char *fileName, CInt fontSize, CInt *codepoints, CInt codepointCount) @extern("LoadFontEx"); // Load font from file with extended parameters, use NULL for codepoints and 0 for codepointCount to load the default character set, font size is provided in pixels height
extern fn Font load_font_from_image(Image image, Color key, CInt firstChar) @extern("LoadFontFromImage");                        // Load font from Image (XNA style)
extern fn Font load_font_from_memory(char *fileType, char *fileData, CInt dataSize, CInt fontSize, CInt *codepoints, CInt codepointCount) @extern("LoadFontFromMemory"); // Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
extern fn bool is_font_valid(Font font) @extern("IsFontValid");                                                          // Check if a font is valid (font data loaded, WARNING: GPU texture not checked)
extern fn GlyphInfo *load_font_data(char *fileData, CInt dataSize, CInt fontSize, CInt *codepoints, CInt codepointCount, CInt type) @extern("LoadFontData"); // Load font data for further use
extern fn Image gen_image_font_atlas(GlyphInfo *glyphs, Rectangle **glyphRecs, CInt glyphCount, CInt fontSize, CInt padding, CInt packMethod) @extern("GenImageFontAtlas"); // Generate image font atlas using chars info
extern fn void unload_font_data(GlyphInfo *glyphs, CInt glyphCount) @extern("UnloadFontData");                               // Unload font chars info data (RAM)
extern fn void unload_font(Font font) @extern("UnloadFont");                                                           // Unload font from GPU memory (VRAM)
extern fn bool export_font_as_code(Font font, char *fileName) @extern("ExportFontAsCode");                               // Export font as code file, returns true on success

// Text drawing functions
extern fn void draw_fps(CInt posX, CInt posY) @extern("DrawFPS");                                                     // Draw current FPS
extern fn void draw_text(char *text, CInt posX, CInt posY, CInt fontSize, Color color) @extern("DrawText");       // Draw text (using default font)
extern fn void draw_text_ex(Font font,  char *text, Vector2 position, float fontSize, float spacing, Color tint) @extern("DrawTextEx"); // Draw text using font and additional parameters
extern fn void draw_text_pro(Font font,  char *text, Vector2 position, Vector2 origin, float rotation, float fontSize, float spacing, Color tint) @extern("DrawTextPro"); // Draw text using Font and pro parameters (rotation)
extern fn void draw_text_codepoint(Font font, CInt codepoint, Vector2 position, float fontSize, Color tint) @extern("DrawTextCodepoint"); // Draw one character (codepoint)
extern fn void draw_text_codepoints(Font font,  CInt *codepoints, CInt codepointCount, Vector2 position, float fontSize, float spacing, Color tint) @extern("DrawTextCodepoints"); // Draw multiple character (codepoint)
extern fn CInt measure_text(char *text, CInt fontSize) @extern("MeasureText");                                      // Measure string width for default font
extern fn Vector2 measure_text_ex(Font font, char *text, float fontSize, float spacing) @extern("MeasureTextEx");    // Measure string size for Font

//Drawing
extern fn void draw_rectange(CInt posX, CInt posY, CInt width, CInt height, Color color) @extern("DrawRectangle");                        // Draw a color-filled rectangle
extern fn void draw_rectange_v(Vector2 position, Vector2 size, Color color) @extern("DrawRectangleV");                                  // Draw a color-filled rectangle (Vector version)
extern fn void draw_rectange_rec(Rectangle rec, Color color) @extern("DrawRectangleRec");                                                 // Draw a color-filled rectangle
extern fn void draw_rectange_pro(Rectangle rec, Vector2 origin, float rotation, Color color) @extern("DrawRectanglePro");                 // Draw a color-filled rectangle with pro parameters

struct Camera2D {
    Vector2 offset;         // Camera offset (displacement from target)
    Vector2 target;         // Camera target (rotation and zoom origin)
    float rotation;         // Camera rotation in degrees
    float zoom;             // Camera zoom (scaling), should be 1.0f by default
}

struct Camera3D {
    Vector3 position;       // Camera position
    Vector3 target;         // Camera target it looks-at
    Vector3 up;             // Camera up vector (rotation over its axis)
    float fovy;             // Camera field-of-view aperture in Y (degrees) in perspective, used as near plane width in orthographic
    int projection;         // Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
}

struct Shader {
    uint id;        // Shader program id
    int *locs;              // Shader locations array (RL_MAX_SHADER_LOCATIONS)
}

struct RenderTexture {
    uint id;        // OpenGL framebuffer object id
    Texture texture;        // Color buffer attachment texture
    Texture depth;          // Depth buffer attachment texture
}

// RenderTexture2D, same as RenderTexture
alias RenderTexture2D = RenderTexture;

struct Color {
    char r;        // Color red value
    char g;        // Color green value
    char b;        // Color blue value
    char a;        // Color alpha value
} 

struct Texture {
    uint id;        // OpenGL texture id
    int width;              // Texture base width
    int height;             // Texture base height
    int mipmaps;            // Mipmap levels, 1 by default
    int format;             // Data format (PixelFormat type)
}

// Texture2D, same as Texture
alias Texture2D = Texture;

// Font, font texture and GlyphInfo array data
struct Font {
    int baseSize;           // Base size (default chars height)
    int glyphCount;         // Number of glyph characters
    int glyphPadding;       // Padding around the glyph characters
    Texture2D texture;      // Texture atlas containing the glyphs
    Rectangle *recs;        // Rectangles in texture for the glyphs
    GlyphInfo *glyphs;      // Glyphs info data
}

// Rectangle, 4 components
struct Rectangle {
    float x;                // Rectangle top-left corner position x
    float y;                // Rectangle top-left corner position y
    float width;            // Rectangle width
    float height;           // Rectangle height
}

// GlyphInfo, font characters glyphs info
struct GlyphInfo {
    int value;              // Character value (Unicode)
    int offsetX;            // Character offset X when drawing
    int offsetY;            // Character offset Y when drawing
    int advanceX;           // Character advance position X
    Image image;            // Character image data
}

// Image, pixel data stored in CPU memory (RAM)
struct Image {
    void *data;             // Image raw data
    int width;              // Image base width
    int height;             // Image base height
    int mipmaps;            // Mipmap levels, 1 by default
    int format;             // Data format (PixelFormat type)
}

struct Vector2 {
    float x;                // Vector x component
    float y;                // Vector y component
}

// Vector3, 3 components
struct Vector3 {
    float x;                // Vector x component
    float y;                // Vector y component
    float z;                // Vector z component
}

// Vector4, 4 components
struct Vector4 {
    float x;                // Vector x component
    float y;                // Vector y component
    float z;                // Vector z component
    float w;                // Vector w component
}

// Quaternion, 4 components (Vector4 alias)
alias Quaternion = Vector4;

// Keyboard keys (US keyboard layout)
// NOTE: Use GetKeyPressed() to allow redefining
// required keys for alternative layouts
enum KeyboardKey : CInt(CInt keycode) {
    KEY_NULL            = 0,        // Key: NULL, used for no key pressed
    // Alphanumeric keys
    KEY_APOSTROPHE      = 39,       // Key: '
    KEY_COMMA           = 44,       // Key: ,
    KEY_MINUS           = 45,       // Key: -
    KEY_PERIOD          = 46,       // Key: .
    KEY_SLASH           = 47,       // Key: /
    KEY_ZERO            = 48,       // Key: 0
    KEY_ONE             = 49,       // Key: 1
    KEY_TWO             = 50,       // Key: 2
    KEY_THREE           = 51,       // Key: 3
    KEY_FOUR            = 52,       // Key: 4
    KEY_FIVE            = 53,       // Key: 5
    KEY_SIX             = 54,       // Key: 6
    KEY_SEVEN           = 55,       // Key: 7
    KEY_EIGHT           = 56,       // Key: 8
    KEY_NINE            = 57,       // Key: 9
    KEY_SEMICOLON       = 59,       // Key: ;
    KEY_EQUAL           = 61,       // Key: =
    KEY_A               = 65,       // Key: A | a
    KEY_B               = 66,       // Key: B | b
    KEY_C               = 67,       // Key: C | c
    KEY_D               = 68,       // Key: D | d
    KEY_E               = 69,       // Key: E | e
    KEY_F               = 70,       // Key: F | f
    KEY_G               = 71,       // Key: G | g
    KEY_H               = 72,       // Key: H | h
    KEY_I               = 73,       // Key: I | i
    KEY_J               = 74,       // Key: J | j
    KEY_K               = 75,       // Key: K | k
    KEY_L               = 76,       // Key: L | l
    KEY_M               = 77,       // Key: M | m
    KEY_N               = 78,       // Key: N | n
    KEY_O               = 79,       // Key: O | o
    KEY_P               = 80,       // Key: P | p
    KEY_Q               = 81,       // Key: Q | q
    KEY_R               = 82,       // Key: R | r
    KEY_S               = 83,       // Key: S | s
    KEY_T               = 84,       // Key: T | t
    KEY_U               = 85,       // Key: U | u
    KEY_V               = 86,       // Key: V | v
    KEY_W               = 87,       // Key: W | w
    KEY_X               = 88,       // Key: X | x
    KEY_Y               = 89,       // Key: Y | y
    KEY_Z               = 90,       // Key: Z | z
    KEY_LEFT_BRACKET    = 91,       // Key: [
    KEY_BACKSLASH       = 92,       // Key: '\'
    KEY_RIGHT_BRACKET   = 93,       // Key: ]
    KEY_GRAVE           = 96,       // Key: `
    // Function keys
    KEY_SPACE           = 32,       // Key: Space
    KEY_ESCAPE          = 256,      // Key: Esc
    KEY_ENTER           = 257,      // Key: Enter
    KEY_TAB             = 258,      // Key: Tab
    KEY_BACKSPACE       = 259,      // Key: Backspace
    KEY_INSERT          = 260,      // Key: Ins
    KEY_DELETE          = 261,      // Key: Del
    KEY_RIGHT           = 262,      // Key: Cursor right
    KEY_LEFT            = 263,      // Key: Cursor left
    KEY_DOWN            = 264,      // Key: Cursor down
    KEY_UP              = 265,      // Key: Cursor up
    KEY_PAGE_UP         = 266,      // Key: Page up
    KEY_PAGE_DOWN       = 267,      // Key: Page down
    KEY_HOME            = 268,      // Key: Home
    KEY_END             = 269,      // Key: End
    KEY_CAPS_LOCK       = 280,      // Key: Caps lock
    KEY_SCROLL_LOCK     = 281,      // Key: Scroll down
    KEY_NUM_LOCK        = 282,      // Key: Num lock
    KEY_PRINT_SCREEN    = 283,      // Key: Print screen
    KEY_PAUSE           = 284,      // Key: Pause
    KEY_F1              = 290,      // Key: F1
    KEY_F2              = 291,      // Key: F2
    KEY_F3              = 292,      // Key: F3
    KEY_F4              = 293,      // Key: F4
    KEY_F5              = 294,      // Key: F5
    KEY_F6              = 295,      // Key: F6
    KEY_F7              = 296,      // Key: F7
    KEY_F8              = 297,      // Key: F8
    KEY_F9              = 298,      // Key: F9
    KEY_F10             = 299,      // Key: F10
    KEY_F11             = 300,      // Key: F11
    KEY_F12             = 301,      // Key: F12
    KEY_LEFT_SHIFT      = 340,      // Key: Shift left
    KEY_LEFT_CONTROL    = 341,      // Key: Control left
    KEY_LEFT_ALT        = 342,      // Key: Alt left
    KEY_LEFT_SUPER      = 343,      // Key: Super left
    KEY_RIGHT_SHIFT     = 344,      // Key: Shift right
    KEY_RIGHT_CONTROL   = 345,      // Key: Control right
    KEY_RIGHT_ALT       = 346,      // Key: Alt right
    KEY_RIGHT_SUPER     = 347,      // Key: Super right
    KEY_KB_MENU         = 348,      // Key: KB menu
    // Keypad keys
    KEY_KP_0            = 320,      // Key: Keypad 0
    KEY_KP_1            = 321,      // Key: Keypad 1
    KEY_KP_2            = 322,      // Key: Keypad 2
    KEY_KP_3            = 323,      // Key: Keypad 3
    KEY_KP_4            = 324,      // Key: Keypad 4
    KEY_KP_5            = 325,      // Key: Keypad 5
    KEY_KP_6            = 326,      // Key: Keypad 6
    KEY_KP_7            = 327,      // Key: Keypad 7
    KEY_KP_8            = 328,      // Key: Keypad 8
    KEY_KP_9            = 329,      // Key: Keypad 9
    KEY_KP_DECIMAL      = 330,      // Key: Keypad .
    KEY_KP_DIVIDE       = 331,      // Key: Keypad /
    KEY_KP_MULTIPLY     = 332,      // Key: Keypad *
    KEY_KP_SUBTRACT     = 333,      // Key: Keypad -
    KEY_KP_ADD          = 334,      // Key: Keypad +
    KEY_KP_ENTER        = 335,      // Key: Keypad Enter
    KEY_KP_EQUAL        = 336,      // Key: Keypad =
    // Android key buttons
    KEY_BACK            = 4,        // Key: Android back button
    KEY_MENU            = 5,        // Key: Android menu button
    KEY_VOLUME_UP       = 24,       // Key: Android volume up button
    KEY_VOLUME_DOWN     = 25        // Key: Android volume down button
}
