#!jinja|yaml

{% set datamap = salt['formhelper.defaults']('libvirt', saltenv) %}

include:
  - libvirt

{% for name, n in datamap.networks|default({})|dictsort %}
  {% set nf_path = datamap.config.networks_dir.path|default('/etc/libvirt/qemu/networks') ~ '/' ~ name ~ '.xml.orig' %}

  {% if n.ensure|default('running') in ['present', 'running'] %}
    {% set nf_ensure = 'managed' %}
  {% else %}
    {% set nf_ensure = 'absent' %}
  {% endif %}

libvirt_network_{{ name }}:
  file:
    - {{ nf_ensure }}
    - name: {{ nf_path }}
  {% if nf_ensure == 'managed' %}
    - mode: {{ datamap.config.network_file.mode|default('600') }}
    - user: {{ datamap.config.network_file.user|default('root') }}
    - group: {{ datamap.config.network_file.group|default('root') }}
    - contents_pillar: libvirt:lookup:networks:{{ name }}:xml
  {% endif %}
    - watch_in:
      - service: libvirt

libvirt_virsh_net_{{ name }}:
  cmd:
    - run
  {% if n.ensure|default('running') in ['present', 'running'] %}
    - name: virsh net-define {{ nf_path }}
    - unless: virsh -q net-list --all | grep -q '^{{ name }}'
 {% elif n.ensure|default('running') == 'absent' %}
    - name: virsh net-destroy {{ name }} 2>&1 1>/dev/null; virsh net-undefine {{ name }}
    - onlyif: virsh -q net-list --all | grep -q '^{{ name }}'
 {% endif %}

libvirt_virsh_net-autostart_{{ name }}:
  cmd:
    - run
  {% if n.autostart|default(True) and n.ensure|default('running') != 'absent' %}
    - name: virsh net-autostart {{ name }}
    - unless: virsh net-info {{ name }} | grep -Eq '^Autostart:\s+yes'
  {% else %}
    - name: virsh net-autostart {{ name }} --disable
    - onlyif: virsh net-info {{ name }} | grep -Eq '^Autostart:\s+yes'
  {% endif %}

libvirt_virsh_net_startstop_{{ name }}:
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
