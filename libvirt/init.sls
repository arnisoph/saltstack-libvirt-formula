#!jinja|yaml

{% from "libvirt/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('libvirt:lookup')) %}

libvirt:
  pkg:
    - installed
    - pkgs: {{ datamap.pkgs }}
  service:
    - running
    - name: {{ datamap.service.name|default('libvirtd') }}
    - enable: {{ datamap.service.enable|default(True) }}
    - require:
      - pkg: libvirt

storages_dir:
  file:
    - name: {{ datamap.config.storages_dir.path|default('/etc/libvirt/storage') }}
    - directory

#TODO:
#/etc/libvirt/libvirtd.conf
#/etc/libvirt/qemu.conf
#/etc/sasl2/libvirt.conf
