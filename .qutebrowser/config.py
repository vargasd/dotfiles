config.load_autoconfig()

c.input.insert_mode.auto_load = True
c.content.javascript.log_message.levels = {
    'qute.*': [],
    '*.tildei.com': ['error'],
    'localhost': ['error'],
}
c.content.javascript.clipboard = 'access'
# c.content.headers.user_agent
c.bindings.key_mappings = {
    '<Ctrl-x>': '<Ctrl-d>'
}

config.unbind('gf') # literally never done this on purpose

# hinting
config.unbind('F')
config.bind('FF', 'hint links tab-fg')
config.bind('Ff', 'hint links tab-bg')
config.bind('Fb', 'hint links tab-bg')
config.bind('Fi', 'hint inputs')
config.bind('Fy', 'hint links yank')
config.bind('Fh', 'hint all hover')
config.bind('Fo', 'hint links fill :open {hint-url}')
config.bind('FO', 'hint links fill :open -t -r {hint-url}')
config.bind('Fr', 'hint --rapid all tab-bg')
config.bind('yf', 'hint links yank')

# homerow vs one-handed hinting
config.set('hints.chars', 'bvcxztrewqgdsa')
# config.bind('tf', 'set hints.chars bvcxztrewqgdsa')
# config.bind('tF', 'set hints.chars ;ahgsldkj')

# scrolling/tab-close
config.bind('x', 'tab-close')
config.bind('U', 'undo')
config.bind('d', 'cmd-run-with-count 15 scroll down')
config.bind('D', 'scroll-page 0 0.2')
config.bind('u', 'cmd-run-with-count 15 scroll up')

# better escape/accidental macros
config.bind('q', 'fake-key <esc>')
config.bind('Q', 'macro-record')

# better tab nav
config.bind('J', 'tab-prev')
config.bind('K', 'tab-next')

# devtools
config.bind('.', 'devtools')
config.bind('>>', 'devtools-focus')
config.bind('>h', 'devtools left')
config.bind('>j', 'devtools down')
config.bind('>k', 'devtools up')
config.bind('>l', 'devtools right')
config.bind('>;', 'devtools window')

# userscripts
config.bind('gp', 'spawn --userscript 1password')
config.bind('gP', 'cmd-set-text -s :spawn --userscript 1password ')
config.bind('gb', 'spawn open -a "Microsoft Edge" {url}')


c.url.searchengines = {
    'DEFAULT':  'https://duckduckgo.com/?q={}',
    'g':  'https://google.com/search?q={}',
}

c.zoom.default = "110%"
c.tabs.position = "bottom"
c.tabs.mousewheel_switching = False
c.fonts.default_size = "16px"
c.fonts.default_family = "JetBrains Mono NL"
c.statusbar.position = "top"
c.window.hide_decoration = True
c.auto_save.session = True
