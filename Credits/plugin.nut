/*
Arcade credits mode Plugin for attractplus version 1.0 by ecco.
This is a virtual arcade credit system to start games in AM+.

Made to add function's for mapping your arcade cabnet with am+ to a coin door for personal use or gain! 
one quarter at a time

 Buttons need to be assinged in controls in the configure > Controls for:
 custom1 add coins / credit     ------with coin sound
 custom2 del coins / credit     ------with depletion sound
 custom3 toggle between credits mode and freeplay mode.  ----with now on now off sounds
 their are 6 locations on the screen that it can be displayed
 in the option: top C L R or bottom C L R
 Pulse option: makes the credit text fade in and out without need for a modual 
*/
// start

class UserConfig </ help="Arcade credits attractplus" />
{
    </ label="Position",
       options="Top-Left,Top-Right,Top-Center,Bottom-Left,Bottom-Right,Bottom-Center",
       help="Move the credit text to a screen location that u want",
       order=1 />
    My_Location="Top-Center";

    </ label="Pulse Effect on off",
       options="Yes,No",
       help="Make the credits text fade in and out",
       order=2 />
       Pulse_Effect="No";
}
class VirtualCredits
{
    virtual_credits = 0;
    freeplay = false;
    credit_text = null;
    snd_coin = null;
    snd_subtract = null;
    snd_nocoins = null;
    snd_modolivre = null;
    snd_modocomercial = null;
    pulse_enabled = false;
    constructor()
    {
        local config = fe.get_config();
        local loc = config["My_Location"];
        pulse_enabled = (config["Pulse_Effect"] == "Yes");

        local w = 400;     
        local h = 50;
        local margin = 3;  
        local x = 0;
        local y = 0;
        local text_align = Align.Centre;

        if (loc.find("Left") != null)
        {
            x = margin;
            text_align = Align.Left;
        }
        else if (loc.find("Right") != null)
        {
            x = fe.layout.width - w - margin;
            text_align = Align.Right;
        }
        else
        {
            x = (fe.layout.width - w) / 2;
            text_align = Align.Centre;
        }
        if (loc.find("Bottom") != null)
            y = fe.layout.height - h - margin;
        else
			y = margin;
        credit_text = fe.add_text("CREDITS : 0", x, y, w, h);
        credit_text.zorder = 10000;
        credit_text.align = text_align;
        credit_text.set_rgb(200, 200, 70);
        credit_text.charsize = 24;w
        credit_text.font = "Geforce Bold.ttf";

        snd_coin          = fe.add_sound("coin.wav");
        snd_subtract      = fe.add_sound("subtraicoin.wav");
        snd_nocoins       = fe.add_sound("nocoins.wav");
        snd_modolivre     = fe.add_sound("modolivre.wav");
        snd_modocomercial = fe.add_sound("modocomercial.wav");

        fe.add_signal_handler(this, "credit_signal_handler");

        if (pulse_enabled)
            fe.add_ticks_callback(this, "pulse");
    }
    function pulse(ttime)
    {
        local period = 2000.0;                                   
        local t = (sin(ttime / period * 2 * PI) + 1.0) / 2.0;    

        credit_text.alpha = (20 + 200 * t).tointeger();     
    }

    function play_sound(snd)
    {
        snd.playing = false;
        snd.playing = true;
    }
    function show_credits()
    {
        if (freeplay)
        {
            credit_text.msg = "FREE - PLAY";
            credit_text.set_rgb(70, 200, 70);
        }
        else
        {
            credit_text.msg = "CREDITS : " + virtual_credits;
            credit_text.set_rgb(200, 200, 70);
        }
    }
    function show_no_coins()
    {
        credit_text.msg = "INSERT COIN TO PLAY!";
        credit_text.set_rgb(255, 250, 0);
        play_sound(snd_nocoins);
    }
    function credit_signal_handler(signal_str)
    {
        if (signal_str == "custom3")
        {
            freeplay = !freeplay;
            show_credits();

            if (freeplay)
                play_sound(snd_modolivre);
            else
                play_sound(snd_modocomercial);
            return true;
        }
        if (freeplay)
        {
            if (signal_str == "custom1" || signal_str == "custom2")
                return true;

            return false;
        }
        if (signal_str == "custom1")
        {
            virtual_credits++;
            show_credits();
            play_sound(snd_coin);
            return true;
        }
        if (signal_str == "custom2")
        {
            if (virtual_credits > 0)
            {
                virtual_credits--;
                show_credits();
                play_sound(snd_subtract);
            }
            else
            {
                show_no_coins();
            }
            return true;
        }
        if (signal_str == "select")
        {
            if (virtual_credits > 0)
            {
                virtual_credits--;
                show_credits();
                return false;
            }
            else
            {
                show_no_coins();
                return true;
            }
        }
        return false;
    }
}
fe.plugin["VirtualCredits"] <- VirtualCredits();
// end 

