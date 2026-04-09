import { BannerContent, Divider } from "@/src/components/Ui";
import { HomeContent } from "@/src/components/HomeContent";
import { Center, Banner } from "@/src/components/Ui";


const Home = async () => {
  return (<div className={`select-none`}>
    <Center><Banner>
      <BannerContent headingText='Hello 👋' dividerClassNames="w-60 sm:w-100">
        <HomeContent />
        <Divider />
      </BannerContent >
    </Banner></Center>
  </div>);
};

export default Home;