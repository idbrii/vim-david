-- luarocks install --only-deps ~/.vim/bundle/aa-david/lua/daveconfig-scm-0.rockspec

package = "daveconfig"
version = "scm-0"

source = {
  url = "",
}

description = {
  summary = "rockspec to specify dependencies for my setup",
}

dependencies = {
  "testy",
  "luacheck",
}

rockspec_format = "3.0"
