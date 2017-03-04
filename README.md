# Consumer

This Ruby app implements the MVC pattern including continuous integration and deployment via Codeship. Please make sure tests are running before committing.

We are using the [Github flow](https://guides.github.com/introduction/flow/) for contribution.

The meta repository containing general information can be found [here](https://github.com/hpi-epic/masterproject-pricewars)

## Application Overview

| Repo | Branch 	| Deployment to  	| Status | Description |
|--- |---	|---	|---  |---   |
| [UI](https://github.com/hpi-epic/pricewars-mgmt-ui) | master  	|  [vm-mpws2016hp1-02.eaalab.hpi.uni-potsdam.de](http://vm-mpws2016hp1-02.eaalab.hpi.uni-potsdam.de) 	| [ ![Codeship Status for hpi-epic/pricewars-mgmt-ui](https://app.codeship.com/projects/d91a8460-88c2-0134-a385-7213830b2f8c/status?branch=master)](https://app.codeship.com/projects/184009) | Stable |
| [Consumer](https://github.com/hpi-epic/pricewars-consumer) | master  	|  [vm-mpws2016hp1-01.eaalab.hpi.uni-potsdam.de](http://vm-mpws2016hp1-01.eaalab.hpi.uni-potsdam.de) | [ ![Codeship Status for hpi-epic/pricewars-consumer](https://app.codeship.com/projects/96f32950-7824-0134-c83e-5251019101b9/status?branch=master)](https://app.codeship.com/projects/180119) | Stable |
| [Producer](https://github.com/hpi-epic/pricewars-producer) | master  	|  [vm-mpws2016hp1-03eaalab.hpi.uni-potsdam.de](http://vm-mpws2016hp1-03.eaalab.hpi.uni-potsdam.de) | [ ![Codeship Status for hpi-epic/pricewars-producer](https://app.codeship.com/projects/0328e450-88c6-0134-e3d6-7213830b2f8c/status?branch=master)](https://app.codeship.com/projects/184016) | Stable |
| [Marketplace](https://github.com/hpi-epic/pricewars-marketplace) | master  	|  [vm-mpws2016hp1-04.eaalab.hpi.uni-potsdam.de/marketplace](http://vm-mpws2016hp1-04.eaalab.hpi.uni-potsdam.de/marketplace/offers) 	| [ ![Codeship Status for hpi-epic/pricewars-marketplace](https://app.codeship.com/projects/e9d9b3e0-88c5-0134-6167-4a60797e4d29/status?branch=master)](https://app.codeship.com/projects/184015) | Stable |
| [Merchant](https://github.com/hpi-epic/pricewars-merchant) | master  	|  [vm-mpws2016hp1-06.eaalab.hpi.uni-potsdam.de/](http://vm-mpws2016hp1-06.eaalab.hpi.uni-potsdam.de/) 	| [ ![Codeship Status for hpi-epic/pricewars-merchant](https://app.codeship.com/projects/a7d3be30-88c5-0134-ea9c-5ad89f4798f3/status?branch=master)](https://app.codeship.com/projects/184013) | Stable |
| [Kafka RESTful API](https://github.com/hpi-epic/pricewars-kafka-rest) | master  	|  [vm-mpws2016hp1-05.eaalab.hpi.uni-potsdam.de](http://vm-mpws2016hp1-05.eaalab.hpi.uni-potsdam.de) 	|  [ ![Codeship Status for hpi-epic/pricewars-kafka-rest](https://app.codeship.com/projects/f59aa150-92f0-0134-8718-4a1d78af514c/status?branch=master)](https://app.codeship.com/projects/186252) | Stable |


## Requirements

* Ruby 2.3
* Rails 4.2

## Folder Structure

```
|-- app
|   `-- controllers
|       `-- concerns
|-- bin
|-- config
|   |-- deploy
|   |-- environments
|   |-- initializers
|   `-- locales
|-- db
|-- doc
|   |-- css
|   `-- js
|-- lib
|   |-- assets
|   |-- capistrano
|   |   `-- tasks
|   `-- tasks
|-- log
|-- public
|-- spec
|   `-- controllers
|-- tmp
|   |-- cache
|   |   `-- assets
|   |-- pids
|   |-- sessions
|   `-- sockets
`-- vendor

```

## Deployment

Clone the repo with

```
git clone https://github.com/hpi-epic/pricewars-consumer
```

### Rails Backend

First, install dependencies

```
bundle exec bundle install
```

afterwards you may start the webserver

```
rails s -b 0.0.0.0
```
where as the ENV var PRICEWARS_MARKETPLACE_URL and PRICEWARS_PRODUCER_URL point to the actual path of the marketplace and the producer.

If all worked out, see the results with _ http://localhost:3000 _ .


## Documentation

### API

The reader will politely be referred to the swagger.io [API documentation](https://hpi-epic.github.io/masterproject-pricewars/api/).

### Source Code

Detailed information regarding method and function usage and behavior can be found within the [doc/ directory](doc/index.html) of this repository.

### ENV parameter

Currently, two ENV params are needed:
* PRICEWARS_PRODUCER_URL
* PRICEWARS_MARKETPLACE_URL

If they are not set, the deployed VM urls are automatically used.

One may simple export them to the related system:

```
export PRICEWARS_MARKETPLACE_URL='http://vm-mpws2016hp1-04.eaalab.hpi.uni-potsdam.de:8080/marketplace'
export PRICEWARS_PRODUCER_URL='http://vm-mpws2016hp1-03.eaalab.hpi.uni-potsdam.de'
```

### Concept

The consumer is defined via behaviors which are implemented in *lib/buyingbehavior.rb*. All available behaviors are included and exposed with their default settings and description in *app/controllers/behavior_controller.rb* .

#### Consumer Behaviors

Via settings, the distribution across those available behaviors is defined as percentage. In the consumer logic then, each behavior is [called and executed](https://github.com/hpi-epic/pricewars-consumer/blob/master/app/controllers/setting_controller.rb#L142) dynamically based on the provided behavior method name and its distribution.

##### Existing new behaviors

* [buy_first](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L29)

> buying the first item out of the marketplace offer list

* [buy_random](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L33)

> buying a random item out of the marketplace offer list

* [buy_cheap](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L37)

> buying the cheapest item out of the marketplace offer list

* [buy_n_cheap(n)](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L41)

> buying the n-cheapest item out of the marketplace offer list

* [buy_second_cheap](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L50)

> buying the second cheapest item out of the marketplace offer list

* [buy_third_cheap](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L54)

> buying the third cheapest item out of the marketplace offer list

* [buy_cheap_and_prime](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L58)

> buying the cheapest item out of the marketplace offer list filtered by prime

* [buy_expensive](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L62)

> buying the most expensive item out of the marketplace offer list

* [buy_cheapest_best_quality_with_prime](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L66)

> buying the cheapest item with the best possible quality out of
the marketplace offer list filtered by prime

* [buy_cheapest_best_quality](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L71)

> buying the cheapest item with the best possible quality out of the marketplace offer list

* [buy_sigmoid_distribution_price](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L77)

> buying items with sigmoid distribution around twice the producer price from the marketplace offer list

* [buy_logit_coefficients](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L99)

> buying items based on the provided logit coefficients from the marketplace offer list


##### Adding new behaviors

For adding a new buying behavior, one simply needs to add the buying logic as method in *lib/buyingbehavior.rb* starting with the prefix *buy_* returning the item (only one!), which is supposed to be bought.

If wished, *validate_max_price()* can be used to validate whether the selected item comply the settings (e.g. max price).

If the new behavior has individual settings, they can be accessed via *@behavior_settings*.

All available product (ids) are included in *$products* and *$items* contains all offer items for one preselected product category. This preselection is done during the [initialization](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L26) and can be realized either by selecting a random product or by selecting a product based on the provided product popularity via settings.

```
# OPTIONS: select_random_product | select_based_on_product_popularity
```

Keep in mind to add the new behavior with its description, default settings and method name in the *app/controller/behavior_controller.rb* in the way that it will be included and listed in the default setting return value.

#### Selection of one product & its market situation

The current implementation supports an even distributed selection of items (random selection). Additionally, one may define product popularity via the consumer settings which is evaluated instead of a random distribution.

The relative selection method can be defined in the [initialize method of the buyingbehavior.rb](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L25) by either using *select_random_product* or  *select_based_on_product_popularity* (see comments).
