#= require jquery-1.8.0.min

# Stole at https://gist.github.com/1251917
jasmine.Matchers.prototype.toBeInstanceOf = (klass) ->
  this.actual instanceof klass

describe "Frundis.Machine", ->
  describe "when instantiated", ->
    beforeEach ->
      spyOn(Frundis.Builder.prototype, "process")
      new Frundis.Machine()

    it "should call the #process method on a Frundis.Builder instance", ->
      expect(Frundis.Builder.prototype.process).toHaveBeenCalled()

  describe ".join", ->
    beforeEach ->
      @machine = new Frundis.Machine ["A", "B", "C"]
      @A_step = @machine.steps.find "A"

    it "should attach a collaborator to the requested step", ->
      spyOn(@A_step, "attach_collaborator")
      callback = ->
      @machine.join "A", callback
      expect(@A_step.attach_collaborator).toHaveBeenCalledWith(callback)

  describe ".init", ->
    beforeEach ->
      @machine = new Frundis.Machine ["A", "B", "C"]
      @A_step = @machine.steps.find "A"

    it "should run its first transition", ->
      spyOn(@A_step, "start")
      @machine.init()
      expect(@A_step.start).toHaveBeenCalled()

describe "Frundis.Step", ->
  beforeEach ->
    @next_success = new Frundis.Step("success")
    @next_failure = new Frundis.Step("failure")
    @step = new Frundis.Step("step_name", @next_success, @next_failure)

  describe "when instantiated", ->

    it "should assign its name", ->
      expect(@step.name).toBe("step_name")

    it "should set its next state if it succeed", ->
      expect(@step.next.success).toEqual @next_success

    it "should set its next state if it fails", ->
      expect(@step.next.failure).toEqual @next_failure

    it "should have a 'collaborators' property", ->
      expect(@step.collaborators).toEqual([])

  describe "#attach_collaborator", ->
    it "should create a new collaborator", ->
      number_of_collaborators = @step.collaborators.length
      @step.attach_collaborator(->)
      expect(@step.collaborators.length).toEqual(number_of_collaborators + 1)

  describe "#start", ->
    it "should invoke all collaborators' callbacks", ->
      #@step = Frundis.Step.find "A"
      spy1 = jasmine.createSpy()
      spy2 = jasmine.createSpy()

      @step.attach_collaborator spy1
      @step.attach_collaborator spy2

      @step.start()

      expect(spy1).toHaveBeenCalled()
      expect(spy2).toHaveBeenCalled()

    it "should pass a deferred to collaborators' callback as an argument", ->
      #@step = Frundis.Step.find "A"
      spy1 = jasmine.createSpy()

      @step.attach_collaborator spy1

      @step.start()

  describe "when one collaborator fails on its deferred", ->
    it "should provoke that #_fail method is called", ->
      spyOn(@step, "_fail")
      callBack1 = (def) -> def.resolve()
      callBack2 = (def) -> def.reject()

      @step.attach_collaborator callBack1
      @step.attach_collaborator callBack2

      @step.start()

      expect(@step._fail).toHaveBeenCalled()

    it "should start next.failure step", ->
      spyOn(@step.next.failure, "start")

      callback1 = (def) -> def.reject()
      callback2 = (def) -> def.resolve()

      @step.attach_collaborator callback1
      @step.attach_collaborator callback2

      @step.start()

      expect(@step.next.failure.start).toHaveBeenCalled()

  describe "when all collaborators success on their deferred", ->
    it "should provoke that #_success method is called", ->
      spyOn(@step, "_success")
      callback1 = (def) -> def.resolve()
      callback2 = (def) -> def.resolve()

      @step.attach_collaborator callback1
      @step.attach_collaborator callback2

      @step.start()

      expect(@step._success).toHaveBeenCalled()

    it "should start next.success step", ->
      spyOn(@step.next.success, "start")

      callback1 = (def) -> def.resolve()
      callback2 = (def) -> def.resolve()

      @step.attach_collaborator callback1
      @step.attach_collaborator callback2

      @step.start()

      expect(@step.next.success.start).toHaveBeenCalled()

describe "Frundis.NullStep", ->
  beforeEach ->
    @nullStep = new Frundis.NullStep()

  describe "#start method", ->
    it "should be defined", ->
      expect(@nullStep.start).toBeDefined()

describe "Frundis.Steps", ->
  beforeEach ->
    @steps = new Frundis.Steps()
    @b_step = new Frundis.Step("b", undefined, undefined)
    @steps.add new Frundis.Step("a", undefined, undefined)
    @steps.add @b_step

  describe "#find", ->
    it "should return the requested step", ->
      expect(@steps.find("b")).toEqual @b_step

  describe "#first", ->
    describe "when a step is passed as parameter" , ->
      it "should be set as the first parameter", ->
        @steps.first(@b_step)
        expect(@steps.first_step).toEqual @b_step

    describe "when no parameters are passed", ->
      describe "when the first step wasn't set explicitly", ->
        it "should return 'undefined'", ->
          expect(@steps.first()).toEqual undefined

      describe "when the first step was set", ->
        beforeEach ->
          @steps.first(@b_step)
        it "should return its first step", ->
          expect(@steps.first().name).toEqual "b"

  describe "#length", ->
    it "should returns its length", ->
      expect(@steps.length()).toEqual 2

  describe "#add", ->
    it "should throw an exception when adding the same step twice", ->
      expect(=> @steps.add new Frundis.Step("a", undefined, undefined)).toThrow()

describe "Frundis.InputTransform", ->
  beforeEach ->
    @inputTransform = new Frundis.InputTransform()
    #@NullStep = {name : 'NullStep', transitions : undefined}
    @NullStep = new Frundis.NullInputStep()
  describe "#process", ->
    beforeEach ->
      spyOn(@inputTransform, "process_string").andCallThrough()
      spyOn(@inputTransform, "process_object").andCallThrough()
      spyOn(@inputTransform, "process_array").andCallThrough()

    it "should call #process_string when the passed parameter is a string", ->
      result = @inputTransform.process "a"
      expect(@inputTransform.process_string).toHaveBeenCalledWith "a"
      expect(result).toEqual(@inputTransform.process_string "a")

    it "should call #process_object when the passet parameter is an object", ->
      object = a : "b"
      result = @inputTransform.process object
      expect(@inputTransform.process_object).toHaveBeenCalledWith object
      expect(result).toEqual(@inputTransform.process_object a : "b")

    it "should call #process_array when the passed parameter is an array", ->
      result = @inputTransform.process ["a"]
      #expect(@inputTransform.process_array).toHaveBeenCalledWith ["a"]
      expect(result).toEqual @inputTransform.process_array ["a"]

    it "should return nullStep when passed 'undefined'", ->
      expect(@inputTransform.process undefined).toEqual @NullStep

  describe "#process_string", ->
    describe "returned object", ->
      beforeEach ->
        @string = "step-A"
        @return = @inputTransform.process_string(@string)

      it "should have the passed string as the value of its 'name' property", ->
        expect(@return.name).toEqual(@string)
      describe "transitions property", ->
        it "should have 'Frundis.NullStep' as the value of its 'success' property", ->
          expect(@return.transitions.success).toEqual @NullStep
        it "should have 'Frundis.NullStep' as the value of its 'failure' property", ->
          expect(@return.transitions.failure).toEqual @NullStep

  describe "#process_object", ->
    it "should raise an exception if the passed object has more than one key", ->
      expect(=> @inputTransform.process_object {a : "a", b : "c"}).toThrow()

    describe "returned object", ->
      beforeEach ->
        input = {a:{}}
        @return = @inputTransform.process_object input
      it "should have the object's only key as name", ->
        expect(@return.name).toEqual("a")

      describe "when object value is a string", ->
        it "should call #process_string method with the given string", ->
          spyOn(@inputTransform, "process_string")
          @inputTransform.process_object a : "b"
          expect(@inputTransform.process_string).toHaveBeenCalledWith "b"

        it "should set #process_string return value as the value of transitions.success property", ->
          resultFromProcessString = @inputTransform.process_string "b"
          result = @inputTransform.process_object a : "b"
          expect(result.transitions.success).toEqual(resultFromProcessString)

        it "should set NullStep as the value of transitions.failure property", ->
          result = @inputTransform.process_object a : "b"
          expect(result.transitions.failure).toEqual @NullStep

      describe "when object value is an object", ->
        it "should call #process with the value of the passed object's success property", ->
          spyOn(@inputTransform, "process").andCallThrough()
          @inputTransform.process_object a : {success : "x", failure : "b"}
          expect(@inputTransform.process).toHaveBeenCalledWith "x"

        it "should call #process with the value of the passed object's failure property", ->
          spyOn(@inputTransform, "process").andCallThrough()
          @inputTransform.process_object a : {success : "x", failure : "y"}
          expect(@inputTransform.process).toHaveBeenCalledWith "y"

  describe "#process_array", ->
    it "should call #process with each of its input elements", ->
      spyOn(@inputTransform, "process").andCallThrough()
      @inputTransform.process_array ["a", "b", "c"]
      expect(@inputTransform.process).toHaveBeenCalledWith "a"
      expect(@inputTransform.process).toHaveBeenCalledWith "b"
      expect(@inputTransform.process).toHaveBeenCalledWith "c"
    describe "when its elements are only strings", ->
      it "should set 'nullStep' as failure transitions", ->
        result = @inputTransform.process_array ["a", "b", "c"]
        expect(result.transitions.failure).toEqual  @NullStep
        expect(result.transitions.success.transitions.failure).toEqual @NullStep
        expect(result.transitions.success.transitions.success.transitions.failure).toEqual @NullStep
      it "should link all as success transitions", ->
        result = @inputTransform.process_array ["a", "b", "c"]
        expect(result.name).toEqual "a"
        expect(result.transitions.success.name).toEqual "b"
        expect(result.transitions.success.transitions.success.name).toEqual "c"

    describe "when it composed of strings and one object as the las element", ->
      it "should link the object as the success transition of the last string", ->
        result = @inputTransform.process_array ["a", {b : "c"}]
        expect(result.name).toEqual "a"
        expect(result.transitions.success.name).toEqual "b"
        expect(result.transitions.success.transitions.success.name).toEqual "c"

    describe "when there's more than one object in the array", ->
      it "should throw an exception"


describe "Frundis.InputStep", ->
  describe "when initialized", ->
    beforeEach ->
      @inputStep = new Frundis.InputStep("a")
    it "should have a 'name' property", ->
      expect(@inputStep.name).toEqual "a"
    it "should have a 'transitions.success' property", ->
      expect(@inputStep.transitions.success).toEqual undefined
    it "should have a 'transitions.failure' property", ->
      expect(@inputStep.transitions.failure).toEqual undefined
  describe "#process", ->
    it "should call passed callback with itself, transitions.success and transitions.failure as parameters", ->
      inputStep = new Frundis.InputStep "a"
      spy = jasmine.createSpy()
      inputStep.process spy

      expect(spy).toHaveBeenCalledWith inputStep, inputStep.transitions.success, inputStep.transitions.failure

describe "Frundis.NullInputStep", ->
  describe "#process", ->
    beforeEach ->
      @nullInputStep = new Frundis.NullInputStep()

    it "should return a NullStep", ->
      expect(@nullInputStep.process()).toBeInstanceOf Frundis.NullStep

describe "Frundis.Builder", ->
  describe "#process", ->
    beforeEach ->
      spyOn(Frundis.InputTransform.prototype, "process").andCallThrough()
      spyOn(Frundis.InputStep.prototype, "process").andCallThrough()
      builder = new Frundis.Builder()
      @result = builder.process ["a", "c", "a"]

    it "should create a Frundis.InputTransform and call #process on it passing the given input", ->
      expect(Frundis.InputTransform.prototype.process).toHaveBeenCalled()

    it "should process returned inputSteps", ->
      expect(Frundis.InputStep.prototype.process).toHaveBeenCalled()

    it "should return a Frundis.Steps", ->
      expect(@result).toBeInstanceOf Frundis.Steps

    it "should return steps in order", ->
      expect(@result.first().name).toEqual "a"

    it "should return as many steps as specified on its input", ->
      expect(@result.length()).toEqual 2
