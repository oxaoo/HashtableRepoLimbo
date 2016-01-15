XMLRPC: module
{
	unknown, request, response : con iota;
	
	decode: 	fn(xmlStr: string) : XMLStruct;
	encode: 	fn(xmlStruct: XMLStruct) : string;
	#create: 	fn() : ref XMLRPC;
	#destroy: 	fn(this: self ref XMLRPC);
	#type: 		fn(xml : XMLStruct);
		
	XMLStruct: adt
	{
		typeXml: int;
		methodName: string;
		params: array of string;

		new: fn(t: int, m: string, p: array of string) : XMLStruct;
	};
	
	getIndex:	fn(subStr : string, str : string) : int;
	getType: fn(xmlStr : string) : int;
	getMethodName: fn(xmlStr : string) : string;
	getParams: fn(xmlStr : string) : array of string;
	
	parseInput: fn(str : string) : XMLStruct;
	split:		fn(str: string) : array of string;
};
