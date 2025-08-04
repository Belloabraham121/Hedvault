import Navbar from "../components/navbar";
import Hero from "../components/hero";
import Partners from "../components/partners";
import Features from "../components/features";
import CTASection from "../components/cta-section";
import Statistics from "../components/statistics";
import FeatureDetail from "../components/feature-detail";
import FAQ from "../components/faq";
import Footer from "../components/footer";

export default function Page() {
  return (
    <div className="flex flex-col min-h-screen">
      <Navbar />
      <Hero />
      <Partners />
      <Features />
      <Statistics />
      <FeatureDetail />
      <CTASection />
      <FAQ />
      <Footer />
    </div>
  );
}
