#!/usr/bin/env python3
"""Tests for tools/roles. Each test builds a throwaway workspace and drives the real CLI.

Run: python3 -B tools/test_roles.py
"""
import os
import pathlib
import shutil
import subprocess
import sys
import tempfile
import unittest

ROLES = pathlib.Path(__file__).resolve().parent / "roles"


class RolesTest(unittest.TestCase):
    def setUp(self):
        self.ws = pathlib.Path(tempfile.mkdtemp())
        self.put("rmx-role0/template.toml", '[vars]\nproject = "rmxOS"\n')
        self.put("rmx-role0/partials/notice.md", "NOTICE rule for {{id}}.\n")
        self.put("rmx-thing0/template.toml",
                 'parent = "role0"\n[vars]\nstrength = "default strength"\n')
        self.put("rmx-thing0/files/AGENTS.md",
                 "# {{instance}} — Thing {{n}} ({{class}})\n"
                 "Project {{project}}; strength: {{strength}}.\n"
                 "{{> notice}}\n"
                 "{{#block extra}}base extra{{/block}}\n")
        self.put("rmx-thing0/files/docs/guide.md", "Guide for {{id}}.\n")
        self.put("rmx-thing1/instance.toml",
                 'class = "thing0"\n[vars]\nstrength = "completeness"\n'
                 '[blocks]\nextra = "{{super}} + thing1 extra"\n')

    def tearDown(self):
        shutil.rmtree(self.ws)

    def put(self, rel, text):
        p = self.ws / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text)

    def read(self, rel):
        return (self.ws / rel).read_text()

    def roles(self, *args, ok=True):
        r = subprocess.run([sys.executable, "-B", str(ROLES), *args], capture_output=True, text=True,
                           env={**os.environ, "ROLES_WORKSPACE": str(self.ws)})
        if ok:
            self.assertEqual(r.returncode, 0, r.stderr + r.stdout)
        return r

    def test_render_applies_vars_includes_blocks_and_super(self):
        self.roles("render", "rmx-thing1")
        text = self.read("rmx-thing1/AGENTS.md")
        self.assertTrue(text.startswith("<!-- Rendered by the Arranger from the thing0 template for thing1."))
        self.assertIn("# rmx-thing1 — Thing 1 (thing0)", text)
        self.assertIn("Project rmxOS; strength: completeness.", text)
        self.assertIn("NOTICE rule for thing1.", text)
        self.assertIn("base extra + thing1 extra", text)
        self.assertIn("Guide for thing1.", self.read("rmx-thing1/docs/guide.md"))

    def test_render_creates_lock_and_local_md_and_is_idempotent(self):
        self.roles("render", "rmx-thing1")
        self.assertTrue((self.ws / "rmx-thing1/.rendered.lock").is_file())
        self.assertIn("This file is yours", self.read("rmx-thing1/LOCAL.md"))
        self.put("rmx-thing1/LOCAL.md", "my notes\n")
        self.assertIn("up to date", self.roles("render", "rmx-thing1").stdout)
        self.assertEqual(self.read("rmx-thing1/LOCAL.md"), "my notes\n")

    def test_template_change_makes_instance_stale_then_render_updates_it(self):
        self.roles("render", "rmx-thing1")
        self.put("rmx-thing0/files/docs/guide.md", "New guide for {{id}}.\n")
        r = self.roles("check", ok=False)
        self.assertEqual(r.returncode, 1)
        self.assertIn("stale: docs/guide.md", r.stdout)
        self.roles("render", "rmx-thing1")
        self.assertEqual(self.read("rmx-thing1/docs/guide.md").splitlines()[1], "New guide for thing1.")
        self.assertIn("0 need attention", self.roles("check").stdout)

    def test_local_edits_to_rendered_files_block_render_unless_forced(self):
        self.roles("render", "rmx-thing1")
        self.put("rmx-thing1/AGENTS.md", "hand edited\n")
        r = self.roles("render", "rmx-thing1", ok=False)
        self.assertIn("edited locally: AGENTS.md", r.stderr)
        self.assertEqual(self.read("rmx-thing1/AGENTS.md"), "hand edited\n")
        self.roles("render", "rmx-thing1", "--force")
        self.assertIn("Thing 1", self.read("rmx-thing1/AGENTS.md"))

    def test_existing_unmanaged_files_need_adopt(self):
        self.put("rmx-thing1/AGENTS.md", "old instructions\n")
        r = self.roles("render", "rmx-thing1", ok=False)
        self.assertIn("differ from the render: AGENTS.md", r.stderr)
        self.roles("render", "rmx-thing1", "--adopt")
        self.assertIn("Thing 1", self.read("rmx-thing1/AGENTS.md"))

    def test_child_template_overrides_parent_partial(self):
        self.put("rmx-thing0/partials/notice.md", "Thing-specific notice for {{id}}.\n")
        self.roles("render", "rmx-thing1")
        self.assertIn("Thing-specific notice for thing1.", self.read("rmx-thing1/AGENTS.md"))

    def test_unknown_variable_and_unmatched_block_fail(self):
        self.put("rmx-thing0/files/bad.md", "{{nope}}\n")
        self.assertIn("unknown variable {{nope}}", self.roles("render", "rmx-thing1", ok=False).stderr)
        self.put("rmx-thing0/files/bad.md", "{{#block open}} never closed\n")
        self.assertIn("unmatched {{#block", self.roles("render", "rmx-thing1", ok=False).stderr)

    def test_singleton_role_keeps_its_template_inside_its_repo(self):
        self.put("rmx-solo/solo0/template.toml", 'parent = "role0"\n')
        self.put("rmx-solo/solo0/files/AGENTS.md", "# {{instance}} ({{id}}, n={{n}}, template {{template}})\n")
        self.put("rmx-solo/instance.toml", 'class = "solo0"\n')
        self.roles("render", "rmx-solo")
        self.assertIn("# rmx-solo (solo, n=1, template solo0/)", self.read("rmx-solo/AGENTS.md"))

    def test_template_builtin_is_relative_to_the_instance(self):
        self.put("rmx-thing0/files/where.md", "template {{template}}\n")
        self.roles("render", "rmx-thing1")
        self.assertIn("template ../rmx-thing0/", self.read("rmx-thing1/where.md"))

    def test_a_template_in_two_places_is_an_error(self):
        self.put("rmx-thing/thing0/template.toml", 'parent = "role0"\n')
        self.assertIn("more than one place", self.roles("render", "rmx-thing1", ok=False).stderr)

    def test_symlinked_instance_folders_are_not_listed_twice(self):
        self.roles("render", "rmx-thing1")
        os.symlink("rmx-thing1", self.ws / "rmx-oldname")
        self.assertEqual(self.roles("list").stdout.count("rmx-thing1:"), 1)
        self.assertNotIn("rmx-oldname", self.roles("list").stdout)


if __name__ == "__main__":
    unittest.main()
