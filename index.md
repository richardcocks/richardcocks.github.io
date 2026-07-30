---
layout: default
title: Richard Cocks
---

I'm Richard Cocks, a .NET/C# developer. I write here about performance, benchmarking, and whatever rabbit hole I've fallen down that week. Find me on [Bluesky](https://bsky.app/profile/eterm.bsky.social) or [GitHub](https://github.com/richardcocks).

# Posts

<p><a href="{{ '/feed.xml' | relative_url }}">RSS feed</a></p>

<ul>
{% for post in site.posts %}
  <li>
    <a href="{{ post.url | relative_url }}">{{ post.date | date: "%Y-%m-%d" }} {{ post.title }}</a>
    {% if post.tagline %}<br><small>{{ post.tagline }}</small>{% endif %}
  </li>
{% endfor %}
</ul>
