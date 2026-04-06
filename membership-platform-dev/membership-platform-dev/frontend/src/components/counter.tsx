'use client';

import React from 'react';
import Button from './shared/button';

interface CounterProps {
  initialCount?: number;
}

function Counter(props: CounterProps) {
  const { initialCount = 0 } = props;

  const [count, setCount] = React.useState(initialCount);

  const handleDecrease = () => {
    setCount((prev) => {
      return prev - 1;
    });
  };

  const handleIncrease = () => {
    setCount((prev) => {
      return prev + 1;
    });
  };

  return (
    <div className="flex gap-2 w-fit items-center">
      <Button onClick={handleDecrease}>-</Button>
      <p className="font-semibold">{count}</p>
      <Button onClick={handleIncrease}>+</Button>
    </div>
  );
}

export default Counter;
