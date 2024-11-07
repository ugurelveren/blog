---
title: "I Moved My Blog to GitHub Again"
date: "2024-09-14"
categories: ["Personal"]
tags: ["blog", "gitHub", "markdown", "static website"]
---

I've done something.

Again.

My cat is on my lap, I'm listening to music with my headset, and I'm writing a blog post about how I moved my blog to another platform. Well, not another platform, actually. I moved it to old friend GitHub again.

This time, though, I developed something simple so I can manage my blog with my own solution.

## Starting From the Beginning

What was the previous platform I was using? I was using Write.as. It's a simple platform where you can share your posts on the Fediverse. The UI is minimal, and the main goal of the CMS platform is clear: just write and share your articles.

Since it's so simple, it doesn't come with a ton of functionality, which was perfect for me in the beginning. Simple UI, no distractions, and a decent community. I also never noticed any downtime (though I never tested it with any APIs, to be fair).

It was a perfect fit for me. I usually don't have long hours to write a post. I'm busy with work, my baby, and life in general. I didn't want to deal with unnecessary problems. But at the same time, it started losing the magic of blogging.

I didn't want to deal with SEO nonsense or anything like that. I believe Google is stifling creativity and ruining the internet. Who cares about SEO? (Unfortunately, I do—just like the rest of the internet. If you don't get your content in front of an audience, it's basically useless, so you have obey Google's rules.) But, like most developers, I want to tinker with my blog. I want to add some Easter eggs, new features, or other improvements.

I never got around to doing that on Write.as. Their goal was simple blogging, and they didn't offer much else. Once I realized that, I stopped blogging altogether. But i want more flexibility. I had plenty of excuses too - my newborn baby, my busy job, etc. So, I stopped.

## Markdown to the Rescue

At the same time, I was working on documentation for a project and supporting new projects with technical documentation. I was heavily using Markdown. Eventually, I ditched Markdown editors and other tools and just stuck with VSCode.

I realized I was enjoying Markdown and writing documentation. It reminded me of my old friend, Jekyll (I hosted my blog on GitHub with Jekyll originally). But I moved away from Jekyll because it wasn't as stable as I wanted. Actually, the problem wasn't Jekyll itself—it was the theme I used. The theme was powerful, but I didn't need something that complex. I needed simplicity, and that bad theme choice left me with a negative feeling about Jekyll.

But then I thought: what if I made a Markdown-based blog for myself? No fancy extras—just Markdown files and my thoughts. That was a great idea, but I wanted my blog to have a little aesthetic touch. So, I thought, if I add a bit of HTML, I could get what I want.

## Building My Own Blog

That's when I remembered Marked.js. The perfect library for this. I only needed a basic HTML template, and I could use it to render Markdown into HTML dynamically. I built a simple HTML template, wrote a few functions using Marked.js, and boom! I was able to create a Markdown-based website that rendered HTML without needing Jekyll or any other CMS support on GitHub.

Basically, I detect the Markdown file name from the URL path and render that Markdown asynchronously in my HTML template. Easy peasy. It worked great, but then I remembered a common issue on the internet: SEO.

Do I need SEO tags? Yes, because I need readers, and without readers, a blog is a bit pointless. I could promote my blog on social media, but I've stopped using most of those platforms.

## What's Next?

And here we are! I'm writing this blog post in a Markdown file on a simple, static, Markdown-based HTML website. I have more ideas for it. The homepage for my domain is built with a terminal-based jQuery library, and I plan to integrate it with my blog. Maybe a search for blog in terminal. There are a lot of cool feature for my **Dynamically Rendered Static Website**. I hope to write another post once I develop that.

