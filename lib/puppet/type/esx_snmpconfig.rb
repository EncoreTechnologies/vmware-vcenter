# Copyright (C) 2013 VMware, Inc.
require 'pathname'
module_lib = Pathname.new(__FILE__).parent.parent.parent

require File.join module_lib, 'puppet_x/vmware/mapper'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet/property/vmware'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet_x/vmware/util'


Puppet::Type.newtype(:esx_snmpconfig) do
  @doc = "This resource allows configuring SNMP parameters on an ESX host."

  newparam(:host, :namevar => true) do
    desc "ESX hostname or ip address."
  end
  
  newproperty(:enabled) do
    desc "boolean for enabling SNMP agent"
    newvalues(:true,:false)
    defaultto(:true)
  end

  newproperty(:port) do
    desc "port for SNMP agent to listen on"
    newvalues(/\d+/)
    defaultto(161)
    validate do |value|
      raise ArgumentError, "port must be in range 1 - 65535." if (value.to_i<1 || value.to_i > 65535)
    end

    munge do |value|
      Integer(value)
    end
  end

  map = PuppetX::VMware::Mapper.new_map('HostSnmpConfigSpecMap')
  map.leaf_list.each do |leaf|
    option = {}
    if type_hash = leaf.olio[t = Puppet::Property::VMware_Array]
      option.update(
        :array_matching => :all,
        :parent => t
      )
    elsif type_hash = leaf.olio[t = Puppet::Property::VMware_Array_Hash]
      option.update(
        # :array_matching => :all,
        :parent => t
      )
    elsif type_hash = leaf.olio[t = Puppet::Property::VMware_Array_VIM_Object]
      option.update(
        # :array_matching => :all,
        :parent => t
      )
    end
    option.update(type_hash[:property_option]) if
      type_hash && type_hash[:property_option]

    newproperty(leaf.prop_name, option) do
      desc(leaf.desc) if leaf.desc
      newvalues(*leaf.valid_enum) if leaf.valid_enum
      munge {|val| leaf.munge.call(val)} if leaf.munge
      validate {|val| leaf.validate.call(val)} if leaf.validate
      eval <<-EOS
        def change_to_s(is, should)
          "[#{leaf.full_name}] changed \#{is_to_s(is).inspect} to \#{should_to_s(should).inspect}"
        end
      EOS
    end
  end
  
  autorequire(:vc_host) do
    # autorequire esx host.
    self[:name]
  end
end
