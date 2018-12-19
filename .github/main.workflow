workflow "Documentation Generation" {
  on = "push"
  resolves = ["Build"]
}

action "Filters for GitHub Actions" {
  uses = "actions/bin/filter@e96fd9a"
  args = "branch v*"
}

action "Build" {
  uses = "aliou/actions/bundler@feature/ad-bundle"
  needs = ["Filters for GitHub Actions"]
  args = "install"
}
