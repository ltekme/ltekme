import type { Metadata } from "next";
import { Analytics } from "@vercel/analytics/react"

import "@/src/globals.css";

export const metadata: Metadata = {
  title: "Ltek.me",
  description: "My Website",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <link rel="icon" href="/icon.ico" sizes="any" />
      </head>
      <Analytics />
      <body>
        {children}
      </body>
    </html>
  );
}
