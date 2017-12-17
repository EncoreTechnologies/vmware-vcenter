# Copyright (C) 2013 VMware, Inc.

require 'set'

module PuppetX::VMware::Mapper

  class HostSnmpConfigSpecMap < Map
    def initialize
      @initTree = {
        Node => NodeData[
          :node_type => 'HostSnmpConfigSpec',
        ],
        :option => LeafData[
          :prop_name => PROP_NAME_IS_FULL_PATH,
	        :desc => 'Array KeyValue options.',
          :olio => {
            Puppet::Property::VMware_Array_VIM_Object => {
              :property_option => {
                :type => 'KeyValue',
                :array_matching => :all,
                :comparison_scope => :array_element,
                :key => [:key],
              },
            },
          },
        ],
	      :readOnlyCommunities => LeafData[
	        :prop_name => PROP_NAME_IS_FULL_PATH,
	        :desc => 'Array of read-only Community strings. For example: ["abc123", "xxx555"]',
	        :olio => {
	          Puppet::Property::VMware_Array => {
	            :property_option => {
	    	        :inclusive => :true,
		            :preserve  => :false,	
  	          },
	          },
	        },
	      ],
        :trapTargets => LeafData[
          :prop_name => PROP_NAME_IS_FULL_PATH,
	        :desc => 'Array HostSnmpDestination objects that define the SNMP trap targets',
          :olio => {
            Puppet::Property::VMware_Array_VIM_Object => {
              :property_option => {
                :type => 'HostSnmpDestination',
                :array_matching => :all,
                :comparison_scope => :array_element,
                :key => [:hostName, :port],
              },
            },
          },
        ],
      }
      super
    end
  end
end

