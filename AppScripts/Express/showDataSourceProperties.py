#env jython

#
#
# name: showDataSourceProperties.py
# author: Shane Reddy
# version: 1.0.0v
# dob: 12/17/2019
# explanation: Print data source(s) properties (server name and port number).
# dependencies: wsadmin
# modifications:
#
# contact: shane.reddy@ttiinc.com
#
#
##############################################################################################

cellName = AdminControl.getCell()
#dataSources = AdminConfig.list("DataSource", AdminConfig.getid( "/Cell:"+cellName+"/ServerCluster:TestCluster/")).splitlines()
dataSources = AdminConfig.list("DataSource").splitlines()
for dataSource in dataSources:
    dsName = AdminConfig.showAttribute(dataSource, "name")
    dsProperties = AdminConfig.list('J2EEResourceProperty', dataSource)
    lProperties = AdminUtilities.convertToList(dsProperties)
    propSet = AdminConfig.list("J2EEResourcePropertySet", dataSource)
    for prop in AdminConfig.list("J2EEResourceProperty", propSet).splitlines():
        if (AdminConfig.showAttribute(prop, "name") == 'serverName'):
            dsServerName=AdminConfig.showAttribute(prop, "value")
            print "Property= 'serverName' is "+dsServerName+" for DataSource= "+dsName
        #endIf
        if (AdminConfig.showAttribute(prop, "name") == 'portNumber'):
            dsPortNumber=AdminConfig.showAttribute(prop, "value")
            print "Property= 'portNumber' is "+dsPortNumber+" for DataSource= "+dsName
        #endIf
    #endFor
#endFor

#end_showDataSourceProperties.py