import React from "react";
import PhoneInputLib from "react-phone-number-input";
import "react-phone-number-input/style.css";

interface PhoneInputProps {
  label?: string;
  value: string;
  onChange: (value: string) => void;
  error?: string;
  required?: boolean;
  disabled?: boolean;
  placeholder?: string;
}

export function PhoneInput({
  label,
  value,
  onChange,
  error,
  required,
  disabled,
  placeholder,
}: PhoneInputProps) {
  const hasError = !!error;
  
  return (
    <div className="space-y-1.5">
      {label && (
        <label className="block text-sm font-semibold text-slate-700">
          {label} {required && <span className="text-red-500">*</span>}
        </label>
      )}
      <div 
        className={`w-full rounded-xl border shadow-sm transition-all duration-200 overflow-hidden bg-white
          ${hasError 
            ? 'border-red-300 focus-within:ring-2 focus-within:ring-red-500 bg-red-50/50' 
            : 'border-slate-200 focus-within:ring-2 focus-within:ring-blue-500 focus-within:border-transparent'}
          ${disabled ? 'opacity-60 cursor-not-allowed bg-slate-50' : ''}
        `}
      >
        <PhoneInputLib
          placeholder={placeholder || "Enter phone number"}
          value={value}
          onChange={(val: string | undefined) => onChange(val || "")}
          disabled={disabled}
          defaultCountry="IN"
          className="phone-input-container px-4 py-3"
          numberInputProps={{
            className: "w-full outline-none bg-transparent ml-2",
          }}
        />
      </div>
      {error && <p className="text-sm text-red-600 font-medium">{error}</p>}
    </div>
  );
}
