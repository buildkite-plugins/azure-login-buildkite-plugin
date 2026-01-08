#!/usr/bin/env bats

setup() {
  load "${BATS_PLUGIN_PATH}/load.bash"

  # Uncomment to enable stub debugging
  # export AZ_STUB_DEBUG=/dev/tty
}

teardown() {
  unstub az || true
}

@test "Managed identity login" {
  export BUILDKITE_PLUGIN_AZURE_LOGIN_USE_IDENTITY="true"

  stub az "login --identity : echo 'Logged in with managed identity'"

  run "$PWD"/hooks/environment

  assert_success
  assert_output --partial "Authenticating to Azure using managed identity"
  assert_output --partial "Azure login successful"

  unstub az
}

@test "Managed identity with client-id" {
  export BUILDKITE_PLUGIN_AZURE_LOGIN_USE_IDENTITY="true"
  export BUILDKITE_PLUGIN_AZURE_LOGIN_CLIENT_ID="test-client-id"

  stub az "login --identity --username test-client-id : echo 'Logged in with managed identity'"

  run "$PWD"/hooks/environment

  assert_success
  assert_output --partial "Authenticating to Azure using managed identity"
  assert_output --partial "Using managed identity with client ID: test-client-id"
  assert_output --partial "Azure login successful"

  unstub az
}

@test "Service principal login" {
  export BUILDKITE_PLUGIN_AZURE_LOGIN_CLIENT_ID="test-client-id"
  export BUILDKITE_PLUGIN_AZURE_LOGIN_CLIENT_SECRET="test-secret"
  export BUILDKITE_PLUGIN_AZURE_LOGIN_TENANT_ID="test-tenant-id"

  stub az "login --service-principal --username test-client-id --password test-secret --tenant test-tenant-id : echo 'Logged in with service principal'"

  run "$PWD"/hooks/environment

  assert_success
  assert_output --partial "Authenticating to Azure using service principal"
  assert_output --partial "Azure login successful"

  unstub az
}

@test "Service principal with secret from environment variable" {
  export BUILDKITE_PLUGIN_AZURE_LOGIN_CLIENT_ID="test-client-id"
  export BUILDKITE_PLUGIN_AZURE_LOGIN_CLIENT_SECRET="MY_SECRET_VAR"
  export BUILDKITE_PLUGIN_AZURE_LOGIN_TENANT_ID="test-tenant-id"
  export MY_SECRET_VAR="resolved-secret-value"

  stub az "login --service-principal --username test-client-id --password resolved-secret-value --tenant test-tenant-id : echo 'Logged in with service principal'"

  run "$PWD"/hooks/environment

  assert_success
  assert_output --partial "Authenticating to Azure using service principal"
  assert_output --partial "Azure login successful"

  unstub az
}

@test "Fails without valid configuration" {
  run "$PWD"/hooks/environment

  assert_failure
  assert_output --partial "Invalid configuration"
}

@test "Service principal fails without client-secret" {
  export BUILDKITE_PLUGIN_AZURE_LOGIN_CLIENT_ID="test-client-id"
  export BUILDKITE_PLUGIN_AZURE_LOGIN_TENANT_ID="test-tenant-id"

  run "$PWD"/hooks/environment

  assert_failure
  assert_output --partial "client-secret is required"
}

@test "Does not run in environment hook when hook is set to pre-command" {
  export BUILDKITE_PLUGIN_AZURE_LOGIN_HOOK="pre-command"
  export BUILDKITE_PLUGIN_AZURE_LOGIN_USE_IDENTITY="true"

  run "$PWD"/hooks/environment

  assert_success
  refute_output --partial "Authenticating to Azure"
}

@test "Azure login failure is reported" {
  export BUILDKITE_PLUGIN_AZURE_LOGIN_USE_IDENTITY="true"

  stub az "login --identity : exit 1"

  run "$PWD"/hooks/environment

  assert_failure
  assert_output --partial "Azure login failed"

  unstub az
}
