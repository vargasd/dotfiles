THEME.git = THEME.git or {}
THEME.git.modified = ui.Style():fg("blue")
THEME.git.deleted = ui.Style():fg("red")
THEME.git.added = ui.Style():fg("green")
THEME.git.ignored = ui.Style():fg("darkgray")

THEME.git.modified_sign = "M"
THEME.git.added_sign = "A"
THEME.git.untracked_sign = "U"
THEME.git.ignored_sign = "I"
THEME.git.deleted_sign = "D"

require("git"):setup()
