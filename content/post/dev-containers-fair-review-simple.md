---
title: "Dev Containers: A Simple, Honest Review"
slug: dev-containers-fair-review-simple
date: "2025-09-12"
tags: ["dev containers","tooling","containers","productivity"]
categories: ["Technical","Dev Containers"]
description: "A plain-language look at Dev Containers: what they are, when to use them, and when to skip them."
author: "Ugur Elveren"
reading_time: 8
draft: true
---

![Dev Containers provide consistent development environments across different operating systems and team setups.](/images/dev-containers.jpg)

## TL;DR

Dev containers turn a complex setup guide into code and give every person the same working environment. They help when your project is not simple, when people use different operating systems, or when you fight **works on my machine** bugs. They can slow things down and add extra upkeep if the project is already easy to run. Use them only when they remove real pain.

Should you use dev containers? If onboarding takes more than a few steps, if you run multiple tools or services, if your team spans macOS, Windows, and Linux, or if CI keeps failing due to environment drift, a dev container will likely help. If your setup is already one or two commands and fast local feedback matters most, you probably do not need one.

## What is a dev container?

A dev container is a folder in your project, usually named `.devcontainer`, that tells the editor how to build a ready‑to‑use development environment. It uses a `devcontainer.json` file and often a `Dockerfile` or a `docker-compose.yml`. These files define the language versions, system packages, tools, editor settings, and optional services like a database or cache. Your editor, such as VS Code or a cloud workspace, reads this and builds a consistent place to work. The idea grew from remote development features plus the spread of containers. Microsoft and GitHub pushed the tooling forward, and the open source community added templates and examples. Today both platform teams and the community maintain it. In short, it is **environment as code** for local and cloud development.

## Why people use them

People use dev containers because they remove long and fragile setup steps. A new person can open the project and start faster instead of installing a list of tools by hand. Using the same container image both locally and in continuous integration reduces surprise differences. A single Linux base also hides many gaps between macOS, Windows, and Linux hosts. Complex stacks with databases or extra services are easier because those services can start automatically. They also help in workshops and demos where you want everyone to begin from the same state. Trying new tools becomes safer because you can throw away the container without harming your main system.

## Real downsides

Dev containers can feel slower, especially on macOS and Windows, because file traffic across the shared folder between host and the Linux VM is slower than a native filesystem. Heavy watch loops, hot reload, and test runs that touch many files can suffer. You can soften this by keeping hot paths inside the container on a Linux volume, by installing dependencies like node_modules into a Docker volume instead of the mounted project folder, and by avoiding large watch loops on the shared mount. On Windows, running code and files inside WSL 2 helps because it uses a Linux filesystem. Image size and rebuild time can also grow over time, so you need to keep the Dockerfile lean and cache‑friendly. The config itself becomes something you must keep clean, updated, and secure. People who do not know Docker may feel blocked. Debugging can get harder when permission or network behavior differs inside the container. Security can slip if you bake secrets into images or ignore outdated packages. Different CPU types like `arm64` and `x86` can cause build failures or force emulation. Prefer multi‑arch base images, and test on both `arm64` and `x86` to avoid surprises. Forcing every small contribution through the container can scare off casual helpers. All of this means dev containers are helpful only when their value beats the overhead.

## When dev containers are a good choice

They make the most sense when getting started takes more than a few simple commands or when the project needs several languages, tools, or system libraries that must work together. They help when team members use different operating systems or hardware. They shine if you want your local runs and your CI runs to match closely. They are useful when outside audits, traceability, or repeatable builds matter. They pay off when many new people join often or when the project depends on services like databases or message queues that should start the same way each time. If several of these points describe your project, a dev container is likely worth it.

## When you can skip them

You can skip dev containers when setup is already short and clear, like clone and run one install command. You can skip them when all contributors share a stable tool setup and do not hit version conflicts. You can skip them when you need very fast feedback loops and the container slows file watching or rebuilds. You can skip them for quick prototypes that change daily or for work that is mostly docs or static content. On Windows, WSL 2 alone often gives you a good Linux‑like development environment without adding a full dev container. In these cases a short README and maybe a language version manager are enough.

