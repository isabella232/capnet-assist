/*
* Copyright 2016-2021 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA.
*/

public class Captive.Application : Gtk.Application {
    private string? debug_url = null;

    public static Settings settings;

    public Application () {
        Object (application_id: "io.elementary.capnet-assist", flags: ApplicationFlags.HANDLES_COMMAND_LINE);
    }

    static construct {
        settings = new Settings ("io.elementary.desktop.capnet-assist");
    }

    public override void activate () {
        if (!settings.get_boolean ("enabled")) {
            quit ();
            return;
        }

        if (!is_busy) {
            mark_busy ();

            var browser = new CaptiveLogin (this);
            browser.start (debug_url);
        }
    }

    public override int command_line (ApplicationCommandLine command_line) {
        OptionEntry[] options = new OptionEntry[1];
        options[0] = { "url", 'u', 0, OptionArg.STRING, ref debug_url, _("Load this address in the browser window"), _("URL") };

        string[] args = command_line.get_arguments ();

        try {
            var opt_context = new OptionContext ("- OptionContext example");
            opt_context.set_help_enabled (true);
            opt_context.add_main_entries (options, null);
            unowned string[] tmp = args;
            opt_context.parse (ref tmp);
        } catch (OptionError e) {
            command_line.print ("error: %s\n", e.message);
            command_line.print ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
            return -1;
        }

        activate ();

        return 0;
    }

    public static int main (string[] args) {
        Environment.set_application_name ("captive-login");
        Environment.set_prgname ("captive-login");

        var application = new Captive.Application ();

        return application.run (args);
    }
}
