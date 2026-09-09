# Project Skill Archives

`projects/` contains isolated, codebase-specific skill archives. Content here is not part of the generic skill library and must not be installed by a root global installer.

Each project archive owns its skills, agent-specific variants, rules, and setup notes. When a workflow is reused by another project, copy it into that project's archive and adapt it there.

Before adding a skill, decide whether it is genuinely generic. If that is unclear, ask which project should own it. Create a new `projects/<project>/` archive rather than placing a project workflow under `skills/`.
