# Gem meta info

## Release a new version

* Make and commit code changes.
* Update `CHANGELOG.md`.
* Update the gem version in `lib/needleman_wunsch_aligner/version.rb`.
* Commit version bump and changelog with message ‘Bumped version to x.y.z’.
* Run `rake release`. This will perform the following steps:
    * Build a gem package to e.g. pkg/needleman_wunsch_aligner-1.0.1.gem.
    * Push the `.gem` package to `Rubygems.org`
    * Add and push a tag like “v1.0.1” to git.
    * Push commits to the git remote.

## Run tests

    rake test

Also every push to github will trigger a test run at travis CI.
