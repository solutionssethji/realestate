import { NextResponse } from "next/server";

const allowedHosts = new Set([
  "firebasestorage.googleapis.com",
  "storage.googleapis.com",
]);

export async function GET(request: Request) {
  const sourceUrl = new URL(request.url).searchParams.get("url");
  if (!sourceUrl) {
    return NextResponse.json({ message: "Missing site layout URL" }, { status: 400 });
  }

  let parsedUrl: URL;
  try {
    parsedUrl = new URL(sourceUrl);
  } catch {
    return NextResponse.json({ message: "Invalid site layout URL" }, { status: 400 });
  }

  if (parsedUrl.protocol !== "https:" || !allowedHosts.has(parsedUrl.hostname)) {
    return NextResponse.json({ message: "Unsupported site layout host" }, { status: 400 });
  }

  const response = await fetch(parsedUrl);
  if (!response.ok) {
    return NextResponse.json({ message: "Unable to fetch site layout" }, { status: response.status });
  }

  return new NextResponse(await response.arrayBuffer(), {
    headers: {
      "Content-Type": response.headers.get("content-type") || "image/jpeg",
      "Cache-Control": "private, max-age=300",
    },
  });
}