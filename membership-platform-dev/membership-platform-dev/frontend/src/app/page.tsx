import Counter from '@/components/counter';
import Button from '@/components/shared/button';

export default function Home() {
  return (
    <main>
      <section>
        <h1 className="bg-bg-brand-primary">Test</h1>
        <Button className="w-fit max-w-fit">Press me</Button>
        <Counter />
      </section>
    </main>
  );
}
