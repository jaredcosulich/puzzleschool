import Logo from "@/components/Logo";
import Footer from "@/components/Footer";

export const metadata = { title: "Contact | The Puzzle School" };

export default function Contact() {
  return (
    <>
      <div className="container">
        <Logo />

        <div className="row">
          <div className="col-xs-12 text-xs-center">
            <p>
              We are actively reaching out to families, educators, businesses and community members in the Cambridge
              area.
            </p>
            <p>
              If you&apos;d like to contact us please email{" "}
              <a href="mailto:info@puzzleschool.com">info@puzzleschool.com</a>
            </p>
          </div>
        </div>
      </div>

      <Footer showQuotes={false} />
    </>
  );
}
