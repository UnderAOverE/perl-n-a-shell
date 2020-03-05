#!/usr/bin/env jython

#
#
# Version : 1.0.0v
# Tool Name: ExpressTTIDeploy.py
# DoB: 02/25/2020
# Shane Reddy
#
#

# Imports
import sys, time

# Variables
earLocation="/tti/deploy/"
appName="TTIXEar"

# Main
if len(sys.argv) == 1:
     Environment = sys.argv[0]
     if Environment == "K":
          cellName = AdminControl.getCell()
          clusterName="tti_k_cluster"
          cluster = AdminControl.completeObjectName('cell='+cellName+',type=Cluster,name='+clusterName+',*')
          State = AdminControl.getAttribute(cluster, 'state')
          if State == "websphere.cluster.stopped":
                print " INFO| '%s' is already stopped." %(clusterName)
          else:
                AdminControl.invoke(cluster, 'stop')
                while 1:
                     State1 = AdminControl.getAttribute(cluster, 'state')
                     if State1 == "websphere.cluster.stopped":
                          print " INFO| '%s' stopped." %(clusterName)
                          break
                     else:
                          print " INFO| '%s' stopping..." %(clusterName)
                     #endIfElse
                     print " INFO| status refresh in 15 seconds..."
                     time.sleep(15)
                #endWhile
          #endIfElse
          print " INFO| uninstalling the application '%s'." %(appName)
          AdminApp.uninstall(appName)
          AdminConfig.save()
          print " INFO| waiting 15 seconds to sync nodes..."
          time.sleep(15)
          earFile=earLocation+"K/ExpressEnterpriseApplication.ear"
          AdminApp.install(earFile, '[-cluster '+clusterName+']')
          AdminConfig.save()
          print " INFO| application '%s' installed." %(appName)
          print " INFO| waiting 15 seconds to sync nodes..."
          time.sleep(15)
          AdminControl.invoke(cluster, 'start')
          while 1:
                State2 = AdminControl.getAttribute(cluster, 'state')
                if State2 == "websphere.cluster.running":
                     print " INFO| '%s' started." %(clusterName)
                     break;
                else:
                     print " INFO| '%s' starting..." %(clusterName)
                #endIfElse
                print " INFO| status refresh in 15 seconds..."
                time.sleep(15)
          #endWhile
     #endIf
     if Environment == "J":
          cellName = AdminControl.getCell()
          clusterName="tti_j_cluster"
          cluster = AdminControl.completeObjectName('cell='+cellName+',type=Cluster,name='+clusterName+',*')
          State = AdminControl.getAttribute(cluster, 'state')
          if State == "websphere.cluster.stopped":
                print " INFO| '%s' is already stopped." %(clusterName)
          else:
                AdminControl.invoke(cluster, 'stop')
                while 1:
                     State1 = AdminControl.getAttribute(cluster, 'state')
                     if State1 == "websphere.cluster.stopped":
                          print " INFO| '%s' stopped." %(clusterName)
                          break
                     else:
                          print " INFO| '%s' stopping..." %(clusterName)
                     #endIfElse
                     print " INFO| status refresh in 15 seconds..."
                     time.sleep(15)
                #endWhile
          #endIfElse
          print " INFO| uninstalling the application '%s'." %(appName)
          AdminApp.uninstall(appName)
          AdminConfig.save()
          print " INFO| waiting 15 seconds to sync nodes..."
          time.sleep(15)
          earFile=earLocation+"J/ExpressEnterpriseApplication.ear"
          AdminApp.install(earFile, '[-cluster %s]') %(clusterName)
          AdminConfig.save()
          print " INFO| application '%s' installed." %(appName)
          print " INFO| waiting 15 seconds to sync nodes..."
          time.sleep(15)
          AdminControl.invoke(cluster, 'start')
          while 1:
                State2 = AdminControl.getAttribute(cluster, 'state')
                if State2 == "websphere.cluster.running":
                     print " INFO| '%s' started." %(clusterName)
                     break;
                else:
                     print " INFO| '%s' starting..." %(clusterName)
                #endIfElse
                print " INFO| status refresh in 15 seconds..."
                time.sleep(15)
          #endWhile
     #endIf
else:
     print " ERROR| Please provide the environment name \"J\" or \"K\"."
     sys.exit(1)
#endIfElse

#end_ExpressTTIDeploy.py