## How to start simply

Begin with the smallest working setup. Pick a slim base image and install only the language runtime and the few tools you truly need to run tests and format code. Add services like a database later only if real work needs them. Offer both native and container instructions at first so people are not forced into a slower path for simple edits. Reuse the same Dockerfile or the exact same image tag or digest in CI so you do not drift. If builds feel slow, reorder steps to keep caches effective, use smaller base images, and avoid extra layers.

Understand the lifecycle hooks so setup is reliable. Use `postCreateCommand` for one‑time setup after the container is first created. Use `postStartCommand` for tasks that should run each time the container starts. Use `postAttachCommand` for actions that should run after the editor attaches to the container.

Be aware of networking behavior. Localhost inside the container is not the host. On macOS and Windows you can reach the host as `host.docker.internal`. In Docker Compose, services reach each other by service name, not by localhost. Knowing these rules up front can save hours of debugging.

## Common mistakes to watch for

A common mistake is using a latest tag for your base image, which causes surprise breakage when the upstream image changes. Another mistake is leaving secrets like API keys inside the Dockerfile or scripts, because those secrets stay in image history. Some teams ignore hardware differences and break things for Apple Silicon users. Forcing the container for tiny doc fixes pushes away drive‑by contributors. Slow rebuilds happen when the Dockerfile order causes cache misses. Letting the dev container drift away from what CI or production uses brings back the very bugs you tried to remove. These traps are easy to avoid once you call them out early.

## Security basics

Security in dev containers is about steady habits. Pin your base image to a version or a digest so it does not change under you, and refresh it on a regular schedule. Do not bake SSH keys, cloud credentials, or other secrets into images or scripts. Pass them only at runtime using your platform’s secrets support. Scan images for known problems with tools like `Trivy` or `Snyk` and act on serious issues. Avoid running everything as root if you can help it. Avoid using a blanket `apt‑get upgrade` in the Dockerfile because it hurts reproducibility; instead pull a newer base image on a schedule and install only what you need. Produce a simple list of what is inside the image, such as an `SBOM`, so you can react fast when a library gets a warning. If provenance matters, sign your images so you know where they came from.

## Alternatives

You do not always need a dev container. A language version manager like `nvm`, `pyenv`, `rbenv`, or `asdf` often solves version drift for a single‑language project. **`Nix`** can define a whole environment in one file with strong repeatability, though it takes time to learn. Docker Compose alone can start your services without tying in editor settings. A full virtual machine helps when you must mirror a legacy system or a very specific OS. Cloud IDEs like **Codespaces** or **Gitpod** remove local setup and sometimes already use dev containers behind the scenes. On Windows, WSL 2 is often a light and effective way to run Linux tools without a container. For very simple or doc‑only projects, plain instructions and maybe a small setup script are enough.

## Developer settings and forced preferences

Dev containers can push a set of editor extensions, settings, and tools onto every developer. This can be useful when you want a shared formatter, linter, or test runner, but it can also feel heavy if it overrides personal workflows. Some people prefer a different theme, keymap, shell, or tool version. A ``devcontainer.json`` can declare editor customizations, but keep them lean and explain what is required and what is optional. Prefer a small ``.editorconfig`` and a formatter enforced in CI over a large set of editor extensions. If you must standardize formatting or lint rules, explain the reasons and keep overrides possible where they do not harm consistency. The goal is to supply helpful defaults, not to lock down choice.

## A minimal working example

Sometimes it helps to see the smallest version that still adds value. The example below defines a Node.js workspace, adds a non‑root user, and starts a Postgres service with Docker Compose. It keeps the image slim and the hooks simple so you can grow it later.

