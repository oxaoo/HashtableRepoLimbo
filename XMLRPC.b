implement XMLRPC;

include "sys.m";
include "draw.m";
include "XMLRPC.m";

sys: Sys;

XMLStruct.new(t: int, m: string, p: array of string) : XMLStruct
{
	x : XMLStruct;
	x.typeXml = t;
	x.methodName = m;
	x.params = p;
	
	return x;
}

encode(xmlStruct: XMLStruct) : string
{
	if (sys == nil)
		sys = load Sys Sys->PATH;
	
	if (xmlStruct.typeXml == request)
	{
		strXml := "<?xml version=\"1.0\"?>\n<methodCall>\n<methodName>";
		strXml += xmlStruct.methodName;
		strXml += "</methodName>\n<params>";
		for (i := 0; i < len xmlStruct.params; i++)
			strXml += "\n<param>\n<value><string>" + xmlStruct.params[i] + "</string></value>\n</param>";
		strXml += "\n</params>\n</methodCall>";
		
		return strXml;
	}
	else if (xmlStruct.typeXml == response)
	{
		strXml := "<?xml version=\"1.0\"?>\n<methodResponse>";
		strXml += "\n<params>";
		for (i := 0; i < len xmlStruct.params; i++)
			strXml += "\n<param>\n<value><string>" + xmlStruct.params[i] + "</string></value>\n</param>";
		strXml += "\n</params>\n</methodResponse>";
		
		return strXml;
	}
	else
	{
		sys->print("Incorrect structure of XML.\n");
		return nil;
	}
}

decode(xmlStr: string) : XMLStruct
{
	aType := getType(xmlStr);
	
	if (aType == request) #request.
	{
		t := request;
		m := getMethodName(xmlStr);
		p := getParams(xmlStr);
		
		return XMLStruct.new(t, m, p);
	}
	else #response.
	{
		t := response;
		m := "";
		p := getParams(xmlStr);
		
		return XMLStruct.new(t, m, p); 
	}
}

getType(xmlStr : string) : int
{
	strMethod := xmlStr[36:46];
	if (strMethod == "methodName")
		return request;
	else
		return response;
}

getMethodName(xmlStr : string) : string
{
	if (sys == nil)
		sys = load Sys Sys->PATH;
	
	b := getIndex("<methodName>", xmlStr);
	e := getIndex("</methodName>", xmlStr);
	
	if (b != -1 && e != -1)
		return xmlStr[b + 12 : e];
	else
	{
		sys->print("Failed to get the method.\n");
		return nil;
	}
}

getParams(xmlStr : string) : array of string
{
	if (sys == nil)
		sys = load Sys Sys->PATH;
	
	b := getIndex("<params>", xmlStr);
	e := getIndex("</params>", xmlStr);
	
	if (b != -1 && e != -1)
	{
		xmlParams := xmlStr[b + 8 : e];
		params := array[127] of string;
		for(i := 0; i < len params; i++)
		{
			b = getIndex("<param>\n<value><string>", xmlParams);
			e = getIndex("</string></value>\n</param>", xmlParams);
			
			if (b != -1 && e != -1)
			{
				params [i] = xmlParams[b + 23 : e];
				xmlParams = xmlParams[e + 26 : len xmlParams];
			}
			else
				return params [:i];
		}
		
		sys->print("No parameters.\n");
		return nil;
	}
	else
	{
		sys->print("Failed to get the method.\n");
		return nil;
	}
	
	
	
}

parseInput(str : string) : XMLStruct
{
	if (sys == nil)
		sys = load Sys Sys->PATH;
	
	b := getIndex("(", str);
	e := getIndex(")", str);
	
	if (b == -1 || e == -1)
		return XMLStruct.new(unknown, nil, nil);
	
	t := request;
	m := str[:b];
	p : array of string;
	
	if (b + 1 == e)
		p = nil;
	else
		p = split(str[b + 1 : e]);
	
	return XMLStruct.new(t, m, p);
}

getIndex(subStr: string, str: string) : int
{
	
	for (i := 0; i < len str - len subStr; i++)
	{
		for (j := 0; j < len subStr; j++)
		{
			if (str[i + j] != subStr[j])
				break;
			
			if (j + 1 == len subStr)
				return i;
		}
	}
		
	return -1;
}

split(str: string) : array of string
{
	params := array[127] of string;
	
	i : int;
	for (i = 0; i < len params; i++)
	{
		if (len str == 0)
			break;
		
		if (index := getIndex(",", str) != -1)
		{
			params[i] = str[:index];
			str = str[index + 1 : len str];
		}
		else
		{
			params[i] = str;
			break;
		}
	}
	
	return params[:i + 1];
}

