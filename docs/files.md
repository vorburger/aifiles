# Files & Directory structure

This project (and Git repository) contains the following files & directories:

- `agents/` : Agent declarations, incl. their prompts etc.
- `docs/` : Documentation about this repo itself; the source code of the https://ai.vorburger.ch website
- `skills/` : The [Agent Skills](https://agentskills.io), with "capabilities" and "expertise" used by the Agent; 📚 Library of Alexandria!
- `scripts/` : Typescript scripts

A separate private repo can contain a structure such as:

- `data/gmail` : Input
- `decisions/` : When the agent/s need decisions from an interactive human, it generates Markdown with check boxes here
- `sessions/` : Persistent ADK sessions, from both interactive chats and autonomous runs; also useful as an _"audit log"_
- `tasks/` : Things the agents needs to get to work to. This is the _"input"_ that triggers the AI to get to work...
