# Nexus Clash - Ruby [Archive]

This branch is for historical reference only and does not reflect the code that is in place on www.nexusclash.com
We don't actually even run anything in this language at this time. This is an old and unmaintained public repository
which is here mostly for historical context only. It may have security vulnerabilities and it may not even run
at this point in time. Please don't try to install and run it.

If you are poking around here looking for the active code, thanks for taking an interest! If you'd like to
apply as a Nexus Clash developer, please type out a little something about why you'd like to become a
Nexus Clash developer, what areas you think you'd like to work on, and just a little introduction to yourself
and your Nexus Clash history. Then please drop an admin a forums PM on https://www.nexusclash.com or hop into
our [discord server](https://discord.gg/gf87Umw) and send a DM to any member of the team.

## Historical README.md

To get set up as a developer,

 * start with a clean Linux Mint install: https://www.linuxmint.com/download.php
 * While you're waiting for it to download and/or install, get accounts on YouTrack & GitHub
    * YouTrack: https://youtrack.nexuscla.sh/
    * GitHub: https://github.com/
 * At some point, you'll need to make sure you have an ssh key on GitHub: https://github.com/settings/keys
 * install git from the command line with `sudo apt-get install git`
 * clone the repo with `git clone git@github.com:invisime/NexusClash4.git`
 * follow the rvm install instructions here: https://rvm.io/rvm/install
 * install ruby with `rvm install ruby-2.4`
 * follow the mongodb install instructions here: https://docs.mongodb.com/manual/tutorial/install-mongodb-on-debian/
 * if desired, create a _gemset_ to isolate the gems from the rest of the system
    * `rvm 2.4@nexus --create --ruby-version`
 * from dash root run the following to get your gems installed:
    * `gem install bundle`
    * `bundle install`
 * run command `cp "config/instance.rb.example" "config/instance.rb"` to configure default instance
 * populate the db with `rake seed` and `rake fixtures`
 * start the app with `ruby app.rb`
