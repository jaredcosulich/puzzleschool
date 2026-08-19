"""Tests for the mode-interpretation helpers the Claude Code hooks share.

Run with the standard library, no dependency to install:

    python3 -m unittest discover -s .claude/hooks -p 'test_*.py'

The three helpers covered here decide what the user reads on every turn
(`mode_display_prefix`), whether build-flow guardrail copy applies at all
(`mode_is_build`), and which slug a refusal steers toward
(`_commit_gate_phrase`). Each one's docstring makes the same promise: an
UNRECOGNIZED mode must degrade in the safe direction, because a shipped hook
copy is routinely older than the binary emitting the mode. That forward-
compatibility contract is the thing worth pinning — a regression in it is
silent, and it misinforms rather than crashes.
"""

import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from _step_metadata import (  # noqa: E402
    _MODE_DISPLAY_PREFIXES,
    _NON_BUILD_MODES,
    mode_display_prefix,
    mode_is_build,
)

# The pretool hook's filename is not an identifier, so it cannot be reached by
# a normal `import` statement.
_commit_gate_phrase = __import__("editor-pretool-hook")._commit_gate_phrase


class ModeDisplayPrefixTest(unittest.TestCase):
    def test_every_shipped_mode_renders_its_own_prefix(self):
        self.assertEqual(mode_display_prefix("ui"), "UI Flow")
        self.assertEqual(mode_display_prefix("backend"), "Backend Flow")
        self.assertEqual(mode_display_prefix("assist"), "Assist")
        self.assertEqual(mode_display_prefix("design"), "Design Round")

    def test_only_builds_say_flow(self):
        # The non-build modes must not carry build framing in the banner:
        # "Flow" is the word the assist and design tracks exist to avoid.
        for mode in _NON_BUILD_MODES:
            self.assertNotIn("Flow", mode_display_prefix(mode))

    def test_unknown_mode_titlecases_itself_rather_than_claiming_ui(self):
        # The regression this guards: an unrecognized mode used to fall back
        # to `ui`, so an assist session announced "UI Flow Step 1/28 (Plan)"
        # on a four-step track with no plan step. Misspelling its own name is
        # the acceptable failure; impersonating another workflow is not.
        self.assertEqual(mode_display_prefix("research"), "Research")
        self.assertEqual(mode_display_prefix("data-migration"), "Data Migration")
        self.assertEqual(mode_display_prefix("data_migration"), "Data Migration")
        self.assertNotEqual(mode_display_prefix("research"), "UI Flow")

    def test_absent_mode_falls_back_to_ui(self):
        # Distinct from an unrecognized mode: nothing was emitted at all, so
        # there is no name to render and the default flow is the honest read.
        for empty in (None, "", "   ", 0, [], {}):
            self.assertEqual(mode_display_prefix(empty), _MODE_DISPLAY_PREFIXES["ui"])


class ModeIsBuildTest(unittest.TestCase):
    def test_shipped_build_modes(self):
        self.assertTrue(mode_is_build("ui"))
        self.assertTrue(mode_is_build("backend"))

    def test_shipped_non_build_modes(self):
        self.assertFalse(mode_is_build("assist"))
        self.assertFalse(mode_is_build("design"))

    def test_unknown_mode_counts_as_a_build(self):
        # Conservative direction, per the docstring: keep the guardrail copy
        # for a mode this hook copy has never heard of. The inverse default
        # would let a newer emitter silently relax a real build flow's
        # framing against an older shipped hook.
        self.assertTrue(mode_is_build("research"))
        self.assertTrue(mode_is_build("some-future-mode"))

    def test_absent_mode_counts_as_a_build(self):
        for empty in (None, "", "   ", 0, [], {}):
            self.assertTrue(mode_is_build(empty))

    def test_agrees_with_the_prefix_table(self):
        # The two helpers read the same emitted field and must not disagree
        # about a shipped mode: anything the prefix table calls a "Flow" is a
        # build, and anything it does not, is not.
        for mode, prefix in _MODE_DISPLAY_PREFIXES.items():
            self.assertEqual(mode_is_build(mode), "Flow" in prefix, mode)


class CommitGatePhraseTest(unittest.TestCase):
    def test_build_flow_single_slug(self):
        # The build flow's set is exactly ["commit"], and this must render
        # the wording that predated the helper.
        self.assertEqual(_commit_gate_phrase(["commit"]), "`commit`")

    def test_assist_flow_names_its_own_gate(self):
        # The regression this guards: hard-coded "advance until the `commit`
        # slug" told an assist session to walk toward a slug its four-step
        # track does not contain.
        self.assertEqual(_commit_gate_phrase(["assist-wrap"]), "`assist-wrap`")

    def test_multiple_slugs_are_joined_and_sorted(self):
        self.assertEqual(_commit_gate_phrase(["b", "a"]), "`a` / `b`")

    def test_empty_falls_back_to_commit(self):
        for empty in (None, [], ()):
            self.assertEqual(_commit_gate_phrase(empty), "`commit`")

    def test_non_string_entries_are_dropped(self):
        # The slugs come from parsed cache JSON, so a malformed entry must
        # not crash a refusal that is already reporting a different problem.
        self.assertEqual(_commit_gate_phrase(["commit", None, 3, {}]), "`commit`")
        self.assertEqual(_commit_gate_phrase([None, 3]), "`commit`")


if __name__ == "__main__":
    unittest.main()
