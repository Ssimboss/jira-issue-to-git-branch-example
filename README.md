# jira-issue-to-git-branch-exampple
Bash script to automatically create a GIT branch with a configurable name from a JIRA issue's summary.

## How to use

- Open your JIRA-profile -> click `Manage your account` -> switch to `Security` tab -> scroll down to `API tokens` section -> click `create and manage API tokens`.
- Create a new JIRA API token or use the existing one.
- Configure JIRA URL, your JIRA-access email and API token in `local.properties.example` file.
- Rename `local.properties.example` to `local.properties`
- Execute `./scripts/make_branch.sh <JIRA_ISSUE_KEY>`.
