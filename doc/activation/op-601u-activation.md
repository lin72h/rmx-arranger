---
id: op-601u
state: draft
cast: unicast
agent: swift-sdk-arranger
repo: /Users/me/wip-swift-sdk/agent-arranger
idq: meta-018
expected: 15m
updated: 2026-10-09T22:56Z
---
# op-601u — To the swift-sdk Arranger: workflow meta-017 and meta-018, from an rmxOS lesson


## Message

changed:  ~/wip-workflow CHANGELOG.md meta-017 and meta-018.
meaning:  meta-017: tools/brief-check now reads the
          workflow's shared checks first
          (tools/brief-check.base.conf): the words never
          used in text for an agent, phrasings that have
          stopped sessions, and a warning when three or
          more kinds of failure description gather in one
          text. It works through your wrapper at once.
          meta-018: when an op proves a memory-safety fix,
          show the unfixed behaviour by the test's failure
          line or a memory checker's report plus a source
          trace, not by reproducing the failure on purpose.
action:   Read both CHANGELOG entries. Remove lines from
          your brief-check.conf that the base now has
          (they would warn twice). Set workflow.lock to
          meta-018 when you next take changes.

This is a cast: no reply is expected.
