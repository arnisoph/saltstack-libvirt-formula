{% from "libvirt/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('libvirt:lookup')) %}

include:
  - libvirt

kvm:
  pkg:
    - installed
    - pkgs:
{% for p in datamap.kvm.pkgs %}
      - {{ p }}
{% endfor %}

{% set kk = datamap.kvm.ksm|default({'service': {}}) %}
{% if kk.service.manage|default(False) %}
ksm_servicescript:
  file:
    - managed
    - name: {{ kk.service.servicepath|default('/etc/init.d/ksm') }}
    - source: {{ kk.service.template_path|default('salt://libvirt/files/ksm/init_ksm') }}
    - mode: 755
    - user: root
    - group: root

ksm_service:
  service:
    - {{ kk.service.state|default('running') }}
    - name: {{ kk.service.name|default('ksm') }}
    - enable: {{ kk.service.enable|default(True) }}
{% endif %}
