#!/usr/bin/env bats

setup() {
  load "${BATS_PLUGIN_PATH}/load.bash"

  # Uncomment to enable stub debugging
  # export AZ_STUB_DEBUG=/dev/tty
}

teardown() {
  unstub az || true
}

@test "Managed identity login in pre-command hook" {
  export BUILDKITE_PLUGIN_AZURE_LOGIN_HOOK="pre-command"
  export BUILDKITE_PLUGIN_AZURE_LOGIN_USE_IDENTITY="true"

  stub az "login --identity : echo 'Logged in with managed identity'"

  run "$PWD"/hooks/pre-command

  assert_success
  assert_output --partial "Authenticating to Azure using managed identity"
  assert_output --partial "Azure login successful"

  unstub az
}

@test "Service principal login in pre-command hook" {
  export BUILDKITE_PLUGIN_AZURE_LOGIN_HOOK="pre-command"
  export BUILDKITE_PLUGIN_AZURE_LOGIN_CLIENT_ID="test-client-id"
  export BUILDKITE_PLUGIN_AZURE_LOGIN_CLIENT_SECRET="test-secret"
  export BUILDKITE_PLUGIN_AZURE_LOGIN_TENANT_ID="test-tenant-id"

  stub az "login --service-principal --username test-client-id --password test-secret --tenant test-tenant-id : echo 'Logged in with service principal'"

  run "$PWD"/hooks/pre-command

  assert_success
  assert_output --partial "Authenticating to Azure using service principal"
  assert_output --partial "Azure login successful"

  unstub az
}

@test "Does not run in pre-command hook by default" {
  export BUILDKITE_PLUGIN_AZURE_LOGIN_USE_IDENTITY="true"

  run "$PWD"/hooks/pre-command

  assert_success
  refute_output --partial "Authenticating to Azure"
}

@test "Does not run in pre-command hook when hook is set to environment" {
  export BUILDKITE_PLUGIN_AZURE_LOGIN_HOOK="environment"
  export BUILDKITE_PLUGIN_AZURE_LOGIN_USE_IDENTITY="true"

  run "$PWD"/hooks/pre-command

  assert_success
  refute_output --partial "Authenticating to Azure"
}
