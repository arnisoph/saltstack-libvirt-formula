#!jinja|yaml

{% set datamap = salt['formhelper.defaults']('libvirt', saltenv) %}

include:
  - libvirt

kvm:
  pkg:
    - installed
    - pkgs: {{ datamap.kvm.pkgs }}

{% if datamap.kvm.ksm.service_script.manage|default(False) %}
ksm_servicescript:
  file:
    - managed
    - name: {{ datamap.kvm.ksm.service_script.servicepath|default('/etc/init.d/ksm') }}
    - source: {{ datamap.kvm.ksm.service_script.template_path|default('salt://libvirt/files/ksm/init_ksm') }}
    - mode: 755
    - user: root
    - group: root
{% endif %}

ksm_service:
  service:
    - {{ datamap.kvm.ksm.service.state|default('running') }}
    - name: {{ datamap.kvm.ksm.service.name|default('ksm') }}
    - enable: {{ datamap.kvm.ksm.service.enable|default(True) }}
