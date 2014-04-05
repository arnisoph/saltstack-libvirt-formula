{% from "libvirt/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('libvirt:lookup')) %}

include:
  - libvirt

{% for name, n in salt['pillar.get']('libvirt:networks', {}).items() %}
  {% set nf_path = datamap.config.networks_dir.path|default('/etc/libvirt/qemu/networks') ~ '/' ~ name ~ '.xml.orig' %}
{{ nf_path }}:
  file:
    - {% if n.ensure|default('running') in ['present', 'running'] %}managed{% elif n.ensure|default('running') == 'absent' %}absent{% endif %}
    - mode: {{ datamap.config.network_file.mode|default('600') }}
    - user: {{ datamap.config.network_file.user|default('root') }}
    - group: {{ datamap.config.network_file.group|default('root') }}
    - contents_pillar: libvirt:networks:{{ name }}:xml

net-{{ name }}:
  cmd:
    - run
  {% if n.ensure|default('running') in ['present', 'running'] %}
    - name: virsh net-define {{ nf_path }}
    - unless: virsh -q net-list --all | grep -q '^{{ name }}'
 {% elif n.ensure|default('running') == 'absent' %}
    - name: virsh net-destroy {{ name }} 2>&1 1>/dev/null; virsh net-undefine {{ name }}
    - onlyif: virsh -q net-list --all | grep -q '^{{ name }}'
 {% endif %}

net-autostart-{{ name }}:
  cmd:
    - run
  {% if n.autostart|default(True) and n.ensure|default('running') != 'absent' %}
    - name: virsh net-autostart {{ name }}
    - unless: virsh net-info {{ name }} | grep -Eq '^Autostart:\s+yes'
  {% else %}
    - name: virsh net-autostart {{ name }} --disable
    - onlyif: virsh net-info {{ name }} | grep -Eq '^Autostart:\s+yes'
  {% endif %}

net-startstop-{{ name }}:
  cmd:
    - run
  {% if n.ensure|default('running') == 'running' %}
    - name: virsh net-start {{ name }}
    - unless: virsh -q net-list --all | grep -Eq '^{{ name }}\s+active'
  {% elif n.ensure|default('running') in ['stopped', 'absent'] %}
    - name: virsh net-destroy {{ name }}
    - onlyif: virsh -q net-list --all | grep -Eq '^{{ name }}\s+active'
  {% endif %}
{% endfor %}
