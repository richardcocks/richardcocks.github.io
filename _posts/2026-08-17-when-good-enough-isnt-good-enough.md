---
layout: post
title: Agentic Perfectionism
date: 2026-08-17
description: '"Good enough" no longer feels good enough'
tagline: 'When "Good enough" is no longer good enough'
---
# Agentic Perfectionism - When "Good enough" is no longer good enough

Coming up to a year into agentic development, I've overcome the initial awkwardness and challenges, but I'm finding increasingly there's a new spectre haunting me: Perfectionism.

It was often difficult in the past to resist one more look at a new feature, one more testing cycle to catch the edge cases, one more commit to polish it off.

When a new feature took a week, then it was irresponsible to give in too much to that instinct. Experience and discipline called such over-work "gold plating", and it was generally agreed that one should draw a line somewhere and finish the work, with any imperfections it might contain.

When working with claude, this is made so much more difficult. You can get to the end of the work, consider it finished, then ask claude for one final look over. Back it comes with a dozen minor code issues, some of which you'd never have even considered, such as the possibility that if someone calls this function in a particular state, and then someone else suspends another process at just the right time, they could end up in a loop. So you think, well that sounds bad, I can't ship that! Even if it's just a hobby project and those conditions would never be met!

Eventually you finish the coding loop and do some final human developer testing, only to realise it'd be handy to add a particular hotkey. Well surely that can't take long, let's quickly add that. Surely it'll only take one prompt and a few minutes.

And so on it goes. The discipline to say no to perfectionism has evaporated, and so any time saved is lost to rounds of polish passes that it never really needed.
