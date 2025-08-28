const lucide = require('lucide-react');

const icons = ['Coffee', 'Menu', 'X', 'ChevronDown', 'ArrowLeft', 'ArrowRight', 'Check', 'Circle'];
icons.forEach(icon => {
  console.log(`${icon}: ${!!lucide[icon]}`);
});
