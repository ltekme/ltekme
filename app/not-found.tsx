import { BannerContent } from "@/src/components/Ui";
import Link from 'next/link'
import { Center, Banner } from "@/src/components/Ui";


export default function NotFound() {
  return (<Center><Banner>
    <BannerContent headingText='Item not found ⚠️'>
      <p>The Item you're looking for is not found or not available.</p>
      Navgate: <Link href={"/"} className='text-accent hover:text-accentHover'>Home</Link>
    </BannerContent>
  </Banner></Center>);
}