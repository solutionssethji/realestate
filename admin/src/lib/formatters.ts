export const formatDateTime = (dateValue: any) => {
  if (!dateValue) return "N/A";
  let date;

  try {
    if (typeof dateValue?.toDate === "function") {
      date = dateValue.toDate();
    } else if (typeof dateValue === "string" || typeof dateValue === "number") {
      date = new Date(dateValue);
    } else if (dateValue instanceof Date) {
      date = dateValue;
    }

    if (!date || isNaN(date.getTime())) return "N/A";

    return date.toLocaleString("en-US", {
      month: "short",
      day: "numeric",
      year: "numeric",
      hour: "numeric",
      minute: "2-digit",
      hour12: true,
    });
  } catch (e) {
    return "N/A";
  }
};

export const formatRelativeTime = (dateValue: any) => {
  if (!dateValue) return "Just now";
  let date;

  try {
    if (typeof dateValue?.toDate === "function") {
      date = dateValue.toDate();
    } else if (typeof dateValue === "string" || typeof dateValue === "number") {
      date = new Date(dateValue);
    } else if (dateValue instanceof Date) {
      date = dateValue;
    }

    if (!date || isNaN(date.getTime())) return "Just now";

    const now = new Date();
    const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);

    if (diffInSeconds < 60) return "Just now";
    if (diffInSeconds < 3600)
      return `${Math.floor(diffInSeconds / 60)} minutes ago`;
    if (diffInSeconds < 86400)
      return `${Math.floor(diffInSeconds / 3600)} hours ago`;
    if (diffInSeconds < 2592000)
      return `${Math.floor(diffInSeconds / 86400)} days ago`;
    if (diffInSeconds < 31536000)
      return `${Math.floor(diffInSeconds / 2592000)} months ago`;

    return `${Math.floor(diffInSeconds / 31536000)} years ago`;
  } catch (e) {
    return "Just now";
  }
};

export const formatCurrency = (amount: number) => {
  if (isNaN(amount)) return "₹0";
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
  }).format(amount);
};

export const numberToWords = (num: number): string => {
  if (num === 0) return "Zero";
  const a = [
    "",
    "One ",
    "Two ",
    "Three ",
    "Four ",
    "Five ",
    "Six ",
    "Seven ",
    "Eight ",
    "Nine ",
    "Ten ",
    "Eleven ",
    "Twelve ",
    "Thirteen ",
    "Fourteen ",
    "Fifteen ",
    "Sixteen ",
    "Seventeen ",
    "Eighteen ",
    "Nineteen ",
  ];
  const b = [
    "",
    "",
    "Twenty",
    "Thirty",
    "Forty",
    "Fifty",
    "Sixty",
    "Seventy",
    "Eighty",
    "Ninety",
  ];
  const numStr = ("000000000" + num)
    .slice(-9)
    .match(/^(\d{2})(\d{2})(\d{2})(\d{1})(\d{2})$/);
  if (!numStr) return "";
  let str = "";
  str +=
    numStr[1] != "00"
      ? (a[Number(numStr[1])] ||
          b[Number(numStr[1][0])] + " " + a[Number(numStr[1][1])]) + "Crore "
      : "";
  str +=
    numStr[2] != "00"
      ? (a[Number(numStr[2])] ||
          b[Number(numStr[2][0])] + " " + a[Number(numStr[2][1])]) + "Lakh "
      : "";
  str +=
    numStr[3] != "00"
      ? (a[Number(numStr[3])] ||
          b[Number(numStr[3][0])] + " " + a[Number(numStr[3][1])]) + "Thousand "
      : "";
  str +=
    numStr[4] != "0"
      ? (a[Number(numStr[4])] ||
          b[Number(numStr[4][0])] + " " + a[Number(numStr[4][1])]) + "Hundred "
      : "";
  str +=
    numStr[5] != "00"
      ? (str != "" ? "and " : "") +
        (a[Number(numStr[5])] ||
          b[Number(numStr[5][0])] + " " + a[Number(numStr[5][1])])
      : "";
  return str.trim();
};
