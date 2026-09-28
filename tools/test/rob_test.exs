# Tests for tools/rob. Each test builds a throwaway workspace and drives the real CLI.
# Run: elixir tools/test/rob_test.exs

ExUnit.start()

defmodule RobTest do
  use ExUnit.Case, async: true

  @rob Path.expand("../rob", __DIR__)

  @legacy_done """
  # op-100 — Explorer: legacy returned op

  op-100 | role: **Explorer** | state: **[Done — returned, not yet validated]** |
  DISPATCH: **CONSUMED**

  ## Body
  original text stays
  """

  setup do
    ws = Path.join(System.tmp_dir!(), "rob-test-#{System.unique_integer([:positive])}")
    root = Path.join(ws, "rmx-arranger")
    File.mkdir_p!(Path.join(root, "tools"))
    File.cp!(@rob, Path.join(root, "tools/rob"))
    File.mkdir_p!(Path.join(root, "doc/activation"))
    File.mkdir_p!(Path.join(root, "idq"))
    File.write!(Path.join(root, "idq/id-042-preview.md"), "# id-042\n")
    File.write!(Path.join(root, "arranger-swap.md"), "journal\n")
    File.write!(Path.join(root, "doc/activation/op-100-activation.md"), @legacy_done)
    on_exit(fn -> File.rm_rf!(ws) end)
    %{ws: ws, root: root}
  end

  defp rob(ctx, args, opts \\ []) do
    {out, code} = System.cmd("elixir", [Path.join(ctx.root, "tools/rob") | args], stderr_to_stdout: true)
    if Keyword.get(opts, :ok, true), do: assert(code == 0, out)
    {out, code}
  end

  defp op_path(ctx, oid), do: Path.join(ctx.root, "doc/activation/#{oid}-activation.md")
  defp read_op(ctx, oid), do: File.read!(op_path(ctx, oid))
  defp write_op(ctx, oid, text), do: File.write!(op_path(ctx, oid), text)

  test "legacy header is mapped and listed", ctx do
    assert elem(rob(ctx, ["board"]), 0) =~ "[returned]: op-100"
    assert elem(rob(ctx, ["list"]), 0) =~ "(legacy [Done"
  end

  test "next id starts above the legacy floor", ctx do
    assert String.trim(elem(rob(ctx, ["next-id"]), 0)) == "op-361"
  end

  test "prose mentions do not reserve ids", ctx do
    File.write!(Path.join(ctx.root, "arranger-swap.md"), "next: relay op-900\n")
    assert String.trim(elem(rob(ctx, ["next-id"]), 0)) == "op-361"
  end

  test "next id follows the highest op file", ctx do
    write_op(ctx, "op-400", "---\nid: op-400\nstate: draft\nagent: a\nrepo: r\n---\n# op-400 — t\n")
    assert String.trim(elem(rob(ctx, ["next-id"]), 0)) == "op-401"
  end

  test "new requires agent and repo", ctx do
    {out, code} = rob(ctx, ["new", "x", "agent=a"], ok: false)
    assert code != 0
    assert out =~ "repo="
  end

  test "new creates a draft pointing at OPS.md", ctx do
    {out, _} = rob(ctx, ["new", "Gatekeeper: t", "agent=gk", "repo=rmx-gatekeeper", "idq=id-042"])
    assert out =~ "op-361-activation.md"
    text = read_op(ctx, "op-361")
    assert String.starts_with?(text, "---\nid: op-361\nstate: draft\n")
    assert text =~ "OPS.md in your repo"
    refute text =~ "REPORT op-"
    assert elem(rob(ctx, ["board"]), 0) =~ "[draft]: op-361"
  end

  test "show renders the relay view without front matter", ctx do
    rob(ctx, ["new", "Gatekeeper: t", "agent=gk", "repo=rmx-gatekeeper", "authority=no guest"])
    {shown, _} = rob(ctx, ["show", "361"])
    assert String.starts_with?(shown, "# op-361 — Gatekeeper: t\nagent: gk | repo: rmx-gatekeeper")
    assert shown =~ "authority: no guest"
    refute shown =~ "state: draft"
    assert String.starts_with?(elem(rob(ctx, ["show", "361", "--raw"]), 0), "---\n")
  end

  test "valid transitions and legacy conversion keep the body", ctx do
    assert elem(rob(ctx, ["set", "100", "closed", "gate=self"]), 0) =~ "returned -> closed"
    text = read_op(ctx, "op-100")
    assert String.starts_with?(text, "---\nid: op-100\nstate: closed\ngate: self\n")
    assert text =~ "legacy-state: Done"
    assert String.ends_with?(text, @legacy_done)
  end

  test "invalid transition is refused unless forced", ctx do
    rob(ctx, ["new", "t", "agent=a", "repo=r"])
    {out, code} = rob(ctx, ["set", "361", "closed"], ok: false)
    assert code != 0
    assert out =~ "draft -> closed is not allowed"
    assert elem(rob(ctx, ["set", "361", "closed", "--force"]), 0) =~ "draft -> closed"
  end

  test "same state updates fields only", ctx do
    rob(ctx, ["new", "t", "agent=a", "repo=r"])
    rob(ctx, ["set", "361", "draft", "needs=op-100"])
    assert read_op(ctx, "op-361") =~ "needs: op-100"
  end

  test "check reports dangling needs, missing idq, and stale ops", ctx do
    write_op(ctx, "op-300", "---\nid: op-300\nstate: returned\nagent: a\nrepo: r\nidq: id-999\n" <>
                              "needs: op-999\nupdated: 2026-01-01T00:00Z\n---\n# op-300 — t\n")
    {out, code} = rob(ctx, ["check"], ok: false)
    assert code == 1
    assert out =~ "needs unknown op-999"
    assert out =~ "idq id-999 has no file"
    assert out =~ "returned"
    assert out =~ "days ago with no progress"
  end

  test "check flags a repo that does not exist", ctx do
    rob(ctx, ["new", "t", "agent=a", "repo=rmx-nowhere (nested)"])
    assert elem(rob(ctx, ["check"], ok: false), 0) =~ "repo rmx-nowhere not found"
  end

  test "check does not look for a repo on another host", ctx do
    rob(ctx, ["new", "t", "agent=a", "repo=mm4:/Users/x/rmx-far", "idq=id-042"])
    assert elem(rob(ctx, ["check"]), 0) =~ "0 with problems"
  end

  test "check passes on a clean workspace", ctx do
    File.mkdir_p!(Path.join(ctx.ws, "r"))
    rob(ctx, ["new", "t", "agent=a", "repo=r", "idq=id-042"])
    assert elem(rob(ctx, ["check"]), 0) =~ "0 with problems"
  end

  test "board says so when nothing is live", ctx do
    rob(ctx, ["set", "100", "closed"])
    assert String.trim(elem(rob(ctx, ["board"]), 0)) == "(no live ops)"
  end
end
