{% from "libvirt/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('libvirt:lookup')) %}

include:
  - libvirt

{% for name, p in salt['pillar.get']('libvirt:pools', {}).items() %}
  {% set po_path = datamap.config.storages_dir.path|default('/etc/libvirt/storage') ~ '/' ~ name ~ '.xml.orig' %}

{{ po_path }}:
  file:
    - {% if p.ensure|default('running') in ['present', 'running'] %}managed{% elif p.ensure|default('running') == 'absent' %}absent{% endif %}
    - mode: {{ datamap.config.storage_file.mode|default('600') }}
    - user: {{ datamap.config.storage_file.user|default('root') }}
    - group: {{ datamap.config.storage_file.group|default('root') }}
    - contents_pillar: libvirt:pools:{{ name }}:xml

{% if p.type == 'dir' and p.ensure|default('running') in ['present', 'running'] %}
{{ p.path }}:
  file:
    - directory
{% endif %}

pool-{{ name }}:
  cmd:
    - run
  {% if p.ensure|default('running') in ['present', 'running'] %}
    - name: virsh pool-define {{ po_path }}
    - unless: virsh -q pool-list --all | grep -q '^{{ name }}'
 {% elif p.ensure|default('running') == 'absent' %}
    - name: virsh pool-destroy {{ name }} 2>&1 /dev/null; virsh pool-undefine {{ name }}
    - onlyif: virsh -q pool-list --all | grep -q '^{{ name }}'
 {% endif %}

pool-autostart-{{ name }}:
  cmd:
    - run
  {% if p.autostart|default(True) and p.ensure|default('running') != 'absent' %}
    - name: virsh pool-autostart {{ name }}
    - unless: virsh pool-info {{ name }} | grep -Eq '^Autostart:\s+yes'
  {% else %}
    - name: virsh pool-autostart {{ name }} --disable
    - onlyif: virsh pool-info {{ name }} | grep -Eq '^Autostart:\s+yes'
  {% endif %}

pool-startstop-{{ name }}:
  cmd:
    - run
  {% if p.ensure|default('running') == 'running' %}
    - name: virsh pool-start {{ name }}
    - unless: virsh -q pool-list --all | grep -Eq '^{{ name }}\s+active'
  {% elif p.ensure|default('running') in ['stopped', 'absent'] %}
    - name: virsh pool-destroy {{ name }}
    - onlyif: virsh -q pool-list --all | grep -Eq '^{{ name }}\s+active'
  {% endif %}
{% endfor %}
