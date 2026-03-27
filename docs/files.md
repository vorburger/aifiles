# Files & Directory structure

This project (and Git repository) contains the following files & directories:

* `agents/` : Agent declarations, incl. their prompts etc.
* `bin/` : Shell scripts (if any; may be removed when fully adopting Nix)
* `decisions/` : When the agent/s need decisions from an interactive human, it generates Markdown with check boxes here
* `docs/` : Documentation about this repo itself; AKA the source code of the https://ai.vorburger.ch website
* `skills/` : The Skills Base, with "facts" used by the Agent for Graph RAG; AKA 📚 Library of Alexandria!
* `sessions/` : Persistent ADK sessions, from both interactive chats and autonomous runs; also useful as an _"audit log"_
* `tasks/` : Things the agents needs to get to work to. This is the _"input"_ that triggers the AI to get to work...
