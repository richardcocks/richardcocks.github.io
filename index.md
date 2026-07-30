---
layout: default
title: Richard Cocks
---

I'm Richard Cocks, a .NET/C# developer. I write here about dotnet performance, benchmarking, and other interests. Find me on [Bluesky](https://bsky.app/profile/eterm.bsky.social) or [GitHub](https://github.com/richardcocks).

# Posts

<p><a href="{{ '/feed.xml' | relative_url }}">RSS feed</a></p>

<ul>
{% for post in site.posts %}
  <li>
    <a href="{{ post.url | relative_url }}">{{ post.date | date: "%Y-%m-%d" }} {{ post.title | escape }}</a>
    {% if post.tagline %}<br><small>{{ post.tagline | escape }}</small>{% endif %}
  </li>
{% endfor %}
</ul>
