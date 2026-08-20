import React from 'react';
import en from '../locales/en.json';

export function useTranslation() {
  return {
    t: (key: keyof typeof en) => en[key] || key,
  };
}
