Mac App Play
============

An agent skill made by agent for agent to use macOS app.

![Screen Recording](Resources/Screen%20Recording.gif)

It's built with a simple CLI tool with `SKILL.md` which works perfectly
for many use cases.


Usage
-----

`make` to produce `mac_app_play` binary in `Skills/mac-app-play/scripts`,
then place `mac-app-play` skill in your skills directory for the agent.

### Privacy Permissions

Agent will use Accessibility and Screen Recording.
You need to grant access these privacy settings manually for the app
where the agent runs, for example, Terminal.app.
