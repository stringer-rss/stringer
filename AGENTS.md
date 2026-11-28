# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

## What this is

Stringer is a self-hosted, anti-social RSS reader: a Rails 8.1 app (Ruby 4.0) backed by PostgreSQL, with feed fetching run as background jobs via GoodJob.

## Commands

Toolchain versions (Ruby, Node, Postgres, pnpm) are pinned in `.tool-versions`; check that file rather than relying on numbers quoted here.

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

**Feed fetching flow:** `Feed::FetchAll` → enqueues `Feed::FetchOne` per feed → `HTTParty` fetches, `Feedjira` parses → `Feed::FindNewStories` drops entries that are too old or already stored → `StoryRepository.add`. Fetch failures set the feed status to `:red` (vs `:green`) and log rather than raise.

**Admin routes** under `/admin` (GoodJob dashboard, settings, debug) are gated by `AdminConstraint` (`lib/admin_constraint.rb`). Stringer is single-user; auth is password-based (`bcrypt`).

**Fever API:** Stringer implements a clone of the Fever API (`fever_controller`, `app/commands/fever_api/`) so third-party mobile clients can connect.

## Frontend

Assets are bundled with **esbuild**, not Rails' asset pipeline compilation (Propshaft serves the built files).

Pages are rendered on the server with **Phlex** components (`app/components/`, `app/views/`), and interactive behavior lives in **Stimulus controllers** (`app/javascript/controllers/`). The story list, for example, is `Components::StoryList` plus the `story`, `story-list` and `hotkeys` controllers. Keyboard shortcuts either use Stimulus key filters or the `hotkeys` controller, which clicks a button marked with `data-hotkey`.

Turbo Drive is explicitly **disabled** (`session.drive = false` in `app/javascript/application.ts`). Turbo Frames and Streams still work, and forms inside a `<turbo-frame>` are submitted by Turbo.

**Saving goes through forms, not JS requests.** Stimulus controllers only change what's on the page; they don't call the server. Each story's contents sit in a `<turbo-frame>` (`Components::StoryFrame`), and every change to a story is a small form inside it:

- Star, keep unread, and mark read (submitted by the `story` controller when a story opens) respond with a **Turbo Stream** that replaces just the affected elements (`Components::ReplaceStream`, via `StoriesController#render_replacements`). The page only changes once the server has saved.
- Refresh responds with the whole story frame.
- The keep unread form carries the saved read state (`data-is-read`/`data-keep-unread`) and is the `story` controller's `readState` target; when a stream swaps it in, the controller copies that state onto the story and announces `story:read-changed` (which updates the unread count).

The tutorial page's sample stories aren't saved. A `tutorial-stories` controller wraps its story list, cancels each form submit, and makes the change the stream would have made, so the shared controllers stay unaware of the tutorial.

Gotchas:

- Each story's frame stops `submit` events from bubbling (Turbo calls `stopImmediatePropagation`), so a handler outside the frame must listen in the capture phase (`submit->controller#method:capture`).
- phlex-rails `form_with` without a block leaves the `<form>` unclosed, nesting whatever follows inside it. Pass an empty block (`{ nil }`) for forms with no fields.
- Phlex drops whitespace between tags that ERB kept; add `whitespace` between inline elements that should be separated.
- Rails' error pages in development and test set `turbo-visit-control: reload`, so a failed frame request there navigates the whole page instead of firing `turbo:frame-missing`.

## Linting baselines

ESLint, Stylelint, and RuboCop each use a generated "todo" baseline file (`.eslint_todo.ts`, `.stylelint_todo.yml`, `.rubocop_todo.yml`) that suppresses pre-existing offenses. The intent is to ratchet these down over time — fix offenses and remove their entries rather than adding new suppressions. Regenerate via `bundle exec exe/eslint_autogen` / `bundle exec exe/stylelint_autogen` (CI checks that the committed baseline matches). A custom RuboCop cop lives in `linters/rubocop/cop/`.

## CI

CircleCI (`.circleci/config.yml`) runs, in order: `tscheck`, eslint (incl. unused-rule check and autogen drift check), vitest, brakeman, stylelint (+ autogen drift), rubocop, then rspec (with `xvfb-run` for system specs). Match this locally before pushing.
