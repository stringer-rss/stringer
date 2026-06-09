# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

## What this is

Stringer is a self-hosted, anti-social RSS reader: a Rails 8.1 app (Ruby 4.0) backed by PostgreSQL, with feed fetching run as background jobs via GoodJob. The README's mention of Backbone.js is partly outdated — see the frontend notes below.

## Commands

Toolchain versions are pinned in `.tool-versions` (Ruby 4.0.5, Node 26.3.0, Postgres 16.8, pnpm 10.5.2).

- **Setup:** `bin/setup` (runs `bundle install`, `db:prepare`, clears logs/tmp, then launches the dev server). Pass `--skip-server` to stop before launching.
- **Run dev server:** `bin/dev` (foreman against `Procfile.dev` — boots Puma on port 3000 plus `js`/`css` esbuild watchers). The app is at `http://localhost:3000`.
- **Ruby tests:** `bundle exec rspec`. Run a single file/example with `bundle exec rspec spec/path/to/file_spec.rb:LINE`.
- **JS tests:** `pnpm test` (vitest + jsdom with coverage). Specs live in `spec/javascript/**/*_spec.ts`. `pnpm test` runs `pretest` first, which runs `tscheck` and `eslint`.
- **Type check:** `pnpm tscheck` (`tsc --noEmit`).
- **Lint (Ruby):** `bundle exec rubocop`. **Lint (JS):** `pnpm eslint`. **Lint (CSS):** `pnpm stylelint`.
- **Security scan:** `bundle exec brakeman`.
- **Interactive console:** `rake console` (or `bin/rails console`).
- **Asset build (one-off):** `pnpm build` (JS via esbuild) and `pnpm build:css` (CSS via esbuild).

Feed operations are exposed as rake tasks: `rake fetch_feeds`, `rake fetch_feed[ID]`, `rake lazy_fetch`, `rake cleanup_old_stories[DAYS]` (default 30 days; removes read, unstarred stories).

## Architecture

**Command objects (`app/commands/`)** hold the business logic. Each is a module or class with a single `.call` entry point (e.g. `Feed::FetchOne.call(feed)`), grouped by domain (`feed/`, `story/`, `user/`, `fever_api/`). Controllers and jobs stay thin and delegate to commands. When adding behavior, prefer a new command over fattening a controller or model.

**Repositories (`app/repositories/`)** wrap all ActiveRecord query/persistence logic (`FeedRepository`, `StoryRepository`, `GroupRepository`, `UserRepository`). Commands and controllers go through repositories rather than calling `Feed.where(...)` etc. directly. Keep DB access in the repository layer.

**Background jobs** funnel through a single `CallableJob`, which just calls any callable: `CallableJob.perform_later(Feed::FetchOne, feed)` enqueues `Feed::FetchOne.call(feed)`. There is rarely a need to write a new `ApplicationJob` subclass — enqueue a command via `CallableJob` instead. Jobs run on GoodJob (Postgres-backed).

**Feed fetching flow:** `Feed::FetchAll` → enqueues `Feed::FetchOne` per feed → `HTTParty` fetches, `Feedjira` parses → `Feed::FindNewStories` diffs against the latest stored entry → `StoryRepository.add`. Fetch failures set the feed status to `:red` (vs `:green`) and log rather than raise.

**Admin routes** under `/admin` (GoodJob dashboard, settings, debug) are gated by `AdminConstraint` (`lib/admin_constraint.rb`). Stringer is single-user; auth is password-based (`bcrypt`).

**Fever API:** Stringer implements a clone of the Fever API (`fever_controller`, `app/commands/fever_api/`) so third-party mobile clients can connect.

## Frontend

Assets are bundled with **esbuild**, not Rails' asset pipeline compilation (Propshaft serves the built files). Two distinct JS worlds coexist:

- **Stimulus controllers** (`app/javascript/controllers/`) — the current approach for new interactive behavior (dialogs, hotkeys, toggles).
- **Backbone** (`app/javascript/application.ts`) — the legacy story-list view (`Story`/`StoryView`/`StoryList`/`AppView`), which talks to `/stories`. Note this file is `@ts-nocheck`. Underscore templates use custom `{{ }}` delimiters (set in `application.ts`), not the default `<% %>`.

Turbo Drive is explicitly **disabled** (`Turbo.session.drive = false`).

## Linting baselines

ESLint, Stylelint, and RuboCop each use a generated "todo" baseline file (`.eslint_todo.ts`, `.stylelint_todo.yml`, `.rubocop_todo.yml`) that suppresses pre-existing offenses. The intent is to ratchet these down over time — fix offenses and remove their entries rather than adding new suppressions. Regenerate via `bundle exec exe/eslint_autogen` / `bundle exec exe/stylelint_autogen` (CI checks that the committed baseline matches). A custom RuboCop cop lives in `linters/rubocop/cop/`.

## CI

CircleCI (`.circleci/config.yml`) runs, in order: `tscheck`, eslint (incl. unused-rule check and autogen drift check), vitest, brakeman, stylelint (+ autogen drift), rubocop, then rspec (with `xvfb-run` for system specs). Match this locally before pushing.
