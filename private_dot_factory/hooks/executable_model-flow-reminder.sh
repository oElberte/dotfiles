#!/bin/sh
# Inject the plan -> code -> review flow reminder on every user prompt.
# Must never fail: a non-zero exit would block and erase the prompt.

cat << 'EOF'
{
  "suppressOutput": true,
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "Model flow reminder: for any non-trivial code change, run the loop automatically — never wait for a manual trigger. 1) Delegate planning to the planner droid (brief: files, approach, constraints, validation). 2) Delegate implementation to the coder droid with that brief; do not write the implementation yourself. 3) Delegate the diff to the reviewer droid; loop coder -> reviewer on corrections, stop and report after 3 failed loops. Skip the loop and handle directly: trivial edits (one-liners, typos, config tweaks), pure Q&A, and exploration. Use the git droid for status/diff/commit-message chores. Pass compact artifacts, not transcripts."
  }
}
EOF
exit 0
