import Image from "next/image";

export default function Home() {

  return (
    <div className='flex flex-col items-center gap-6 p-64 text-center'>
      <Image 
        src='/images/compass_logo.png' 
        alt="The Puzzle School"
        width={349}
        height={132}
        className='mr-[72px]'
      />
      <div>
        An educational philosophy focused on developing the metacognitive skills for navigating ambiguity.
      </div>
      <div>More coming soon...</div>
    </div>
  );
}
