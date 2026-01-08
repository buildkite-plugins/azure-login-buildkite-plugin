# Azure Login Buildkite Plugin

A Buildkite plugin that authenticates to Azure using managed identity or service principal credentials.

## Authentication Methods

This plugin supports two authentication methods:

1. **Managed Identity** - Uses Azure managed identity (`az login --identity`). Ideal for agents running on Azure VMs or Azure Container Instances with assigned managed identities.

2. **Service Principal** - Uses Azure service principal credentials (`az login --service-principal`). Suitable for any environment where you have service principal credentials available.

## Options

### `hook` (optional, string)

Which Buildkite hook to run the Azure login in. Valid values are `environment` and `pre-command`.

Default: `environment`

### `use-identity` (optional, boolean)

When set to `true`, authenticates using managed identity (`az login --identity`).

Default: `false`

### `client-id` (optional, string)

The Application (client) ID for service principal authentication. When using managed identity with multiple identities assigned, this can be used to specify which identity to use.

### `client-secret` (optional, string)

The client secret for service principal authentication. This can be either:
- A direct secret value
- An environment variable name containing the secret (the plugin will resolve it)

Required when using service principal authentication.

### `tenant-id` (optional, string)

The Azure tenant ID. Required when using service principal authentication.

## Examples

### Managed Identity

Authenticate using the Azure managed identity assigned to the VM or container:

```yaml
steps:
  - label: ":azure: Deploy to Azure"
    command: "az account show"
    plugins:
      - azure-login#v1.0.0:
          use-identity: true
```

### Managed Identity with Specific Client ID

When multiple managed identities are assigned, specify which one to use:

```yaml
steps:
  - label: ":azure: Deploy to Azure"
    command: "az account show"
    plugins:
      - azure-login#v1.0.0:
          use-identity: true
          client-id: "00000000-0000-0000-0000-000000000000"
```

### Service Principal

Authenticate using service principal credentials:

```yaml
steps:
  - label: ":azure: Deploy to Azure"
    command: "az account show"
    plugins:
      - azure-login#v1.0.0:
          client-id: "00000000-0000-0000-0000-000000000000"
          client-secret: "your-client-secret"
          tenant-id: "00000000-0000-0000-0000-000000000000"
```

### Service Principal with Environment Variable Secret

Use an environment variable to provide the client secret:

```yaml
steps:
  - label: ":azure: Deploy to Azure"
    command: "az account show"
    env:
      AZURE_CLIENT_SECRET: "your-client-secret"
    plugins:
      - azure-login#v1.0.0:
          client-id: "00000000-0000-0000-0000-000000000000"
          client-secret: "AZURE_CLIENT_SECRET"
          tenant-id: "00000000-0000-0000-0000-000000000000"
```

### Using pre-command Hook

Run the Azure login in the pre-command hook instead of the environment hook:

```yaml
steps:
  - label: ":azure: Deploy to Azure"
    command: "az account show"
    plugins:
      - azure-login#v1.0.0:
          hook: pre-command
          use-identity: true
```

### Debug Mode

Enable verbose logging for troubleshooting:

```yaml
steps:
  - label: ":azure: Deploy to Azure"
    command: "az account show"
    env:
      BUILDKITE_PLUGIN_DEBUG: "true"
    plugins:
      - azure-login#v1.0.0:
          use-identity: true
```

## Compatibility

| Elastic Stack | Agent Stack K8s | Hosted (Mac) | Hosted (Linux) | Notes |
| :-----------: | :-------------: | :----------: | :------------: | :---- |
|       ?       |        ?        |      ?       |       ?        | Requires Azure CLI (`az`) to be installed |

## Developing

Run all tests:

```bash
docker run -it --rm -v "$PWD:/plugin:ro" buildkite/plugin-tester
```

Validate plugin structure:

```bash
docker run -it --rm -v "$PWD:/plugin:ro" buildkite/plugin-linter --id azure-login --path /plugin
```

Run shellcheck:

```bash
shellcheck hooks/* lib/*
```

## License

MIT License. See [LICENSE](LICENSE) for details.
