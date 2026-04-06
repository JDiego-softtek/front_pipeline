import type { Metadata } from 'next';
import { Fira_Sans } from 'next/font/google';
import './globals.css';

const fira = Fira_Sans({
  subsets: ['latin'],
  weight: ['400', '500', '600', '800'],
  variable: '--font-fira-sans',
});

export const metadata: Metadata = {
  title: 'Membership Desk',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={fira.variable}>
      <body>{children}</body>
    </html>
  );
}
