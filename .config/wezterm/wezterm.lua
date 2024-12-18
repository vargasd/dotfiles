local wezterm = require("wezterm")

---@type WeztermConfig
local config = wezterm.config_builder()

config.tab_bar_at_bottom = true
config.audible_bell = "Disabled"
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_max_width = 1000
config.show_tabs_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.window_decorations = "RESIZE"
config.font = wezterm.font("JetBrains Mono NL", { weight = "Bold" })
config.font_size = 15
config.use_resize_increments = false
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

config.color_scheme = "Atlas (base16)"
-- config.color_scheme = "GruvboxDark"
config.color_scheme = "Popping and Locking"
-- config.color_scheme = "atlas-mod"
config.bold_brightens_ansi_colors = false
config.quick_select_alphabet = "arstqwfpzxcvneioluymdhgjbk"

config.keys = {
	{
		mods = "ALT",
		key = "Enter",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{
		mods = "CMD",
		key = "m",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{
		mods = "CMD",
		key = "h",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{
		key = "o",
		mods = "CTRL|SHIFT",
		action = wezterm.action.QuickSelectArgs({
			patterns = { "https?://[^\\s]+" },
			action = wezterm.action_callback(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				wezterm.open_with(url)
			end),
		}),
	},
	{
		key = "o",
		mods = "CMD",
		action = wezterm.action.QuickSelectArgs({
			patterns = { "https?://[^\\s]+" },
			action = wezterm.action_callback(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				wezterm.open_with(url)
			end),
		}),
	},
}

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab_title(tab)

	return {
		{ Background = { AnsiColor = tab.is_active and "Yellow" or "Gray" } },
		{ Foreground = { AnsiColor = "Black" } },
		{
			Text = " " .. title .. " ",
		},
		{ Background = { AnsiColor = "Green" } },
	}
end)

return config

---@meta
---@class WeztermPlugin
---@field require fun(url: string): any

---@alias FontStretch
---| "UltraCondensed"
---| "ExtraCondensed"
---| "Condensed"
---| "SemiCondensed"
---| "Normal"
---| "SemiExpanded"
---| "Expanded"
---| "ExtraExpanded"
---| "UltraExpanded"
---@alias FontWeight
---| "Thin"
---| "ExtraLight"
---| "Light"
---| "DemiLight"
---| "Book"
---| "Regular"
---| "Medium"
---| "DemiBold"
---| "Bold"
---| "ExtraBold"
---| "Black"
---| "ExtraBlack"
---@alias FreeTypeRenderTarget "Normal" | "HorizontalLcd"
---@alias FreeTypeLoadTarget "Normal" | "Light" | "Mono" | "HorizontalLcd"
---@alias FontAttributes { family: string, harfbuzz_features: string[], stretch: FontStretch, weight: FontWeight, freetype_load_flags: string, freetype_load_target: FreeTypeLoadTarget, freetype_render_target: FreeTypeRenderTarget, assume_emoji_presentation: boolean }

---@class HyperLinkRules
---@field regex string The regular expression to match
---@field format string Controls which parts of the regex match will be used to form the link. Must have a prefix: signaling the protocol type (e.g., https:/mailto:), which can either come from the regex match or needs to be explicitly added. The format string can use placeholders like $0, $1, $2 etc. that will be replaced with that numbered capture group. So, $0 will take the entire region of text matched by the whole regex, while $1 matches out the first capture group. In the example below, mailto:$0 is used to prefix a protocol to the text to make it into an URL.
---@field highlight number? Specifies the range of the matched text that should be highlighted/underlined when the mouse hovers over the link. The value is a number that corresponds to a capture group in the regex. The default is 0, highlighting the entire region of text matched by the regex. 1 would be the first capture group, and so on.

---@class FontObj
---@field family string
---@field is_fallback boolean
---@field is_synthetic boolean
---@field stretch FontStretch
---@field style "Normal" | "Italic" | "Oblique"
---@field weight FontWeight
---@alias Fonts {fonts: FontObj[]}

---@class SSHDomainObj
---@field name string The name of this specific domain.  Must be unique amongst all types of domain in the configuration file.
---@field remote_address string Identifies the host:port pair of the remote server. Can be a DNS name or an IP address with an optional ":port" on the end.
---@field no_agent_auth boolean Whether agent auth should be disabled. Set to true to disable it.
---@field username string The username to use for authenticating with the remote host.
---@field connect_automatically boolean If true, connect to this domain automatically at startup
---@field timeout number Specify an alternative read timeout
---@field remote_wezterm_path string The path to the wezterm binary on the remote host. Primarily useful if it isn't installed in the $PATH that is configure for ssh.

---@class wezterm
---@field GLOBAL any
---@field action KeyAssignment
---@field action_callback any
---@field add_to_config_reload_watch_list fun(path: string): nil Adds path to the list of files that are watched for config changes. If `automatically_reload_config` is enabled, then the config will be reloaded when any of the files that have been added to the watch list have changed.
---@field background_child_process fun(args: string[]): nil Accepts an argument list; it will attempt to spawn that command in the background.
---@field battery_info fun(): BatteryInfo[] Returns battery information for each of the installed batteries on the system. This is useful for example to assemble status information for the status bar.
---@field column_width fun(string): number Given a string parameter, returns the number of columns that that text occupies in the terminal, which is useful together with format-tab-title and update-right-status to compute/layout tabs and status information.
---@field config_builder fun(): WeztermConfig Returns a config builder object that can be used to define your configuration.
---@field config_dir string This constant is set to the path to the directory in which your wezterm.lua configuration file was found.
---@field config_file string This constant is set to the path to the wezterm.lua that is in use.
---@field color WezTermColor The `wezterm.color` module exposes functions that work with colors.
---@field default_hyperlink_rules fun(): HyperLinkRules[] Returns the compiled-in default values for hyperlink_rules.
---@field default_ssh_domains fun(): SSHDomainObj[] Computes a list of SshDomain objects based on the set of hosts discovered in your ~/.ssh/config. Each host will have both a plain SSH and a multiplexing SSH domain generated and returned in the list of domains. The former don't require wezterm to be installed on the remote host, while the latter do require it. The intended purpose of this function is to allow you the opportunity to edit/adjust the returned information before assigning it to your config.
---@field default_wsl_domains fun(): { name: string, distribution: string }[] Computes a list of WslDomain objects, each one representing an installed WSL distribution on your system. This list is the same as the default value for the wsl_domains configuration option, which is to make a WslDomain with the distribution field set to the name of WSL distro and the name field set to name of the distro but with "WSL:" prefixed to it.
---@field emit fun(event: string, ...)
---@field enumerate_ssh_hosts fun(ssh_config_file_name: string?): { [string] : { hostname: string, identityagent: string, identityfile: string, port: string, user: string, userknownhostsfile: string } } This function will parse your ssh configuration file(s) and extract from them the set of literal (non-pattern, non-negated) host names that are specified in Host and Match stanzas contained in those configuration files and return a mapping from the hostname to the effective ssh config options for that host.  You may optionally pass a list of ssh configuration files that should be read, in case you have a special configuration.
---@field executable_dir string This constant is set to the directory containing the wezterm executable file.
---@field font fun(font_attributes: FontAttributes): Fonts | fun(name: string, font_attributes: FontAttributes?): Fonts https://wezfurlong.org/wezterm/config/lua/wezterm/font.html
---@field font_with_fallback fun(fonts: string[] | FontAttributes[]): Fonts https://wezfurlong.org/wezterm/config/lua/wezterm/font_with_fallback.html
---@field format fun(...: FormatItem[]): string Can be used to produce a formatted string with terminal graphic attributes such as bold, italic and colors. The resultant string is rendered into a string with wezterm compatible escape sequences embedded.
---@field get_builtin_color_schemes any #TODO
---@field glob fun(pattern: string, relative_to: string?): string[] This function evalutes the glob pattern and returns an array containing the absolute file names of the matching results. Due to limitations in the lua bindings, all of the paths must be able to be represented as UTF-8 or this function will generate an error.
---@field gui WezTermGui
---@field gradient_colors any #TODO
---@field has_action fun(action: string): boolean
---@field mux WezTermMux
---@field home_dir string This constant is set to the home directory of the user running wezterm.
---@field hostname fun(): string This function returns the current hostname of the system that is running wezterm. This can be useful to adjust configuration based on the host.
---@field json_encode fun(value: any): string Encodes the supplied lua value as json.
---@field json_parse fun(value: string): any Parses the supplied string as json and returns the equivalent lua values.
---@field log_error fun(msg: any, ...: any): nil Logs the provided message string through wezterm's logging layer at 'ERROR' level. If you started wezterm from a terminal that text will print to the stdout of that terminal. If running as a daemon for the multiplexer server then it will be logged to the daemon output path.
---@field log_info fun(msg: any, ...: any): nil Logs the provided message string through wezterm's logging layer at 'INFO' level. If you started wezterm from a terminal that text will print to the stdout of that terminal. If running as a daemon for the multiplexer server then it will be logged to the daemon output path.
---@field log_warn fun(msg: any, ...: any): nil Logs the provided message string through wezterm's logging layer at 'WARN' level. If you started wezterm from a terminal that text will print to the stdout of that terminal. If running as a daemon for the multiplexer server then it will be logged to the daemon output path.
---@field nerdfonts WezTermNF
---@field on EventAugmentCommandPalette | EventBell | EventFormatTabTitle | EventFormatWindowTitle | EventNewTabButtonClick | EventOpenUri | EventUpdateRightStatus | EventUpdateStatus | EventUserVarChanged | EventWindowConfigReloaded | EventWindowFocusChanged | EventWindowResized | EventCustom
---@field open_with fun(path_or_url: string, application: string?) This function opens the specified path_or_url with either the specified application or uses the default application if application was not passed in.
---@field pad_left fun(string: string, min_width: integer): string Returns a copy of string that is at least min_width columns (as measured by wezterm.column_width)
---@field pad_right fun(string: string, min_width: integer): string Returns a copy of string that is at least min_width columns (as measured by wezterm.column_width).
---@field permute_any_mods any #TODO
---@field permute_any_or_no_mods any #TODO
---@field plugin WeztermPlugin
---@field read_dir fun(path: string): string Returns an array containing the absolute file names of the directory specified. Due to limitations in the lua bindings, all of the paths must be able to be represented as UTF-8 or this function will generate an error.
---@field reload_configuration fun(): nil Immediately causes the configuration to be reloaded and re-applied.
---@field run_child_process fun(args: string[]): { success: boolean, stdout: string, stderr: string } Will attempt to spawn that command and will return a tuple consisting of the boolean success of the invocation, the stdout data and the stderr data.
---@field running_under_wsl fun(): boolean Returns a boolean indicating whether we believe that we are running in a Windows Services for Linux (WSL) container.
---@field shell_join_args fun(args: string[]): string Joins together its array arguments by applying posix style shell quoting on each argument and then adding a space.
---@field shell_quote_arg fun(string: string): string Quotes its single argument using posix shell quoting rules.
---@field shell_split fun(line: string): string[] Splits a command line into an argument array according to posix shell rules.
---@field sleep_ms fun(milliseconds: number): nil wezterm.sleep_ms suspends execution of the script for the specified number of milliseconds. After that time period has elapsed, the script continues running at the next statement.
---@field split_by_newlines fun(string: string): string[] takes the input string and splits it by newlines (both \n and \r\n are recognized as newlines) and returns the result as an array of strings that have the newlines removed.
---@field strftime fun(format: string): string Formats the current local date/time into a string using the Rust chrono strftime syntax.
---@field strftime_utc fun(format: string): string Formats the current UTC date/time into a string using the Rust chrono strftime syntax.
---@field target_triple string This constant is set to the Rust target triple for the platform on which wezterm was built. This can be useful when you wish to conditionally adjust your configuration based on the platform.
---@field time Time
---@field truncate_left fun(string: string, max_width: number): string Returns a copy of string that is no longer than max_width columns (as measured by wezterm.column_width). Truncation occurs by reemoving excess characters from the left end of the string.
---@field truncate_right fun(string: string, max_width: number): string Returns a copy of string that is no longer than max_width columns (as measured by wezterm.column_width). Truncation occurs by reemoving excess characters from the right end of the string.
---@field utf16_to_utf8 fun(string: string): string Overly specific and exists primarily to workaround this wsl.exe issue. It takes as input a string and attempts to convert it from utf16 to utf8.
---@field version string This constant is set to the wezterm version string that is also reported by running wezterm -V. This can potentially be used to adjust configuration according to the installed version.

---@alias FormatItemAttribute { Underline: "None" | "Single" | "Double" | "Curly" | "Dotted" | "Dashed" } | { Intensity: "Normal" | "Bold" | "Half" } | { Italic: boolean }
---@alias FormatItemReset "ResetAttributes" Reset all attributes to default.
---@alias FormatItem { Attribute: FormatItemAttribute } | { Foreground: Color } | { Background: Color } | { Text: string } | FormatItemReset

---@class AugmentCommandPaletteReturn
---@field brief string The brief description for the entry
---@field doc string? A long description that may be shown after the entry, or that may be used in future versions of wezterm to provide more information about the command.
---@field action KeyAssignment The action to take when the item is activated. Can be any key assignment action.
---@field icon WezTermNF? optional Nerd Fonts glyph name to use for the icon for the entry. See wezterm.nerdfonts for a list of icon names.

---@alias CallbackWindowPane fun(window: WindowObj, pane: PaneObj)
---@alias EventAugmentCommandPalette fun(event: "augment-command-palette", callback: fun(window: WindowObj, pane: WindowObj): AugmentCommandPaletteReturn): nil This event is emitted when the Command Palette is shown. It's purpose is to enable you to add additional entries to the list of commands shown in the palette. This hook is synchronous; calling asynchronous functions will not succeed.
---@alias EventBell fun(event: "augment-command-palette", callback: CallbackWindowPane) The bell event is emitted when the ASCII BEL sequence is emitted to a pane in the window. Defining an event handler doesn't alter wezterm's handling of the bell; the event supplements it and allows you to take additional action over the configured behavior.
---@alias EventFormatTabTitle fun(event: "format-tab-title", callback: fun(tab: MuxTabObj, tabs: MuxTabObj[], panes: PaneObj[], config: WeztermConfig, hover: boolean, max_width: number): string) TODO
---@alias EventFormatWindowTitle fun(event: "format-window-title", callback: fun(window: WindowObj, pane: PaneObj, tabs: MuxTabObj[], panes: PaneObj[], config: WeztermConfig)) TODO
---@alias EventNewTabButtonClick fun(event: "new-tab-button-click", callback: fun(window: WindowObj, pane: PaneObj, button: "Left" | "Middle" | "Right", default_action: KeyAssignment): nil) TODO
---@alias EventOpenUri fun(event: "open-uri", callback: fun(window: WindowObj, pane: PaneObj, uri: string): nil) TODO
---@alias EventUpdateRightStatus fun(event: "update-right-status", callback: CallbackWindowPane) TODO
---@alias EventUpdateStatus fun(event: "update-status", callback: CallbackWindowPane) TODO
---@alias EventUserVarChanged fun(event: "user-var-changed", callback: fun(window: WindowObj, pane: PaneObj, name: string, value: string): nil) TODO
---@alias EventWindowConfigReloaded fun(event: "window-config-reloaded", callback: CallbackWindowPane) TODO
---@alias EventWindowFocusChanged fun(event: "window-focus-changed", callback: CallbackWindowPane) TODO
---@alias EventWindowResized fun(event: "window-resized", callback: CallbackWindowPane) TODO
---@alias EventCustom fun(event: string, callback: fun(...: any): nil) A custom declared function

---@class Background TODO any `any` field should be typed
---@field source string Defines the source of the layer texture data. See below for source definitions
---@field attachment "Fixed" | "Scroll" | { Parallax: number } Controls whether the layer is fixed to the viewport or moves as it scrolls.
---@field repeat_x "Repeat" | "Mirror" | "NoRepeat" Controls whether the image is repeated in the x-direction.
---@field repeat_x_size number | string Normally, when repeating, the image is tiled based on its width such that each copy of the image is immediately adjacent to the preceding instance. You may set repeat_x_size to a different value to increase or decrease the space between the repeated instances.
---@field repeat_y any Like `repeat_x` but affects the y-direction.
---@field repeat_y_size any Like `repeat_x_size` but affects the y-direction.
---@field vertical_align "Top" | "Middle" | "Bottom" Controls the initial vertical position of the layer, relative to the viewport:
---@field vertical_offset number | string Specify an offset from the initial vertical position. Accepts:
---@field horizontal_align "Left" | "Center" | "Right" Controls the initial horizontal position of the layer, relative to the viewport:
---@field horizontal_offset number | string like `vertical_offset` but applies to the x-direction.
---@field opacity number A number in the range 0 through 1.0 inclusive that is multiplied with the alpha channel of the source to adjust the opacity of the layer. The default is 1.0 to use the source alpha channel as-is. Using a smaller value makes the layer less opaque/more transparent.
---@field hsb { hue: number, saturation: number, brightness: number } A hue, saturation, brightness tranformation that can be used to adjust those attributes of the layer. See `foreground_text_hsb` for more information about this kind of transform.
---@field height "Cover" | "Contain" | number | string Controls the height of the image. The following values are accepted:
---@field width "Cover" | "Contain" | number | string controls the width of the image. Same details as height but applies to the x-direction.

---@alias EasingFunction "Linear" | "Ease" | "EaseIn" | "EaseInOut" | "EaseOut" | { CubicBezier: number[] } | "Constant"

---@alias AnsiColor "Black" | "Maroon" | "Green" | "Olive" | "Navy" | "Purple" | "Teal" | "Silver" | "Grey" | "Red" | "Lime" | "Yellow" | "Blue" | "Fuchsia" | "Aqua" | "White"
---@alias Color { AnsiColor: AnsiColor } | { Color: string }
---@class ColorSchemeTabBarTab
---@field bg_color string The color of the background area for the tab
---@field fg_color string The color of the text for the tab
---@field intensity "Half" | "Normal" | "Bold" Specify whether you want "Half", "Normal" or "Bold" intensity for the label shown for this tab. The default is "Normal"
---@field underline "None" | "Single" | "Double" Specify whether you want "None", "Single" or "Double" underline for the label shown for this tab. The default is "None"
---@field italic boolean Specify whether you want italic text for the label shown for this tab. The default is false
---@field strikethrough boolean Specify whether you want strikethrough text for the label shown for this tab. The default is false

---@class ColorSchemeTabBar
---@field background string The color of the strip that goes along the top of the window (does not apply when fancy tab bar is in use)
---@field active_tab ColorSchemeTabBarTab The active tab is the one that has focus in the window
---@field inactive_tab ColorSchemeTabBarTab The inactive tab is the one that does not have focus in the window
---@field inactive_tab_hover ColorSchemeTabBarTab You can configure some alternate styling when the mouse pointer moves over inactive tabs
---@field new_tab ColorSchemeTabBarTab The new tab button that let you create new tabs
---@field new_tab_hover ColorSchemeTabBarTab You can configure some alternate styling when the mouse pointer moves over the new tab button

---@class ColorScheme
---@field foreground string The default foreground color
---@field background string The default background color
---@field cursor_bg string Overrides the cell background color when the current cell is occupied by the cursor and the cursor style is set to Block
---@field cursor_border string Specifies the border color of the cursor when the cursor style is set to Block, or the color of the vertical or horizontal bar when the cursor style is set to Bar or Underline.
---@field cursor_fg string Overrides the cell foreground color when the current cell is occupied by the cursor and the cursor style is set to Block
---@field selection_bg string The background color of selected text
---@field selection_fg string The foreground color of selected text
---@field scrollbar_thumb string The color of the scrollbar "thumb"; the portion that represents the current viewport
---@field split string The color of the split lines between panes
---@field ansi string[] The color palette for the first 8 ANSI colors
---@field brights string[] The color palette for the second 8 ANSI colors
---@field indexed { [number]: string } Arbitrary colors of the palette in the range from 16 to 255
---@field composer_cursor string The color of the cursor when the IME is active
---@field copy_mode_active_highlight_bg Color The background color of the active text in copy mode
---@field copy_mode_active_highlight_fg Color The foreground color of the active text in copy mode
---@field copy_mode_inactive_highlight_bg Color The background color of the inactive text in copy mode
---@field copy_mode_inactive_highlight_fg Color The foreground color of the inactive text in copy mode
---@field quick_select_label_bg Color The background color of the label in quick select mode
---@field quick_select_label_fg Color The foreground color of the label in quick select mode
---@field quick_select_match_bg Color The background color of the match in quick select mode
---@field quick_select_match_fg Color The foreground color of the match in quick select mode
---@field tab_bar ColorSchemeTabBar The colors and config for the tab bar

---@class WeztermConfig
---@field adjust_window_size_when_changing_font_size boolean Control whether changing the font size adjusts the dimensions of the window (true) or adjusts the number of terminal rows/columns (false). The default is true. If you use a tiling window manager then you may wish to set this to false.
---@field allow_square_glyphs_to_overflow_width "WhenFollowedBySpace" | "Always" | "Never" Configures how square symbol glyph's cell is rendered.
---@field allow_win32_input_mode boolean When set to true, wezterm will honor an escape sequence generated by the Windows ConPTY layer to switch the keyboard encoding to a proprietary scheme that has maximum compatibility with win32 console applications.
---@field alternate_buffer_wheel_scroll_speed integer Normally the vertical mouse wheel will scroll the terminal viewport so that different sections of the scrollback are visible. When an application activates the Alternate Screen Buffer (this is common for "full screen" terminal programs such as pagers and editors), the alternate screen doesn't have a scrollback. In this mode, if the application hasn't enabled mouse reporting, wezterm will generate Arrow Up/Down key events when the vertical mouse wheel is scrolled.
---@field animation_fps integer This setting controls the maximum frame rate used when rendering easing effects for blinking cursors, blinking text and visual bell. Setting it larger will result in smoother easing effects but will increase GPU utilization.
---@field audible_bell "SystemBeep" | "Disabled" When the BEL ascii sequence is sent to a pane, the bell is "rung" in that pane. You may choose to configure the audible_bell option to change the sound that wezterm makes when the bell rings.
---@field automatically_reload_config boolean When true (the default), watch the config file and reload it automatically when it is detected as changing. When false, you will need to manually trigger a config reload with a key bound to the action ReloadConfiguration.
---@field background Background The background config option allows you to compose a number of layers to produce the background content in the terminal. Layers can be image files, gradients or solid blocks of color. Layers composite over each other based on their alpha channel. Images in layers can be made to fill the viewport or to tile, and also to scroll with optional parallax as the viewport is scrolled.
---@field bold_brightens_ansi_colors boolean When true (the default), PaletteIndex 0-7 are shifted to bright when the font intensity is bold. This brightening effect doesn't occur when the text is set to the default foreground color! This defaults to true for better compatibility with a wide range of mature software; for instance, a lot of software assumes that Black+Bold renders as a Dark Grey which is legible on a Black background, but if this option is set to false, it would render as Black on Black.
---@field bypass_mouse_reporting_modifiers "SHIFT" | "ALT" If an application has enabled mouse reporting mode, mouse events are sent directly to the application, and do not get routed through the mouse assignment logic. Holding down the bypass_mouse_reporting_modifiers modifier key(s) will prevent the event from being passed to the application. The default value for bypass_mouse_reporting_modifiers is SHIFT, which means that holding down shift while clicking will not send the mouse event to eg: vim running in mouse mode and will instead treat the event as though SHIFT was not pressed and then match it against the mouse assignments.
---@field canonicalize_pasted_newlines boolean "None"	| "LineFeed" | "CarriageReturn"	| "CarriageReturnAndLineFeed" Controls whether pasted text will have newlines normalized. If bracketed paste mode is enabled by the application, the effective value of this configuration option is "None".
---@field cell_width number Scales the computed cell width to adjust the spacing between successive cells of text. If possible, you should prefer to specify the stretch parameter when selecting a font using `wezterm.font` or `wezterm.font_with_fallback` as that will generally look better and have fewer undesirable side effects.
---@field check_for_updates boolean Wezterm checks regularly if there is a new stable version available on github, and shows a simple UI to let you know about the update (See `show_update_window` to control this UI).
---@field check_for_updates_interval_seconds integer Set an alternative update interval
---@field clean_exit_codes number[] Defines the set of exit codes that are considered to be a "clean" exit by exit_behavior when the program running in the terminal completes. Acceptable values are an array of integer exit codes that you wish to treat as successful.
---@field color_scheme string Specifies the name of the color scheme to use.
---@field color_schemes table<string, ColorScheme> If you'd like to keep a couple of color schemes handy in your configuration file, rather than filling out the colors section, place it in a `color_schemes` section; you can then reference it using the color_scheme setting.
---@field colors ColorScheme You can specify the color palette using the colors configuration section.
---@field command_palette_bg_color string Specifies the background color used by ActivateCommandPalette.
---@field command_palette_fg_color string Specifies the foreground color used by ActivateCommandPalette.
---@field command_palette_font_size number Specifies the font size used by ActivateCommandPalette.
---@field cursor_blink_ease_in EasingFunction Specifies the easing function to use when computing the color for the text cursor when it is set to a blinking style.
---@field cursor_blink_ease_out EasingFunction Specifies the easing function to use when computing the color for the text cursor when it is set to a blinking style.
---@field cursor_blink_rate integer Specifies how often a blinking cursor transitions between visible and invisible, expressed in milliseconds. Setting this to 0 disables blinking. Note that this value is approximate due to the way that the system event loop schedulers manage timers; non-zero values will be at least the interval specified with some degree of slop.
---@field cursor_thickness number | string If specified, overrides the base thickness of the lines used to render the textual cursor glyph. The default is to use the `underline_thickness`.
---@field custom_block_glyphs boolean When set to true (the default), WezTerm will compute its own idea of what the glyphs in the following unicode ranges should be, instead of using glyphs resolved from a font. Ideally this option wouldn't exist, but it is present to work around a hinting issue in freetype.
---@field daemon_options { stdout: string, stderr: string, pid_file: string } Allows configuring the multiplexer (mux) server and how it places itself into the background to run as a daemon process. You should not normally need to configure this setting; the defaults should be sufficient in most cases.
---@field debug_key_events boolean When set to true, each key event will be logged by the GUI layer as an INFO level log message on the stderr stream from wezterm. You will typically need to launch wezterm directly from another terminal to see this logging. This can be helpful in figuring out how keys are being decoded on your system, or for discovering the system-dependent "raw" key code values.
---@field default_cursor_style CursorShape Specifies the default cursor style. Various escape sequences can override the default style in different situations (eg: an editor can change it depending on the mode), but this value controls how the cursor appears when it is reset to default. The default is SteadyBlock.
---@field default_cwd string Sets the default current working directory used by the initial window. The value is a string specifying the absolute path that should be used for the home directory. Using strings like ~ or ~username that are typically expanded by the shell is not supported. You can use wezterm.home_dir to explicitly refer to your home directory.
---@field default_domain string When starting the GUI (not using the serial or connect subcommands), by default wezterm will set the built-in "local" domain as the default multiplexing domain. The "local" domain represents processes that are spawned directly on the local system.
---@field default_gui_startup_args string[] When launching the GUI using either wezterm or wezterm-gui (with no subcommand explicitly specified), wezterm will use the value of default_gui_startup_args to pick a default mode for running the GUI. The default for this config is {"start"} which makes wezterm with no additional subcommand arguments equivalent to wezterm start.
---@field default_prog string[] If no prog is specified on the command line, use this instead of running the user's shell. For example, to have wezterm always run top by default, you'd use this:
---@field default_workspace string Specifies the name of the default workspace. The default is "default".
---@field detect_password_input boolean When set to true, on unix systems, for local panes, wezterm will query the termios associated with the PTY to see whether local echo is disabled and canonical input is enabled. If those conditions are met, then the text cursor will be changed to a lock to give a visual cue that what you type will not be echoed to the screen.
---@field disable_default_key_bindings boolean If set to true, the default mouse assignments will not be used, allowing you to tightly control those assignments.
---@field disable_default_mouse_bindings boolean If set to true, the default mouse assignments will not be used, allowing you to tightly control those assignments.
---@field disable_default_quick_select_patterns boolean  When set to true, the default set of quick select patterns are omitted, and your quick_select_patterns config specifies the total set of patterns used for quick select mode. Defaults to false.
---@field display_pixel_geometry "RGB" | "BGR" Configures whether subpixel anti-aliasing should produce either "RGB" or "BGR" ordered output. If your display has a BGR pixel geometry then you will want to set this to "BGR" for the best results when using subpixel antialiasing. The default value is "RGB".
---@field dpi number Override the detected DPI (dots per inch) for the display. This can be useful if the detected DPI is inaccurate and the text appears either blurry or too small (especially if you are using a 4K display on X11 or Wayland).
---@field enable_csi_u_key_encoding boolean When set to true, the keyboard encoding will be changed to use the scheme that is described here. It is not recommended to enable this option as it does change the behavior of some keys in backwards incompatible ways and there isn't a way for applications to detect or request this behavior. The default for this option is false.
---@field enable_kitty_keyboard boolean When set to true, wezterm will honor kitty keyboard protocol escape sequences that modify the keyboard encoding.
---@field enable_scroll_bar boolean Enable the scrollbar. This is currently disabled by default. It will occupy the right window padding space. If right padding is set to 0 then it will be increased to a single cell width.
---@field enable_tab_bar boolean Controls whether the tab bar is enabled. Set to false to disable it. See also `hide_tab_bar_if_only_one_tab`
---@field enable_wayland boolean If false, do not try to use a Wayland protocol connection when starting the gui frontend, and instead use X11. This option is only considered on X11/Wayland systems and has no effect on macOS or Windows. The default is true. In versions prior to 20220624-141144-bd1b7c5d it was disabled by default.
---@field exit_behavior "Close" | "Hold" | "CloseOnCleanExit" Controls the behavior when the shell program spawned by the terminal exits.
---@field font Font Configures the font to use by default. The font setting can specify a set of fallbacks and other options, and is described in more detail in the Fonts section. You will typically use `wezterm.font` or `wezterm.font_with_fallback` to specify the font.
---@field font_antialias "None" | "Greyscale" | "Subpixel" **DEPRECATED** Use freetype_load_target instead
---@field font_dirs string[] By default, wezterm will use an appropriate system-specific method for locating the fonts that you specify using the options below. In addition, if you configure the `font_dirs` option, wezterm will load fonts from that set of directories.
---@field font_hinting "None" | "Vertical" | "VerticalSubpixel" | "Full" **DEPRECATED** Use `freetype_load_target` instead
---@field font_locator "ConfigDirsOnly" | nil specifies the method by which system fonts are located and loaded. You may specify ConfigDirsOnly to disable loading system fonts and use only the fonts found in the directories that you specify in your font_dirs configuration option. Otherwise, it is recommended to omit this setting.
---@field font_rasterizer "FreeType" Specifies the method by which fonts are rendered on screen. The only available implementation is FreeType.
---@field font_rules { intensity: FontWeight, italic: boolean, font: Font }[] When textual output in the terminal is styled with bold, italic or other attributes, wezterm uses font_rules to decide how to render that text. By default, unstyled text will use the font specified by the font configuration, and wezterm will use that as a base, and then automatically generate appropriate font_rules that use heavier weight fonts for bold text, lighter weight fonts for dim text and italic fonts for italic text. Most users won't need to specify any explicit value for font_rules, as the defaults should be sufficient.
---@field font_shaper "Harfbuzz" **DEPRECATED**
---@field font_size number Specifies the size of the font, measured in points. You may use fractional point sizes, such as 13.3, to fine tune the size.
---@field force_reverse_video_cursor boolean When force_reverse_video_cursor = true, override the cursor_fg, cursor_bg, cursor_border settings from the color scheme and force the cursor to use reverse video colors based on the foreground and background colors. When force_reverse_video_cursor = false (the default), cursor_fg, cursor_bg and cursor_border color scheme settings are applied as normal.
---@field foreground_text_hsb { hue: number, saturation: number, brightness: number } #TODO Configures a Hue, Saturation, Brightness transformation that is applied to monochrome glyphs. The transform works by converting the RGB colors to HSV values and then multiplying the HSV by the numbers specified in foreground_text_hsb.
---@field freetype_interpreter_version 35 | 38 | 30 Selects the freetype interpret version to use. Possible values are 35, 38 and 40 which have different characteristics with respective to subpixel hinting. See https://freetype.org/freetype2/docs/hinting/subpixel-hinting.html
---@field freetype_load_flags string An advanced option to fine tune the freetype rasterizer. This is a bitfield, so you can combine one or more of these options together, separated by the | character, although not many of the available options necessarily make sense to be combined.
---@field freetype_load_target FreeTypeLoadTarget Configures the hinting and (potentially) the rendering mode used with the freetype rasterizer.
---@field freetype_pcf_long_family_names boolean This option provides control over the no-long-family-names FreeType PCF font driver property. The default is for this configuration to be false which sets the PCF driver to use the un-decorated font name. This corresponds to the default mode of operation of the freetype library. Some Linux distributions build the freetype library in a way that causes the PCF driver to report font names differently; instead of reporting just Terminus it will prefix the font name with the foundry (xos4 in the case of Terminus) and potentially append Wide to the name if the font has wide glyphs. The purpose of that configuration option is to disambiguate fonts, as there are a number of fonts from different foundries that all have the name Fixed, and being presented with multiple items with the same Fixed label is a very ambiguous user experience.
---@field freetype_render_target FreeTypeRenderTarget Configures the rendering mode used with the freetype rasterizer. The default is to use the value of freetype_load_target.
---@field front_end
---| "OpenGL" # use GPU accelerated rasterization.
---| "Software" # use CPU-based rasterization.
---| "WebGpu" # use GPU accelerated rasterization (Since: Version 20221119-145034-49b9839f)
---@field harfbuzz_features string[] When font_shaper = "Harfbuzz", this setting affects how font shaping takes place.
---@field hide_mouse_cursor_when_typing boolean If true, the mouse cursor will be hidden when typing, if your mouse cursor is hovering over the window. The default is true. Set to false to disable this behavior.
---@field hide_tab_bar_if_only_one_tab boolean If set to true, when there is only a single tab, the tab bar is hidden from the display. If a second tab is created, the tab will be shown.
---@field hyperlink_rules HyperLinkRules[] Defines rules to match text from the terminal output and generate clickable links. The value is a list of rule entries.
---@field ime_preedit_rendering "Builtin" | "System" Control IME preedit rendering. IME preedit is an area that is used to display the string being preedited in IME. WezTerm supports the following IME preedit rendering.
---@field inactive_pane_hsb { hue: number, saturation: number, brightness: number } TODO
---@field initial_cols integer
---@field initial_rows integer
---@field integrated_title_button_alignment any #TODO
---@field integrated_title_button_color any #TODO
---@field integrated_title_button_style any #TODO
---@field integrated_title_buttons any #TODO
---@field key_map_preference any #TODO
---@field key_tables any #TODO
---@field launch_menu any #TODO
---@field leader any #TODO
---@field line_height number
---@field log_unknown_escape_sequences any #TODO
---@field macos_forward_to_ime_modifier_mask any #TODO
---@field macos_window_background_blur any #TODO
---@field max_fps integer
---@field min_scroll_bar_height string
---@field mouse_wheel_scrolls_tabs any #TODO
---@field mux_env_remove any #TODO
---@field native_macos_fullscreen_mode boolean
---@field normalize_output_to_unicode_nfc boolean
---@field pane_focus_follows_mouse boolean
---@field prefer_egl boolean
---@field quick_select_alphabet string
---@field quick_select_patterns any #TODO
---@field quit_when_all_windows_are_closed any #TODO
---@field quote_dropped_files any #TODO
---@field scroll_to_bottom_on_input boolean
---@field scrollback_lines integer
---@field selection_word_boundary string
---@field serial_ports any #TODO
---@field set_environment_variables { [string]: string } Specifies a map of environment variables that should be set when spawning new commands in the "local" domain. This configuration is consulted at the time that a program is launched. It is not possible to update the environment of a running program on any Operating System. This is not used when working with remote domains.
---@field set_strict_mode fun(self: WeztermConfig, strict: boolean)
---@field show_new_tab_button_in_tab_bar boolean When set to true (the default), the tab bar will display the new-tab button, which can be left-clicked to create a new tab, or right-clicked to display the Launcher Menu. When set to false, the new-tab button will not be drawn into the tab bar.
---@field show_tab_index_in_tab_bar boolean When set to true (the default), tab titles show their tab number (tab index) with a prefix such as 1:. When false, no numeric prefix is shown.
---@field show_tabs_in_tab_bar boolean When set to true (the default), the tab bar will display the tabs associated with the current window. When set to false, the tabs will not be drawn into the tab bar.
---@field show_update_window boolean When Wezterm checks for an update and detects a new version, this option controls whether a window is shown with information about the new available version and links to download/install it.
---@field skip_close_confirmation_for_processes_named string[] This configuration specifies a list of process names that are considered to be "stateless" and that are safe to close without prompting when closing windows, panes or tabs. When closing a pane wezterm will try to determine the processes that were spawned by the program that was started in the pane. If all of those process names match one of the names in the skip_close_confirmation_for_processes_named list then it will not prompt for closing that particular pane.
---@field ssh_backend "Ssh2" | "LibSsh" Sets which ssh backend should be used by default for the integrated ssh client. Despite the naming, libssh2 is not a newer version of libssh, they are completely separate ssh implementations. In prior releases, "Ssh2" was the only option. "LibSsh" is the default as it has broader support for newer keys and cryptography, and has clearer feedback about authentication events that require entering a passphrase.
---@field ssh_domains SSHDomainObj[] Configures SSH multiplexing domains.
---@field status_update_interval integer
---@field strikethrough_position string | number
---@field swallow_mouse_click_on_pane_focus boolean
---@field swallow_mouse_click_on_window_focus boolean
---@field swap_backspace_and_delete boolean
---@field switch_to_last_active_tab_when_closing_tab boolean
---@field tab_and_split_indices_are_zero_based boolean
---@field tab_bar_at_bottom boolean
---@field tab_bar_style any #TODO
---@field tab_max_width number
---@field term string What to set the TERM environment variable to. The default is xterm-256color, which should provide a good level of feature support without requiring the installation of additional terminfo data.
---@field text_blink_ease_in any #TODO
---@field text_blink_ease_out any #TODO
---@field text_blink_rapid_ease_in any #TODO
---@field text_blink_rapid_ease_out any #TODO
---@field text_blink_rate integer
---@field text_blink_rate_rapid integer
---@field tiling_desktop_environments any #TODO
---@field tls_clients any #TODO
---@field tls_servers any #TODO
---@field treat_east_asian_ambiguous_width_as_wide boolean
---@field treat_left_ctrlalt_as_altgr boolean
---@field ulimit_nofile any #TODO
---@field ulimit_nproc any #TODO
---@field underline_position string | number
---@field underline_thickness string | number
---@field unicode_version integer
---@field unix_domains any #TODO
---@field unzoom_on_switch_pane boolean
---@field use_cap_height_to_scale_fallback_fonts boolean
---@field use_fancy_tab_bar boolean
---@field use_ime boolean
---@field use_resize_increments boolean
---@field visual_bell any #TODO
---@field warn_about_missing_glyphs boolean
---@field webgpu_force_fallback_adapter any #TODO
---@field webgpu_power_preference any #TODO
---@field webgpu_preferred_adapter any #TODO
---@field win32_acrylic_accent_color any #TODO
---@field win32_system_backdrop any #TODO
---@field window_background_gradient any #TODO
---@field window_close_confirmation any #TODO
---@field window_decorations any #TODO
---@field window_frame any #TODO
---@field window_padding { left: number, right: number, top: number, bottom: number }
---@field wsl_domains any #TODO
---@field xim_im_name string

---@alias CursorShape "SteadyBlock" | "BlinkingBlock" | "SteadyUnderline" | "BlinkingUnderline" | "SteadyBar" | "BlinkingBar"
---@alias CursorVisibility "Visible" | "Hidden"

---@class WezTermColor
---@field extract_colors_from_image any #TODO
---@field from_hsla any #TODO
---@field get_builtin_schemes fun(): table<string, ColorScheme>
---@field get_default_colors any #TODO
---@field gradient any #TODO
---@field load_base16_scheme any #TODO
---@field load_scheme any #TODO
---@field load_terminal_sexy_scheme any #TODO
---@field parse fun(color: string): ColorObj? Parses the passed color and returns a Color object. Color objects evaluate as strings but have a number of methods that allow transforming and comparing colors.
---@field save_scheme any #TODO

---@class WezTermGui
---@field default_key_tables any #TODO
---@field default_keys any #TODO
---@field enumerate_gpus any #TODO
---@field get_appearance fun(): "Light" | "Dark" | "LightHighContrast" | "DarkHighContrast" Returns the appearance of the window environment.
---@field gui_window_for_mux_window any #TODO
---@field gui_windows any #TODO
---@field screens any #TODO

---@class BatteryInfo
---@field state_of_charge number The battery level expressed as a number between 0.0 (empty) and 1.0 (full)
---@field vendor string Battery manufacturer name, or "unknown" if not known.
---@field model string The battery model string, or "unknown" if not known.
---@field serial string The battery serial number, or "unknown" if not known.
---@field time_to_full number? If charging, how long until the battery is full (in seconds). May be nil.
---@field time_to_empty number? If discharing, how long until the battery is empty (in seconds). May be nil.
---@field state "Charging" | "Discharging" | "Empty" | "Full" | "Unknown"

---@class ProcInfo
---@field current_working_dir_for_pid string? Returns the current working directory for the specified process id. This function may return nil if it was unable to return the info.
---@field executable_path_for_pid string? Returns the path to the executable image for the specified process id. This function may return nil if it was unable to return the info.
---@field get_info_for_pid fun(pid: number): LocalProcessInfo Returns a LocalProcessInfo object for the specified process id.
---@field pid fun(): number Returns the process id for the current process.

---@class TimeObj
---@field format fun(self: TimeObj, format: string): string Formats the time object as a string, using the local date/time representation of the time.
---@field format_utc fun(self: TimeObj, format: string): string Formats the time object as a string, using the UTC date/time representation of the time.
---@field sun_times fun(self: TimeObj, lat: number, lon: number): { rise: TimeObj, set: TimeObj, progression: number, up: boolean } For the date component of the time object, compute the times of the sun rise and sun set for the given latitude and longitude.

---@class Time
---@field call_after fun(interval: number, function: function): nil Arranges to call your callback function after the specified number of seconds have elapsed.
---@field now fun(): TimeObj Returns a WezTermTimeObj object representing the time at which wezterm.time.now() was called.
---@field parse fun(string): TimeObj Parses a string that is formatted according to the supplied format string.
---@field parse_rfc3339 fun(string): TimeObj Parses a string that is formatted according to RFC 3339 and returns a Time object representing that time.

---@alias LRUD "Left" | "Right" | "Up" | "Down"
---@alias CharSelectGroups
---| "RecentlyUsed" # Recently selected characters, ordered by frecency
---| "SmileysAndEmotion"
---| "PeopleAndBody"
---| "AnimalsAndNature"
---| "FoodAndDrink"
---| "TravelAndPlaces"
---| "Activities"
---| "Objects"
---| "Symbols"
---| "Flags"
---| "NerdFonts" # Glyphs that are present in Nerd Fonts
---| "UnicodeNames" # All codepoints defined in unicode

---@alias CellWordLine "Cell" | "Word" | "Line"

---@class KeyAssignment
---@field ActivateCommandPalette fun() Activates the Command Palette, a modal overlay that enables discovery and activation of various commands.
---@field ActivateCopyMode fun() Activates copy mode.
---@field ActivateKeyTable fun(args: { name: string, timeout_milliseconds: number?, one_shot: boolean?, replace_current: boolean?, until_unknown: boolean?, prevent_fallback: boolean? }) Activates a named key table. See Key Tables for a detailed example.
---@field ActivateLastTab fun() Activate the previously active tab. If there is none, it will do nothing.
---@field ActivatePaneByIndex fun(index: number) ActivatePaneByIndex activates the pane with the specified index within the current tab. Invalid indices are ignored.
---@field ActivatePaneDirection fun(direction: LRUD) Activate an adjacent pane in the specified direction. In cases where there are multiple adjacent panes in the intended direction, wezterm will choose the pane that has the largest edge intersection.
---@field ActivateTab fun(index: number) Activate the tab specified by the argument value. eg: 0 activates the leftmost tab, while 1 activates the second tab from the left, and so on.
---@field ActivateTabRelative fun(index: number) Activate a tab relative to the current tab. The argument value specifies an offset. eg: -1 activates the tab to the left of the current tab, while 1 activates the tab to the right.
---@field ActivateTabRelativeNoWrap fun(index: number) Activate a tab relative to the current tab. The argument value specifies an offset. eg: -1 activates the tab to the left of the current tab, while 1 activates the tab to the right.
---@field ActivateWindow fun(index: number) Activates the nth GUI window, zero-based.
---@field ActivateWindowRelative fun(index: number) Activates a GUI window relative to the current window. ActivateWindowRelative(1) activates the next window, while ActivateWindowRelative(-1) activates the previous window.
---@field ActivateWindowRelativeNoWrap fun(index: number) Activates a GUI window relative to the current window. ActivateWindowRelativeNoWrap(1) activates the next window, while ActivateWindowRelativeNoWrap(-1) activates the previous window. This action will NOT wrap around; if the current window is the first/last, then this action will not change the current window.
---@field AdjustPaneSize fun(args: {direction: LRUD, change: number}) Manipulates the size of the active pane, allowing the size to be adjusted by an integer amount in a specific direction.
---@field AttachDomain fun(domain: string) Attempts to attach the named multiplexing domain. The name can be any of the names used in you ssh_domains, unix_domains or tls_clients configurations.
---@field CharSelect fun(args: { copy_on_select: boolean?, copy_to: CopyToTarget?, group: CharSelectGroups? }) Activates Character Selection Mode, which is a pop-over modal that allows you to browse characters by category as well as fuzzy search by name or hex unicode codepoint value.
---@field ClearKeyTableStack fun() Clears the entire key table stack. Note that this is triggered implicitly when the configuration is reloaded.
---@field ClearScrollback fun(scope: "ScrollbackOnly" | "ScrollbackAndViewport" | nil) Clears the lines that have scrolled off the top of the viewport, resetting the scrollbar thumb to the full height of the window.
---@field ClearSelection fun() Clears the selection in the current pane.
---@field CloseCurrentPane fun(args: { confirm: boolean? }) Closes the current pane. If that was the last pane in the tab, closes the tab. If that was the last tab, closes that window. If that was the last window, wezterm terminates.
---@field CloseCurrentTab fun(args: { confirm: boolean? }) Closes the current tab, terminating all contained panes. If that was the last tab, closes that window. If that was the last window, wezterm terminates.
---@field CompleteSelection fun(target: CopyToTarget) Completes an active text selection process; the selection range is marked closed and then the selected text is copied as though the Copy action was executed.
---@field CompleteSelectionOrOpenLinkAtMouseCursor fun(target: CopyToTarget) If a selection is in progress, acts as though CompleteSelection was triggered. Otherwise acts as though OpenLinkAtMouseCursor was triggered.
---@field Copy fun() **DEPRECATED**: Please use CopyTo instead. Copy the selection to the clipboard.
---@field CopyTo fun(target: CopyToTarget) Copy the selection to the specified clipboard buffer.
---@field DecreaseFontSize fun() Decreases the font size of the current window by 10%.
---@field DetachDomain fun(args: { DomainName: string } | "CurrentPaneDomain") Attempts to detach the specified domain. Detaching a domain causes it to disconnect and remove its set of windows, tabs and panes from the local GUI. Detaching does not cause those panes to close; if or when you later attach to the domain, they'll still be there.
---@field DisableDefaultAssignment fun() Has no special meaning of its own; this action will undo the registration of a default assignment if that key/mouse/modifier combination is one of the default assignments and cause the key press to be propagated through to the tab for processing.
---@field EmitEvent fun(event: string) This action causes the equivalent of wezterm.emit(name, window, pane) to be called in the context of the current pane.
---@field ExtendSelectionToMouseCursor fun(arg: CellWordLine) Extends the current text selection to the current mouse cursor position.
---@field Hide fun() Hides (or minimizes, depending on the platform) the current window.
---@field HideApplication fun() On macOS, hide the WezTerm application.
---@field IncreaseFontSize fun() Increases the font size of the current window by 10%.
---@field InputSelector fun(args: { title: string, choices: { label: string, id: string }[], action: any }) Activates an overlay to display a list of choices for the user to select from. When the user accepts a line, emits an event that allows you to act upon the input.
---@field MoveTab fun(index: number) Move the tab so that it has the index specified by the argument. eg: 0 moves the tab to be leftmost, while 1 moves the tab so that it is second tab from the left, and so on.
---@field MoveTabRelative fun(index: number) Move the current tab relative to its peers. The argument specifies an offset. eg: -1 moves the tab to the left of the current tab, while 1 moves the tab to the right.
---@field Multiple fun(args: KeyAssignment[]) Performs a sequence of multiple assignments. This is useful when you want a single key press to trigger multiple actions.
---@field Nop fun() Causes the key press to have no effect; it behaves as though those keys were not pressed.
---@field OpenLinkAtMouseCursor fun() If the current mouse cursor position is over a cell that contains a hyperlink, this action causes that link to be opened.
---@field PaneSelect fun(args: { alphabet: string?, mode: "Activate" | "SwapWithActive" | nil }) This action activates the pane selection modal display. In this mode, each pane will be overlayed with a one- or two-character label taken from the selection alphabet.
---@field Paste any **DEPRECATED**: Please use PasteFrom instead. Paste the clipboard to the current pane.
---@field PasteFrom fun(target: "Clipboard" | "PrimarySelection") Paste the specified clipboard to the current pane. This is only really meaningful on X11 and some Wayland systems that have multiple clipboards.
---@field PastePrimarySelection fun() **DEPRECATED**: Please use PasteFrom instead. X11: Paste the Primary Selection to the current tab. On other systems, this behaves identically to Paste.
---@field PopKeyTable fun() Pops the current key table, if any, from the activation stack. See Key Tables for a detailed example.
---@field PromptInputLine fun(args: { description: string, action: KeyAssignment }) Activates an overlay to display a prompt and request a line of input from the user. When the user enters the line, emits an event that allows you to act upon the input.
---@field QuickSelect fun() Activates Quick Select Mode.
---@field QuickSelectArgs fun(args: QuickSelectArgsArgs) Activates Quick Select Mode but with the option to override the global configuration.
---@field QuitApplication fun() Terminate the WezTerm application, killing all tabs.
---@field ReloadConfiguration fun() Explicitly reload the configuration.
---@field ResetFontAndWindowSize fun() Reset both the font size and the terminal dimensions for the current window to the values specified by your font, initial_rows, and initial_cols configuration.
---@field ResetFontSize fun() Reset the font size for the current window to the value in your configuration.
---@field ResetTerminal fun() Sends the RIS "Reset to Initial State" escape sequence (ESC-c) to the output side of the current pane, causing the terminal emulator to reset its state. This will reset tab stops, margins, modes, graphic rendition, palette, activate the primary screen, erase the display and move the cursor to the home position.
---@field RotatePanes fun(direction: "Clockwise" | "CounterClockwise") Rotates the sequence of panes within the active tab, preserving the sizes based on the tab positions. Panes within a tab have an ordering that follows the creation order of the splits.
---@field ScrollByCurrentEventWheelDelta fun() Adjusts the scroll position by the number of lines in the vertical mouse wheel delta field of the current mouse event, provided that it is a vertical mouse wheel event.
---@field ScrollByLine fun(lines: number) Adjusts the scroll position by the number of lines specified by the argument. Negative values scroll upwards, while positive values scroll downwards.
---@field ScrollByPage fun(pages: number) Adjusts the scroll position by the number of pages specified by the argument. Negative values scroll upwards, while positive values scroll downwards.You may now use floating point values to scroll by partial pages.
---@field ScrollToBottom fun() This action scrolls the viewport to the bottom of the scrollback.
---@field ScrollToPrompt fun(move: number) This action operates on Semantic Zones defined by applications that use OSC 133 Semantic Prompt Escapes and requires configuring your shell to emit those sequences. Takes an argument that specifies the number of zones to move and the direction to move in; -1 means to move to the previous zone while 1 means to move to the next zone.
---@field ScrollToTop fun() This action scrolls the viewport to the top of the scrollback.
---@field Search fun(args: { Regex: string?, CaseSensitiveString: string?, CaseInSensitiveString: string? } | "CurrentSelectionOrEmptyString") This action will trigger the search overlay for the current tab. It accepts a typed pattern string as its parameter, allowing for Regex, CaseSensitiveString and CaseInSensitiveString as pattern matching types.
---@field SelectTextAtMouseCursor fun(scope: CellWordLine | "SemanticZone" | "Block") Initiates selection of text at the current mouse cursor position.
---@field SendKey fun(args: { mods: string?, key: string }) Send the specified key press to the current pane. This is useful to rebind the effect of a key combination. Note that this rebinding effect only applies to the input that is about to be sent to the pane; it doesn't get re-evaluated against the key assignments you've configured in wezterm again.
---@field SendString fun(string: string) Sends the string specified argument to the terminal in the current tab, as though that text were literally typed into the terminal.
---@field SetPaneZoomState fun(set: boolean) Sets the zoom state of the current pane. A Zoomed pane takes up all available space in the tab, hiding all other panes while it is zoomed. Switching its zoom state off will restore the prior split arrangement. Setting the zoom state to true zooms the pane if it wasn't already zoomed. Setting the zoom state to false un-zooms the pane if it was zoomed.
---@field Show fun() Shows the current window.
---@field ShowDebugOverlay fun() Overlays the current tab with the debug overlay, which is a combination of a debug log and a lua REPL.
---@field ShowLauncher fun() Activate the Launcher Menu in the current tab.
---@field ShowLauncherArgs fun(args: { flags: string, title: string? }) Activate the Launcher Menu in the current tab, scoping it to a set of items and with an optional title.
---@field ShowTabNavigator fun() Activate the tab navigator UI in the current tab. The tab navigator displays a list of tabs and allows you to select and activate a tab from that list. TODO: https://wezfurlong.org/wezterm/config/lua/SpawnCommand.html
---@field SpawnCommandInNewTab any TODO
---@field SpawnCommandInNewWindow any TODO
---@field SpawnTab any TODO
---@field SpawnWindow fun() Create a new window containing a tab from the default tab domain.
---@field SplitHorizontal any TODO
---@field SplitPane fun(args: { direction: LRUD, size: any?, command: any?, top_level: boolean  }) Splits the active pane in a particular direction, spawning a new command into the newly created pane. TODO: size, command
---@field SplitVertical any TODO
---@field StartWindowDrag fun() Places the window in the drag-to-move state, which means that the window will move to follow your mouse pointer until the mouse button is released.
---@field SwitchToWorkspace any TODO
---@field SwitchWorkspaceRelative fun(offset: number) Switch to the workspace relative to the current workspace. Workspaces are ordered lexicographically based on their names. The argument value specifies an offset. eg: -1 switches to the workspace immediately prior to the current workspace, while 1 switches to the workspace immediately following the current workspace.
---@field ToggleFullScreen fun() Toggles full screen mode for the current window.
---@field TogglePaneZoomState fun() Toggles the zoom state of the current pane. A Zoomed pane takes up all available space in the tab, hiding all other panes while it is zoomed. Switching its zoom state off will restore the prior split arrangement.

---@class QuickSelectArgsArgs
---@field patterns string[]? If present, completely overrides the normal set of patterns and uses only the patterns specified
---@field alphabet string? if present, this alphabet is used instead of quick_select_alphabet
---@field action KeyAssignment? if present, this key assignment action is performed as if by window:perform_action when an item is selected. The normal clipboard action is NOT performed in this case.
---@field label string? if present, replaces the string "copy" that is shown at the bottom of the overlay; you can use this to indicate which action will happen if you are using action.
---@field scope_lines number? Specify the number of lines to search above and below the current viewport. The default is 1000 lines. The scope will be increased to the current viewport height if it is smaller than the viewport.

---@class StableCursorPosition
---@field x number The horizontal cell index.
---@field y number the vertical stable row index.
---@field shape CursorShape The CursorShape enum value.
---@field visibility CursorVisibility The CursorVisibility enum value.

---@class RenderableDimensions
---@field cols number The number of columns.
---@field viewport_rows number The number of vertical cells in the visible portion of the window.
---@field scrollback_rows number The total number of lines in the scrollback and viewport.
---@field physical_top number The top of the physical non-scrollback screen expressed as a stable index.
---@field scrollback_top number The top of the scrollback; the earliest row remembered by wezterm.

---@class PaneMetadata
---@field password_input boolean A boolean value that is populated only for local panes. It is set to true if it appears as though the local PTY is configured for password entry (local echo disabled, canonical input mode enabled).
---@field is_tardy boolean A boolean value that is populated only for multiplexer client panes. It is set to true if wezterm is waiting for a response from the multiplexer server.
---@field since_last_response_ms number An integer value that is populated only for multiplexer client panes. It is set to the number of elapsed milliseconds since the most recent response from the multiplexer server.

---@class PaneObj
---@field activate fun(self: PaneObj): nil Activates (focuses) the pane and its containing tab.
---@field get_current_working_dir fun(self: PaneObj): string Returns the current working directory of the pane, if known. The current directory can be specified by an application sending OSC 7.
---@field get_cursor_position fun(self: PaneObj): StableCursorPosition Returns a lua representation of the StableCursorPosition struct that identifies the cursor position, visibility and shape.
---@field get_dimensions fun(self: PaneObj): RenderableDimensions Returns a lua representation of the RenderableDimensions struct that identifies the dimensions and position of the viewport as well as the scrollback for the pane.
---@field get_domain_name fun(self: PaneObj): string Returns the name of the domain with which the pane is associated.
---@field get_foreground_process_info fun(self: PaneObj): LocalProcessInfo Returns a LocalProcessInfo object corresponding to the current foreground process that is running in the pane.
---@field get_foreground_process_name fun(self: PaneObj): string Returns the path to the executable image for the pane.
---@field get_lines_as_text fun(self: PaneObj, lines: number?): string Returns the textual representation (not including color or other attributes) of the physical lines of text in the viewport as a string. A physical line is a possibly-wrapped line that composes a row in the terminal display matrix. If you'd rather operate on logical lines, see pane:get_logical_lines_as_text. If the optional nlines argument is specified then it is used to determine how many lines of text should be retrieved. The default (if nlines is not specified) is to retrieve the number of lines in the viewport (the height of the pane). The lines have trailing space removed from each line. The lines will be joined together in the returned string separated by a \n character. Trailing blank lines are stripped, which may result in fewer lines being returned than you might expect if the pane only had a couple of lines of output.
---@field get_logical_lines_as_text fun(self: PaneObj, lines: number?): string Returns the textual representation (not including color or other attributes) of the logical lines of text in the viewport as a string. A logical line is an original input line prior to being wrapped into physical lines to composes rows in the terminal display matrix. WezTerm doesn't store logical lines, but can recompute them from metadata stored in physical lines. Excessively long logical lines are force-wrapped to constrain the cost of rewrapping on resize and selection operations. If you'd rather operate on physical lines, see pane:get_lines_as_text. If the optional nlines argument is specified then it is used to determine how many lines of text should be retrieved. The default (if nlines is not specified) is to retrieve the number of lines in the viewport (the height of the pane). The lines have trailing space removed from each line. The lines will be joined together in the returned string separated by a \n character. Trailing blank lines are stripped, which may result in fewer lines being returned than you might expect if the pane only had a couple of lines of output.
---@field get_metadata fun(self: PaneObj): PaneMetadata? Returns metadata about a pane. The return value depends on the instance of the underlying pane. If the pane doesn't support this method, nil will be returned. Otherwise, the value is a lua table with the metadata contained in table fields.
---@field get_semantic_zone_at fun(self: PaneObj): any TODO
---@field get_semantic_zones fun(self: PaneObj): any TODO
---@field get_text_from_region fun(self: PaneObj, start_x: number, start_y: number, end_x: number, end_y: number): string Returns the text from the specified region.
---@field get_text_from_semantic_zone fun(self: PaneObj): any TODO
---@field get_title fun(self: PaneObj): string Returns the title of the pane. This will typically be wezterm by default but can be modified by applications that send OSC 1 (Icon/Tab title changing) and/or OSC 2 (Window title changing) escape sequences. The value returned by this method is the same as that used to display the tab title if this pane were the only pane in the tab; if OSC 1 was used to set a non-empty string then that string will be returned. Otherwise the value for OSC 2 will be returned. Note that on Microsoft Windows the default behavior of the OS level PTY is to implicitly send OSC 2 sequences to the terminal as new programs attach to the console. If the title text is wezterm and the pane is a local pane, then wezterm will attempt to resolve the executable path of the foreground process that is associated with the pane and will use that instead of wezterm.
---@field get_tty_name fun(self: PaneObj): string? Returns the tty device name, or nil if the name is unavailable.
---@field get_user_vars fun(self: PaneObj): { [string]: string } Returns a table holding the user variables that have been assigned to this pane. User variables are set using an escape sequence defined by iterm2, but also recognized by wezterm; this example sets the foo user variable to the value bar:
---@field has_unseen_output fun(self: PaneObj): boolean Returns true if there has been output in the pane since the last time the time the pane was focused.
---@field inject_output fun(self: PaneObj, text: string): nil Sends text, which may include escape sequences, to the output side of the current pane. The text will be evaluated by the terminal emulator and can thus be used to inject/force the terminal to process escape sequences that adjust the current mode, as well as sending human readable output to the terminal. Note that if you move the cursor position as a result of using this method, you should expect the display to change and for text UI programs to get confused. Not all panes support this method; at the time of writing, this works for local panes but not for multiplexer panes.
---@field is_alt_screen_active fun(self: PaneObj): boolean Returns whether the alternate screen is active for the pane. The alternate screen is a secondary screen that is activated by certain escape codes. The alternate screen has no scrollback, which makes it ideal for a "full-screen" terminal program like vim or less to do whatever they want on the screen without fear of destroying the user's scrollback. Those programs emit escape codes to return to the normal screen when they exit.
---@field move_to_new_tab fun(self: PaneObj): { tab: MuxTabObj, window: MuxWindowObj } Creates a new tab in the window that contains pane, and moves pane into that tab. Returns the newly created MuxTab object, and the MuxWindow object that contains it.
---@field move_to_new_window fun(self: PaneObj, workspace: string?): { tab: MuxTabObj, window: MuxWindowObj } Creates a window and moves pane into that window. The WORKSPACE parameter is optional; if specified, it will be used as the name of the workspace that should be associated with the new window. Otherwise, the current active workspace will be used. Returns the newly created MuxTab object, and the newly created MuxWindow object.
---@field mux_pane fun(self: PaneObj): nil **DEPRECATED**
---@field pane_id fun(self: PaneObj): number Returns the id number for the pane. The Id is used to identify the pane within the internal multiplexer and can be used when making API calls via wezterm cli to indicate the subject of manipulation.
---@field paste fun(self: PaneObj, text: string): nil Sends the supplied text string to the input of the pane as if it were pasted from the clipboard, except that the clipboard is not involved. If the terminal attached to the pane is set to bracketed paste mode then the text will be sent as a bracketed paste. Otherwise the string will be streamed into the input in chunks of approximately 1KB each.
---@field send_paste fun(self: PaneObj, text: string): nil Sends text to the pane as though it was pasted. If bracketed paste mode is enabled then the text will be sent as a bracketed paste. Otherwise, it will be sent as-is.
---@field send_text fun(self: PaneObj, text: string): nil Sends text to the pane as-is.
---@field split fun(self: PaneObj): PaneObj TODO
---@field tab fun(self: PaneObj): MuxTabObj? the MuxTab that contains this pane. Note that this method can return nil when pane is a GUI-managed overlay pane (such as the debug overlay), because those panes are not managed by the mux layer.
---@field window fun(self: PaneObj): MuxWindowObj Returns the MuxWindow that contains the tab that contains this pane.

---@alias CopyToTarget "Clipboard" | "PrimarySelection" | "ClipboardAndPrimarySelection"

---@class WindowObj
---@field active_key_table fun(self: WindowObj): string Returns a string holding the top of the current key table activation stack, or nil if the stack is empty.  See [Key Tables](https://wezfurlong.org/wezterm/config/key-tables.html) for a detailed example.
---@field active_pane fun(self: WindowObj): PaneObj A convenience accessor for returning the active pane in the active tab of the GUI window. This is similar to [mux_window:active_pane()](https://wezfurlong.org/wezterm/config/lua/window/active_pane.html) but, because it operates at the GUI layer, it can return *Pane* objects for special overlay panes that are not visible to the mux layer of the API.
---@field active_tab fun(self: WindowObj): MuxTabObj A convenience accessor for returning the active tab within the window.
---@field active_workspace fun(self: WindowObj): string Returns the name of the active workspace. This example demonstrates using the launcher menu to select and create workspaces, and how the workspace can be shown in the right status area.
---@field composition_status fun(self: WindowObj): string? Returns a string holding the current dead key or IME composition text, or nil if the input layer is not in a composition state. This is the same text that is shown at the cursor position when composing.
---@field copy_to_clipboard fun(self: WindowObj, text: string, target: CopyToTarget?): nil Puts text into the specified clipboard.
---@field current_event fun(self: WindowObj): string Returns the current event. For now only implemented for mouse events. #TODO: type annotate the Event
---@field effective_config fun(self: WindowObj): WeztermConfig Returns a lua table representing the effective configuration for the Window. The table is in the same format as that used to specify the config in the wezterm.lua file, but represents the fully-populated state of the configuration, including any CLI or per-window configuration overrides.  Note: changing the config table will NOT change the effective window config; it is just a copy of that information.
---@field focus fun(self: WindowObj): nil Attempts to focus and activate the window.
---@field get_appearance fun(self: WindowObj): "Light" | "Dark" | "LightHighContrast" | "DarkHighContrast" Returns the appearance of the window environment.
---@field get_config_overrides fun(self: WindowObj): WeztermConfig Returns a copy of the current set of configuration overrides that is in effect for the window. See `set_config_overrides` for examples!
---@field get_dimensions fun(self: WindowObj): { pixel_width: number, pixel_height: number, dpi: number, is_full_screen: boolean } Returns a Lua table representing the dimensions for the Window.
---@field get_selection_escapes_for_pane fun(self: WindowObj): string Returns the text that is currently selected within the specified pane within the specified window formatted with the escape sequences necessary to reproduce the same colors and styling. This is the same text that `window:get_selection_text_for_pane()` would return, except that it includes escape sequences.
---@field get_selection_text_for_pane fun(self: WindowObj): string Returns the text that is currently selected within the specified pane within the specified window. This is the same text that would be copied to the clipboard if the CopyTo action were to be performed. Why isn't this simply a method of the `pane` object? The reason is that the selection is an attribute of the containing window, and a given pane can potentially be mapped into multiple windows.
---@field is_focused fun(self: WindowObj): boolean Returns true if the window has focus. The update-status event is fired when the focus state changes.
---@field keyboard_modifiers fun(self: WindowObj): { mods: string, leds: string } Returns two values; the keyboard modifiers and the key status leds. Both values are exposed to lua as strings with |-delimited values representing the various modifier keys and keyboard led states: Modifiers - is the same form as keyboard assignment modifiers Leds - possible flags are "CAPS_LOCK" and "NUM_LOCK". Note that macOS doesn't have a num lock concept.
---@field leader_is_active fun(self: WindowObj): boolean Returns true if the Leader Key is active in the window, or false otherwise.
---@field maximize fun(self: WindowObj): nil Puts the window into the maximized state. Use `window:restore()` to return to the normal/non-maximized state.
---@field mux_window fun(self: WindowObj): MuxWindowObj Returns the MuxWindow representation of this window.
---@field perform_action fun(self: WindowObj, key_assignment: KeyAssignment, pane: PaneObj): nil Performs a key assignment against the window and pane. There are a number of actions that can be performed against a pane in a window when configured via the keys and mouse configuration options. This method allows your lua script to trigger those actions for itself.
---@field restore fun(self: WindowObj): nil Restores the window from the maximized state. See also: `window:maximize()`.
---@field set_config_overrides fun(self: WindowObj, overrides: WeztermConfig): nil Changes the set of configuration overrides for the window. The config file is re-evaluated and any CLI overrides are applied, followed by the keys and values from the overrides parameter. This can be used to override configuration on a per-window basis; this is only useful for options that apply to the GUI window, such as rendering the GUI. Each call to `window:set_config_overrides` will emit the `window-config-reloaded` event for the window. If you are calling this method from inside the handler for `window-config-reloaded` you should take care to only call `window:set_config_overrides` if the actual override values have changed to avoid a loop.
---@field set_inner_size fun(self: WindowObj, width: number, height: number): nil Resizes the inner portion of the window (excluding any window decorations) to the specified width and height.
---@field set_left_status fun(self: WindowObj, string: string): nil This method can be used to change the content that is displayed in the tab bar, to the left of the tabs. The content is displayed left-aligned and will take as much space as needed to display the content that you set; it will not be implicitly clipped. The parameter is a string that can contain escape sequences that change presentation. It is recommended that you use wezterm.format to compose the string.
---@field set_position fun(self: WindowObj, x: number, y: number): nil Repositions the top-left corner of the window to the specified x, y coordinates. Note that Wayland does not allow applications to directly control their window placement, so this method has no effect on Wayland.
---@field set_right_status fun(self: WindowObj, string: string): nil This method can be used to change the content that is displayed in the tab bar, to the right of the tabs and new tab button. The content is displayed right-aligned and will be clipped from the left edge to fit in the available space. The parameter is a string that can contain escape sequences that change presentation. It is recommended that you use wezterm.format to compose the string.
---@field toast_notification fun(self: WindowObj, title: string, message: string, url: string?, timeout_milliseconds: number): nil Generates a desktop "toast notification" with the specified title and message. An optional url parameter can be provided; clicking on the notification will open that URL. An optional timeout parameter can be provided; if so, it specifies how long the notification will remain prominently displayed in milliseconds. To specify a timeout without specifying a url, set the url parameter to nil. The timeout you specify may not be respected by the system, particularly in X11/Wayland environments, and Windows will always use a fixed, unspecified, duration. The notification will persist on screen until dismissed or clicked, or until its timeout duration elapses.
---@field toggle_fullscreen fun(self: WindowObj): nil Toggles full screen mode for the window.
---@field window_id fun(self: WindowObj): number Returns the id number for the window. The Id is used to identify the window within the internal multiplexer and can be used when making API calls via wezterm cli to indicate the subject of manipulation.
