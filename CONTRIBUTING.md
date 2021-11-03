# We are always looking for contributions to kurren

In particular, this community seeks the following types of contributions:

* code: contribute your expertise in an area by helping us fix/expand the
  functionality
* ideas: participate in an issues thread or start your own to have your voice
  heard.
* copy editing: fix typos, clarify language, and generally improve the quality
  of the content of kurren

Read this guide on how to do that.

1. [How to contribute code](#how-to-contribute-code)
2. [How to review code submissions](#how-to-review-code-submissions)

# How to Contribute Code

**Prerequisites**: familiarity with [GitHub Pull Requests](https://help.github.com/articles/using-pull-requests)

Fork the repository and make a pull request with your changes. A developer of
the kurren team will review your pull request. And if the pull request gets a
positive review, the reviewer will merge it.

But first, please bear in mind the following guidelines to create the perfect
pull request:

## Discuss Large Changes in Advance

If you see a glaring flaw within kurren, resist the urge to jump
into the code and make sweeping changes right away. We know it can be tempting,
but for large, structural changes(bug fixes or features) it's a wiser choice to
first discuss them with everyone in an
[issue](https://github.com/hennevogel/kurren/issues). It may turn out that
someone is already working on this or that someone already has tried to solve
this and hit a roadblock, maybe there even is a good reason why that flaw
exists? If nothing else, a discussion of the change will familiarize the
reviewer with your proposed changes and streamline the review process when you
create a pull request.

A good rule of thumb for when you should discuss in an issue is to estimate how
much time would be wasted if the pull request was rejected. If it's a couple of
hours then you can probably dive head first and eat the loss in the worst case.
Otherwise, making a quick check with the other developers could save you lots of
time down the line.

## Small Commits & Pull Request Scope

A commit should contain a single logical change, the scope should be as small as
possible. And a pull request should only consist of the commits that you need
for your change (bug fix or feature). If it's possible for you to split larger
changes into smaller blocks please do so.

Limiting the scope of commits/pull requests makes reviewing much easier. Because
it will mean each commit can be evaluated independently and a smaller amount of
commits per pull request also means a smaller amount of code to be reviewed.

## Proper Commit Messages

We are keen on proper commit messages because they will help us to maintain
this piece of code in the future. So for the benefit of all the people who will
look at this commit now and in the future, follow this style:

* The title of your commit should summarizes **what** has been done
  * If the title is to small to explain **what** you have done then elaborate on
    it in the body
* The body of your commit should explain **why** you have changed this. This is
  the most important content of the message!
* Make sure you also explain potential side-effects of this change, if there are any.

## Proper Pull Request

To make it as easy as possible for other developers to review your
pull request we ask you to:

* Explain what this PR is about in the description
* Explain the steps the reviewer has to follow to verify your change
* If the reviewer needs sample data to verify your change, please explain how to
  create that data
* If you include visual changes in this PR, please add screenshots or GIFs
* If you address performance in this PR, add benchmark data or explain how the
  reviewer can benchmark this
* If the PR requires any particular action or consideration before deployment,
  set out the reasons in the PR description.

## Mind the Automated Reviews

Please make sure to mind our continuous integration cycle. If one of the steps
goes wrong for your pull request please address the issue.

# How to Review Code Submissions

Prerequisites: familiarity with [GitHub pull request reviews](https://help.github.com/articles/about-pull-request-reviews).

We believe every code submission should be reviewed by another developer to
determine its *maintainability*. That means you, the reviewer, should check that
the submitted code is:

* functional
* tested
* secure
* effective
* understandable

We also consider code reviews to be one of the best ways to share knowledge
about language features/syntax, design and software architecture. We take this
serious.

## How to Provide Feedback

The tone of your code review will greatly influence morale within our community.

Harsh language in code reviews creates a hostile environment, opinionated
language turns people defensive. Often leading to heated discussions and hurt
feelings. On the other hand a positive tone can contribute to a more inclusive
environment. People start to feel safe, healthy and lively discussions evolve.

So here are some basic rules we aspire to follow (we took inspiration from [GitLab](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/development/code_review.md) for these) to foster constructive, positive feedback.

* **Be respectful** to each other: We are in this together!
* **Be humble**: Reviews aren't about showing off (Example: "I'm not sure - let's look it up.")
* **Be explicit**: People don't always understand your intentions online.
* **Be careful about the use of sarcasm**: Everything we do is public; what
  seems like good-natured kidding to you and a long-time friend, might come off
  as mean and unwelcoming to a person new to the project
* Accept that many decisions are opinions: Discuss trade-offs and preferences openly
* Propose solutions instead of only requesting changes. (Example: *"What do you
  think about naming this `:user_id` instead of `:db_user`?"*)
* Ask for clarification instead of assuming things (Example: *"I don't
  understand this change. Can you clarify this for me please?"*)
* Consider one-on-one chats or video calls if there are too many things that are
  not clear. Afterward post a follow-up comment summarizing the discussion you
  had, so everybody can follow your decision.
* Avoid expressing selective ownership of code (*"my code"*, *"not my code"*,
  *"your code"*), we are a community and share ownership
* Avoid using terms that could be seen as referring to personal traits.
  (Example: *"dumb"*, *"stupid"*, *"simple"*). Assume everyone is attractive,
  intelligent, and well-meaning, because everyone is!
* Don't use hyperbole. (Example: *"always"*, *"never"*, *"endlessly"*,
  *"nothing"*).
* Avoid asking for changes which are out of scope. Things out of scope should be
  addressed at another time (open an issue or send a PR).

## How to Merge Pull Requests

In order to merge a pull request, it needs:

* The **required** GitHub checks to pass
* A review from at least one kurren developer
* All requested changes to be addressed*

\* Dismissing a review with requested changes should only be done if we know the
reviewer is not reachable for a while.


# Happy Hacking! 💚
