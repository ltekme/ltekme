import type { Metadata } from "next";
import { ClockDisplay } from "./clock";
import { Center, Banner } from "@/src/components/Ui";

export const metadata: Metadata = {
  title: "Ltek.me | Clock",
  description: "Year-round Clock",
};

export default function ClockPage() {
  return (<Center><Banner>
    <ClockDisplay />
  </Banner></Center>);
}