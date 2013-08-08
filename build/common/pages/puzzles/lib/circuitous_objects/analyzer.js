// Generated by CoffeeScript 1.3.3
var analyzer, circuitousObject,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

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
      node: {},
      nodes: {},
      sections: {},
      components: {},
      path: {}
    };
  };

  Analyzer.prototype.run = function() {
    var circuit, keys, level, parallelSection, parentSection, percentageFlow, powerSource, roundedAmps, section, sid, _i, _ref, _ref1, _ref2;
    this.reduce();
    if ((keys = Object.keys(this.info.sections[this.level])).length !== 1) {
      return;
    }
    circuit = this.info.sections[this.level][keys[0]];
    if (circuit && circuit.negativeComponentId && Object.keys(circuit.components).length > 1) {
      powerSource = this.board.components[circuit.negativeComponentId];
      circuit.complete = this.compareObjectNodes(powerSource, circuit.nodes);
      if (circuit.resistance > 0) {
        circuit.amps = powerSource.voltage / circuit.resistance;
      } else {
        circuit.amps = 'infinite';
      }
    } else {
      circuit.complete = false;
    }
    circuit.sections = [];
    if (circuit.complete) {
      for (level = _i = _ref = Math.max(this.level - 1, 1); _i >= 1; level = _i += -1) {
        _ref1 = this.info.sections[level];
        for (sid in _ref1) {
          section = _ref1[sid];
          if (section.parallelSection) {
            parallelSection = this.info.sections[level + 1][section.parallelSection];
            if (!parallelSection.amps) {
              parallelSection.amps = circuit.amps;
            }
            if (!circuit.resistance) {
              section.amps = (section.resistance ? 0 : 'infinite');
            } else {
              percentageFlow = (1.0 / section.resistance) / (1.0 / parallelSection.resistance);
              section.amps = parallelSection.amps * percentageFlow;
            }
          } else {
            parentSection = ((_ref2 = this.info.sections[level + 1]) != null ? _ref2[section.parentId] : void 0) || circuit;
            section.amps = parentSection.amps;
          }
          if (level === 1) {
            roundedAmps = Math.round(1000.0 * section.amps) / 1000.0;
            if (!isNaN(roundedAmps)) {
              section.amps = roundedAmps;
            }
            circuit.sections.push(section);
          }
        }
      }
    }
    return circuit;
  };

  Analyzer.prototype.initLevel = function(level) {
    this.level = level;
    this.info.node[level] = {};
    this.info.nodes[level] = {};
    this.info.sections[level] = {};
    this.info.components[level] = {};
    return this.info.path[level] = [];
  };

  Analyzer.prototype.compareNodes = function(node1, node2) {
    return node1.x === node2.x && node1.y === node2.y;
  };

  Analyzer.prototype.compareObjectNodes = function(object, nodes) {
    var n, objectNodes;
    objectNodes = (function() {
      var _i, _len, _ref, _results;
      _ref = object.currentNodes();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        _results.push(this.board.boardPosition(n));
      }
      return _results;
    }).call(this);
    if ((this.compareNodes(nodes[0], objectNodes[0]) || this.compareNodes(nodes[0], objectNodes[1])) && (this.compareNodes(nodes[1], objectNodes[0]) || this.compareNodes(nodes[1], objectNodes[1]))) {
      return true;
    }
    return false;
  };

  Analyzer.prototype.reduce = function(level) {
    var cid, component, existingSection, negativeTerminal, node, otherNode, s, sid, _i, _len, _ref, _ref1;
    if (level == null) {
      level = 1;
    }
    this.initLevel(level);
    _ref = this.board.components;
    for (cid in _ref) {
      component = _ref[cid];
      if (component.powerSource) {
        _ref1 = component.currentNodes('negative');
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          negativeTerminal = _ref1[_i];
          node = this.board.boardPosition(negativeTerminal);
          existingSection = ((function() {
            var _ref2, _ref3, _results;
            _ref2 = this.info.sections[level - 1] || {};
            _results = [];
            for (sid in _ref2) {
              s = _ref2[sid];
              if ((_ref3 = s.components) != null ? _ref3[cid] : void 0) {
                _results.push(s);
              }
            }
            return _results;
          }).call(this))[0];
          if (existingSection) {
            otherNode = this.otherNode(existingSection.nodes, node);
            otherNode.negative = true;
          }
          this.combineSections(level, otherNode || node, existingSection || component, this.newSection(node));
        }
      }
    }
    if (Object.keys(this.info.sections[this.level]).length > 1) {
      this.redraw(this.level);
    }
    if (Object.keys(this.info.sections[this.level]).length > 1) {
      this.initLevel(this.level + 1);
      if (this.reduceParallels(this.level)) {
        return this.reduce(this.level + 1);
      }
    }
  };

  Analyzer.prototype.recordSection = function(level, section, children) {
    var child, _i, _len;
    if (children) {
      if (!/Array/.test(children.constructor)) {
        children = [children];
      }
      for (_i = 0, _len = children.length; _i < _len; _i++) {
        child = children[_i];
        child.parentId = section.id;
        section.sections[child.id] = true;
      }
    }
    if (!(this.info.path[level].indexOf(section.id) > -1)) {
      this.info.path[level].push(section.id);
    }
    this.info.sections[level][section.id] = section;
    return this.recordSectionAtNodes(level, section);
  };

  Analyzer.prototype.recordSectionAtNodes = function(level, section) {
    var node1Coords, node2Coords, _base, _base1, _base2, _base3, _name, _name1, _name2, _name3;
    node1Coords = "" + section.nodes[0].x + ":" + section.nodes[0].y;
    node2Coords = "" + section.nodes[1].x + ":" + section.nodes[1].y;
    (_base = this.info.node[level])[_name = "" + node1Coords] || (_base[_name] = {});
    this.info.node[level]["" + node1Coords][section.id] = section;
    (_base1 = this.info.node[level])[_name1 = "" + node2Coords] || (_base1[_name1] = {});
    this.info.node[level]["" + node2Coords][section.id] = section;
    (_base2 = this.info.nodes[level])[_name2 = "" + node1Coords + node2Coords] || (_base2[_name2] = {});
    this.info.nodes[level]["" + node1Coords + node2Coords][section.id] = section;
    (_base3 = this.info.nodes[level])[_name3 = "" + node2Coords + node1Coords] || (_base3[_name3] = {});
    return this.info.nodes[level]["" + node2Coords + node1Coords][section.id] = section;
  };

  Analyzer.prototype.deleteSection = function(level, section) {
    var cid;
    for (cid in section.components) {
      delete this.info.components[level][cid];
    }
    this.info.path[level].splice(this.info.path[level].indexOf(section.id), 1);
    delete this.info.sections[level][section.id];
    return this.deleteSectionAtNodes(level, section);
  };

  Analyzer.prototype.deleteSectionAtNodes = function(level, section) {
    var node1Coords, node2Coords;
    node1Coords = "" + section.nodes[0].x + ":" + section.nodes[0].y;
    node2Coords = "" + section.nodes[1].x + ":" + section.nodes[1].y;
    delete this.info.node[level]["" + node1Coords][section.id];
    delete this.info.node[level]["" + node2Coords][section.id];
    delete this.info.nodes[level]["" + node1Coords + node2Coords][section.id];
    return delete this.info.nodes[level]["" + node2Coords + node1Coords][section.id];
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

  Analyzer.prototype.redraw = function(level) {
    var cConnections, cEndNode, ccStartNodeIndex, ccs, ccsid, changeMade, childSectionId, connectingSection, connections, csid, endNode, endNodeIndex, otherNode, section, sid, _i, _len, _ref, _ref1;
    changeMade = false;
    endNode = null;
    _ref = this.info.path[level];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      sid = _ref[_i];
      section = this.info.sections[level][sid];
      endNode = endNode ? this.otherNode(section.nodes, endNode) : section.nodes[1];
      connections = this.info.node[level]["" + endNode.x + ":" + endNode.y];
      if (Object.keys(connections).length > 2) {
        for (csid in connections) {
          connectingSection = connections[csid];
          if (csid !== sid) {
            if (!connectingSection.resistance && !connectingSection.powerSource) {
              changeMade = true;
              this.deleteSection(level, connectingSection);
              cEndNode = this.otherNode(connectingSection.nodes, endNode);
              cConnections = this.info.node[level]["" + cEndNode.x + ":" + cEndNode.y];
              for (ccsid in cConnections) {
                ccs = cConnections[ccsid];
                this.deleteSectionAtNodes(level, ccs);
                ccStartNodeIndex = (this.compareNodes(ccs.nodes[0], cEndNode) ? 0 : 1);
                ccs.nodes[ccStartNodeIndex] = endNode;
                this.recordSectionAtNodes(level, ccs);
                if (this.compareNodes.apply(this, ccs.nodes)) {
                  if (!ccs.resistance) {
                    this.consumeSection(section, ccs);
                  }
                  this.deleteSection(level, ccs);
                }
              }
              this.consumeSection(section, connectingSection);
            }
          }
        }
      } else if (Object.keys(connections).length === 2) {
        for (csid in connections) {
          connectingSection = connections[csid];
          if (!(csid !== sid)) {
            continue;
          }
          otherNode = this.otherNode(connectingSection.nodes, endNode);
          this.deleteSection(level, connectingSection);
          this.addToSection(level, section, otherNode, connectingSection);
          for (childSectionId in connectingSection.sections) {
            if ((_ref1 = this.info.sections[childSectionId]) != null) {
              _ref1.parentId;
            }
          }
          endNodeIndex = (this.compareNodes(section.nodes[0], endNode) ? 0 : 1);
          section.nodes[endNodeIndex] = otherNode;
          changeMade = true;
        }
      }
      if (changeMade) {
        this.redraw(level);
        return true;
      }
    }
    return false;
  };

  Analyzer.prototype.reduceParallels = function(level) {
    var analyzed, cid, componentIds, id, newSection, node1Coords, node2Coords, nodeIds, parallel, reductionFound, resistance, section, sections, _ref;
    reductionFound = false;
    analyzed = {};
    _ref = this.info.nodes[level - 1];
    for (nodeIds in _ref) {
      sections = _ref[nodeIds];
      if (!(Object.keys(sections).length)) {
        continue;
      }
      section = sections[Object.keys(sections)[0]];
      node1Coords = "" + section.nodes[0].x + ":" + section.nodes[0].y;
      node2Coords = "" + section.nodes[1].x + ":" + section.nodes[1].y;
      if (analyzed[node1Coords] && analyzed[node2Coords] && analyzed[node1Coords] === analyzed[node2Coords]) {
        continue;
      }
      if (Object.keys(sections).length > 1) {
        reductionFound = true;
        resistance = 0;
        for (id in sections) {
          section = sections[id];
          resistance += 1.0 / section.resistance;
        }
        parallel = {
          id: this.generateId(),
          resistance: 1.0 / resistance,
          components: {},
          nodes: section.nodes,
          sections: []
        };
        for (id in sections) {
          section = sections[id];
          section.parallelSection = parallel.id;
          parallel.sections.push(id);
          for (cid in section.components) {
            parallel.components[cid] = true;
          }
        }
        analyzed[node1Coords] = analyzed[node2Coords] = parallel.id;
        this.recordSection(level, parallel, sections);
        componentIds = [];
        for (id in sections) {
          section = sections[id];
          componentIds = componentIds.concat((function() {
            var _results;
            _results = [];
            for (id in section.components) {
              _results.push(id);
            }
            return _results;
          })());
        }
      } else {
        analyzed[node1Coords] = analyzed[node2Coords] = section.id;
        newSection = JSON.parse(JSON.stringify(section));
        newSection.id = this.generateId();
        this.recordSection(level, newSection, section);
      }
    }
    if (reductionFound) {
      this.reduceParallels();
    }
    return reductionFound;
  };

  Analyzer.prototype.consumeSection = function(section, toBeConsumedSection) {
    var childSection, cid, csid, _results;
    for (csid in toBeConsumedSection) {
      childSection = toBeConsumedSection[csid];
      childSection.parentId = section.id;
    }
    _results = [];
    for (cid in toBeConsumedSection.components) {
      _results.push(section.components[cid] = true);
    }
    return _results;
  };

  Analyzer.prototype.combineSections = function(level, node, component, section) {
    var c, connectingConnections, connections, _i, _j, _len, _len1;
    connections = this.analyzeSection(level, node, component, section);
    if (connections.length > 1) {
      for (_i = 0, _len = connections.length; _i < _len; _i++) {
        c = connections[_i];
        connectingConnections = this.analyzeSection(level, c.otherNode, c.component, this.newSection(c.node));
      }
      for (_j = 0, _len1 = connectingConnections.length; _j < _len1; _j++) {
        c = connectingConnections[_j];
        this.combineSections(level, c.otherNode, c.component, this.newSection(c.node));
      }
    }
    return true;
  };

  Analyzer.prototype.analyzeSection = function(level, node, component, section) {
    var connection, connections;
    connections = [];
    if (this.addToSection(level, section, node, component)) {
      if ((connections = this.findConnections(level, node, component, section)).length === 1) {
        connection = connections[0];
        if (connection.otherNode.negative || section.components[connection.component.id] || !(connections = this.analyzeSection(level, connection.otherNode, connection.component, section)).length) {
          this.endSection(level, section, node, connection.component);
        }
      } else if (connections.length > 1) {
        this.endSection(level, section, node, component);
        return connections;
      } else {
        this.endSection(level, section, node, component);
      }
    }
    return connections;
  };

  Analyzer.prototype.findConnections = function(level, node, component, circuit) {
    var c, connection, connections, id, matchingNode, n, nodes, otherNode, segment, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
    connections = [];
    if (level > 1) {
      _ref = this.info.node[level - 1]["" + node.x + ":" + node.y];
      for (id in _ref) {
        connection = _ref[id];
        if (!(connection.id !== component.id)) {
          continue;
        }
        otherNode = this.otherNode(connection.nodes, node);
        connections.push({
          component: connection,
          otherNode: otherNode,
          node: node
        });
      }
      return connections;
    } else {
      _ref1 = this.board.components;
      for (id in _ref1) {
        c = _ref1[id];
        if (c !== component && (id === circuit.negativeComponentId || !circuit.components[id])) {
          _ref2 = (nodes = c.currentNodes());
          for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
            n = _ref2[_i];
            matchingNode = this.board.boardPosition(n);
            if (!this.compareNodes(matchingNode, node)) {
              continue;
            }
            if (nodes.length === 1) {
              return [
                {
                  component: c,
                  otherNode: matchingNode,
                  node: node
                }
              ];
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
      }
      _ref3 = this.board.wires.find(node);
      for (_j = 0, _len1 = _ref3.length; _j < _len1; _j++) {
        segment = _ref3[_j];
        if (!circuit.components[segment.id]) {
          connections.push({
            component: segment,
            otherNode: this.otherNode(segment.nodes, node),
            node: node
          });
        }
      }
    }
    return connections;
  };

  Analyzer.prototype.newSection = function(node) {
    var section;
    section = {
      nodes: [node],
      resistance: 0,
      components: {},
      sections: {},
      id: this.generateId()
    };
    return section;
  };

  Analyzer.prototype.addToSection = function(level, section, node, component) {
    var cid;
    if (this.info.components[level][component.id]) {
      return false;
    }
    if (component.powerSource && node.negative) {
      section.powerSource = true;
      section.negativeComponentId = component.negativeComponentId || component.id;
      section.nodes[0].negative = true;
    }
    section.resistance += component.resistance || 0;
    if (component.components) {
      for (cid in component.components) {
        section.components[cid] = true;
      }
    } else {
      section.components[component.id] = true;
    }
    this.info.components[level][component.id] = section.id;
    component.parentId = section.id;
    section.sections[component.id] = true;
    return true;
  };

  Analyzer.prototype.endSection = function(level, section, node, component, record) {
    if (component.powerSource) {
      section.powerSource = true;
    }
    this.info.components[level][component.id] = section.id;
    section.nodes.push(node);
    return this.recordSection(level, section, component);
  };

  return Analyzer;

})(circuitousObject.Object);