{% from "libvirt/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('libvirt:lookup')) %}

libvirt:
  pkg:
    - installed
    - pkgs:
{% for p in datamap.pkgs %}
      - {{ p }}
{% endfor %}
  service:
    - running
    - name: {{ datamap.service.name|default('libvirtd') }}
    - enable: {{ datamap.service.enable|default(True) }}
    #- watch:
{% for c in datamap.config.manage|default([]) %}
      - file: {{ datamap.config[c].path }} #TODO ugly
{% endfor %}
    - require:
      - pkg: libvirt
{% for c in datamap.config.manage|default([]) %}
      - file: {{ datamap.config[c].path }} #TODO ugly
{% endfor %}

{{ datamap.config.storages_dir.path|default('/etc/libvirt/storage') }}:
  file:
    - directory

#TODO:
#/etc/libvirt/libvirtd.conf
#/etc/libvirt/qemu.conf
#/etc/sasl2/libvirt.conf
