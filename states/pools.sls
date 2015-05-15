#!jinja|yaml

{% set datamap = salt['formhelper.defaults']('libvirt', saltenv) %}

include:
  - libvirt

{% for name, p in datamap.pools|default({})|dictsort %}
  {% set po_path = datamap.config.storages_dir.path|default('/etc/libvirt/storage') ~ '/' ~ name ~ '.xml.orig' %}

  {% if p.ensure|default('running') in ['present', 'running'] %}
    {% set po_ensure = 'managed' %}
  {% else %}
    {% set po_ensure = 'absent' %}
  {% endif %}

libvirt_pool_{{ name }}:
  file:
    - {{ po_ensure }}
    - name: {{ po_path }}
  {% if po_ensure == 'managed' %}
    - mode: {{ datamap.config.storage_file.mode|default('600') }}
    - user: {{ datamap.config.storage_file.user|default('root') }}
    - group: {{ datamap.config.storage_file.group|default('root') }}
    - contents_pillar: libvirt:lookup:pools:{{ name }}:xml
  {% endif %}
    - watch_in:
      - service: libvirt

{% if p.type == 'dir' and p.ensure|default('running') in ['present', 'running'] %}
libvirt_pool_{{ name }}_dir_{{ p.path }}:
  file:
    - directory
    - name: {{ p.path }}
{% endif %}

libvirt_virsh_pool_{{ name }}:
  cmd:
    - run
  {% if p.ensure|default('running') in ['present', 'running'] %}
    - name: virsh pool-define {{ po_path }}
    - unless: virsh -q pool-list --all | grep -q '^{{ name }}'
 {% elif p.ensure|default('running') == 'absent' %}
    - name: virsh pool-destroy {{ name }} 2>&1 1>/dev/null; virsh pool-undefine {{ name }}
    - onlyif: virsh -q pool-list --all | grep -q '^{{ name }}'
 {% endif %}

libvirt_pool_virsh_autostart_{{ name }}:
  cmd:
    - run
  {% if p.autostart|default(True) and p.ensure|default('running') != 'absent' %}
    - name: virsh pool-autostart {{ name }}
    - unless: virsh pool-info {{ name }} | grep -Eq '^Autostart:\s+yes'
  {% else %}
    - name: virsh pool-autostart {{ name }} --disable
    - onlyif: virsh pool-info {{ name }} | grep -Eq '^Autostart:\s+yes'
  {% endif %}

libvirt_virsh_pool_startstop_{{ name }}:
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
