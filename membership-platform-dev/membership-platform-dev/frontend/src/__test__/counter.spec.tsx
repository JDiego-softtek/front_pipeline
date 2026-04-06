import Counter from '@/components/counter';
import { fireEvent, render } from '@testing-library/react';
import { act } from 'react';

describe('<Counter />', () => {
  it('should increse when the + button is clicked', () => {
    const initialValue = 1;
    const result = render(<Counter initialCount={initialValue} />);

    const increaseBtn = result.getByRole('button', { name: '+' });
    act(() => {
      fireEvent.click(increaseBtn);
    });

    expect(result.getByText(initialValue + 1)).toBeInTheDocument();
  });

  it('should decrease when the - button is clicked', () => {
    const initialValue = 1;
    const result = render(<Counter initialCount={initialValue} />);

    const decreaseBtn = result.getByRole('button', { name: '-' });
    act(() => {
      fireEvent.click(decreaseBtn);
    });

    expect(result.getByText(initialValue - 1)).toBeInTheDocument();
  });

  it('should render 10 when the initialCount is set to 10', () => {
    const initialValue = 10;
    const result = render(<Counter initialCount={initialValue} />);

    expect(result.getByText(initialValue)).toBeInTheDocument();
  });
});
