# Exploring Lambda, APIGW, SQS, SNS and ReactJS

## background

When I was studying for the AWS-SAA exam I came a cross [`decoupling`](https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-integrating-microservices/decouple-messaging.html) a lot.

From a monolith ec2 instence to s3 for static content and lambda function to handle request. If a lambda function handle too many task or takes too long to complete or may not be able to complete, we decouple it with SQS. I know I know why and when to use SQS, but in practice, how does it actually work? I've want to play with it for a while now, but I havn't been able to find a usecase for myself.

### The problem

Last month one of my friend from highschool draged sme to chat with his friends to talk about an idea he had. The project is an online platform that allow it's users to post something, someone resonse and something something, not going into details, but one of the problem we encounted is platform moderation. We want to allow users to post content(mostly text) freely, and we also want to not monitor the platform 24/7.

That's when I had an idea to use AI to screen to content before it is published. The idea is to have an LLM look at the content submitted and mark it as safe and not safe based on a set of rules, if a submission is flagged the site will send an email to moderators to manually verify the content.

### What happened

The idea is greate and the project lead thinks it's greate as well. The only problem is that the 2 person leading the project didn't prepare anything and prabably didn't know what they are doing. When me and my friend pointed out a list of concerns and problems that didn't cross their mind, the prject was scraped in the end.

But the idead of a content screanner is not dead and I now have an excuse to use SQS, SNS and APIGW and lambda function to solve a problem that doesn't exist. So here is what I have gone through and learned from building somthing like this.

## Design

Github repo: [ltekme/AI-Screener-For-User-Generated-Content](https://github.com/ltekme/AI-Screener-For-User-Generated-Content)

![Project Diagram](diagrams/exports/Full-export.png)

This is an illistration on how I host it on aws. Because I wanted make it work on both normal and AWS Acaedmy Learn Lab account.

Some of the things are not included when deploying on Learner Lab, namely Bedrock, CloudFront. I can understand bedrock, but cloudfront as well??? I can spend another couple of days to migrate the AI part to google Vertex AI so it can still flag content, but I figured, no.

## S3 + ReactJS is great

### What is ReactJS

[ReactJS](https://react.dev/) is a java script library for building user interface developed by facebook and is widely used by develepors to create dunamic web interfaces. To learn more, checkout: [https://react.dev/learn](https://react.dev/learn)

### React offerings

React offers both `server-side rendering` and `client-side rendering`. In short `server-side rendering` is the server construct the html and send to the broswer to render the page. It is mostly used on dynamic webpages.

`client-side rendering` is the opposite of `server-side rendering`. It renders the web page after it has arrived at the broswer. The broswer executes reactjs. React then add and change element on client to render the page. The page rendering process is now done on the client instead of the server.

Read more: [React.js: Server-Side Rendering vs Client-Side Rendering](https://flatirons.com/blog/react-js-server-side-rendering-vs-client-side-rendering/#:~:text=Key%20Takeaways%3A-,React.,using%20JavaScript%20for%20dynamic%20updates.)


It flexability allows developers to quickly spinup an idea without too much hasel. Not to mention it's brothers like [vuejs](https://vuejs.org/), [nextjs](https://nextjs.org/). Alost anything that comes to mind on a brower window can be built using it. It is just JavaScript. Being popular among developersm, it is widely adopted by hosting providers like [Vercel](https://vercel.com/). It can even be run on [github pages](https://pages.github.com/). Both of which is free* to a cetern extend.


### S3 is perfect

What the above, react only need the client cpu to do the rendering, we only need to serve the html to the broswer. It is scremeing "host it on s3".

To put it simply. S3 is a harddisk plugged into the internet, allowing user to store and access their data as long as there is an internet connection. One of it's feature is [static website hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html). I made a post on how you can use s3 and cloudfront to host your website globally for almost free* [here](../1.Using-S3-to-host-static-website/README.md).
