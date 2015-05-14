#!jinja|yaml

{% from "libvirt/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('libvirt:lookup')) %}

include:
  - libvirt

kvm:
  pkg:
    - installed
    - pkgs: {{ datamap.kvm.pkgs }}

{% set kk = datamap.kvm.ksm|default({'service': {}, 'service_script': {}}) %}
{% if kk.service_script.manage|default(False) %}
ksm_servicescript:
  file:
    - managed
    - name: {{ kk.service_script.servicepath|default('/etc/init.d/ksm') }}
    - source: {{ kk.service_script.template_path|default('salt://libvirt/files/ksm/init_ksm') }}
    - mode: 755
    - user: root
    - group: root
{% endif %}

{% set kk = datamap.kvm.ksm|default({'service': {}}) %}
ksm_service:
  service:
    - {{ kk.service.state|default('running') }}
    - name: {{ kk.service.name|default('ksm') }}
    - enable: {{ kk.service.enable|default(True) }}
