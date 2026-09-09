# Skill Scope Policy

This repository separates reusable skills from project skills.

- Treat a skill as generic only when its workflow is independent of a company, product, codebase, local path, and internal conventions.
- Before creating or expanding a non-generic skill, ask whether it belongs to an existing project archive or a new project archive. Do not infer that a project workflow is generic.
- Store project skills under `projects/<project>/`. Keep Cursor and Codex variants separate when their instructions differ.
- Reuse a skill across projects by copying it into the receiving project's archive. Do not share a project skill through a common path or global installer.
- Root global-install scripts may install generic skills only. Project skills require an explicit project installer.
