---
layout: default
title: Richard Cocks
---

I'm on bluesky at [@eterm.bsky.social](https://bsky.app/profile/eterm.bsky.social)

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
