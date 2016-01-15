# HashtableRepoLimbo
:beers: Hashtable repository in a multithreaded environment (Limbo)

## Description:
Implementation of synchronized operation of external clients with the data store (server) presented in the hashtable form.

## Conditions:
- Multiple clients can simultaneously read from a remote storage;  
- Writing in the store at the same time produces only one client;  
- The implementation of a mechanism to allow the transaction "rollback" of changes in the event of an error during a write operation;  
- Network service: XML-RPC.  

<br>
##### The format of xml-rpc request has the following appearance:
```xml
<?xml version="1.0"?>
 <methodCall>
   <methodName>method_name</methodName>
   <params>
     <param>
         <value><string>parameter</string></value>
     </param>
   </params>
 </methodCall>
 ```
 
##### The format of xml-rpc response has the following appearance:
```xml
<?xml version="1.0"?>
 <methodResponse>
   <params>
     <param>
         <value><string>result</string></value>
     </param>
   </params>
 </methodResponse>
```

<br>
##### For the hashtable the following methods are realized:
```go
bool clear();
bool containsKey(int key);
bool containsValue(string value);
string get(int key);
bool isEmpty();
string put(int key, string value);
string remove(int key);
int size();
int hashcode(int key);
string toString();
```

##### Also, the hashtable has the following properties:
```java
Entry[] table;
float loadFactor;
int capacity;
int size;
int threshold;
```
