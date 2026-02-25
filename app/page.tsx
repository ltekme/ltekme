import { BannerContent, Divider } from "@/src/components/Ui";
import { HomeContent } from "@/src/components/HomeContent";
import Link from "next/link";

const Home = async () => {
  return (<BannerContent headingText='Hello 👋' dividerClassNames="w-60 sm:w-100">
    < HomeContent />
    <Divider />
  </BannerContent >);
};

export default Home;