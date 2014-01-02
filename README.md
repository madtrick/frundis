[![Analytics](https://ga-beacon.appspot.com/UA-46795389-1/frundis/README)](https://github.com/igrigorik/ga-beacon)

# Frundis #

This library providess a simple way to coordinate asynchronous code with ease.

## Information ##
  * Source code available at [Github](https://github.com/madtrick/frundis)
  * Needs [jQuery](http://jquery.com/) to work. Tested with 1.8.0

## The idea behind ##

With Frundis you divide the work into steps 

### Steps ###

Steps can be expressed following the rules given in this "grammar":

```
Steps : String | Object | Array
String   : JS_String
Object   : {Key : Value}
Key      : String
Value    : {success : String | Array | Object} | {fail : String | Array | Object} | String | Array
Array    : [String*] | [String* | Object]
```

#### Strings & Keys ####

All steps must be expressed with a valid string in JavaScript (_JS_STRING_).

#### Arrays ####
This is the simplest way to create steps that are linked to the successful finishing of their predecesor:

```coffeescript
steps = ["a", "b", "c"]
```

This will create three steps named: "a", "b" and "c".

To execute "b", "a" must finish successfully and to execute "c", both "a" and "b" must have finished successfully.

The last element in an array can be an Object. Anyother step introduced after this object will be ignored.

#### Objects ####
With an object you have more control. You have to especify both the name of the step and the transition. By default a successful transition is assumed.

```coffeescript
steps = { "a" : "b"}
```

This will create two steps: "a" and "b". When "a" ends successfully "b" will execute.

```coffeescript
steps = { "a" : ["b", "c"] }
```

This will create three steps: "a", "b" and "c". The steps in the array will execute if "a" finishes successfully.

```coffeescript
steps = { "a" : { "b" : "c"}}
```

This will create three steps: "a", "b" and "c". I will assume that you already understand what happens next.

```coffeescript
steps = { "a" : {failure: "b", success : ["c", "d"]}}
```

Here we have given all the details. If the step "a" ends successfully the step "c" will be run otherwise "b" will be run.

### Usage ###

Define your steps

```coffeescript
steps =
  "init" :
    success :
      [ "task1", "task2", { "process" : {succcess : "finish", failure : "error"}}]
    failure : "error"
```

Create the machine

```coffeescript
machine = new Frundis.Machine steps
```

Add stuff to each step

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
  #
  # If something goes wrong
  #fail the deferred
  #
  d.reject() # will transit to "error" step

machine.join "error", ->
  console.log "OMG"

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





