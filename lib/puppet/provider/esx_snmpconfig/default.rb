# Copyright (C) 2013 VMware, Inc.

provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_snmpconfig).provide(:esx_snmpconfig, :parent => Puppet::Provider::Vcenter) do
  @doc = "This resource allows configuring SNMP parameters on an ESX host."

  Puppet::Type.type(:esx_snmpconfig).properties.collect{|x| x.name}.each do |prop|

    prop_sym = PuppetX::VMware::Util.camelize(prop, :lower).to_sym
 
    define_method(prop) do
      case value = host.configManager.snmpSystem.configuration[prop_sym]
        when TrueClass then :true
        when FalseClass then :false
        else value
      end
    end

    define_method("#{prop}=") do |value|
      hostSnmpConfig[prop_sym]= value
      @pending_changes = true
    end
  end

  def flush
    if @pending_changes
      host.configManager.snmpSystem.ReconfigureSnmpAgent(:spec => @host_snmp)
    end
  end

  private
 
  def hostSnmpConfig
    @host_snmp ||= {}.merge(host.configManager.snmpSystem.configuration.props)
  end

  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
  end

end
