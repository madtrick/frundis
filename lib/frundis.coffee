# Copyright [2012] [Farruco Sanjurjo Arcay]
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
Frundis = {}
Frundis.version = "1.0.0"

###
Class Frundis.Steps

  A steps collection
###
class Frundis.Steps
  constructor : ->
    @storage = []

  add : (step) ->
    throw name : "Exception", message : "Step with name \"#{step.name}\" is already in the collection" if @find step.name
    @storage.push step

  find : (step_name) ->
    (@storage.filter (step) ->
      step.name == step_name)[0]

  first : (step) ->
    @first_step = step if step?
    @first_step

  length : ->
    @storage.length

###
  Class Frundis.Steps

  Represents a Step in the transition machine
###
class Frundis.Step

  constructor : (step_name, succeedStep, failStep) ->
    @name = step_name
    @next = {}
    @next.success = succeedStep
    @next.failure = failStep
    @collaborators = []

  attach_collaborator : (callback) ->
    @collaborators.push callback

  start : ->
    deferreds = @collaborators.map (callback) ->
        deferred = new $.Deferred()
        callback(deferred)
        deferred

    $.when.apply(null, deferreds)
      .done(=> @_success())
      .fail(=> @_fail())


  _fail : ->
    @next.failure.start()

  _success : ->
    @next.success.start()

###
   Class Frundis.NullStep

   A implementation of the null object pattern
   Acts as the leaf in the transtions graph
###
class Frundis.NullStep
  start : ->

###
   Class Frundis.InputStep

   Abstract representation of the input given to the user.
###
class Frundis.InputStep
  constructor : (name) ->
    @name = name
    @transitions = {}

  process : (callback) ->
    callback(@, @transitions.success, @transitions.failure)

###
   Class Frundis.NullInputStep
###
class Frundis.NullInputStep extends Frundis.InputStep
  constructor : ->
    super("NullInputStep")

  process : ->
    new Frundis.NullStep()

###
   Class Frundis.InputTransform

   Transforms the input given by the user in InputSteps
###
class Frundis.InputTransform
  nullStep = new Frundis.NullInputStep()

  process : (input) ->
    return nullStep unless input?
    return @process_string(input) if typeof input == "string"
    return @process_array(input) if input instanceof Array
    return @process_object(input) if input instanceof Object

  process_string : (string) ->
    inputStep = new Frundis.InputStep string
    inputStep.transitions.success = nullStep
    inputStep.transitions.failure = nullStep
    inputStep

  process_object : (object) ->
    keys = Object.keys(object)
    throw message : "Object can have just one key" if keys.length > 1

    ret_object = new Frundis.InputStep keys[0]

    if typeof object[ret_object.name] == "object"
      success = object[ret_object.name].success
      failure = object[ret_object.name].failure
    else
      success = object[ret_object.name]
      failure = undefined

    ret_object.transitions['success'] = @process success
    ret_object.transitions['failure'] = @process failure
    ret_object

  process_array : (array) ->
    return nullStep if array.length == 0
    value = array.shift()
    if typeof value == "string"
      ret = @process value
      ret.transitions.success = @process_array array
    else
      ret = @process value

    ret

###
  Class Frundis.Builder

  Articulates other components to create Steps
###
class Frundis.Builder
  process : (input) ->
    @transformer = new Frundis.InputTransform()
    @_tmp_steps = {}
    inputStep = @transformer.process(input)
    inputStep.process(@_build)

    steps = new Frundis.Steps()

    for own key, value of @_tmp_steps
      steps.add value

    steps.first(steps.find inputStep.name)
    steps

  _build : (inputStep, successInputStep, failureInputStep) =>
    return @_tmp_steps[inputStep.name] if @_tmp_steps[inputStep.name]?
    @_tmp_steps[inputStep.name] = new Frundis.Step(inputStep.name, undefined, undefined)
    @_tmp_steps[inputStep.name].next.success = successInputStep.process @_build
    @_tmp_steps[inputStep.name].next.failure = failureInputStep.process @_build

    @_tmp_steps[inputStep.name]

###
  Class Frundis.Machine

  Facade to all this shit
###
class Frundis.Machine
  constructor : (steps_spec) ->
    builder = new Frundis.Builder()
    @steps =  builder.process steps_spec
  join : (step, callback) ->
    step = @steps.find step
    step.attach_collaborator callback

  init : ->
    @steps.first().start()

window.Frundis = Frundis
