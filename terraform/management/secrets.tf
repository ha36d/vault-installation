resource "vault_mount" "kv" {
  path        = "production"
  type        = "kv-v2"
  description = "This is an example KV Version 2 secret engine mount"
}

resource "vault_generic_secret" "example" {
  path = "production/secret"

  data_json = <<EOT
{
  "foo":   "bar",
  "pizza": "cheese"
}
EOT
}
