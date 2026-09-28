# Tests for tools/roles. Each test builds a throwaway workspace and drives the real CLI.
# Run: elixir tools/test/roles_test.exs

ExUnit.start()

defmodule RolesTest do
  use ExUnit.Case, async: true

  @roles Path.expand("../roles", __DIR__)

  setup do
    ws = Path.join(System.tmp_dir!(), "roles-test-#{System.unique_integer([:positive])}")
    File.mkdir_p!(ws)
    on_exit(fn -> File.rm_rf!(ws) end)
    ctx = %{ws: ws}
    put(ctx, "rmx-role0/template.json", ~s({"vars": {"project": "rmxOS"}}))
    put(ctx, "rmx-role0/partials/notice.md", "NOTICE rule for {{id}}.\n")
    put(ctx, "rmx-thing0/template.json", ~s({"parent": "role0", "vars": {"strength": "default strength"}}))

    put(ctx, "rmx-thing0/files/AGENTS.md", """
    # {{instance}} — Thing {{n}} ({{class}})
    Project {{project}}; strength: {{strength}}.
    {{> notice}}
    {{#block extra}}base extra{{/block}}
    """)

    put(ctx, "rmx-thing0/files/docs/guide.md", "Guide for {{id}}.\n")

    put(ctx, "rmx-thing1/instance.json",
        ~s({"class": "thing0", "vars": {"strength": "completeness"},) <>
          ~s( "blocks": {"extra": "{{super}} + thing1 extra"}}))

    ctx
  end

  defp put(ctx, rel, text) do
    path = Path.join(ctx.ws, rel)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, text)
  end

  defp read(ctx, rel), do: File.read!(Path.join(ctx.ws, rel))

  defp roles(ctx, args, opts \\ []) do
    {out, code} =
      System.cmd("elixir", [@roles | args], stderr_to_stdout: true, env: [{"ROLES_WORKSPACE", ctx.ws}])

    if Keyword.get(opts, :ok, true), do: assert(code == 0, out)
    {out, code}
  end

  test "render applies vars, includes, blocks, and super", ctx do
    roles(ctx, ["render", "rmx-thing1"])
    text = read(ctx, "rmx-thing1/AGENTS.md")
    assert String.starts_with?(text, "<!-- Rendered by the Arranger from the thing0 template for thing1.")
    assert text =~ "# rmx-thing1 — Thing 1 (thing0)"
    assert text =~ "Project rmxOS; strength: completeness."
    assert text =~ "NOTICE rule for thing1."
    assert text =~ "base extra + thing1 extra"
    assert read(ctx, "rmx-thing1/docs/guide.md") =~ "Guide for thing1."
  end

  test "render creates the lock and LOCAL.md and is idempotent", ctx do
    roles(ctx, ["render", "rmx-thing1"])
    assert File.regular?(Path.join(ctx.ws, "rmx-thing1/.rendered.lock"))
    assert read(ctx, "rmx-thing1/LOCAL.md") =~ "This file is yours"
    put(ctx, "rmx-thing1/LOCAL.md", "my notes\n")
    assert elem(roles(ctx, ["render", "rmx-thing1"]), 0) =~ "up to date"
    assert read(ctx, "rmx-thing1/LOCAL.md") == "my notes\n"
  end

  test "a template change makes the instance stale, then render updates it", ctx do
    roles(ctx, ["render", "rmx-thing1"])
    put(ctx, "rmx-thing0/files/docs/guide.md", "New guide for {{id}}.\n")
    {out, code} = roles(ctx, ["check"], ok: false)
    assert code == 1
    assert out =~ "stale: docs/guide.md"
    roles(ctx, ["render", "rmx-thing1"])
    assert Enum.at(String.split(read(ctx, "rmx-thing1/docs/guide.md"), "\n"), 1) == "New guide for thing1."
    assert elem(roles(ctx, ["check"]), 0) =~ "0 need attention"
  end

  test "local edits to rendered files block render unless forced", ctx do
    roles(ctx, ["render", "rmx-thing1"])
    put(ctx, "rmx-thing1/AGENTS.md", "hand edited\n")
    assert elem(roles(ctx, ["render", "rmx-thing1"], ok: false), 0) =~ "edited locally: AGENTS.md"
    assert read(ctx, "rmx-thing1/AGENTS.md") == "hand edited\n"
    roles(ctx, ["render", "rmx-thing1", "--force"])
    assert read(ctx, "rmx-thing1/AGENTS.md") =~ "Thing 1"
  end

  test "existing unmanaged files need --adopt", ctx do
    put(ctx, "rmx-thing1/AGENTS.md", "old instructions\n")
    assert elem(roles(ctx, ["render", "rmx-thing1"], ok: false), 0) =~ "differ from the render: AGENTS.md"
    roles(ctx, ["render", "rmx-thing1", "--adopt"])
    assert read(ctx, "rmx-thing1/AGENTS.md") =~ "Thing 1"
  end

  test "a child template overrides a parent partial", ctx do
    put(ctx, "rmx-thing0/partials/notice.md", "Thing-specific notice for {{id}}.\n")
    roles(ctx, ["render", "rmx-thing1"])
    assert read(ctx, "rmx-thing1/AGENTS.md") =~ "Thing-specific notice for thing1."
  end

  test "an unknown variable and an unmatched block fail", ctx do
    put(ctx, "rmx-thing0/files/bad.md", "{{nope}}\n")
    assert elem(roles(ctx, ["render", "rmx-thing1"], ok: false), 0) =~ "unknown variable {{nope}}"
    put(ctx, "rmx-thing0/files/bad.md", "{{#block open}} never closed\n")
    assert elem(roles(ctx, ["render", "rmx-thing1"], ok: false), 0) =~ "unmatched {{#block"
  end

  test "a singleton role keeps its template inside its repo", ctx do
    put(ctx, "rmx-solo/solo0/template.json", ~s({"parent": "role0"}))
    put(ctx, "rmx-solo/solo0/files/AGENTS.md", "# {{instance}} ({{id}}, n={{n}}, template {{template}})\n")
    put(ctx, "rmx-solo/instance.json", ~s({"class": "solo0"}))
    roles(ctx, ["render", "rmx-solo"])
    assert read(ctx, "rmx-solo/AGENTS.md") =~ "# rmx-solo (solo, n=1, template solo0/)"
  end

  test "the template built-in is relative to the instance", ctx do
    put(ctx, "rmx-thing0/files/where.md", "template {{template}}\n")
    roles(ctx, ["render", "rmx-thing1"])
    assert read(ctx, "rmx-thing1/where.md") =~ "template ../rmx-thing0/"
  end

  test "a template in two places is an error", ctx do
    put(ctx, "rmx-thing/thing0/template.json", ~s({"parent": "role0"}))
    assert elem(roles(ctx, ["render", "rmx-thing1"], ok: false), 0) =~ "more than one place"
  end

  defp remote_instance(ctx) do
    remote = Path.join(ctx.ws, "far-host/rmx-thing2")
    put(ctx, "rmx-thing2/instance.json", ~s({"class": "thing0", "remote": "#{remote}"}))
    roles(ctx, ["render", "rmx-thing2"])
    remote
  end

  test "sync copies a remote instance's files and creates LOCAL.md only once", ctx do
    remote = remote_instance(ctx)
    assert elem(roles(ctx, ["sync", "rmx-thing2"]), 0) =~ "(LOCAL.md created)"
    assert File.read!(Path.join(remote, "AGENTS.md")) == read(ctx, "rmx-thing2/AGENTS.md")
    assert File.regular?(Path.join(remote, "instance.json"))
    File.write!(Path.join(remote, "LOCAL.md"), "remote notes\n")
    roles(ctx, ["sync", "rmx-thing2"])
    assert File.read!(Path.join(remote, "LOCAL.md")) == "remote notes\n"
  end

  test "sync refuses to overwrite a rendered file edited on the remote", ctx do
    remote = remote_instance(ctx)
    roles(ctx, ["sync", "rmx-thing2"])
    File.write!(Path.join(remote, "AGENTS.md"), "edited over there\n")
    assert elem(roles(ctx, ["sync", "rmx-thing2"], ok: false), 0) =~ "edited on"
    assert File.read!(Path.join(remote, "AGENTS.md")) == "edited over there\n"
    roles(ctx, ["sync", "rmx-thing2", "--force"])
    assert File.read!(Path.join(remote, "AGENTS.md")) =~ "Thing 2"
  end

  test "check reports a mirror rendered but not synced", ctx do
    remote_instance(ctx)
    roles(ctx, ["render", "rmx-thing1"])
    {out, code} = roles(ctx, ["check"], ok: false)
    assert code == 1
    assert out =~ "rmx-thing2: not synced"
    roles(ctx, ["sync", "rmx-thing2"])
    assert elem(roles(ctx, ["check"]), 0) =~ "0 need attention"
  end

  test "symlinked instance folders are not listed twice", ctx do
    roles(ctx, ["render", "rmx-thing1"])
    File.ln_s!("rmx-thing1", Path.join(ctx.ws, "rmx-oldname"))
    {out, _} = roles(ctx, ["list"])
    assert length(String.split(out, "rmx-thing1:")) == 2
    refute out =~ "rmx-oldname"
  end
end
