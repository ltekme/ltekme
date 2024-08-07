# What is API

[↩️ go back](../../README.md)

## Table of contents

- [What is API](#what-is-api)
  - [Table of contents](#table-of-contents)
  - [API in real life](#api-in-real-life)
    - [Example](#example)
  - [Tipical API setup](#tipical-api-setup)
    - [Example](#example-1)
  - [Common API setup on AWS](#common-api-setup-on-aws)
    - [Example](#example-2)
  - [Reverse Proxy](#reverse-proxy)

When it comes to API, there is your api in your code and there is your API that runs over the netork. Not going into details, [here](https://aws.amazon.com/what-is/api/) is an article covering API from aws. Over here we are goint to talk about API over network. These includes HTTP, REST, WebSocket.

## API in real life

You can think of the API as the interface between you and the kitchin in a restaurant. In the kitchen there is a screen that tells the chefs what you ordered and you have you phone clicking the button telling the resaurant what you want to order. The things between you and the kitchen can be understand as an API. You give instruction to thge kitchen the kitchen process your request and comes out with the resault, the food you ordered.

### Example

![API In Real Life Example](images/api-illistration-IRL.drawio.png)

In the above example, we can see The customer placing an order.

Following the blue arrows

1. The customer place an order, and sends it to the restaurant.
2. The restaurant hands the order to the kitchen.

Following the red arrows

1. The kitchen finishes the order, hands it back to the restaurant.
2. The restaurant hands the order to the customer

In this case, the resaurant the the API. The customer is the web page you see on your broswer. The kitchen is the backend servers.

## Tipical API setup

In most cases API setup is really simple. When an application is monolithic, there may not be a "Restaurant" in the chain.

### Example

![Typical API Setup Example](images/api-illistration-tipical.drawio.png)

In the above example, we can see users querying a sever.

Following the blue arrows

1. The user make a request to the server asking to get the info of the user "karl"

Following the red arrows

1. The server response back with the user info requested.

In this case, the server can in interperated as the API as well.

## Common API setup on AWS

Because of how elastic and dynamic AWS can be. API on aws can a bit more complicated than monolithic server archecture when going for [cloud native](https://aws.amazon.com/what-is/cloud-native/). But the concept is still the same, user make a request to an API, the API resonse back with the resault.

### Example

![Common API Setup on aws](images/api-illistration-aws.drawio.png)

In the above image we can see the user making a requst to an API.

Following the blue arrows

1. The user make a request to API gateway.
2. The API gateway determin where to send the request to based on the integration setup
3. The request is then send to the integration to get processed. In this case, lambda

Following the red arrows

1. After the integration, complete the request and response with the resault
2. The request resault is send back to API gateway
3. Then request resault is send back to the user.

## Reverse Proxy

Now that I am laying out what I know about API, API gateway is really simular to a reverse proxy.

[↩️ back to article](../../README.md)
