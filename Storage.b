implement Storage;

include "sys.m";
include "draw.m";
include "Storage.m";

sys: Sys;

HashMap.new(capacity: int) : ref HashMap
{
	#sys->print("New HashMap.\n");
	sys = load Sys Sys->PATH;
	
	hm : HashMap;
	hm.mCapacity = capacity;
	hm.mLoadFactor = 0.75;
	hm.mSize = 0;
	hm.mTreshold = int (real hm.mCapacity * hm.mLoadFactor);
	
	hm.mTable = array[capacity] of list of (int, string);
	#for (i := 0; i < capacity; i++)
	#	hm.mTable[i] : list of (int, string);
	
	return ref hm;
}

HashMap.copy(hm: self ref HashMap) : HashMap
{
	table := array[len hm.mTable] of list of (int, string);
	for(i := 0; i < len hm.mTable; i++)
	{
		if (len hm.mTable[i] > 0)
		{
			tempList := hm.mTable[i];
			newList : list of (int, string);
			do
			{
				newList = hd tempList :: newList;
				tempList = tl tempList;
			} 
			while (tempList != nil);
			
			table[i] = newList;
		}
	}
	
	shm : HashMap;
	shm.mTable = table;
	shm.mLoadFactor = hm.mLoadFactor;
	shm.mCapacity = hm.mCapacity;
	shm.mSize = hm.mSize;
	shm.mTreshold = hm.mTreshold;
	
	return shm;
}	

HashMap.print(hm: self ref HashMap)
{
	str := hm.toString();
	sys->print("HashMap: %s\n", str);
}

HashMap.hashcode(hm: self ref HashMap, key: int) : int
{
	return key % hm.mCapacity;
}

HashMap.toString(hm: self ref HashMap) : string
{
	#sys->print("Call HashMap.toString().\n");
	if (hm.mTable == nil)
		return nil;
	
	str := "[";
	for (i := 0; i < len hm.mTable; i++)
	{
		str = str + "(";
		curList := hm.mTable[i];
		pair : (int, string);
		
		while (curList != nil)
		{
			pair = hd curList;
			curList = tl curList;
			str = str + "{" + string pair.t0 + ", " + pair.t1 + "}, ";
		}
		if (len str > 2 && str[len str - 2] == ',')
			str = str[:len str - 2];
		
		str = str + "), ";
	}
	
	if (len str > 2 && str[len str - 2] == ',')
		str = str[0 : len str - 2];
	
	str = str + "]";
	
	return str;
}

HashMap.clear(hm: self ref HashMap) : boolean
{
	#sys->print("Clear HashMap.\n");
	if (hm.mSize == 0)
		return 0;
	else
	{
		hm.mTable = array[hm.mCapacity] of list of (int, string);
		hm.mSize = 0;
	}
	return 1;
}

HashMap.containsKey(hm: self ref HashMap, key: int) : boolean
{
	#sys->print("Call HashMap.containsKey().\n");
	
	if (hm.mTable == nil)
		return 0;
	
	k := hm.hashcode(key);
	if (k - 1 > len hm.mTable)
		return 0;
	
	curList := hm.mTable[k];
	pair : (int, string);
	
	while (curList != nil)
	{
		pair = hd curList;
		curList = tl curList;
		if (pair.t0 == key)
			return 1;
	} 
	
	
	return 0;
}

HashMap.containsValue(hm: self ref HashMap, value: string) : boolean
{
	#sys->print("Call HashMap.containsValue().\n");
	
	if (hm.mTable == nil)
		return 0;
	
	for (i := 0; i < len hm.mTable; i++)
	{
		curList := hm.mTable[i];
		pair : (int, string);
		
		while (curList != nil)
		{
			pair = hd curList;
			curList = tl curList;
			if (pair.t1 == value)
				return 1;
		} 
		
	}
	
	return 0;
}

HashMap.get(hm: self ref HashMap, key: int) : string
{
	#sys->print("Call HashMap.get().\n");
	
	if (hm.mTable == nil)
		return nil;

	k := hm.hashcode(key);
	if (k - 1 > len hm.mTable)
		return nil;
	
	curList := hm.mTable[k];
	pair : (int, string);
	
	while (curList != nil)
	{
		pair = hd curList;
		curList = tl curList;
		if (pair.t0 == key)
			return pair.t1;
	} 
		
	return nil;
}

HashMap.isEmpty(hm: self ref HashMap) : boolean
{
	#sys->print("Call HashMap.isEmpty().\n");
	
	if (hm.mSize == 0)
		return 1;
	else
		return 0;
}

HashMap.size(hm: self ref HashMap) : int
{
	#sys->print("Call HashMap.size().\n");
	
	return hm.mSize;
}

HashMap.put(hm: self ref HashMap, key: int, value: string) : string
{
	#sys->print("Call HashMap.put().\n");
	
	if (hm.mTable == nil)
		return nil;
	
	k := hm.hashcode(key);
	if (k - 1 > len hm.mTable)
		return nil;
	
	curList := hm.mTable[k];
	head : list of (int, string);
	pair : (int, string);
	
	while (curList != nil)
	{
		pair = hd curList;
		curList = tl curList;
		if (pair.t0 == key)
		{
			#exist key-value.
			if (pair.t1 == value)
				return pair.t1;
			else
			{
				#exist only key.
				curList = (key, value) :: curList;
				if (head == nil) #only one item in list
					hm.mTable[k] = curList;
				else
					hm.mTable[k] = concat(head, curList);
				return value;
			}
		}
		head = pair :: head;
	} 
	
	#not exist key-value.
	hm.mTable[k] = (key, value) :: hm.mTable[k];
	hm.mSize++;
	
	return value;
}

HashMap.remove(hm: self ref HashMap, key: int) : string
{
	#sys->print("Call HashMap.remove().\n");
	
	if (hm.mTable == nil)
		return nil;
	
	k := hm.hashcode(key);
	if (k - 1 > len hm.mTable)
		return nil;
	
	curList := hm.mTable[k];
	head : list of (int, string);
	pair : (int, string);
	
	while (curList != nil)
	{
		pair = hd curList;
		curList = tl curList;
		if (pair.t0 == key)
		{
			if (head == nil) #only one item in list
				hm.mTable[k] = curList;
			else
				hm.mTable[k] = concat(head, curList);
			
			hm.mSize--;
			
			return pair.t1;
		}
		head = pair :: head;
	} 
	

	return nil;
}

concat(list1: list of (int, string), list2: list of (int, string)) : list of (int, string)
{
	resList := list2;
	
	tailList1 := tl list1;
	if (tailList1 != nil)
		resList = concat(tailList1, list2);
	
	resList = hd list1 :: resList;
	return resList;
}

getIndex(el: string, str: string) : int
{
	for (i := 0; i < len str; i++)
	{
		if (string str[i] == string el[0])
			return i;
	}
	
	return -1;
}	
