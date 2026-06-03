"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import type { Card } from "@/lib/puzzles";

// Card metadata, ported from the original code_puzzle_projects.coffee FUNCTIONS map.
const FUNCTIONS: Record<string, { name: string; method: string; color: boolean }> = {
  A1: { name: "Move Forward", method: "moveForward", color: false },
  A2: { name: "Move Backward", method: "moveBackward", color: false },
  A3: { name: "Rotate Right", method: "rotateRight", color: false },
  A4: { name: "Rotate Left", method: "rotateLeft", color: false },
  A5: { name: "Fill Color", method: "fillColor", color: true },
  P1: { name: "Pen Up", method: "penUp", color: false },
  P2: { name: "Pen Down", method: "penDown", color: false },
  P3: { name: "Pen Size", method: "penSize", color: false },
  P4: { name: "Pen Color", method: "penColor", color: true },
  F1: { name: "Function", method: "function", color: false },
  F2: { name: "End Function", method: "endFunction", color: false },
  L1: { name: "Loop", method: "loop", color: false },
  L2: { name: "End Loop", method: "endLoop", color: false },
};

const CANVAS_SIZE = 640;
const SPEEDS: Record<string, number> = { Slow: 1000, Fast: 200, "Very Fast": 50, Immediate: 0 };

type Loop = { start: number; completed: number; total: number };
type UserFn = { start: number; functions: Array<() => number> };

type EngineState = {
  ctx: CanvasRenderingContext2D;
  arrowCtx: CanvasRenderingContext2D;
  currentPoint: [number, number];
  currentAngle: number;
  penSize: number;
  penColor: [number, number, number];
  penIsDown: boolean;
  loops: Loop[];
  userFunctions: Record<string, UserFn>;
  currentFunction?: string;
  fillColor?: [number, number, number];
  executionIndex: number;
};

function colorFromParam(param: string): [number, number, number] {
  const parts = param
    .split(/\s+/)
    .filter((s) => s.length > 0)
    .map((v) => Math.floor(parseFloat(v) * 255));
  return [parts[0] || 0, parts[1] || 0, parts[2] || 0];
}

function calculateXDistance(distance: number, angle: number): number {
  const a = angle % 360;
  if (a === 90 || a === 270) return 0;
  if (a === 0) return distance * -1;
  if (a === 180) return distance;
  return Math.cos(a * (Math.PI / 180)) * distance * -1;
}

function calculateYDistance(distance: number, angle: number): number {
  const a = angle % 360;
  if (a === 0 || a === 180) return 0;
  if (a === 270) return distance;
  if (a === 90) return distance * -1;
  return Math.sin(a * (Math.PI / 180)) * distance * -1;
}

function calculatePoint(point: [number, number], distance: number, angle: number): [number, number] {
  return [point[0] + calculateXDistance(distance, angle), point[1] + calculateYDistance(distance, angle)];
}

// Simple queue-based flood fill (replaces the original ImageProcessing.fill helper).
function floodFill(ctx: CanvasRenderingContext2D, fill: [number, number, number], sx: number, sy: number) {
  const w = ctx.canvas.width;
  const h = ctx.canvas.height;
  const startX = Math.round(sx);
  const startY = Math.round(sy);
  if (startX < 0 || startY < 0 || startX >= w || startY >= h) return;

  const img = ctx.getImageData(0, 0, w, h);
  const data = img.data;
  const idx = (x: number, y: number) => (y * w + x) * 4;
  const start = idx(startX, startY);
  const target = [data[start], data[start + 1], data[start + 2], data[start + 3]];
  const fillRGBA = [fill[0], fill[1], fill[2], 255];
  if (target.every((v, i) => v === fillRGBA[i])) return;

  const match = (p: number) =>
    Math.abs(data[p] - target[0]) < 10 &&
    Math.abs(data[p + 1] - target[1]) < 10 &&
    Math.abs(data[p + 2] - target[2]) < 10 &&
    Math.abs(data[p + 3] - target[3]) < 10;

  const stack: Array<[number, number]> = [[startX, startY]];
  while (stack.length) {
    const [x, y] = stack.pop()!;
    const p = idx(x, y);
    if (!match(p)) continue;
    data[p] = fillRGBA[0];
    data[p + 1] = fillRGBA[1];
    data[p + 2] = fillRGBA[2];
    data[p + 3] = fillRGBA[3];
    if (x > 0) stack.push([x - 1, y]);
    if (x < w - 1) stack.push([x + 1, y]);
    if (y > 0) stack.push([x, y - 1]);
    if (y < h - 1) stack.push([x, y + 1]);
  }
  ctx.putImageData(img, 0, 0);
}

