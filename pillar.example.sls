libvirt:
  networks:
    default:
      ensure: absent #present, running, stopped, absent
    mydefault:
      xml: |
        <network>
          <name>mydefault</name>
          <bridge name="virbr0"/>
          <forward/>
          <ip address="192.168.122.1" netmask="255.255.255.0">
            <dhcp>
              <range start="192.168.122.2" end="192.168.122.254"/>
            </dhcp>
          </ip>
        </network>
    ovs-net:
      autostart: False
      xml: |
        <network>
          <name>ovs-net</name>
          <forward mode='bridge'/>
          <bridge name='ovsbr0'/>
          <virtualport type='openvswitch'>
            <parameters interfaceid='09b11c53-8b5c-4eeb-8f00-d84eaa0aaa4f'/>
          </virtualport>
        </network>

  pools:
    virtimages:
      type: dir
      path: /var/lib/libvirt/images
      xml: |
        <pool type="dir">
          <name>virtimages</name>
            <target>
              <path>/var/lib/libvirt/images</path>
            </target>
        </pool>
