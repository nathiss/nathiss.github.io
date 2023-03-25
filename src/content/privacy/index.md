+++
title = 'About Tracking & Data Collection'
date = 2023-03-25T19:15:33+01:00
type = 'privacy'
tags = []
images = []

aliases = [
    "about-tracking-data-collection",
]

show_table_of_contents = false
show_disqus = false
show_comment_count = false
show_date = false
show_reading_time = false
show_author = false
visible_in_rss = false

share_buttons = []

katex = false
draft = false
+++

This blog is a statically generated website; on it's own, it {{< underline >}}does not{{< /underline >}} perform any
data collection. As of now, it uses two external services:

* [Google Analytics 4](https://marketingplatform.google.com/about/analytics/) which tracts how users interact with the
website, their scrolling patterns, and whether they click on links pointing to external domains,
* [Disqus](https://disqus.com/) which provides out of the box, fully functional discussion solution.

I do not wish to gather your personal information for targeting purposes. In fact, there's nothing here that could be
personalized in the first place: there's no digital ad inventory, the website itself is not linked to
[Google Ads](https://ads.google.com/home/). I've made a series of steps, to ensure that data gathered by these services
is as limited as they allow it to be, while still providing functionality I'd like them to provide.

In {{< underline >}}Google Analytics{{< /underline >}} I've disabled linking your activity on this website against your
Google Account personal information, as well as, Ads personalization. GA4 **does** collect your city-level location (see
[here](https://support.google.com/analytics/answer/12002752?hl=en-GB&utm_id=ad) to read more). Execute this line of code
in your console to retrieve geo-location object used by GA4:

```javascript
localStorage.getItem("geo-location");
```

In {{< underline >}}Disqus{{< /underline >}} admin panel I've disabled anonymous cookie targeting used for personalized
advertizing. Other than that I could not find any tracking/personalization settings. As far as I'm aware, it gathers
data only for the sake of comments.

As was already mentioned in the consent dialog, this website respects
**[Do Not Track](https://en.wikipedia.org/wiki/Do_Not_Track)** header field. If you enable DNT for this domain, then
Google Analytics 4 will be disabled. Use this snippet to check whether DNT is enabled already:

```javascript
const dnt = (navigator.doNotTrack || window.doNotTrack || navigator.msDoNotTrack);
const isDntEnabled = (dnt == "1" || dnt == "yes");
```

I don't know if this brief statement was of any help. I guess I wrote it to give you some idea of what _happens_ when
you browse through these pages and how to control your privacy. Feel free to reach out to me if you have any questions
about the topic.

{{< success >}}Kamil{{< /success >}}