function drawArrow(state: EngineState, point = state.currentPoint, angle = state.currentAngle) {
  const a = state.arrowCtx;
  const width = 7;
  const height = 15;
  a.clearRect(0, 0, CANVAS_SIZE, CANVAS_SIZE);
  a.save();
  a.fillStyle = "red";
  a.translate(point[0], point[1]);
  a.rotate(((angle - 90) * Math.PI) / 180);
  a.translate(width * -1, height * -1);
  a.beginPath();
  a.moveTo(0, height);
  a.lineTo(width, 0);
  a.lineTo(width * 2, height);
  a.closePath();
  a.fill();
  a.restore();
}

function resetState(state: EngineState) {
  state.ctx.clearRect(0, 0, CANVAS_SIZE, CANVAS_SIZE);
  state.currentPoint = [CANVAS_SIZE / 2, CANVAS_SIZE / 2];
  state.currentAngle = 90;
  state.penSize = 1;
  state.penColor = [0, 0, 0];
  state.penIsDown = true;
  state.loops = [];
  state.userFunctions = {};
  state.currentFunction = undefined;
  state.fillColor = undefined;
  state.executionIndex = 0;
}

// Faithful port of executeCard from the original CoffeeScript engine.
function executeCard(state: EngineState, cards: Card[], index: number): number {
  const card = cards[index];
  if (!card) return 1;

  const info = FUNCTIONS[card.code];
  if (!info) return 1;
  const methodName = info.method;
  const paramNumber = parseFloat(card.param);

  if (state.currentFunction != null) {
    if (methodName === "endFunction") {
      state.currentFunction = undefined;
    } else {
      state.userFunctions[state.currentFunction].functions.push(() => executeCard(state, cards, index));
    }
    return 1;
  }

  let nextPoint = state.currentPoint;
  let fill = false;

  switch (methodName) {
    case "moveForward":
      nextPoint = calculatePoint(state.currentPoint, paramNumber, state.currentAngle);
      break;
    case "moveBackward":
      nextPoint = calculatePoint(state.currentPoint, paramNumber * -1, state.currentAngle);
      break;
    case "rotateRight":
      state.currentAngle += paramNumber;
      break;
    case "rotateLeft":
      state.currentAngle -= paramNumber;
      break;
    case "penUp":
      state.penIsDown = false;
      break;
    case "penDown":
      state.penIsDown = true;
      break;
    case "penSize":
      state.penSize = paramNumber;
      break;
    case "penColor":
      state.penColor = colorFromParam(card.param);
      break;
    case "fillColor":
      state.fillColor = colorFromParam(card.param);
      fill = true;
      break;
    case "loop":
      state.loops.push({ start: index + 1, completed: 0, total: paramNumber });
      break;
    case "endLoop": {
      const currentLoop = state.loops[state.loops.length - 1];
      if (currentLoop) {
        currentLoop.completed += 1;
        if (currentLoop.completed === currentLoop.total) {
          state.loops.pop();
        } else {
          return currentLoop.start - index;
        }
      }
      break;
    }
    case "function": {
      const userFunction = state.userFunctions[card.param];
      if (userFunction) {
        let functionIndex = 0;
        while (functionIndex <= userFunction.functions.length - 1) {
          functionIndex += userFunction.functions[functionIndex]();
        }
      } else {
        state.userFunctions[card.param] = { start: index, functions: [] };
        state.currentFunction = card.param;
      }
      break;
    }
    default:
      break;
  }

  drawArrow(state, nextPoint, state.currentAngle);

  if (state.penIsDown && (state.currentPoint[0] !== nextPoint[0] || state.currentPoint[1] !== nextPoint[1])) {
    state.ctx.lineWidth = state.penSize;
    state.ctx.strokeStyle = `rgb(${state.penColor.join(",")})`;
    state.ctx.beginPath();
    state.ctx.moveTo(state.currentPoint[0], state.currentPoint[1]);
    state.ctx.lineTo(nextPoint[0], nextPoint[1]);
    state.ctx.stroke();
  }

  if (fill && state.fillColor) {
    floodFill(state.ctx, state.fillColor, nextPoint[0], nextPoint[1]);
  }

  state.currentPoint = nextPoint;
  return 1;
}

