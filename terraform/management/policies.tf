locals {
  ro_capabilities   = ["read", "list"]
  rw_capabilities   = concat(local.ro_capabilities, ["create", "update"])
  rwd_capabilities  = concat(local.rw_capabilities, ["delete"])
  sudo_capabilities = concat(local.rwd_capabilities, ["sudo"])
  deny_capabilities = ["deny"]
  base_policies = {
    child_token = [
      {
        path         = "auth/token/create",
        capabilities = local.rwd_capabilities,
        description  = "Create child token for Terraform"
      }
    ]
    dev = [
      {
        path         = "production/*",
        capabilities = local.rw_capabilities,
        description  = "Allow create/read/update/list"
      },
    ],
    admin = [
      {
        path         = "auth/*",
        capabilities = local.sudo_capabilities,
        description  = "Manage auth backends broadly across Vault"
      },
      {
        path         = "sys/auth/*",
        capabilities = local.sudo_capabilities,
        description  = "List, create, update, and delete auth backends"
      },
      {
        path = "sys/policy",
        capabilities = [
          "read"
        ],
        description = "List policies"
      },
      {
        path         = "sys/policy/*",
        capabilities = local.sudo_capabilities,
        description  = "Create and manage ACL policies broadly across Vault"
      },
      {
        path         = "sys/leases/*",
        capabilities = local.sudo_capabilities,
        description  = "Allow managing leases"
      },
      {
        path         = "*",
        capabilities = local.sudo_capabilities,
        description  = "Allow all on secrets"
      },
      {
        path         = "sys/mounts/*",
        capabilities = local.sudo_capabilities,
        description  = "Manage and manage secret backends broadly across Vault"
      },
      {
        path = "sys/health",
        capabilities = [
          "read",
          "sudo"
        ],
        description = "Read health checks"
      },
      {
        path         = "sys/capabilities",
        capabilities = ["create", "read", "update"],
        description  = ""
      },
      {
        path         = "sys/capabilities-self",
        capabilities = ["create", "read", "update"],
        description  = ""
      }
    ]
  }
  policies = {
    admin = [local.base_policies.admin]
    dev   = [local.base_policies.dev]
  }
}

# POLICIES
data "vault_policy_document" "policy" {
  for_each = local.policies

  dynamic "rule" {
    for_each = flatten(each.value)
    content {
      path         = rule.value.path
      capabilities = toset(rule.value.capabilities)
      description  = rule.value.description
    }
  }
}

resource "vault_policy" "policy" {
  for_each = local.policies
  name     = each.key
  policy   = data.vault_policy_document.policy[each.key].hcl
}
