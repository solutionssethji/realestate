"use client";

import React, { createContext, useContext, useState, useEffect } from 'react';
import enTranslations from '../locales/en.json';
import hiTranslations from '../locales/hi.json';

type Language = 'en' | 'hi';
type Translations = Record<string, string>;

interface LanguageContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
  t: (key: string, params?: Record<string, string>) => string;
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export const LanguageProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [language, setLanguage] = useState<Language>('en');
  const englishTranslations = enTranslations as Translations;
  const hindiTranslations = hiTranslations as Translations;
  const [translations, setTranslations] = useState<Translations>(englishTranslations);

  useEffect(() => {
    // Load saved language from local storage on mount
    const savedLang = localStorage.getItem('admin_lang') as Language;
    if (savedLang && (savedLang === 'en' || savedLang === 'hi')) {
      setLanguage(savedLang);
    }
  }, []);

  useEffect(() => {
    setTranslations(language === 'en' ? englishTranslations : hindiTranslations);
    localStorage.setItem('admin_lang', language);
  }, [language]);

  const t = (key: string, params?: Record<string, string>): string => {
    let str = translations[key] || englishTranslations[key] || key;
    if (params) {
      Object.entries(params).forEach(([k, v]) => {
        str = str.replace(`{${k}}`, v);
      });
    }
    return str;
  };

  return (
    <LanguageContext.Provider value={{ language, setLanguage, t }}>
      {children}
    </LanguageContext.Provider>
  );
};

export const useLanguage = () => {
  const context = useContext(LanguageContext);
  if (context === undefined) {
    throw new Error('useLanguage must be used within a LanguageProvider');
  }
  return context;
};
