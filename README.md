rdm
===

A WebKit GTK and Ruby based display manager. 

Installing
==========

**ROOT Required - either sudo su or prefix all commands with sudo.** 

* git clone in /root

* cp rdm.conf.example to /etc/rdm/rdm.conf

* cp initscript to /etc/init.d/rdm

* run update-rc.d rdm defaults

* apt-get install ruby-shadow

* gem build rdm.gemspec

* gem install rdm-0.1.0.gem

* edit /etc/X11/default-display-manager to read /usr/local/bin/rdm

Changing Theme
==============

All themeing is done in html, erb and CSS. 

All the session types from /usr/share/xsessions are passed through 
to the erb in the variable sessions.

Special Javascript functions include: 

login(username, password) - called by the panel to perform a login
reboot() - called to perform a reboot
shutdown() - called to perform a shutdown

All panels must implement a version of these JS functions: 

session() - called to get the currently selected session. 
message(msg, type) - called to make the panel display a message 
clean() - called to empty/reset the panel 

Other than those functions anything you can do in webkit, you can do to theme RDM :D 

The main page must be called login.html.erb 

In order to use a different theme, change the themepath variable in /etc/rdm/rdm.conf to
point at the theme directory.


Default Theme
=============

The default theme Aurora is basic example of how to theme RDM. 
The background image can be found on deviantart.com here http://www.deviantart.com/art/Aurora-63979267.
