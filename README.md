# Consumer

This repository contains the Consumer-component of the Price Wars simulation. The consumer represents the costumers arriving at the marketplace and buying products. How often and which products they buy is decided based on custom consumer-behaviors that can be configured and changed.

The consumer is realized using a Ruby-app implementing the MVC pattern including continuous integration and deployment via Codeship. Please make sure tests are running before committing.

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

The consumer is written in Rails. Ensure to have the following components installed and set up on your computer:

* Ruby 2.3
* Rails 4.2

## Setup

After cloning the repo, install the necessary dependencies with `bundle exec bundle install`.

Afterwards you may start the webserver with `rails s -b 0.0.0.0` where the ENV variables PRICEWARS_MARKETPLACE_URL and PRICEWARS_PRODUCER_URL point to the actual path of the marketplace and the producer.

If all worked out, see the results at _ http://localhost:3000 _ .

## Configuration

Currently, two ENV params are needed:
* PRICEWARS_PRODUCER_URL
* PRICEWARS_MARKETPLACE_URL

If they are not set, the deployed VM urls are automatically used.

One may simple export them to the related system:

```
export PRICEWARS_MARKETPLACE_URL='http://vm-mpws2016hp1-04.eaalab.hpi.uni-potsdam.de:8080/marketplace'
export PRICEWARS_PRODUCER_URL='http://vm-mpws2016hp1-03.eaalab.hpi.uni-potsdam.de'
```

## Concept

The consumer is defined via behaviors which are implemented in *lib/buyingbehavior.rb*. All available behaviors are included and exposed with their default settings and description in *app/controllers/behavior_controller.rb* .

### Consumer Behaviors

