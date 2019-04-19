# matrix

require ruby 2.6.3

**Installation**
- clone project ``git clone git@github.com:shartep/matrix.git``
- step into project derictory ``cd matrix``
- copy file with environment variables ``cp .env.example .env`` 
- ensure you have correct ruby version ``ruby -v``, should be ``ruby 2.6.3``
- install bundle gem ``gem install bundler``
- install dependencies ``bundle install``

**Running**
- run application ``ruby app.rb -u neo -p knok_knok``
- execute ``ruby app.rb --help`` for more details

**Specs**
- execute ``rspec`` to run all specs

**Docker**
- build image ``docker build -t matrix .``
- run application ``docker run matrix``
- run specs ``docker run -it matrix rspec``
