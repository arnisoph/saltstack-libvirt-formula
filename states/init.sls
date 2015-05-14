#!jinja|yaml

{% set datamap = salt['formhelper.defaults']('libvirt', saltenv) %}

libvirt:
  pkg:
    - installed
    - pkgs: {{ datamap.pkgs }}
  service:
    - running
    - name: {{ datamap.service.name }}
    - enable: {{ datamap.service.enable|default(True) }}

storages_dir:
  file:
    - name: {{ datamap.config.storages_dir.path|default('/etc/libvirt/storage') }}
    - directory
    - require_in:
      - service: libvirt

#TODO:
#/etc/libvirt/libvirtd.conf
#/etc/libvirt/qemu.conf
#/etc/sasl2/libvirt.conf
