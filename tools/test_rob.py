#!/usr/bin/env python3
"""Tests for tools/rob. Each test builds a throwaway workspace and drives the real CLI.

Run: python3 -B tools/test_rob.py
"""
import pathlib
import shutil
import subprocess
import sys
import tempfile
import textwrap
import unittest

ROB = pathlib.Path(__file__).resolve().parent / "rob"

LEGACY_DONE = textwrap.dedent("""\
    # op-100 — Explorer: legacy returned op

    op-100 | role: **Explorer** | state: **[Done — returned, not yet validated]** |
    DISPATCH: **CONSUMED**

    ## Body
    original text stays
    """)


class RobTest(unittest.TestCase):
    def setUp(self):
        self.root = pathlib.Path(tempfile.mkdtemp())
        (self.root / "tools").mkdir()
        shutil.copy(ROB, self.root / "tools" / "rob")
        (self.root / "doc" / "activation").mkdir(parents=True)
        (self.root / "idq").mkdir()
        (self.root / "idq" / "id-042-preview.md").write_text("# id-042\n")
        (self.root / "arranger-swap.md").write_text("journal mentions chat-only op-205\n")
        self.write("op-100", LEGACY_DONE)

    def tearDown(self):
        shutil.rmtree(self.root)

    def write(self, oid, text):
        (self.root / "doc" / "activation" / f"{oid}-activation.md").write_text(text)

    def read(self, oid):
        return (self.root / "doc" / "activation" / f"{oid}-activation.md").read_text()

    def rob(self, *args, ok=True):
        r = subprocess.run([sys.executable, "-B", str(self.root / "tools" / "rob"), *args],
                           capture_output=True, text=True)
        if ok:
            self.assertEqual(r.returncode, 0, r.stderr + r.stdout)
        return r

    def test_legacy_header_is_mapped_and_listed(self):
        self.assertIn("[returned]: op-100", self.rob("board").stdout)
        self.assertIn("(legacy [Done", self.rob("list").stdout)

    def test_next_id_skips_ids_mentioned_only_in_the_journal(self):
        self.assertEqual(self.rob("next-id").stdout.strip(), "op-206")

    def test_new_requires_agent_and_repo(self):
        r = self.rob("new", "x", "agent=a", ok=False)
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("repo=", r.stderr)

    def test_new_creates_draft_pointing_at_ops_md(self):
        out = self.rob("new", "Gatekeeper: t", "agent=gk", "repo=rmx-gatekeeper", "idq=id-042").stdout
        self.assertIn("op-206-activation.md", out)
        text = self.read("op-206")
        self.assertTrue(text.startswith("---\nid: op-206\nstate: draft\n"))
        self.assertIn("OPS.md in your repo", text)
        self.assertNotIn("REPORT op-", text)
        self.assertIn("[draft]: op-206", self.rob("board").stdout)

    def test_show_renders_relay_view_without_front_matter(self):
        self.rob("new", "Gatekeeper: t", "agent=gk", "repo=rmx-gatekeeper", "authority=no guest")
        shown = self.rob("show", "206").stdout
        self.assertTrue(shown.startswith("# op-206 — Gatekeeper: t\nagent: gk | repo: rmx-gatekeeper"))
        self.assertIn("authority: no guest", shown)
        self.assertNotIn("state: draft", shown)
        self.assertTrue(self.rob("show", "206", "--raw").stdout.startswith("---\n"))

    def test_valid_transitions_and_legacy_conversion_keep_the_body(self):
        self.assertIn("returned -> closed", self.rob("set", "100", "closed", "gate=self").stdout)
        text = self.read("op-100")
        self.assertTrue(text.startswith("---\nid: op-100\nstate: closed\ngate: self\n"))
        self.assertIn("legacy-state: Done", text)
        self.assertTrue(text.endswith(LEGACY_DONE))

    def test_invalid_transition_is_refused_unless_forced(self):
        self.rob("new", "t", "agent=a", "repo=r")
        r = self.rob("set", "206", "closed", ok=False)
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("draft -> closed is not allowed", r.stderr)
        self.assertIn("draft -> closed", self.rob("set", "206", "closed", "--force").stdout)

    def test_same_state_updates_fields_only(self):
        self.rob("new", "t", "agent=a", "repo=r")
        self.rob("set", "206", "draft", "needs=op-100")
        self.assertIn("needs: op-100", self.read("op-206"))

    def test_check_reports_dangling_needs_missing_idq_and_stale_ops(self):
        self.write("op-300", "---\nid: op-300\nstate: returned\nagent: a\nrepo: r\n"
                             "idq: id-999\nneeds: op-999\nupdated: 2026-01-01T00:00Z\n---\n# op-300 — t\n")
        r = self.rob("check", ok=False)
        self.assertEqual(r.returncode, 1)
        self.assertIn("needs unknown op-999", r.stdout)
        self.assertIn("idq id-999 has no file", r.stdout)
        self.assertIn("returned", r.stdout)
        self.assertIn("days ago with no progress", r.stdout)

    def test_check_passes_on_a_clean_workspace(self):
        self.rob("new", "t", "agent=a", "repo=r", "idq=id-042")
        self.assertIn("0 with problems", self.rob("check").stdout)

    def test_board_says_so_when_nothing_is_live(self):
        self.rob("set", "100", "closed")
        self.assertEqual(self.rob("board").stdout.strip(), "(no live ops)")


if __name__ == "__main__":
    unittest.main()
