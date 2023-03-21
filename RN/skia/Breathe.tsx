import React, { useMemo, useContext, useState } from "react";
import { DimensionsProvider, useDimensions } from "../hooks/Provider";
import {
  Canvas,
  Circle,
  Color,
  Easing,
  Group,
  interpolate,
  interpolateColors,
  SkiaValue,
  Transforms2d,
  useComputedValue,
  useTiming,
} from "@shopify/react-native-skia";
import { COLORS } from "../constants";
import { LevelContext } from '../context';

const Breathe = () => {
  return (
    <DimensionsProvider>
      <_Breathe />
    </DimensionsProvider>
  );
};

export default Breathe;

let lastHRV = 0;
let lastHeart = 0;

const _Breathe = () => {
  const [update, setUpdate] = useState(0.2)

  const ctx = useContext(LevelContext);

  React.useEffect(() => {
    setTimeout(()=>
    setUpdate(0.4)
   , 7000);
   const timer = setInterval(() => {
    if (lastHRV === 0 || lastHeart === 0) return;
    let updatePoint = 0.0;
    if (ctx.hrv < lastHRV || ctx.heartRate < lastHeart) updatePoint += 0.1;
    if (ctx.hrv > lastHRV || ctx.heartRate > lastHeart) updatePoint -= 0.1;
    lastHeart = ctx.heartRate;
    lastHRV = ctx.hrv
    setUpdate(updatePoint < 0.4 ? 0.4 : updatePoint);
   }, 10000)

   return () => clearInterval(timer)
  }, []);

  const { CENTER, SCREEN_HEIGHT, SCREEN_WIDTH } = useDimensions();
  const data = useMemo(() => {
    return Array(8).fill(0);
  }, []);

  const radius = SCREEN_WIDTH / 6;
  const skValue = useTiming({ from: 0, to: update, loop: true, yoyo: true }, { duration: 3500, easing: Easing.bezier(0.5, 0, 0.5, 1) })
  return (
    <Canvas style={{ width: SCREEN_WIDTH, height: SCREEN_HEIGHT }}>
      {data.map((_, i) => {
        return (
          <MyCircle
            center={CENTER}
            radius={radius}
            color={i <= 2 ? COLORS[0] : COLORS[1]}
            opacity={1 / data.length}
            skValue={skValue}
            angle={2 * Math.PI * (i / data.length)}
            key={i}
          />
        );
      })}
    </Canvas>
  );
};

interface MyCircleProps {
  center: { x: number; y: number };
  radius: number;
  color: Color;
  opacity: number;
  skValue: SkiaValue<number>;
  angle: number;
}

const MyCircle = ({ center, radius, color, opacity, skValue, angle }: MyCircleProps) => {
  const r = useComputedValue(() => {
    return radius / interpolate(skValue.current, [1, 2], [1, 1]);
  }, [skValue]);

  const transform = useComputedValue((): Transforms2d => {
    return [
      { translateY: -r.current },
      { rotate: interpolate(skValue.current, [0, 1], [angle, angle + Math.PI / 2]) },
      { translateY: interpolate(skValue.current, [0, 1], [r.current, 0]) },
    ];
  }, [skValue, r]);

  const origin = useComputedValue(() => {
    return { x: center.x, y: center.y + r.current };
  }, [r]);

  const animatedColor = useComputedValue(() => {
    return interpolateColors(skValue.current, [0, 0.3], ["#7FFFD4", color]);
  }, [skValue]);

  return (
    <Group transform={transform} origin={origin}>
      <Circle cx={center.x} cy={center.y} r={r} color={animatedColor} opacity={opacity} />
    </Group>
  );
};
