# -*- mode: bash; tab-width: 2; -*-
# vim: ts=2 sw=2 ft=bash noet

# Copy the code into the live directory which will be used to run the app
publish_release() {
  nos_print_bullet "Moving build into live app directory..."
  rsync -a $(nos_code_dir)/ $(nos_app_dir)
}

# Determine the crystal runtime to install. This will first check
# within the Boxfile, then will rely on default_runtime to
# provide a sensible default
runtime() {
  echo $(nos_validate \
    "$(nos_payload "config_runtime")" \
    "string" "$(default_runtime)")
}

# Provide a default crystal version.
default_runtime() {
  echo "crystal-0.23"
}

# Install the crystal runtime along with any dependencies.
install_runtime_packages() {
  pkgs=("$(runtime)")

  # add any client dependencies
  pkgs+=("$(query_dependencies)")

  nos_install ${pkgs[@]}
}

# Setup environment variables that the crystal compiler
# and runtime use for building and running the app
setup_crystal_env() {
  nos_template_file \
    "env.d/LD_LIBRARY_PATH" \
    "$(nos_etc_dir)/env.d/LD_LIBRARY_PATH"
    
  nos_template_file \
    "env.d/LIBRARY_PATH" \
    "$(nos_etc_dir)/env.d/LIBRARY_PATH"
}

# Uninstall build dependencies
uninstall_build_packages() {
  pkgs=()

  # if pkgs isn't empty, let's uninstall what we don't need
  if [[ ${#pkgs[@]} -gt 0 ]]; then
    nos_uninstall ${pkgs[@]}
  fi
}

# Fetch crystal shards from shard.yml
fetch_shards() {
  if [[ -f $(nos_code_dir)/shard.yml ]]; then

    cd $(nos_code_dir)
    nos_run_process "Fetching crystal shards" \
      "crystal deps"
    cd - >/dev/null
  fi
}

# compiles a list of dependencies that will need to be installed
query_dependencies() {
  deps=()

  # todo: add deps

  echo "${deps[@]}"
}
