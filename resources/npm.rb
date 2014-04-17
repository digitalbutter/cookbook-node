actions :install,:uninstall,:linstall,:luninstall
default_action :install

attribute :name, :kind_of => String, :name_attribute => true
attribute :version, :default => nil
