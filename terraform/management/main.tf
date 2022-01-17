provider "vault" {
  address = var.vault_addr
}

locals {
  ou_config = yamldecode(file("employees.yaml"))

  expanded_names = flatten([
    for e in local.ou_config.Employees : [
      for d in e.Department : [
        for key, person in d : [
          person
        ]
      ]
    ]
  ])

  groups = flatten([
    for key, person in local.ou_config.Groups : [
      person
    ]
  ])
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_identity_group" "internal" {
  for_each = { for o in local.groups : o.role => o }
  name     = each.value.role
  type     = "internal"
  policies = each.value.policies

}

module "userpass" {
  for_each   = { for o in local.expanded_names : o.username => o }
  source     = "./modules/userpass"
  username   = each.value.username
  policies   = ["default"]
  password   = each.value.password
  group      = each.value.group
  depends_on = [vault_identity_group.internal]

}

#output "test" {
#    value = local.groups
#}
