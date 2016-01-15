implement Hashtable;

include "sys.m";
include "draw.m";
include "Storage.m";
include "XMLRPC.m";

Connection: import sys;
XMLStruct : import xmlrpc;
HashMap : import storage;

storage: Storage;
xmlrpc: XMLRPC;
sys: Sys;


Hashtable: module
{
	boolean:		type int;
	
	mAlreadyInit : boolean;
	
	mHashMap: ref storage->HashMap;
	shm:		  storage->HashMap;
	
	channel : chan of boolean;
		
	init: 			fn(nil: ref Draw->Context, argv: list of string);
	runClient: 		fn();
	runServer: 		fn();
	listen: 		fn(conn : Connection);
	handlerThread:	fn(conn : Connection);
	make:			fn(xmlResponse: XMLStruct) : XMLStruct;
	
	lock: 			fn();
	unlock: 		fn();
	
	snapshot:		fn(hm: storage->HashMap);
	rollback:		fn() : ref storage->HashMap;
};

snapshot(hm: storage->HashMap)
{	
	shm = hm;
}

rollback() : ref storage->HashMap
{
	return ref shm;
}


make(xmlResponse: XMLStruct) : XMLStruct
{
	case xmlResponse.methodName
	{
		"new" =>
		{
			#sys->print("Print mHashMap: %s.\n", string mHashMap);
			#sys->print("Print shm: %s.\n", string shm);
			
			lock();
			if (mHashMap != nil)
			{
				str := "Already initialized HashMap";
				sys->print("%s.\n", str);
				
				unlock();
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			
			capacity := int xmlResponse.params[0];
			mHashMap = storage->HashMap.new(capacity);
			str := "Create new HashMap(" + string capacity + ")";
			sys->print("%s.\n", str);
			
			unlock();
			return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
		}
		
		"toString" =>
		{
			if (mHashMap == nil)
			{
				str := "Don't initialize HashMap";
				sys->print("%s.\n", str);
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			
			str := "Result to string of HashMap: " + mHashMap.toString();
			
			sys->print("%s.\n", str);
			return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
		}
		
		"clear" =>
		{
			lock();
			
			if (mHashMap == nil)
			{
				str := "Don't initialize HashMap";
				sys->print("%s.\n", str);
				
				unlock();
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			
			shmTemp := mHashMap.copy();
			res := boolean mHashMap.clear();
			
			if (res == 1)
			{
				snapshot(shmTemp);
				
				str := "Clean the HashMap";
				sys->print("%s.\n", str);
				
				unlock();
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			else
			{
				str := "Failed to clear the HashMap";
				sys->print("%s.\n", str);
				
				unlock();
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
		}
		
		"containsKey" =>
		{
			if (mHashMap == nil)
			{
				str := "Don't initialize HashMap";
				sys->print("%s.\n", str);
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			
			key := int xmlResponse.params[0];
			res := boolean mHashMap.containsKey(key);
			
			if (res == 1)
			{
				str := "The key is contains in the HashMap";
				sys->print("%s.\n", str);
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			else
			{
				str := "The key isn't contains in the HashMap";
				sys->print("%s.\n", str);
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
		}
		
		"containsValue" =>
		{
			if (mHashMap == nil)
			{
				str := "Don't initialize HashMap";
				sys->print("%s.\n", str);
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			
			value := xmlResponse.params[0];
			res := boolean mHashMap.containsValue(value);
			
			if (res == 1)
			{
				str := "The value is contains in the HashMap";
				sys->print("%s.\n", str);
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			else
			{
				str := "The value isn't contains in the HashMap";
				sys->print("%s.\n", str);
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
		}
		
		"get" =>
		{
			if (mHashMap == nil)
			{
				str := "Don't initialize HashMap";
				sys->print("%s.\n", str);
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			
			key := int xmlResponse.params[0];
			value := mHashMap.get(key);
			
			if (value != nil)
			{
				str := "The value: " + value + ", by the key: " + string key;
				sys->print("%s.\n", str);
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			else
			{
				str := "Key: " + string key + " is not contains in the HashMap";
				sys->print("%s.\n", str);
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
		}
		
		"isEmpty" =>
		{
			if (mHashMap == nil)
			{
				str := "Don't initialize HashMap";
				sys->print("%s.\n", str);
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			
			res := boolean mHashMap.isEmpty();
			if (res == 1)
			{
				str := "The HashMap is empty";
				sys->print("%s.\n", str);
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			else
			{
				str := "The HashMap isn't empty";
				sys->print("%s.\n", str);
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
		}
		
		"size" =>
		{
			if (mHashMap == nil)
			{
				str := "Don't initialize HashMap";
				sys->print("%s.\n", str);
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			
			res := mHashMap.size();
			
			str := "Size of the HashMap: " + string res;
			sys->print("%s.\n", str);
			return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
		}
		
		"put" =>
		{
			lock();
	
			if (mHashMap == nil)
			{
				str := "Don't initialize HashMap";
				sys->print("%s.\n", str);
				
				unlock();
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			
			key := int xmlResponse.params[0];
			value := xmlResponse.params[1];
			

			shmTemp := mHashMap.copy();
			snapshot(shmTemp);
			res := mHashMap.put(key, value);
			
			str := "Result of put in the HashMap: " + res;
			sys->print("%s.\n", str);
				
			unlock();
			return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
		}
		
		"remove" =>
		{
			lock();
	
			if (mHashMap == nil)
			{
				str := "Don't initialize HashMap";
				sys->print("%s.\n", str);
				
				unlock();
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			
			key := int xmlResponse.params[0];
			#shmTemp : ref storage->HashMap;
			shmTemp := mHashMap.copy();
			res := mHashMap.remove(key);
			
			if (res != nil)
			{
				snapshot(shmTemp);
				str := "Remove the value: " + res + ", by the key: " + string key;
				sys->print("%s.\n", str);
				
				unlock();
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			else
			{
				str := "Key: " + string key + " is not contains in the HashMap";
				sys->print("%s.\n", str);
				
				unlock();
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
		}
		
		"print" =>
		{
			if (mHashMap == nil)
			{
				str := "Don't initialize HashMap";
				sys->print("%s.\n", str);
				return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
			}
			
			str := "Result print of HashMap: " + mHashMap.toString();
			
			sys->print("Result print of HashMap: ");
			mHashMap.print();
			return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
		}
		
		"rollback" =>
		{
			lock();
			mHashMap = rollback();
			
			str : string;
			if (mHashMap != nil)
				str = "Rolled back the last transaction";
			else
				str = "Failed to roll back the last transaction";
			
			sys->print("%s.\n", str);
			
			unlock();
			return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
		}
		
		* =>
		{
			str := "Incorrect input: " + xmlResponse.methodName;
			sys->print("%s.\n", str);

			return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
		}
	}
}


runClient()
{
	(ok, conn) := sys->dial("tcp!127.0.0.1!80", nil);
	if (ok < 0)
	{
		sys->print("Failed dial the client.\n");
		exit;
	}

	buf := array[255] of byte;
	bufReq := array[sys->ATOMICIO] of byte;
    stdin := sys->fildes(0);
	
	sys->print("To exit, enter the key: exit.\n");
	for(;;)
	{
		sys->print("Input: ");
		lenBuf := sys->read(stdin, buf, len buf);
		if (lenBuf > 0)
		{			
			str := buf[:lenBuf];
			
			if (xmlrpc->getIndex("exit", string str) != -1)
				break;
			
			# парсинг и генерация xmlrpc.
			x := xmlrpc->parseInput(string str);
			strX := array of byte xmlrpc->encode(x); #кодирование в строку.
						
			if (x.typeXml == xmlrpc->unknown)
			{
				sys->print("Invalid input: %s.\n", string str[:len str - 1]);
				continue;
			}
			
			#отправка запроса.
			if (sys->write(conn.dfd, strX, len strX) != len strX)
			{
				sys->print("Failed write to conn.dfd.\n");
				exit;
			}
		
			#получение ответа. 
			lenBufReq := sys->read(conn.dfd, bufReq, len bufReq);
			if (lenBufReq > 0)
			{
				strReqX := string bufReq[:lenBufReq];
				reqX := xmlrpc->decode(strReqX);
				if (reqX.typeXml != xmlrpc->unknown)
				{
					for (i := 0; i < len reqX.params; i++)
						sys->print("Request: %s.\n", reqX.params[i]);
				}
				else
					sys->print("Nil response.\n");
				
				#sys->print("Request: %s\n", string bufReq[:lenBufReq]);
			}

		}
		else
			sys->print("Failed input");
	}
}

runServer()
{
	(ok, conn) := sys->announce("tcp!*!80");
	if (ok < 0)
	{
		sys->print("Failed announce the server.\n");
		exit;
	}
	
	for(;;)
	{
		listen(conn);
	}
}

listen(conn : Connection)
{
	buf := array[sys->ATOMICIO] of byte;
	(ok, c) := sys->listen(conn);
	if (ok < 0)
	{
		sys->print("Failed to start listening on the server.\n");
		exit;
	}
	
	rfd := sys->open(conn.dir + "/remote", Sys->OREAD);
	n := sys->read(rfd, buf, len buf);
	
	#sys->print("Got new connection from: %s\n", string buf[:n]);
	sys->print("A new connection...\n");
	
	spawn handlerThread(c);
}

handlerThread(conn : Connection)
{
	buf := array [sys->ATOMICIO] of byte;
	
	rdfd := sys->open(conn.dir + "/data", Sys->OREAD);
	wdfd := sys->open(conn.dir + "/data", Sys->OWRITE);
	rfd := sys->open(conn.dir + "/remote", Sys->OREAD);
	wfd := sys->open(conn.dir + "/remote", Sys->OWRITE);
	
	n := sys->read(rfd, buf, len buf);
	
	sys->print("Connection information: %s\n", string buf[:n]);
	
	in := sys->read(rdfd, buf, len buf); #получение команды от удаленного узла.
	while (in > 0)
	{
		strX := string buf[:in];
		x := xmlrpc->decode(strX);
		
		if (x.typeXml != xmlrpc->unknown)
		{
			res := make(x);
			strRes := array of byte xmlrpc->encode(res);
			
			sys->write(wdfd, strRes, len strRes); #отправка результата удленному узлу.				
		}
		else
			sys->print("Nil response.\n");
		
		in = sys->read(rdfd, buf, len buf); #получение новой команды от удаленного узла.

	}
	
	sys->print("The session is closed.\n");
}

lock()
{
		alt
		{
			channel <- = 1 
				=> sys->print("Lock repository.\n");
		}
}

unlock()
{
	#sys->print("Begin sleep.\n");
	#sys->sleep(5000);
	#sys->print("End sleep.\n");
		
		alt
		{
			<- channel
				=> sys->print("Unlock repository.\n");
		}
}
	
init(nil: ref Draw->Context, argv: list of string)
{
	sys = load Sys Sys->PATH;
	storage = load Storage "Storage.dis";
	xmlrpc = load XMLRPC "XMLRPC.dis";
	sys->print("Success init!\n");
	
	channel = chan[1] of boolean;

	if (len argv < 2)
	{
		sys->print("Unknown module type.\n");
		exit;
	}
	
	moduleType := hd tl argv;
	
	if (moduleType == "server")
	{
		sys->print("Run the server.\n");
		runServer();
	}
	else
	{
		sys->print("Run the client.\n");
		runClient();
	}
}