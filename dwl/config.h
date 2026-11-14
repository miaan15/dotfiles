#include <X11/XF86keysym.h>

#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }
/* appearance */
static const int sloppyfocus               = 1;
static const int bypass_surface_visibility = 0;
static const unsigned int borderpx         = 2;
static const unsigned int snap             = 32; /* snap pixel */
static const int showbar                   = 1; /* 0 means no bar */
static const int barwidth                  = 40;
static const char *fonts[]                 = {"monospace:size=9"};
static const float rootcolor[]             = COLOR(0x000000ff);
static const float fullscreen_bg[]         = {0.0f, 0.0f, 0.0f, 1.0f}; /* You can also use glsl colors */

static unsigned int colors[][3]            = {
	/*               fg          bg          border    */
	[SchemeNorm] = { 0xbbbbbbff, 0x222222ff, 0x444444ff },
	[SchemeSel]  = { 0xeeeeeeff, 0x00940cff, 0x00940cff },
	[SchemeUrg]  = { 0,          0,          0x770000ff },
};

/* tagging */
static char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

/* logging */
static int log_level = WLR_ERROR;

static const char *const autostart[] = {
	"swayidle", "-w", "timeout", "600", "systemctl suspend", NULL,
    "/bin/sh", "-c", "./.local/src/dwl/startup.sh", NULL,
    "easyeffects", "&", NULL,
	NULL /* terminate */
};

static const Rule rules[] = {
    /* app_id             title       tags mask     isfloating   monitor */
    { "zen",              NULL,       1 << 1,       0,           -1 },
    { "discord",          NULL,       1 << 2,       0,           -1 },
    { "obs",              NULL,       1 << 4,       0,           -1 },
};

/* layout(s) */
static const Layout layouts[] = {
    /* symbol     arrange function */
    { "T",      tile },
    { "F",      NULL },
    { "M",      monocle },
};

/* monitors */
static const MonitorRule monrules[] = {
   /* name        mfact  nmaster scale layout       rotate/reflect                x    y */
    { NULL,       0.55f, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
};

/* keyboard */
static const struct xkb_rule_names xkb_rules = {
    .options = NULL,
};

static const int repeat_rate = 25;
static const int repeat_delay = 600;

/* Trackpad */
static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 0;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;

static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;

static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;

static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;

static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;

static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

#define MODKEY WLR_MODIFIER_LOGO

#define TAGKEYS(KEY,TAG) \
    { MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
    { MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
    { MODKEY|WLR_MODIFIER_SHIFT, KEY,            tag,             {.ui = 1 << TAG} }, \
    { MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,KEY,toggletag,  {.ui = 1 << TAG} }

#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *termcmd[] = { "foot", NULL };
static const char *menucmd[] = { "wmenu-run", NULL };

static const char *upvol[]   = { "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+", NULL };
static const char *downvol[] = { "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-", NULL };
static const char *mutevol[] = { "wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle", NULL };

static const char *upbl[]    = { "brightnessctl", "set", "5%+", NULL };
static const char *downbl[]  = { "brightnessctl", "set", "5%-", NULL };

static const Key keys[] = {
    /* modifier                  key                       function          argument */
    { MODKEY,                    XKB_KEY_d,                spawn,            {.v = menucmd} },
    { MODKEY,                    XKB_KEY_t,                spawn,            {.v = termcmd} },

    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_q,                killclient,       {0} },

    { 0,                         XF86XK_AudioRaiseVolume,  spawn,            {.v = upvol} },
    { 0,                         XF86XK_AudioLowerVolume,  spawn,            {.v = downvol} },
    { 0,                         XF86XK_AudioMute,         spawn,            {.v = mutevol} },
    { 0,                         XF86XK_MonBrightnessUp,   spawn,            {.v = upbl} },
    { 0,                         XF86XK_MonBrightnessDown, spawn,            {.v = downbl} },

    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Escape,           quit,             {0} },

    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_b,                togglebar,             {0} },

    { MODKEY,                    XKB_KEY_Right,            focusstack,       {.i = +1} },
    { MODKEY,                    XKB_KEY_Left,             focusstack,       {.i = -1} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Right,            setmfact,         {.f = +0.05f} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Left,             setmfact,         {.f = -0.05f} },
    { MODKEY,                    XKB_KEY_Up,               zoom,             {0} },

    { MODKEY,                    XKB_KEY_f,                togglefullscreen, {0} },
    { MODKEY,                    XKB_KEY_space,            togglefloating,   {0} },

    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_u,                setlayout,        {.v = &layouts[0]} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_i,                setlayout,        {.v = &layouts[1]} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_o,                setlayout,        {.v = &layouts[2]} },

    { MODKEY,                    XKB_KEY_Tab,              view,             {0} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_0,                tag,              {.ui = ~0} },

    { MODKEY,                    XKB_KEY_comma,            focusmon,         {.i = WLR_DIRECTION_LEFT} },
    { MODKEY,                    XKB_KEY_period,           focusmon,         {.i = WLR_DIRECTION_RIGHT} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_comma,            tagmon,           {.i = WLR_DIRECTION_LEFT} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_period,           tagmon,           {.i = WLR_DIRECTION_RIGHT} },

    TAGKEYS(                     XKB_KEY_1,                0),
    TAGKEYS(                     XKB_KEY_2,                1),
    TAGKEYS(                     XKB_KEY_3,                2),
    TAGKEYS(                     XKB_KEY_4,                3),
    TAGKEYS(                     XKB_KEY_5,                4),
    TAGKEYS(                     XKB_KEY_6,                5),
    TAGKEYS(                     XKB_KEY_7,                6),
    TAGKEYS(                     XKB_KEY_8,                7),
    TAGKEYS(                     XKB_KEY_9,                8),

#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_F##n, chvt, {.ui = (n)} }
    { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_BackSpace, quit, {0} },
    CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
    CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

static const Button buttons[] = {
	{ ClkLtSymbol, 0,      BTN_LEFT,   setlayout,      {.v = &layouts[0]} },
	{ ClkLtSymbol, 0,      BTN_RIGHT,  setlayout,      {.v = &layouts[2]} },
	{ ClkTitle,    0,      BTN_MIDDLE, zoom,           {0} },
	{ ClkStatus,   0,      BTN_MIDDLE, spawn,          {.v = termcmd} },
	{ ClkClient,   MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ ClkClient,   MODKEY, BTN_MIDDLE, togglefloating, {0} },
	{ ClkClient,   MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
	{ ClkTagBar,   0,      BTN_LEFT,   view,           {0} },
	{ ClkTagBar,   0,      BTN_RIGHT,  toggleview,     {0} },
	{ ClkTagBar,   MODKEY, BTN_LEFT,   tag,            {0} },
	{ ClkTagBar,   MODKEY, BTN_RIGHT,  toggletag,      {0} },
};

static const Axis axes[] = {
    { 0, 0, NULL, {0} },
};
