To get set up as a devloper,

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
 * from dash root run the following to get your gems installed:
    * `gem install bundle`
    * `bundle install`
 * run command `cp "config/instance.rb.example" "config/instance.rb"` to configure default instance
 * populate the db with `rake seed`
 * start the app with `ruby app.rb`
