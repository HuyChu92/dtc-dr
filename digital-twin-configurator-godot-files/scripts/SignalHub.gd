extends Node

#JSON
signal updateComponents(ComponentId, ComponentName)

#Signaal dat in raster-main wordt meegegeven aan een nieuwe graph-node
signal InitialComponentName(ComponentId, InitialComponentName)

#Signaal dat de boolean van het ComponentMenu behandelt.
signal ComponentMenuStatus(ComponentMenuVisBool, ComponentName)

#NodeInformatie 
signal NodeInformation(ComponentName, ApiInput, rawApiData)

#dict van de nodeinformation
signal nodeInformationDict(nodeInformationDict)

#Connection Line registratie
signal ConnectionLine(from, from_slot, to, to_slot)

#dict van alle connecties
signal connectionDict(connectionDict)
