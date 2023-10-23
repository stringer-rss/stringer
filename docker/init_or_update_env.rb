require 'set'

# verify existing env vars
existing_env_vars = Set.new(File.read("/.env").split)

# hardcoded list of env vars we require
required_env_vars = Set.new(["SECRET_KEY_BASE",
"ENCRYPTION_PRIMARY_KEY",
"ENCRYPTION_DETERMINISTIC_KEY",
"ENCRYPTION_KEY_DERIVATION_SALT"])

# set operation to get only env vars we need that don't exist yet
new_env_var_keys = required_env_vars - existing_env_vars

for new_env_var_key in new_env_var_keys do
    # TODO: generate the default
end

# write only new env vars to file in append mode
File.write("/.env", new_env_vars.join("\n"), mode: "a")
