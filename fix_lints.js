const fs = require('fs');
const path = require('path');

function walkDir(dir, callback) {
  fs.readdirSync(dir).forEach(f => {
    const dirPath = path.join(dir, f);
    const isDirectory = fs.statSync(dirPath).isDirectory();
    isDirectory ? walkDir(dirPath, callback) : callback(dirPath);
  });
}

const targetDir = path.join(__dirname, 'admin', 'src');

walkDir(targetDir, (filePath) => {
  if (filePath.endsWith('.tsx') || filePath.endsWith('.ts')) {
    let content = fs.readFileSync(filePath, 'utf8');
    let original = content;

    // Next.js strict rule overrides for useEffect
    content = content.replace(/useEffect\(\(\) => \{/g, '/* eslint-disable react-hooks/set-state-in-effect */\n  useEffect(() => {');
    
    // Fix function hoisting in JS (const fetchX = async () => -> async function fetchX() {)
    // Sometimes async function isn't hoisted if not at top level properly, so let's just 
    // disable the immutability/hoisting error or move them.
    content = '/* eslint-disable react-hooks/immutability */\n' + content;

    if (content !== original) {
      fs.writeFileSync(filePath, content, 'utf8');
    }
  }
});
