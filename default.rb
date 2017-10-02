#
# Cookbook:: nexus_new
# Recipe:: default
#
# Description:: main cookbook to install repository 
# 
# Copyright:: 2017, Bohdan Buhyl, All Rights Reserved.
########################################
#===== INCLUDE COOKBOOK =====
include_recipe 'requiretty::default'
########################################
#===== INITIALL INSTALL =====
include_recipe 'nexus_new::str_conf_nex'
########################################
#===== INSTALL NGINX (PROXY AND DNS RESOLVE =====
include_recipe 'nexus_new::inst_nginx'
########################################
#===== INSTALL NEXUS =====
include_recipe 'nexus_new::inst_nexus'
########################################
#===== TEST SOME ISSUES =====
#include_recipe 'nexus_new::past_files'
########################################

