Via settings, the distribution across those available behaviors is defined as percentage. In the consumer logic then, each behavior is [called and executed](https://github.com/hpi-epic/pricewars-consumer/blob/master/app/controllers/setting_controller.rb#L127) dynamically based on the provided behavior method name and its distribution.

#### Existing behaviors

* [buy_first](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L24)

> buying the first item out of the marketplace offer list

* [buy_random](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L28)

> buying a random item out of the marketplace offer list

* [buy_cheap](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L32)

> buying the cheapest item out of the marketplace offer list

* [buy_n_cheap(n)](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L36)

> buying the n-cheapest item out of the marketplace offer list

* [buy_second_cheap](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L45)

> buying the second cheapest item out of the marketplace offer list

* [buy_third_cheap](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L49)

> buying the third cheapest item out of the marketplace offer list

* [buy_cheap_and_prime](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L53)

> buying the cheapest item out of the marketplace offer list filtered by prime

* [buy_expensive](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L57)

> buying the most expensive item out of the marketplace offer list

* [buy_cheapest_best_quality_with_prime](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L61)

> buying the cheapest item with the best possible quality out of
the marketplace offer list filtered by prime

* [buy_cheapest_best_quality](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L66)

> buying the cheapest item with the best possible quality out of the marketplace offer list

* [buy_sigmoid_distribution_price](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L72)

> buying items with sigmoid distribution around twice the producer price from the marketplace offer list

* [buy_logit_coefficients](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L94)

> buying items based on the provided logit coefficients from the marketplace offer list

#### Sigmoid distribution behavior in detail

The [sigmoid distribution](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L72) behavior realizes a sigmoid(-x) distribution of consumer purchases over [twice the producer price](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L82) which is used as mean.

The following figures delineate the sigmoid distribution where y is the probability of purchase and x the price of an offer. In the given example, the mean is twice the producer price (15€) therefore 30€.

![alt tag](/public/doc/sigmoid.png?raw=true)
![alt tag](/public/doc/sigmoid_2.png?raw=true)

Consequently, the cheaper the offer is, the higher the purchase probability; the higher the price the lower the purchase probability.

#### Logistic regression behavior in detail

The [logit behavior](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L94) implements a logistic regression with feature scaling and calculates for each offer the buying probability based on the feature coefficients provided in the behavior settings. Based on this buying probability for each offer, the consumer will actually choose an offer to buy.
In this way, potential consumer behavior can be learned on real world data and imitated in the simulation solution.

Logistic regression is a regression model where the dependent variable -- in our case the selling of an offer -- is categorical. This categorization outcome must be discrete and should be dichotomous in nature simply expressed by a boolean whether a purchase happened or not. To determine this, this behavior consumes features and their coefficients can be altered within runtime and will then be applied to the next calculation iteration taking place. The describing hashmap of features and their coefficients contains only available features which are already implemented otherwise they will be ignored.

The default settings for the logit behavior holds the following settings:

```
{
   "coefficients":{
      "intercept":-6.6177961,
      "price_rank":0.2083944,
      "amount_of_all_competitors":0.253481,
      "average_price_on_market":-0.0079326,
      "quality_rank":-0.1835972
   }
}
```

which were extracted from a real world use case provided by a big book retail company.
For deeper insights in the concepts of logistic regression, the reader is kindly referred to [DW Hosmer Jr et al. work](https://www.researchgate.net/profile/Andrew_Cucchiara/publication/261659875_Applied_Logistic_Regression/links/542c7eff0cf277d58e8c811e/Applied-Logistic-Regression.pdf).

#### Adding new features for logit behaviors

For adding a new feature for the logit behavior, one simply needs to extend the logic in *lib\features.rb*. In particular, one may implement a new method and include it in the switch case starting in L9.

#### Adding new behaviors

For adding a new buying behavior, one simply needs to add the buying logic as method in *lib/buyingbehavior.rb* starting with the prefix *buy_* returning the item (only one!), which is supposed to be bought.

If wished, *validate_max_price()* can be used to validate whether the selected item comply the settings (e.g. max price).

If the new behavior has individual settings, they can be accessed via *@behavior_settings*.

All available product (ids) are included in *$products* and *$items* contains all offer items for one preselected product category. This preselection is done during the [initialization](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L26) and can be realized either by selecting a random product or by selecting a product based on the provided product popularity via settings.

```
# OPTIONS: select_random_product | select_based_on_product_popularity
```

Keep in mind to add the new behavior with its description, default settings and method name in the *app/controller/behavior_controller.rb* in the way that it will be included and listed in the default setting return value.


### Selection of one product & its market situation

The current implementation supports an even distributed selection of items (random selection). Additionally, one may define product popularity via the consumer settings which is evaluated instead of a random distribution.

The relative selection method can be defined in the [initialize method of the buyingbehavior.rb](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L19) by either using *select_random_product* or  *select_based_on_product_popularity* (see comments).

## Host entries

When working on the provided VMs make sure to including DNS routing in the local /etc/hosts file. We experienced a lot of issues with TCP connection timeouts if those are not set. Also within the CI & CD pipeline in the way that github was not reachable due to connection timeouts.
Different resolvers were tried out, however, the only working solution is to expand the host file,

```
/etc/hosts

# Reducing DNS lookups by assigning statically marketplace host
192.168.31.90 vm-mpws2016hp1-04.eaalab.hpi.uni-potsdam.de
192.168.31.89 vm-mpws2016hp1-03.eaalab.hpi.uni-potsdam.de
```

## Sample Configuration

Like described in the [API documentation](https://hpi-epic.github.io/masterproject-pricewars/), a sample setting json for the consumer looks like the following:

> HTTP GET http://localhost:3000/setting/

```
{
   "consumer_per_minute":100.0,
   "amount_of_consumers":1,
   "probability_of_buy":100,
   "min_buying_amount":1,
   "max_buying_amount":1,
   "min_wait":0.1,
   "max_wait":2,
   "behaviors":[
      {
         "name":"first",
         "description":"I am buying the first possible item",
         "settings":{

         },
         "settings_description":"Behavior settings not necessary",
         "amount":9
      },
      {
         "name":"random",
         "description":"I am buying random items",
         "settings":{

         },
         "settings_description":"Behavior settings not necessary",
         "amount":9
      },
      {
         "name":"cheap",
         "description":"I am buying the cheapest item",
         "settings":{

         },
         "settings_description":"Behavior settings not necessary",
         "amount":9
      },
      {
         "name":"expensive",
         "description":"I am buying the most expensive item",
         "settings":{

         },
         "settings_description":"Behavior settings not necessary",
         "amount":9
      },
      {
         "name":"cheap_and_prime",
         "description":"I am buying the cheapest item which supports prime shipping",
         "settings":{

         },
         "settings_description":"Behavior settings not necessary",
         "amount":9
      },
      {
         "name":"cheapest_best_quality",
         "description":"I am buying the cheapest best quality available.",
         "settings":{

         },
         "settings_description":"Behavior settings not necessary",
         "amount":9
      },
      {
         "name":"cheapest_best_quality_with_prime",
         "description":"I am buying the cheapest best quality available which supports prime.",
         "settings":{

         },
         "settings_description":"Behavior settings not necessary",
         "amount":9
      },
      {
         "name":"second_cheap",
         "description":"I am buying the second cheapest item",
         "settings":{

         },
         "settings_description":"Behavior settings not necessary",
         "amount":9
      },
      {
         "name":"third_cheap",
         "description":"I am buying the third cheapest item",
         "settings":{

         },
         "settings_description":"Behavior settings not necessary",
         "amount":9
      },
      {
         "name":"sigmoid_distribution_price",
         "description":"I am with sigmoid distribution on the price regarding the producer prices",
         "settings":{

         },
         "settings_description":"Behavior settings not necessary",
         "amount":9
      },
      {
         "name":"logit_coefficients",
         "description":"I am with logit coefficients",
         "settings":{
            "coefficients":{
               "intercept":-6.6177961,
               "price_rank":0.2083944,
               "amount_of_all_competitors":0.253481,
               "average_price_on_market":-0.0079326,
               "quality_rank":-0.1835972
            }
         },
         "settings_description":"Key Value map for Feature and their coeffient",
         "amount":9
      }
   ],
   "timeout_if_no_offers_available":2,
   "timeout_if_too_many_requests":30,
   "max_buying_price":80,
   "debug":true,
   "producer_url":"http://vm-mpws2016hp1-03.eaalab.hpi.uni-potsdam.de",
   "product_popularity":{
      "1":25.0,
      "2":25.0,
      "3":25.0,
      "4":25.0
   },
   "marketplace_url":"http://vm-mpws2016hp1-04.eaalab.hpi.uni-potsdam.de:8080/marketplace"
}
```

## Source Code

Detailed information regarding method and function usage and behavior can be found within the [public/doc/ directory](public/doc/index.html) of this repository or within the deployed service by [clicking here](http://vm-mpws2016hp1-01.eaalab.hpi.uni-potsdam.de/doc/index.html).
