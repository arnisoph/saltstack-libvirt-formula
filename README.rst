===============
libvirt-formula
===============

Salt Stack Formula to set up and configure libvirt, a virtualization API

NOTICE BEFORE YOU USE
=====================

* This formula aims to follow the conventions and recommendations described at http://docs.saltstack.com/en/latest/topics/best_practices.html

TODO
====

* Manage libvirt/ KVM/ QEMU configuration files

Instructions
============

1. Add this repository as a `GitFS <http://docs.saltstack.com/topics/tutorials/gitfs.html>`_ backend in your Salt master config.

2. Configure your Pillar top file (``/srv/pillar/top.sls``), see pillar.example

3. Include this Formula within another Formula or simply define your needed states within the Salt top file (``/srv/salt/top.sls``).

Available states
================

.. contents::
    :local:

``libvirt``
-----------
Installs libvirt and manages libvirt service

``libvirt.kvm``
---------------
Manages QEMU/ KVM

``libvirt.networks``
--------------------
Manages libvirt networks

``libvirt.pools``
-----------------
Manages libvirt storage pools

Additional resources
====================

None

Formula Dependencies
====================

None

Contributions
=============

Contributions are always welcome. All development guidelines you have to know are

* write clean code (proper YAML+Jinja syntax, no trailing whitespaces, no empty lines with whitespaces, LF only)
* set sane default settings
* test your code
* update README.rst doc

Salt Compatibility
==================

Tested with:

* 2014.1.1

OS Compatibility
================

Tested with:

* GNU/ Linux Debian Wheezy