```json name=.devcontainer/devcontainer.json
{
  "name": "example-node-postgres",
  "build": { "dockerfile": "Dockerfile" },
  "remoteUser": "dev",
  "workspaceFolder": "/workspaces/app",
  "postCreateCommand": "corepack enable && npm ci || true",
  "customizations": {
    "vscode": {
      "extensions": [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode"
      ],
      "settings": {
        "editor.formatOnSave": true
      }
    }
  },
  "dockerComposeFile": "docker-compose.yml",
  "service": "app"
}
```

```dockerfile name=.devcontainer/Dockerfile
FROM node:20-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates openssh-client \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 dev
USER dev
WORKDIR /workspaces/app
```

```yaml name=.devcontainer/docker-compose.yml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    init: true
    volumes:
      - ..:/workspaces/app
    depends_on:
      - db
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: app
      POSTGRES_DB: app
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app -d app"]
      interval: 5s
      timeout: 3s
      retries: 10
```

This setup is small on purpose. It keeps a non‑root user for safer defaults. It uses a slim base image and avoids extra packages. It runs Postgres as a separate service so your app can connect by the service name db instead of localhost. If performance is slow, move heavy paths like node_modules into a named Docker volume or into a container‑local directory and adjust your package manager settings to use that path.

## Performance in practice

If file watching or hot reload feels slow, first move the busiest paths off the shared mount. Put generated files, caches, and dependency folders on a Linux filesystem inside the container or in a named volume. If you are on Windows, keep your project under the WSL 2 Linux filesystem rather than under the Windows filesystem, and open it from WSL 2. If the image rebuild is slow, check layer order. Install system packages and language runtimes before copying source code so Docker can reuse caches when you change your app. Keep the base image slim and avoid running package upgrades in the Dockerfile. Prebuild images in CI and pull them locally if cold starts are a problem. If you need both arm64 and x86, choose multi‑arch images and test your dev container on both architectures to catch problems early.

## Networking in practice

Remember that localhost inside the container is the container, not the host. On macOS and Windows, use ``host.docker.internal`` to reach the host from the container. In Docker Compose, call other services by their service name because Docker provides its own DNS. If a service on your host needs to call a service in the container, expose the port in Compose and connect to it through the published port on the host. Be careful with firewalls and VPNs, because they can block traffic between the container network and external services in ways that are not obvious.

## CI parity and image strategy

You will avoid many bugs if local development and CI share the same image. Build one image from your Dockerfile and use the same fixed tag or digest in both places. Refresh the base image on a schedule and rebuild to pull in security updates. Keep environment variables and tool versions pinned so developers and the pipeline see the same behavior. If cold start time is a concern, prebuild images in CI and push them to a registry so developers do not build from scratch. If you use Codespaces, prebuilds can remove container build time, but you still need to pin versions to keep runs repeatable.

## Architecture strategy

Apple Silicon is fast on arm64 code and slow when emulating x86. Pick base images and dependencies that publish both arm64 and x86. If you build custom images, use buildx to publish multi‑arch images. If you depend on tools that only ship x86 binaries, consider providing a conditional path for Apple Silicon or move those tools to CI instead of local runs.

## Troubleshooting that saves time

If you see permission errors when editing files, check the container user. Use remoteUser in devcontainer.json and create that user in the Dockerfile with a stable UID. This keeps created files owned by a normal user instead of root. If the container cannot reach a local database on the host, switch from localhost to ``host.docker.internal`` on macOS and Windows, and verify the port is published. If watched files do not trigger rebuilds, reduce the number of watched paths on the shared mount and move hot caches inside the container.

## How to know if it helped

You will know the dev container helps if new people go from clone to first successful run faster than before. You will know if environment questions drop in chat or in issue reports. You will know if CI failures caused by local machine differences become rare. You will know if the team reports less friction in casual feedback. If build times and maintenance time grow while these signals do not improve, the setup might be too heavy or mis‑scoped.

## Final thought

Use dev containers to remove real friction and improve repeatability; if they do not deliver measurable value, keep the setup simpler.