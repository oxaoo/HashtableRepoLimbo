Storage: module
{
	boolean:		type int;
		
	HashMap: adt
	{
		mTable:			array of list of (int, string);
		mLoadFactor:	real;
		mCapacity:		int;
		mSize:			int;
		mTreshold:		int;
		
		clear:			fn(hm: self ref HashMap) : boolean;
		containsKey:	fn(hm: self ref HashMap, key: int) : boolean;
		containsValue:	fn(hm: self ref HashMap, value: string) : boolean;
		get:			fn(hm: self ref HashMap, key: int) : string;
		isEmpty:		fn(hm: self ref HashMap) : boolean;
		put:			fn(hm: self ref HashMap, key: int, value: string) : string;
		remove:			fn(hm: self ref HashMap, key: int) : string;
		size:			fn(hm: self ref HashMap) : int;
		hashcode:		fn(hm: self ref HashMap, key: int) : int;
		toString:		fn(hm: self ref HashMap) : string;
		
		#custom function
		new:			fn(capacity: int) : ref HashMap;
		print:			fn(hm: self ref HashMap);
		copy:			fn(hm: self ref HashMap) : HashMap;
	};
			
	concat: fn(list1: list of (int, string), list2: list of (int, string)) : list of (int, string);
	getIndex: fn(el: string, str: string) : int;
};
