import React from "react";

import { getCountries, getCountryCallingCode } from "react-phone-number-input";
import enLocale from "react-phone-number-input/locale/en.json";

const countryOptions = getCountries().map((country) => ({
  country,
  name: enLocale[country as keyof typeof enLocale],
  code: `+${getCountryCallingCode(country)}`,
})).sort((a, b) => a.name.localeCompare(b.name));

// Prioritize some common countries at top
const priorityCodes = ["IN", "US", "AE", "GB", "AU", "SG", "QA"];
const sortedCountryOptions = [
  ...priorityCodes.map(code => countryOptions.find(c => c.country === code)).filter(Boolean) as typeof countryOptions,
  ...countryOptions.filter(c => !priorityCodes.includes(c.country))
];

interface PhoneInputWithCountryProps {
  label?: string;
  countryCode: string;
  onCountryCodeChange: (code: string) => void;
  value: string;
  onChange: (value: string) => void;
  error?: string;
  required?: boolean;
  disabled?: boolean;
  placeholder?: string;
}

export const PhoneInputWithCountry = React.forwardRef<HTMLInputElement, PhoneInputWithCountryProps>(
  ({ label, countryCode, onCountryCodeChange, value, onChange, error, required, disabled, placeholder }, ref) => {
    return (
      <div className="w-full">
        {label && (
          <label className="block text-sm font-semibold text-slate-700 mb-1.5">
            {label} {required && <span className="text-red-500">*</span>}
          </label>
        )}
        <div className="flex relative">
          <select
            value={countryCode || "+91"}
            onChange={(e) => onCountryCodeChange(e.target.value)}
            disabled={disabled}
            className={`
              pl-3 pr-8 py-2.5 bg-slate-50 border rounded-l-xl text-slate-700
              focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 shadow-sm
              ${error ? 'border-red-300' : 'border-slate-200 border-r-0'}
              ${disabled ? 'opacity-60 cursor-not-allowed' : ''}
              appearance-none font-medium
            `}
            style={{ width: '100px', backgroundImage: 'url("data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%23475569%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E")', backgroundRepeat: 'no-repeat', backgroundPosition: 'right 0.7rem top 50%', backgroundSize: '0.65rem auto' }}
          >
            {sortedCountryOptions.map((c) => (
              <option key={c.country} value={c.code}>
                {c.country} ({c.code})
              </option>
            ))}
            {!sortedCountryOptions.find(c => c.code === countryCode) && countryCode && (
               <option value={countryCode}>{countryCode}</option>
            )}
          </select>
          <input
            ref={ref}
            type="tel"
            value={value}
            onChange={(e) => onChange(e.target.value.replace(/[^0-9]/g, ''))}
            disabled={disabled}
            placeholder={placeholder || "10-digit number"}
            className={`
              block w-full px-4 py-2.5 bg-white border rounded-r-xl text-slate-900 placeholder-slate-400 
              focus:outline-none focus:ring-2 focus:border-transparent transition-all duration-200 shadow-sm
              ${error
                ? 'border-red-300 focus:ring-red-500 bg-red-50/50'
                : 'border-slate-200 focus:ring-blue-500 border-l-0'}
              ${disabled ? 'bg-slate-50 text-slate-500 cursor-not-allowed' : ''}
            `}
          />
        </div>
        {error && (
          <p className="mt-1.5 text-sm text-red-600 font-medium animate-in fade-in slide-in-from-top-1">
            {error}
          </p>
        )}
      </div>
    );
  }
);

PhoneInputWithCountry.displayName = "PhoneInputWithCountry";
