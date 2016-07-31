To get set up as a devloper,

 * start with a clean Linux Mint install: https://www.linuxmint.com/download.php
 * While you're waiting for it to download and/or install, get accounts on YouTrack & GitLab
    * YouTrack: https://youtrack.nexuscla.sh/
    * GitLab: https://source.windrunner.mx/
 * At some point, you'll need to make sure you have an ssh key on gitlab: https://source.windrunner.mx/profile/keys
 * install git from the command line with `sudo apt-get install git`
 * clone the repo with `git clone git@source.windrunner.mx:nexus-clash/dash.git`
 * follow the rvm install instructions here: https://rvm.io/rvm/install
 * install ruby with `rvm install jruby`
 * follow the mongodb install instructions here: https://docs.mongodb.com/manual/tutorial/install-mongodb-on-debian/
 * from dash root run the following to get your gems installed:
    * `gem install bundle`
    * `bundle install`
 * populate the db with `rake seed`
 * start the app with `ruby app.rb`
