// Generated by CoffeeScript 1.3.3
var analyzer, circuitousObject,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

analyzer = typeof exports !== "undefined" && exports !== null ? exports : provide('./analyzer', {});

circuitousObject = require('./object');

analyzer.Analyzer = (function(_super) {

  __extends(Analyzer, _super);

  function Analyzer(board) {
    this.board = board;
    this.init();
  }

  Analyzer.prototype.init = function() {
    return this.info = {
      matrix: {},
      node: {},
      sections: {},
      components: {}
    };
  };

  Analyzer.prototype.run = function() {
    this.init();
    this.analyze();
    this.createMatrix();
    this.saveMatrixIdentityLoops();
    this.solveMatrix();
    this.deleteShorts();
    this.checkPolarizedComponents();
    return this.roundedComponentValues();
  };

  Analyzer.prototype.roundedComponentValues = function() {
    var amps, cid, componentInfo, resistance, round, section, sectionId, _ref;
    componentInfo = {};
    round = function(number) {
      if (isNaN(number)) {
        return number;
      } else {
        return Math.round(number * 100.0) / 100.0;
      }
    };
    _ref = this.info.sections;
    for (sectionId in _ref) {
      section = _ref[sectionId];
      for (cid in section.components) {
        resistance = round(section.resistance);
        amps = round(section.amps);
        if (amps > 1000) {
          amps = 'infinite';
        }
        componentInfo[cid] = {
          resistance: resistance,
          amps: amps
        };
      }
    }
    return componentInfo;
  };

  Analyzer.prototype.analyze = function() {
    var cid, component, end, positiveTerminal, s, start, startKey, startKeys, startNode, startSections, _ref, _results;
    _ref = this.board.components;
    _results = [];
    for (cid in _ref) {
      component = _ref[cid];
      if (!component.voltage) {
        continue;
      }
      if (this.info.components[cid]) {
        continue;
      }
      _results.push((function() {
        var _i, _len, _ref1, _results1;
        _ref1 = component.currentNodes('positive');
        _results1 = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          positiveTerminal = _ref1[_i];
          startNode = this.board.boardPosition(positiveTerminal);
          this.createSections([
            {
              component: component,
              node: startNode
            }
          ]);
          startSections = (function() {
            var _j, _len1, _ref2, _results2;
            _ref2 = this.info.node[this.nodeId(startNode)];
            _results2 = [];
            for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
              s = _ref2[_j];
              if (!this.compareNodes(s.nodes[0], s.nodes[1])) {
                _results2.push(s);
              }
            }
            return _results2;
          }).call(this);
          if ((startKeys = Object.keys(startSections)).length === 2) {
            startKey = this.compareNodes(startSections[startKeys[1]].nodes[1], startNode) ? 1 : 0;
            end = startKey === 1 ? startSections[startKeys[0]] : startSections[startKeys[1]];
            start = startSections[startKeys[startKey]];
            _results1.push(this.consumeSection(start, end));
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  Analyzer.prototype.nodeId = function(node) {
    return "" + node.x + ":" + node.y;
  };

  Analyzer.prototype.newSection = function(node) {
    var section;
    section = {
      nodes: [node],
      resistance: 0,
      components: {},
      sections: {},
      id: this.generateId('section')
    };
    return section;
  };

  Analyzer.prototype.createSections = function(sectionInfos) {
    var connections, sectionInfo, _i, _len;
    connections = [];
    for (_i = 0, _len = sectionInfos.length; _i < _len; _i++) {
      sectionInfo = sectionInfos[_i];
      connections = connections.concat(this.createSection(sectionInfo.component, sectionInfo.node));
    }
    if (connections.length) {
      return this.createSections(connections);
    }
  };

  Analyzer.prototype.createSection = function(component, node) {
    var connections, section;
    section = this.newSection(node);
    connections = this.analyzeSection(section, component, this.otherNode(this.boardNodes(component), node));
    this.endSection(section);
    return connections;
  };

  Analyzer.prototype.analyzeSection = function(section, component, node) {
    var c, connection, connections, _i, _len;
    if (this.addToSection(section, component, node)) {
      connections = (function() {
        var _i, _len, _ref, _results;
        _ref = this.findConnections(node);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          if (c.component !== component) {
            _results.push(c);
          }
        }
        return _results;
      }).call(this);
      if (component.nodes.length === 1) {
        connections = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = connections.length; _i < _len; _i++) {
            c = connections[_i];
            if (!this.info.components[c.component.id]) {
              _results.push(c);
            }
          }
          return _results;
        }).call(this);
      }
      for (_i = 0, _len = connections.length; _i < _len; _i++) {
        connection = connections[_i];
        if (connection.component.nodes.length === 1) {
          connections = [connection];
          break;
        }
      }
      if (connections.length === 1) {
        connection = connections[0];
        return this.analyzeSection(section, connection.component, connection.otherNode);
      } else if (connections.length > 1) {
        return connections;
      }
    }
    return [];
  };

  Analyzer.prototype.addToSection = function(section, component, node) {
    var componentNodes, voltage;
    if (this.info.components[component.id]) {
      return false;
    }
    if ((componentNodes = this.boardNodes(component)).length > 1) {
      component.direction = (this.compareNodes(node, componentNodes[1]) ? 1 : -1);
    }
    if (component.voltage) {
      voltage = component.voltage * (node.negative ? 1 : -1);
      section.voltage = (section.voltage || 0) + voltage;
    }
    section.resistance += component.resistance || 0;
    section.components[component.id] = true;
    section.nodes[1] = node;
    this.info.components[component.id] = section.id;
    return true;
  };

  Analyzer.prototype.consumeSection = function(section, sectionToBeConsumed) {
    var cid;
    this.deleteSection(section);
    this.deleteSection(sectionToBeConsumed);
    for (cid in sectionToBeConsumed.components) {
      this.info.components[cid] = section.id;
      section.components[cid] = true;
    }
    section.resistance = (section.resistance || 0) + (sectionToBeConsumed.resistance || 0);
    section.voltage = (section.voltage || 0) + (sectionToBeConsumed.voltage || 0);
    section.nodes[1] = sectionToBeConsumed.nodes[1];
    return this.recordSection(section);
  };

  Analyzer.prototype.endSection = function(section) {
    var cid, component;
    if (!Object.keys(section.components).length) {
      return;
    }
    if (!section.direction) {
      section.direction = 1;
    }
    if (section.direction === -1) {
      for (cid in section.components) {
        component = this.board.componentsAndWires()[cid];
        component.direction = component.direction * -1;
      }
    }
    return this.recordSection(section, component);
  };

  Analyzer.prototype.findConnections = function(node) {
    var c, connections, id, matchingNode, n, nodes, otherNode, segment, _i, _j, _len, _len1, _ref, _ref1, _ref2;
    connections = [];
    _ref = this.board.components;
    for (id in _ref) {
      c = _ref[id];
      _ref1 = (nodes = c.currentNodes());
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        n = _ref1[_i];
        matchingNode = this.board.boardPosition(n);
        if (!this.compareNodes(matchingNode, node)) {
          continue;
        }
        if (nodes.length === 1) {
          otherNode = matchingNode;
        } else {
          otherNode = this.board.boardPosition(this.otherNode(nodes, n));
        }
        connections.push({
          component: c,
          otherNode: otherNode,
          node: node
        });
      }
    }
    _ref2 = this.board.wires.find(node);
    for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
      segment = _ref2[_j];
      connections.push({
        component: segment,
        otherNode: this.otherNode(segment.nodes, node),
        node: node
      });
    }
    return connections;
  };

  Analyzer.prototype.compareNodes = function(node1, node2) {
    return node1.x === node2.x && node1.y === node2.y;
  };

  Analyzer.prototype.recordSection = function(section) {
    var node1Coords, node2Coords, _base, _base1;
    this.info.sections[section.id] = section;
    node1Coords = this.nodeId(section.nodes[0]);
    node2Coords = this.nodeId(section.nodes[1]);
    (_base = this.info.node)[node1Coords] || (_base[node1Coords] = {});
    this.info.node[node1Coords][section.id] = section;
    (_base1 = this.info.node)[node2Coords] || (_base1[node2Coords] = {});
    return this.info.node[node2Coords][section.id] = section;
  };

  Analyzer.prototype.deleteSection = function(section) {
    delete this.info.sections[section.id];
    delete this.info.node[this.nodeId(section.nodes[0])][section.id];
    return delete this.info.node[this.nodeId(section.nodes[1])][section.id];
  };

  Analyzer.prototype.otherNode = function(nodes, node) {
    var n;
    return ((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = nodes.length; _i < _len; _i++) {
        n = nodes[_i];
        if (!this.compareNodes(n, node)) {
          _results.push(n);
        }
      }
      return _results;
    }).call(this))[0];
  };

  Analyzer.prototype.boardNodes = function(component) {
    var nodes,
      _this = this;
    if (nodes = typeof component.currentNodes === "function" ? component.currentNodes() : void 0) {
      return nodes.map(function(node) {
        return _this.board.boardPosition(node);
      });
    } else {
      return component.nodes;
    }
  };

  Analyzer.prototype.addToMatrixLoop = function(section, direction, node) {
    this.info.matrix.currentLoop.path.push(section.id);
    this.info.matrix.currentLoop.nodes[this.nodeId(node)] = true;
    if (!this.info.matrix.currentLoop.startNode) {
      this.info.matrix.currentLoop.startNode = node;
    }
    this.info.matrix.currentLoop.sections[section.id] = {
      resistance: section.resistance * direction * -1
    };
    if (section.voltage) {
      this.info.matrix.currentLoop.voltage += section.voltage * direction * -1;
    }
    if (this.compareNodes.apply(this, section.nodes) && Object.keys(this.info.matrix.currentLoop.sections).length === 1) {
      this.completeMatrixLoop();
    }
    return this.info.matrix.pathsAnalyzed[this.info.matrix.currentLoop.path.join('__')] = true;
  };

  Analyzer.prototype.initMatrix = function() {
    this.info.matrix.loops = {};
    this.info.matrix.unsavedIdentityLoops = [];
    this.info.matrix.sections = [];
    this.info.matrix.pathsToTry = [];
    this.info.matrix.pathsAnalyzed = {};
    return this.info.matrix.totalLoops = 0;
  };

  Analyzer.prototype.addMatrixLoop = function() {
    return this.info.matrix.currentLoop = {
      voltage: 0,
      sections: {},
      path: [],
      nodes: {}
    };
  };

  Analyzer.prototype.completeMatrixLoop = function(loopInfo) {
    var s, sid;
    if (loopInfo == null) {
      loopInfo = this.info.matrix.currentLoop;
    }
    loopInfo.completed = true;
    if (loopInfo.identity) {
      loopInfo.id = ((function() {
        var _ref, _results;
        _ref = loopInfo.sections;
        _results = [];
        for (sid in _ref) {
          s = _ref[sid];
          _results.push("" + sid + ":" + s.resistance);
        }
        return _results;
      })()).join('__');
    } else {
      loopInfo.id = ((function() {
        var _results;
        _results = [];
        for (sid in loopInfo.sections) {
          _results.push(sid);
        }
        return _results;
      })()).sort().join('__');
    }
    if (this.info.matrix.loops[loopInfo.id]) {
      return;
    }
    for (sid in loopInfo.sections) {
      if (this.info.matrix.sections.indexOf(sid) === -1) {
        this.info.matrix.sections.push(sid);
      }
    }
    this.info.matrix.totalLoops += 1;
    return this.info.matrix.loops[loopInfo.id] = loopInfo;
  };

  Analyzer.prototype.matrixLoopDirection = function(section, startingNode) {
    var direction, nodeAligned;
    nodeAligned = this.compareNodes(section.nodes[0], startingNode);
    if ((nodeAligned && section.direction === 1) || (!nodeAligned && section.direction === -1)) {
      return direction = 1;
    } else {
      return direction = -1;
    }
  };

  Analyzer.prototype.addMatrixIndentityLoop = function(node, sections) {
    var identityLoop, section, sid;
    identityLoop = {
      identity: true,
      voltage: 0,
      sections: {}
    };
    for (sid in sections) {
      section = sections[sid];
      identityLoop.sections[sid] = {
        resistance: this.matrixLoopDirection(section, node) * -1
      };
    }
    return this.info.matrix.unsavedIdentityLoops.push(identityLoop);
  };

  Analyzer.prototype.saveMatrixIdentityLoops = function() {
    var identityLoop, sectionId, _i, _len, _ref;
    _ref = this.info.matrix.unsavedIdentityLoops;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      identityLoop = _ref[_i];
      for (sectionId in identityLoop.sections) {
        if (this.info.matrix.sections.indexOf(sectionId) === -1) {
          delete identityLoop.sections[sectionId];
        }
      }
      if (Object.keys(identityLoop.sections).length) {
        this.completeMatrixLoop(identityLoop);
      }
    }
    return delete this.info.matrix.unsavedIdentityLoops;
  };

  Analyzer.prototype.createMatrix = function() {
    var cid, component, direction, index, lastSection, nextNode, nextSection, nextSections, path, sectionId, sid, _ref, _results;
    this.initMatrix();
    _ref = this.board.components;
    _results = [];
    for (cid in _ref) {
      component = _ref[cid];
      this.addMatrixLoop();
      nextSection = this.info.sections[this.info.components[cid]];
      if (!nextSection) {
        continue;
      }
      this.addToMatrixLoop(nextSection, 1, nextSection.nodes[0]);
      nextNode = nextSection.nodes[0];
      _results.push((function() {
        var _i, _len, _results1;
        _results1 = [];
        while (nextSection) {
          nextNode = this.otherNode(nextSection.nodes, nextNode);
          if (nextNode) {
            nextSections = this.info.node[this.nodeId(nextNode)];
            this.addMatrixIndentityLoop(nextNode, nextSections);
          }
          lastSection = nextSection;
          nextSection = null;
          if (nextNode && this.compareNodes(nextNode, this.info.matrix.currentLoop.startNode)) {
            this.completeMatrixLoop();
          } else if (nextNode && !this.info.matrix.currentLoop.nodes[this.nodeId(nextNode)]) {
            if (Object.keys(nextSections).length > 2) {
              for (sid in nextSections) {
                if (this.info.matrix.currentLoop.sections[sid]) {
                  continue;
                }
                if (this.info.matrix.pathsAnalyzed[__slice.call(this.info.matrix.currentLoop.path).concat([sid]).join('__')]) {
                  continue;
                }
                if (nextSection) {
                  this.info.matrix.pathsToTry.push(this.info.matrix.currentLoop.path.concat([sid]));
                } else {
                  nextSection = this.info.sections[sid];
                  direction = this.matrixLoopDirection(nextSection, nextNode);
                }
              }
            }
          }
          if (!nextSection) {
            this.addMatrixLoop();
            if ((path = this.info.matrix.pathsToTry.splice(0, 1)[0])) {
              nextNode = this.info.sections[path[0]].nodes[0];
              for (index = _i = 0, _len = path.length; _i < _len; index = ++_i) {
                sectionId = path[index];
                nextSection = this.info.sections[sectionId];
                direction = this.matrixLoopDirection(nextSection, nextNode);
                if (index < path.length - 1) {
                  this.addToMatrixLoop(nextSection, direction, nextNode);
                  nextNode = this.otherNode(nextSection.nodes, nextNode);
                }
              }
            }
          }
          if (nextSection) {
            _results1.push(this.addToMatrixLoop(nextSection, direction, nextNode));
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  Analyzer.prototype.fillOutMatrix = function() {
    var index, index2, loopInfo, loopInfo2, sectionId, _ref, _results;
    _ref = this.info.matrix.loops;
    _results = [];
    for (index in _ref) {
      loopInfo = _ref[index];
      loopInfo.adjustedVoltage = loopInfo.voltage;
      _results.push((function() {
        var _results1;
        _results1 = [];
        for (sectionId in loopInfo.sections) {
          loopInfo.sections[sectionId].adjusted = loopInfo.sections[sectionId].resistance;
          _results1.push((function() {
            var _base, _ref1, _results2;
            _ref1 = this.info.matrix.loops;
            _results2 = [];
            for (index2 in _ref1) {
              loopInfo2 = _ref1[index2];
              if (index2 !== index) {
                _results2.push((_base = loopInfo2.sections)[sectionId] || (_base[sectionId] = {
                  resistance: 0,
                  adjusted: 0
                }));
              }
            }
            return _results2;
          }).call(this));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  Analyzer.prototype.reduceMatrix = function() {
    var adjustingLoop, adjustingLoopId, adjustingSection, adjustingSectionId, adjustingVariableIndex, adjustingfactor, equalsZero, factor, factorLoop, factorLoopId, loopId, loopInfo, sectionId, sectionIds, sectionInfo, testIndex, testSectionId, tested, variableCount, variableIndex, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3, _results,
      _this = this;
    if (!Object.keys(this.info.matrix.loops).length) {
      return;
    }
    sectionIds = this.info.matrix.sections;
    equalsZero = function(number) {
      return ((_this.board.wires.resistance * -1) < number && number < _this.board.wires.resistance);
    };
    for (variableIndex = _i = 0, _len = sectionIds.length; _i < _len; variableIndex = ++_i) {
      sectionId = sectionIds[variableIndex];
      _ref = this.info.matrix.loops;
      for (factorLoopId in _ref) {
        factorLoop = _ref[factorLoopId];
        tested = true;
        for (testIndex = _j = 0, _len1 = sectionIds.length; _j < _len1; testIndex = ++_j) {
          testSectionId = sectionIds[testIndex];
          if (testIndex < variableIndex) {
            if (!equalsZero(factorLoop.sections[testSectionId].adjusted)) {
              tested = false;
              break;
            }
          }
        }
        if (equalsZero(factorLoop.sections[sectionId].adjusted)) {
          tested = false;
        }
        if (tested) {
          break;
        }
      }
      factor = factorLoop.sections[sectionId].adjusted;
      if (!factor) {
        continue;
      }
      _ref1 = this.info.matrix.loops;
      for (adjustingLoopId in _ref1) {
        adjustingLoop = _ref1[adjustingLoopId];
        if (!(adjustingLoopId !== factorLoopId)) {
          continue;
        }
        adjustingfactor = adjustingLoop.sections[sectionId].adjusted;
        for (adjustingVariableIndex = _k = 0, _len2 = sectionIds.length; _k < _len2; adjustingVariableIndex = ++_k) {
          adjustingSectionId = sectionIds[adjustingVariableIndex];
          adjustingSection = adjustingLoop.sections[adjustingSectionId];
          adjustingSection.adjusted = adjustingSection.adjusted - (factorLoop.sections[adjustingSectionId].adjusted * (adjustingfactor / factor));
          if (equalsZero(adjustingSection.adjusted)) {
            adjustingSection.adjusted = 0;
          }
        }
        adjustingLoop.adjustedVoltage = adjustingLoop.adjustedVoltage - (factorLoop.adjustedVoltage * (adjustingfactor / factor));
        if (equalsZero(adjustingLoop.adjustedVoltage)) {
          adjustingLoop.adjustedVoltage = 0;
        }
      }
    }
    _ref2 = this.info.matrix.loops;
    _results = [];
    for (loopId in _ref2) {
      loopInfo = _ref2[loopId];
      variableCount = 0;
      _ref3 = loopInfo.sections;
      for (sectionId in _ref3) {
        sectionInfo = _ref3[sectionId];
        if (!equalsZero(sectionInfo.adjusted)) {
          variableCount += 1;
        }
      }
      if (variableCount > 1) {
        _results.push(loopInfo.unsolved = true);
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  Analyzer.prototype.assignAmps = function() {
    var index, loopInfo, loopInfoIndex, sectionId, _i, _len, _ref, _ref1, _results;
    _ref = this.info.matrix.sections;
    _results = [];
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      sectionId = _ref[index];
      if (this.info.sections[sectionId].amps) {
        continue;
      }
      _ref1 = this.info.matrix.loops;
      for (loopInfoIndex in _ref1) {
        loopInfo = _ref1[loopInfoIndex];
        if (!loopInfo.unsolved) {
          if (loopInfo.sections[sectionId].adjusted !== 0) {
            break;
          }
        }
      }
      if (loopInfo) {
        _results.push(this.info.sections[sectionId].amps = loopInfo.adjustedVoltage / loopInfo.sections[sectionId].adjusted);
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  Analyzer.prototype.solveMatrix = function() {
    var loopId, loopInfo, _ref;
    _ref = this.info.matrix.loops;
    for (loopId in _ref) {
      loopInfo = _ref[loopId];
      delete loopInfo.unsolved;
    }
    this.fillOutMatrix();
    this.reduceMatrix();
    return this.assignAmps();
  };

  Analyzer.prototype.deleteShorts = function() {
    var changeMade, loopId, loopInfo, section, sid, _ref, _ref1, _ref2;
    changeMade = false;
    _ref = this.info.sections;
    for (sid in _ref) {
      section = _ref[sid];
      if (section.resistance < 0.01 && Math.abs(section.amps) > 1000) {
        changeMade = true;
        section.amps = 'infinite';
      }
    }
    _ref1 = this.info.matrix.loops;
    for (loopId in _ref1) {
      loopInfo = _ref1[loopId];
      for (sid in loopInfo.sections) {
        if (this.info.sections[sid].amps === 'infinite') {
          delete this.info.matrix.loops[loopId];
        }
      }
    }
    if (changeMade) {
      _ref2 = this.info.sections;
      for (sid in _ref2) {
        section = _ref2[sid];
        if (section.amps !== 'infinite') {
          delete section.amps;
        }
      }
      this.solveMatrix();
      return this.deleteShorts();
    }
  };

  Analyzer.prototype.checkPolarizedComponents = function() {
    var changeMade, cid, component, loopId, loopInfo, section, sid, _ref, _ref1, _ref2;
    changeMade = false;
    _ref = this.board.components;
    for (cid in _ref) {
      component = _ref[cid];
      if (!(component.nodes.length > 1 && component.nodes[0].negative && !component.voltage)) {
        continue;
      }
      section = this.info.sections[this.info.components[cid]];
      if (!section) {
        continue;
      }
      if (this.info.matrix.sections.indexOf(section.id) > -1) {
        if (section.amps > 0 && component.direction < 0 || section.amps < 0 && component.direction > 0) {
          changeMade = true;
          this.info.matrix.sections.splice(this.info.matrix.sections.indexOf(section.id, 1));
          _ref1 = this.info.matrix.loops;
          for (loopId in _ref1) {
            loopInfo = _ref1[loopId];
            if (loopInfo.sections[section.id]) {
              delete this.info.matrix.loops[loopId];
            }
          }
        }
      }
    }
    if (changeMade) {
      _ref2 = this.info.sections;
      for (sid in _ref2) {
        section = _ref2[sid];
        delete section.amps;
      }
      this.solveMatrix();
      return this.checkPolarizedComponents();
    }
  };

  return Analyzer;

})(circuitousObject.Object);
