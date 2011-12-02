actions :start,:stop,:restart,:enable,:disable

attribute :name, :kind_of => String, :name_attribute => true
attribute :dependency, :kind_of => Array, :default => []
attribute :script, :kind_of => String
attribute :user, :kind_of => String
attribute :args, :kind_of => String, :default => ""
attribute :init_style, :kind_of => Symbol, :equal_to => [:upstart, :init, :runit]

# some default values need to be set late because they are dynamic
def initialize(*args)
  super
  @init_style ||= value_for_platform(:ubuntu => { :default => :upstart }, :default => :init)
  @user ||= node[:node][:user]
  @action = :start
end

