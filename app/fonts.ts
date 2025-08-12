import { Inter, Sora } from "next/font/google";

export const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});

export const sora = Sora({
  subsets: ["latin"],
  variable: "--font-sora",
  weight: ["400","500","600","700"],
  display: "swap",
});
