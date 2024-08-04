# Exploring Lambda, APIGW, SQS, SNS and ReactJS

## background

When I was studying for the AWS-SAA exam I came a cross [`decoupling`](https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-integrating-microservices/decouple-messaging.html) a lot.

From a monolith ec2 instence to s3 for static content and lambda function to handle request. If a lambda function handle too many task or takes too long to complete or may not be able to complete, we decouple it with SQS. I know I know why and when to use SQS, but in practice, how does it actually work? I've want to play with it for a while now, but I havn't been able to find a usecase for myself.

### The problem

Last month one of my friend from highschool draged me to chat with his friends to talk about an idea he had. The project is an online platform that allow it's users to post something, someone resonse and something something, not going into details, but one of the problem we encounted is platform moderation. We want to allow users to post content(mostly text) freely, and we also want to not monitor the platform 24/7.

That's when I had an idea to use AI to screen to content before it is published. The idea is to have an LLM look at the content submitted and mark it as safe and not safe based on a set of rules, if a submission is flagged the site will send an email to moderators to manually verify the content.

### What happened

The idea is greate and the project lead thinks it's greate as well. The only problem is that the 2 person leading the project didn't prepare anything and prabably didn't know what they are doing. When me and my friend pointed out a list of concerns and problems that didn't cross their mind, the prject was scraped in the end.

But the idead of a content screanner is not dead and I now have an excuse to use SQS, SNS and APIGW and lambda function to solve a problem that doesn't exist. So here is what I have gone through and learned from building somthing like this.