export default function CodePuzzle({ cards, title }: { cards: Card[]; title: string }) {
  const drawingRef = useRef<HTMLCanvasElement>(null);
  const arrowRef = useRef<HTMLCanvasElement>(null);
  const stateRef = useRef<EngineState | null>(null);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const cardListRef = useRef<HTMLDivElement>(null);

  const [activeIndex, setActiveIndex] = useState(0);
  const [speedLabel, setSpeedLabel] = useState("Fast");
  const [signature, setSignature] = useState("");
  const [swatch, setSwatch] = useState<string | null>(null);

  const updateSignature = useCallback(
    (index: number) => {
      const card = cards[index];
      if (!card) return;
      const info = FUNCTIONS[card.code];
      if (info.color) {
        setSignature(info.name);
        setSwatch(`rgb(${colorFromParam(card.param).join(",")})`);
      } else {
        setSignature(card.param ? `${info.name} ${card.param}` : info.name);
        setSwatch(null);
      }
    },
    [cards]
  );

  const stopInterval = useCallback(() => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
  }, []);

  // Run cards [0, endIndex] from a clean slate.
  const executeUpTo = useCallback(
    (endIndex: number) => {
      const state = stateRef.current;
      if (!state) return;
      resetState(state);
      drawArrow(state);
      let index = 0;
      while (index <= endIndex) {
        index += executeCard(state, cards, index);
      }
      state.executionIndex = endIndex + 1;
      setActiveIndex(endIndex);
      updateSignature(endIndex);
    },
    [cards, updateSignature]
  );

  const play = useCallback(() => {
    const state = stateRef.current;
    if (!state) return;
    stopInterval();
    const speed = SPEEDS[speedLabel];

    if (speed === 0) {
      executeUpTo(cards.length - 1);
      return;
    }

    intervalRef.current = setInterval(() => {
      if (state.executionIndex >= cards.length) {
        stopInterval();
        return;
      }
      const index = state.executionIndex;
      state.executionIndex += executeCard(state, cards, index);
      setActiveIndex(index);
      updateSignature(index);
    }, speed);
  }, [cards, speedLabel, executeUpTo, stopInterval, updateSignature]);

  // Initialize canvases and auto-play once mounted.
  useEffect(() => {
    const drawing = drawingRef.current;
    const arrow = arrowRef.current;
    if (!drawing || !arrow) return;

    const ctx = drawing.getContext("2d");
    const arrowCtx = arrow.getContext("2d");
    if (!ctx || !arrowCtx) return;

    ctx.lineCap = "round";
    ctx.lineJoin = "round";
    ctx.translate(0.5, 0.5);

    const state: EngineState = {
      ctx,
      arrowCtx,
      currentPoint: [CANVAS_SIZE / 2, CANVAS_SIZE / 2],
      currentAngle: 90,
      penSize: 1,
      penColor: [0, 0, 0],
      penIsDown: true,
      loops: [],
      userFunctions: {},
      executionIndex: 0,
    };
    stateRef.current = state;

    resetState(state);
    drawArrow(state);
    play();

    return () => stopInterval();
    // Only run on mount; play picks up the latest speed via its own closure on replay.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Keep the active card scrolled into view.
  useEffect(() => {
    const list = cardListRef.current;
    if (!list) return;
    const el = list.children[activeIndex] as HTMLElement | undefined;
    if (el) {
      const top = el.offsetTop - list.clientHeight / 2 + el.clientHeight / 2;
      list.scrollTo({ top, behavior: "smooth" });
    }
  }, [activeIndex]);

  return (
    <div className="codepuzzle-app">
      <div className="cp-sidebar">
        <div className="cp-signature">
          {swatch && <span className="cp-swatch" style={{ backgroundColor: swatch }} />}
          <span>{signature}</span>
        </div>

        <div className="cp-cards" ref={cardListRef}>
          {cards.map((card, i) => (
            <button
              type="button"
              key={i}
              className={`cp-card ${i === activeIndex ? "active" : ""}`}
              onClick={() => {
                stopInterval();
                executeUpTo(i);
              }}
              title={`${FUNCTIONS[card.code]?.name}${card.param ? ` ${card.param}` : ""}`}
            >
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={`/images/codepuzzle/cards/${card.code}.png`} alt={FUNCTIONS[card.code]?.name} />
              {card.param && !FUNCTIONS[card.code]?.color && <span className="cp-param">{card.param}</span>}
            </button>
          ))}
        </div>

        <div className="cp-controls">
          <button type="button" className="btn btn-success" onClick={play}>
            Play
          </button>
          <button type="button" className="btn btn-danger" onClick={stopInterval}>
            Pause
          </button>
          <select
            className="custom-select"
            value={speedLabel}
            onChange={(e) => setSpeedLabel(e.target.value)}
          >
            {Object.keys(SPEEDS).map((label) => (
              <option key={label} value={label}>
                {label}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="cp-canvas-wrap">
        <div className="cp-canvas">
          <canvas ref={drawingRef} width={CANVAS_SIZE} height={CANVAS_SIZE} aria-label={`${title} drawing`} />
          <canvas ref={arrowRef} width={CANVAS_SIZE} height={CANVAS_SIZE} />
        </div>
      </div>
    </div>
  );
}
