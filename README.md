# Consumer

This Ruby app implements the MVC pattern including continuous integration and deployment via Codeship. Please make sure tests are running before committing. HTML can be found in the _public/_ dir.

We are using the [Github flow](https://guides.github.com/introduction/flow/) for contribution. [See more details here](https://github.com/jaSunny/ImmoDash/wiki).

## Branch Overview

| Branch 	| Deployment to  	| Status | Description |
|---	|---	|---  |---   |
| master  	|  [consumer.vm-mpws2016hp1-01.eaalab.hpi.uni-potsdam.de](https://consumer.vm-mpws2016hp1-01.eaalab.hpi.uni-potsdam.de) 	| [ ![Codeship Status for hpi-epic/pricewars-consumer](https://app.codeship.com/projects/96f32950-7824-0134-c83e-5251019101b9/status?branch=master)](https://app.codeship.com/projects/180119) | Stable |


## Requirements

* Ruby 2.3
* Rails 4.2


## Deployment

### Rails Backend & Dashboard

First, run

```bundle exec bundle install```

then execute migration

```bundle exec rake db:create && bundle exec rake db:migrate && bundle exec rake db:seed```

afterwards you may start the webserver

```rails s```

and see the results with _http://localhost:3000_ .


## API

[Ref](https://hpi-epic.github.io/masterproject-pricewars/api/)
