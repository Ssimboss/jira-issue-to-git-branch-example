#!/bin/bash

show_help() {
  cat << EOF
Usage: $0 <JIRA_ISSUE_KEY>

Creates a git branch from a JIRA issue.

Arguments:
  JIRA_ISSUE_KEY    JIRA issue key (e.g., PROD-1234)

The branch will be created as: feature/<sanitized_issue_summary>

Requirements:
  - Must be run from the root of a git repository
  - local.properties file must contain:
      jira.url="https://your-domain.atlassian.net"
      jira.email="your-email@example.com"
      jira.api_token="your-api-token"

Examples:
  $0 PROD-1234
  $0 DEV-567
EOF
  exit 0
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
  show_help
fi

if [ ! -d ".git" ]; then
    echo "Error: Must be run from the root of a git repository"
    exit 1
fi

ISSUE_KEY="$1"

if [ -z "$ISSUE_KEY" ]; then
  echo "Error: Issue key(Task Number) is required"
  echo "Example: $0 PROD-12345"
  exit 2
fi

get_local_property() {
  local key="$1"
  local file="local.properties"
  local line
  line=$(grep -m1 "^${key}=" "$file" 2>/dev/null || true)
  if [ -z "$line" ]; then
    return 1
  fi
  printf '%s' "${line#*=}" | tr -d '"'
}

if ! JIRA_URL=$(get_local_property "jira.url"); then
  echo "Error: local.properties missing jira.url"
  exit 3
fi
if ! JIRA_EMAIL=$(get_local_property "jira.email"); then
  echo "Error: local.properties missing jira.email"
  exit 4
fi
if ! JIRA_API_TOKEN=$(get_local_property "jira.api_token"); then
  echo "Error: local.properties missing jira.api_token"
  exit 5
fi

response=$(curl -s -w "\n%{http_code}" \
        -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
        "$JIRA_URL/rest/api/3/issue/$ISSUE_KEY?fields=summary")
        
http_code=$(echo "$response" | tail -n1)
if [ "$http_code" -eq 200 ]; then
  body=$(echo "$response" | sed '$d')
  summary=$(echo "$body" | jq -r '.fields.summary')
  formatted_summary=$(echo "$summary" | sed 's/[^a-zA-Z0-9]/_/g; s/__*/_/g; s/^_//; s/_$//')
  branch="feature/$ISSUE_KEY-$formatted_summary"
  git checkout -b "$branch"
  exit 0
elif [ "$http_code" -eq 404 ]; then
  echo "Error: Issue(Task) $ISSUE_KEY does not exist"
  exit 6
else
  echo "Error: unexpected HTTP-code $http_code"
  exit 7
fi

