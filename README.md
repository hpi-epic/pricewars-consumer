# Consumer

This repository contains the Consumer-component of the Price Wars simulation. The consumer represents the costumers arriving at the marketplace and buying products. How often and which products they buy is decided based on custom consumer-behaviors that can be configured and changed.

The consumer is realized using a Ruby-app implementing the MVC pattern. Please make sure tests are running before committing.

The meta repository containing general information can be found [here](https://github.com/hpi-epic/pricewars)

## Application Overview

| Repo |
|--- |
| [UI](https://github.com/hpi-epic/pricewars-mgmt-ui) |
| [Consumer](https://github.com/hpi-epic/pricewars-consumer) |
| [Producer](https://github.com/hpi-epic/pricewars-producer) |
| [Marketplace](https://github.com/hpi-epic/pricewars-marketplace) |
| [Merchant](https://github.com/hpi-epic/pricewars-merchant) |
| [Kafka RESTful API](https://github.com/hpi-epic/pricewars-kafka-rest) |

## Requirements

The consumer is written in Rails. Ensure to have the following components installed and set up on your computer:

* Ruby 2.3
* Rails 4.2

## Setup

After cloning the repo, install the necessary dependencies with `bundle exec bundle install`.

Afterwards you may start the webserver with `rails s -b 0.0.0.0` where the ENV variable PRICEWARS_MARKETPLACE_URL should point to the marketplace server.

If all worked out, see the results at http://localhost:3000

## Configuration

The marketplace url is configured in the environment variable `PRICEWARS_MARKETPLACE_URL`.
If it is not set, a default url `http://marketplace:8080` is used.
The environment variable can be set with:

```
export PRICEWARS_MARKETPLACE_URL='http://your_hostname:8080'
```

## Concept

The consumer is defined via behaviors which are implemented in *lib/buyingbehavior.rb*. All available behaviors are included and exposed with their default settings and description in *app/controllers/behavior_controller.rb* .

### Consumer Behaviors

The consumer chooses a random buying behavior for each buying decision.
The buying behaviors have weights that determine how frequently each behavior is chosen.

The implemented behaviors are:

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

* [buy_logit_coefficients](https://github.com/hpi-epic/pricewars-consumer/blob/master/lib/buyingbehavior.rb#L94)

> buying items based on the provided logit coefficients from the marketplace offer list

* buy_prefer_cheap

> Buys with highest probability the cheapest product, but also has a chance to buy more expensive products. The probabilities are calculated with a modified market power formula.

* buy_scoring_based

> Scores each offer based on price and quality. A lower score is better.
The consumer buys from the best offer if its score is below or equal to the consumer's willingness to buy.
The importance of price and quality and the willingness varies for each consumer (visit).

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

A buying behavior chooses at most one offer from all available offers.

Keep in mind to add the new behavior with its description, default settings and method name in the *app/controller/behavior_controller.rb* in the way that it will be included and listed in the default setting return value.

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

Detailed information regarding method and function usage and behavior can be found within the [public/doc/ directory](public/doc/index.html) of this repository.
