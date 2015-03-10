[![Analytics](https://ga-beacon.appspot.com/UA-46795389-1/frundis/README)](https://github.com/igrigorik/ga-beacon)

# Frundis

With this library you can implement a simple Finite State Machine with a twist.

  * Source code available at [Github](https://github.com/madtrick/frundis)
  * Needs [jQuery](http://jquery.com/) to work. Tested with 1.8.0  

## The idea behind

This library was created to ease the development of code where operations (and its order) were dependant on the execution of asynchronous tasks (loading of remote files, AJAX requests, etc.).

But you can use Frundis to do more than that. It can be used to split a complex workflow into smaller steps and combine them to fullfil the same goal but in a more structured way.

## Building elements
Frundis uses two elements to do its thing:

  * A Frundis machine. A Frundis machine goes through its steps executing the collaborators of each step and taking the appropiate transition on each case.
  * A bunch of collaborators. Collaborators are functions attached to steps that will be called on entering the step they are attached to. A collaborator can success or fail its execution.
  
### Machine
Frundis machines are no more than Finite State Machines. To create one, give it a steps specification:

```coffescript
machine = Frundis.Machine <specification>
```

### Collaborators
Collaborators are the units where the work is done in a Frundis machine.

Collaborators are functions that are  _attached_ to one of the states of a Frundis machine and are only executed when the machine reaches that state. This functions receive as argument a [Deferred object](http://api.jquery.com/jQuery.Deferred/). At any moment of its execution a collaborator can _reject_ or _resolve_ this Deferred. The rejection or resolution of this Deferred will be used to decide if the machine uses the success or the failure transition.

Any step can have as many collaborators as required. The transition from a step will depend of the rejection or resolution of the Deferreds of all its collaboratos:

  * To go down the "success" transition all the collaborators must resolve its Deferred.
  * To go down the "failure" transition one of the collaborators have to reject its Deferred.
  

  
## Machine specification
To create a Frundis machine you have to pass a machine specification to the constructor ```Frundis.Machine```. Below is a description of this specification.

### Steps

Steps can be expressed following the rules given in this "grammar":

```
Steps    : String | Object | Array
String   : JS_String
Object   : {Key : Value}
Key      : String
Value    : {success : String | Array | Object} | {failure : String | Array | Object} | 
	{success : String | Array | Object, failure : String | Array | Object} | String | Array
Array    : [String*] | [String* , Object]
```

#### Strings & Keys

All steps must be expressed with a valid string in JavaScript (_JS_STRING_).

#### Arrays
This is the simplest way to create steps which are linked to the successful finishing of their predecesor:

```coffeescript
steps = ["a", "b", "c"]
```

This will create three steps: "a", "b" and "c". To execute "b", "a" must finish successfully and to execute "c", both "a" and "b" must have finished successfully.

![machine](https://raw.github.com/madtrick/frundis/readme-assets/readme-assets/machine-1.png)

You can also express loops:

```coffeescript
steps = ["a", "b", "a"]
```

![machine](https://raw.github.com/madtrick/frundis/readme-assets/readme-assets/machine-4.png)


The last element in an array can be an Object. Any other step introduced after this object will be ignored.

#### Objects ####

Only objects with one key are valid, i.e. this ```{"a" : "b"}``` is valid but this ```{"a" : "b", "c" : "d"}``` will raise an exception. This key will be the name of the step and its value will define the next steps. If an Array or a String are given as value, they will be bound to the success of the "key" step.

Examples:

```coffeescript
steps = { "a" : "b"}
```

Is the same as:

![machine](https://raw.github.com/madtrick/frundis/readme-assets/readme-assets/machine-2.png)


```coffeescript
steps = { "a" : ["b", "c"] }
```

Is the same as:

![machine](https://raw.github.com/madtrick/frundis/readme-assets/readme-assets/machine-1.png)

A object can have as value other object with the keys **failure** and/or **success**

```coffeescript
steps = { "a" : {failure: "b", success : ["c", "d"]}}
```

Is the same as:

![machine](https://raw.github.com/madtrick/frundis/readme-assets/readme-assets/machine-3.png)


### Usage ###

Below is a full example of the usage of a ```Frundis.Machine```.

1. Define your steps

	```coffeescript
	steps =
  		"init" :
    		success :
      			[ "task1", "task2", { "process" : {succcess : "finish", failure : "error"}}]
    		failure : "error"
	```
	
	Which is this:
	
	![machine](https://raw.github.com/madtrick/frundis/readme-assets/readme-assets/machine-5.png)

2. Create the machine

	```coffeescript
	machine = new Frundis.Machine steps
	```
	
3. Add collaborators to each step

	```coffeescript
	machine.join "init", (d) ->
  	 #your init stuff
   	 #
  	 # If everything went ok
  	 #resolve the deferred
  	 #
  	 d.resolve() # will transit to "task1" step
	
	machine.join "task1", (d) ->
	 #...
	machine.join "task2", (d) ->
  	 #...
  	
  	machine.join "process", (d) ->
    # If something goes wrong
    # fail the deferred
    #
    d.reject() # will transit to "error" step
    
    machine.join "error", ->
     console.log "OMG I crashed"
 	```

4. Start the machine

	```coffescript
	machine.init()
	```	

### Author ###

This stuff has been writen by Farruco sanjurjo

  * [@madtrick](https://twitter.com/madtrick) at twitter
  * Blog at [blog.tenako.com](http://blog.tenako.com)

### Contributions, bugs, etc ###

### Tests ###

### License ###

Copyright [2012] [Farruco Sanjurjo Arcay]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.





