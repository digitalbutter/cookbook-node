name             "node"
maintainer       "Tikibooth Limited"
maintainer_email "devops@butter.com.hk"
license          "Apache 2.0"
description      "Installs/Configures node, npm and node server providers"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "1.1.2"
depends          "git"
depends          "runit"
supports         "ubuntu"
recipe           "node-js", "Install node and npm"

attribute "node-js/version",
  :display_name => "The version of node to install",
  :default => "HEAD"
