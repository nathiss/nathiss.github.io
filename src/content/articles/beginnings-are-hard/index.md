+++
title = 'Beginnings Are Hard'
date = 2023-02-25T20:14:43+01:00
type = 'Article'

disqus_identifier = '702013d025d184f252a4725999d0e5b8'
## Optional, will use <title> tag value instead.
# disqus_title = ''
## Optional, will use window.location.href instead.
# disqus_url = ''
show_disqus = true
show_comment_count = true

share_buttons = ['facebook', 'twitter']

draft = false
+++

Well it took some time (almost 6 years) to create a personal blog, but here we are.

<!--more-->

## How did we come here?

This is not the first attempt on creating my own website. On my [GitHub](https://github.com/nathiss) there are many
(most of them private) repos, which contains some sort of _personal website_. All of them abandoned, but not this one!

... at least not yet. ✌(-‿-)✌ However I'm optimistic.

To better understand why I have such high hopes for this project let's go down the rabbit hole and analyze its ancestors
and try to point out why they failed.

### Platform 1: 0x52 (Django 2.2)

[Django](https://www.djangoproject.com/) is one of the first tools I've ever used to create something on the web.

> Django is a high-level Python web framework that encourages rapid development and clean, pragmatic design.
> Built by experienced developers, it takes care of much of the hassle of web development, so you can focus on writing
> your app without needing to reinvent the wheel. It’s free and open source.  
> ~ [Django website](https://www.djangoproject.com/)

Using that framework I've built a web journal. The idea was that at any moment I could use one of my devices to create
a new journal entry. They were automatically sorted by creation date and tagged with tokens retrieved from the entry's
content. The latter deserves a bit more digging into, so let's consider the following entry:

> Lorem ipsum @dolor sit amet, consectetur adipiscing elit. Aliquam sed eleifend magna. @Quisque venenatis ex ex, a
> suscipit purus iaculis ac. Sed @lacinia tincidunt nunc vitae consectetur.

A tag is a sequence of characters between `'@'` and one of `',<.>/?;:\'"[{]}\\|()=+#$%^&*~\r\n '`. When an entry was
either created or modified, then the logic extracted tags from content:

```python
@staticmethod
def extract_tag_names(text):
    words = re.split(Tag.escape_delimiters(Tag.TAG_DELIMITERS), text)
    words = list(filter(None, words))
    return [tag_name[1:].lower() for tag_name in words if tag_name.startswith(Tag.TAG_SYMBOL)]
```

It worked pretty well. I could create a new tag or use an already existing one. When the tag was orphaned _(meaning it
was referenced by no entry)_ the logic was able to take care of that too. :eyes:

The solution was designed to be used by more that one user: each person would have an account and they would be able to
access only their own entries and tags.

What happened with that project? I used it for a while, but after some time I wasn't really actively adding new entries,
so it just fated away. Also it was more of a personal utility website, than a blog. It was publicly available on
[Heroku](https://www.heroku.com/) until quite recently actually. I took down the website when [Heroku announced their
removal of free product plans](https://help.heroku.com/RSBRUH58/removal-of-heroku-free-product-plans-faq).

### Platform 2: Titan (ASP.NET)

This was _an another_ iteration of personal website development. I've decided to use
[.NET](https://en.wikipedia.org/wiki/.NET) for this one, because earlier in that year I got my first job in the field
and I was hyped to build something with the technology we used at work _(we were developing a few solutions and one of
them was built on top of [.NET Framework](https://en.wikipedia.org/wiki/.NET_Framework))_.

Sadly I deleted the source code some time ago as a part of my GitHub purge, but I remember quite vividly the problem(s)
with this one. In a sentence: it was too overengineered.

> the strategy is definitely: first make it work, then make it right, and, finally, make it fast.  
> ~ "The C Language and Models for Systems Programming" in Byte magazine (August 1983)

I wanted to use [JWT](https://en.wikipedia.org/wiki/JSON_Web_Token) as a user authentication method. I've read on many
places on the web that it's a bad idea, but still I was devoted to make it work. One of the issues I was aware of was
that you cannot _easily_ and _permanently_ logout a user when using JWT.

In a nutshell JWT are tokens stored on the client-side. However, due to encryption, they can only be read by the
service. So with each request the client sends its token to the sever (like a cookie, you might say). If the token is
well-formed, then the server, with quite high certainty, can assume it wasn't tinkered with.

Going back to logout issue: to ensure that session will not last indefinitely the server could add `"expiryDate"` field
to payload and check its value with each request and respond accordingly. That works pretty well. The client has no way
of modifying `"expiryDate"`.

Yet it's much harder to kill the session before token expiries. My attempt was to add a new field to token's payload
which would indicate that its no longer valid and send it back to the client. The problem though is that the client does
not **need** to use the new token. It still can use the old one and, since we don't store session information on the
server, the service has not way of detecting that. :anger:

The solution I came up with was to use [Redis](https://redis.io/). To store that information on the server-side.

> **Redis:**
> The open source, in-memory data store used by millions of developers as a database, cache, streaming engine,
> and message broker.

Once the server decides the user should be logged out, it will store JWT's ID in Redis alongside with an indication of
whether the session has ended.

Can you see now when I said it was overengineered? So many complex solutions for a logout functionality. The project
ended because I was too wornout to finish it.

### Platform 3: Polaris (React)

I'm actually quite proud of this one. It's a static website running on [React](https://reactjs.org/) and hosting my
vector graphics. It's painfully simple, but that was kinda the point. I wanted to have a way of hosting those images
ASAP, hence React and GitHub Pages, [where the website is actually hosted](https://nathiss.github.io/Polaris/).

It wasn't my first contact with technologies used in frontend, but it was the first time when I used _state of the art_
tools for a new website. My knowledge of [NodeJS](https://nodejs.org/en/) and utilities built on top of it was
practically nonexistent. That changed once I've written Polaris; now I'm just new to this stuff.

![Steam on the horizon](./steam-on-the-horizon-small.png)

I don't have much more to say here other that, it was a while when I've used [Inkscape](https://inkscape.org/) to create
those images and when I needed to use it again, for the sake of this blog, it was terrifying to see how much one can
forget what one has learned. ಠ_ಠ

### Platforms long forgotten

There were many more projects which aimed to create my personal space on the web, but only these mentioned above are
still remembered by me enough to write a few sentences about.

It's safe to say they all suffered from the same fundamental flaws:

- they were too complex,
- they were trying to solve all possible future problem without aiming to deliver the most basic functionality,
- backend is hard.

This blog, on the other hand, is a static content website build with [Hugo](https://gohugo.io/). I think to some extend
I was aware that tools like Hugo existed, but I've never considered using them. I cannot really explain as to why; maybe
I was trying too hard to use a new fancy tool I've just learned about.

## The goal and future of this project

The goal of this project is to create an archive for stuff I'm going to learn. It's still unclear as to what I'm going
to post on this blog, but it's safe to say that it's going to be techy.

I cannot say with any amount of certainty how often I'll writing new articles. I'm really looking forward to making new
content though. I believe it will also tilt me significantly into learning about new things.

There are still some adjustments I need to make on the website, I'm probably going to focus on them before I'll work on
new articles, but in general it is functionally complete.

So as of now, thank you for reading.

:ocean:
