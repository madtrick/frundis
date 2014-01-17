(function() {
  var Frundis,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Frundis = {};

  Frundis.version = "1.1.0";

  /*
  Class Frundis.Steps
  
    A steps collection
  */


  Frundis.Steps = (function() {

    function Steps() {
      this.storage = [];
    }

    Steps.prototype.add = function(step) {
      if (this.find(step.name)) {
        throw {
          name: "Exception",
          message: "Step with name \"" + step.name + "\" is already in the collection"
        };
      }
      return this.storage.push(step);
    };

    Steps.prototype.find = function(step_name) {
      return (this.storage.filter(function(step) {
        return step.name === step_name;
      }))[0];
    };

    Steps.prototype.first = function(step) {
      if (step != null) {
        this.first_step = step;
      }
      return this.first_step;
    };

    Steps.prototype.length = function() {
      return this.storage.length;
    };

    return Steps;

  })();

  /*
    Class Frundis.Steps
  
    Represents a Step in the transition machine
  */


  Frundis.Step = (function() {

    function Step(step_name, succeedStep, failStep) {
      this.name = step_name;
      this.next = {};
      this.next.success = succeedStep;
      this.next.failure = failStep;
      this.collaborators = [];
    }

    Step.prototype.attach_collaborator = function(callback) {
      return this.collaborators.push(callback);
    };

    Step.prototype.start = function() {
      var deferreds,
        _this = this;
      deferreds = this.collaborators.map(function(callback) {
        var deferred;
        deferred = new $.Deferred();
        callback(deferred);
        return deferred;
      });
      return $.when.apply(null, deferreds).done(function() {
        return _this._success();
      }).fail(function() {
        return _this._fail();
      });
    };

    Step.prototype._fail = function() {
      return this.next.failure.start();
    };

    Step.prototype._success = function() {
      return this.next.success.start();
    };

    return Step;

  })();

  /*
     Class Frundis.NullStep
  
     A implementation of the null object pattern
     Acts as the leaf in the transtions graph
  */


  Frundis.NullStep = (function() {

    function NullStep() {}

    NullStep.prototype.start = function() {};

    return NullStep;

  })();

  /*
     Class Frundis.InputStep
  
     Abstract representation of the input given to the user.
  */


  Frundis.InputStep = (function() {

    function InputStep(name) {
      this.name = name;
      this.transitions = {};
    }

    InputStep.prototype.process = function(callback) {
      return callback(this, this.transitions.success, this.transitions.failure);
    };

    return InputStep;

  })();

  /*
     Class Frundis.NullInputStep
  */


  Frundis.NullInputStep = (function(_super) {

    __extends(NullInputStep, _super);

    function NullInputStep() {
      NullInputStep.__super__.constructor.call(this, "NullInputStep");
    }

    NullInputStep.prototype.process = function() {
      return new Frundis.NullStep();
    };

    return NullInputStep;

  })(Frundis.InputStep);

  /*
     Class Frundis.InputTransform
  
     Transforms the input given by the user in InputSteps
  */


  Frundis.InputTransform = (function() {
    var nullStep;

    function InputTransform() {}

    nullStep = new Frundis.NullInputStep();

    InputTransform.prototype.process = function(input) {
      if (input == null) {
        return nullStep;
      }
      if (typeof input === "string") {
        return this.process_string(input);
      }
      if (input instanceof Array) {
        return this.process_array(input);
      }
      if (input instanceof Object) {
        return this.process_object(input);
      }
    };

    InputTransform.prototype.process_string = function(string) {
      var inputStep;
      inputStep = new Frundis.InputStep(string);
      inputStep.transitions.success = nullStep;
      inputStep.transitions.failure = nullStep;
      return inputStep;
    };

    InputTransform.prototype.process_object = function(object) {
      var failure, keys, ret_object, success;
      keys = Object.keys(object);
      if (keys.length > 1) {
        throw {
          message: "Object can have just one key"
        };
      }
      ret_object = new Frundis.InputStep(keys[0]);
      if (typeof object[ret_object.name] === "object") {
        success = object[ret_object.name].success;
        failure = object[ret_object.name].failure;
      } else {
        success = object[ret_object.name];
        failure = void 0;
      }
      ret_object.transitions['success'] = this.process(success);
      ret_object.transitions['failure'] = this.process(failure);
      return ret_object;
    };

    InputTransform.prototype.process_array = function(array) {
      var ret, value;
      if (array.length === 0) {
        return nullStep;
      }
      value = array.shift();
      if (typeof value === "string") {
        ret = this.process(value);
        ret.transitions.success = this.process_array(array);
      } else {
        ret = this.process(value);
      }
      return ret;
    };

    return InputTransform;

  })();

  /*
    Class Frundis.Builder
  
    Articulates other components to create Steps
  */


  Frundis.Builder = (function() {

    function Builder() {
      this._build = __bind(this._build, this);

    }

    Builder.prototype.process = function(input) {
      var inputStep, key, steps, value, _ref;
      this.transformer = new Frundis.InputTransform();
      this._tmp_steps = {};
      inputStep = this.transformer.process(input);
      inputStep.process(this._build);
      steps = new Frundis.Steps();
      _ref = this._tmp_steps;
      for (key in _ref) {
        if (!__hasProp.call(_ref, key)) continue;
        value = _ref[key];
        steps.add(value);
      }
      steps.first(steps.find(inputStep.name));
      return steps;
    };

    Builder.prototype._build = function(inputStep, successInputStep, failureInputStep) {
      if (this._tmp_steps[inputStep.name] != null) {
        return this._tmp_steps[inputStep.name];
      }
      this._tmp_steps[inputStep.name] = new Frundis.Step(inputStep.name, void 0, void 0);
      this._tmp_steps[inputStep.name].next.success = successInputStep.process(this._build);
      this._tmp_steps[inputStep.name].next.failure = failureInputStep.process(this._build);
      return this._tmp_steps[inputStep.name];
    };

    return Builder;

  })();

  /*
    Class Frundis.Machine
  
    Facade to all this shit
  */


  Frundis.Machine = (function() {

    function Machine(steps_spec) {
      var builder;
      builder = new Frundis.Builder();
      this.steps = builder.process(steps_spec);
    }

    Machine.prototype.join = function(step, callback) {
      step = this.steps.find(step);
      return step.attach_collaborator(callback);
    };

    Machine.prototype.init = function() {
      return this.steps.first().start();
    };

    return Machine;

  })();

  window.Frundis = Frundis;

}).call(this);
