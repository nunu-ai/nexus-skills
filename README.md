# nexus-skills

skills for the [nunu.ai](https://nunu.ai) nexus mcp/platform.

## Skills

- **verification-test-authoring** — author, port, and edit high-quality verification tests for the nexus platform
- **flaky-test-refinement** — diagnose and stabilize flaky verification tests by comparing matched run history

## Install

> [!NOTE]
> The visual installation flows below are for the desktop apps.

### Claude Desktop

1. Open **Settings → Plugins**.
2. Open the **Add** menu and select **Add marketplace**.

![Open the Add menu and select Add marketplace](assets/claude-plugins.png)

3. Enter `https://github.com/nunu-ai/nexus-skills`, keep automatic syncing
   enabled, and select **Sync**.

![Add the nunu.ai Nexus Skills marketplace](assets/claude-add-marketplace.png)

4. Browse the marketplace and install **Nexus Skills**.

### Codex Desktop

1. Open **Plugins**.
2. Open the **Add** menu and select **Add a marketplace**.

![Open the Add menu and select Add a marketplace](assets/gpt-plugins.png)

3. Enter `https://github.com/nunu-ai/nexus-skills` as the source and select
   **Add marketplace**.

![Add the nunu.ai Nexus Skills marketplace](assets/gpt-add-marketplace.png)

4. Browse the plugin directory and install **Nexus Skills**.

### Claude Code CLI

```shell
/plugin marketplace add nunu-ai/nexus-skills
/plugin install nexus-skills@nunu-ai
```

### Codex CLI

Add this repository as a Codex plugin marketplace:

```shell
codex plugin marketplace add nunu-ai/nexus-skills
```

Then restart Codex and install `Nexus Skills` from the `nunu.ai Plugins`
marketplace.

## Update

### In Claude Code

Refresh the marketplace first, then update the installed plugin:

```shell
/plugin marketplace update nunu-ai
/plugin update nexus-skills@nunu-ai
```

### In Codex

Open the plugin directory, choose the `nunu.ai Plugins` marketplace, and update
`Nexus Skills`.
