"use client"

import { useState } from "react"
import { Plus, Minus } from "lucide-react"

export default function FAQ() {
  const [openIndex, setOpenIndex] = useState<number | null>(null)

  const faqs = [
    {
      question: "What is HedVault, and how does it work?",
      answer:
        "HedVault is a pioneering platform built on Hedera Hashgraph that enables the tokenization of real-world assets (RWAs) and integrates them with decentralized finance (DeFi) functionalities. Users can buy, sell, swap, lend, borrow, and earn rewards from their tokenized RWAs.",
    },
    {
      question: "How does RWA swapping work?",
      answer:
        "RWA swapping on HedVault is facilitated through Automated Market Makers (AMMs) and Over-the-Counter (OTC) mechanisms. You can easily swap your tokenized RWAs for other assets or stablecoins, providing liquidity and flexibility in your DeFi portfolio.",
    },
    {
      question: "Can I borrow against my RWAs?",
      answer:
        "Yes, HedVault offers lending and borrowing functionalities. You can use your tokenized RWAs as collateral to borrow funds, unlocking liquidity without needing to sell your assets. Our platform supports overcollateralized lending to ensure security for all participants.",
    },
    {
      question: "How do I earn yield?",
      answer:
        "You can earn yield on HedVault by staking your RWAs and receiving reward tokens. These rewards are distributed directly to your Hedera wallet through the HedVault platform, providing periodic income from your tokenized assets.",
    },
    {
      question: "How do I tokenize my real-world assets?",
      answer:
        "HedVault provides a straightforward process for tokenizing real-world assets. You can upload your asset details, set the token parameters, and our platform will handle the tokenization process using Hedera Token Service (HTS).",
    },
    {
      question: "What industries can benefit from RWA tokenization?",
      answer:
        "RWA tokenization can benefit a wide range of industries, including real estate, commodities, art, and more. HedVault offers solutions tailored to each industry's needs, enabling the integration of DeFi functionalities with real-world assets.",
    },
    {
      question: "How is my investment on HedVault secure?",
      answer:
        "Yes, security is paramount at HedVault. We utilize Hedera Hashgraph's bank-grade security and robust consensus mechanism. All RWAs are backed by real-world assets held by regulated custodians with strict KYC/AML compliance.",
    },
    {
      question: "Can I trade my tokenized RWAs on other exchanges?",
      answer:
        "Yes, you can trade your tokenized RWAs on other exchanges that support Hedera Hashgraph. HedVault facilitates seamless integration with various DeFi platforms, allowing you to maximize the value of your tokenized assets.",
    },
  ]

  const toggleFAQ = (index: number) => {
    setOpenIndex(openIndex === index ? null : index)
  }

  return (
    <section className="bg-black py-20 md:py-32">
      <div className="container mx-auto px-6 md:px-8 lg:px-12">
        {/* Header */}
        <div className="text-center mb-16">
          {/* Badge */}
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-gray-700 bg-gray-900/50 backdrop-blur-sm mb-8">
            <span className="text-sm font-medium text-green-400">FAQ</span>
          </div>

          {/* Heading */}
          <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold text-white mb-6 leading-tight">
            Get Answers To Common Questions
          </h2>

          {/* Description */}
          <p className="text-lg md:text-xl text-gray-400 leading-relaxed max-w-3xl mx-auto">
            Everything you need to know about interacting with tokenized RWAs.
          </p>
        </div>

        {/* FAQ Items */}
        <div className="max-w-4xl mx-auto space-y-4">
          {faqs.map((faq, index) => (
            <div
              key={index}
              className="border border-gray-800 rounded-lg bg-gray-900/30 backdrop-blur-sm overflow-hidden"
            >
              <button
                onClick={() => toggleFAQ(index)}
                className="w-full px-6 py-6 text-left flex items-center justify-between hover:bg-gray-800/50 transition-colors duration-200"
              >
                <span className="text-lg md:text-xl font-medium text-white pr-4">{faq.question}</span>
                {openIndex === index ? (
                  <Minus className="w-6 h-6 text-green-400 flex-shrink-0" />
                ) : (
                  <Plus className="w-6 h-6 text-green-400 flex-shrink-0" />
                )}
              </button>
              {openIndex === index && (
                <div className="px-6 pb-6">
                  <p className="text-gray-400 leading-relaxed">{faq.answer}</p>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}