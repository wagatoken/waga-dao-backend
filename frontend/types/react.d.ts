/// <reference types="react" />

declare namespace React {
  interface FormEvent<T = Element> {
    preventDefault(): void;
    target: T;
  }
}

declare module 'react' {
  export = React;
  export as namespace React;
}

declare module 'lucide-react' {
  export interface IconProps {
    className?: string;
    size?: number | string;
    [key: string]: any;
  }
  
  export const Shield: React.FC<IconProps>;
  export const Upload: React.FC<IconProps>;
  export const CheckCircle: React.FC<IconProps>;
  export const XCircle: React.FC<IconProps>;
  export const Clock: React.FC<IconProps>;
  export const Search: React.FC<IconProps>;
  export const RefreshCw: React.FC<IconProps>;
  export const BarChart3: React.FC<IconProps>;
  export const FileText: React.FC<IconProps>;
  export const Zap: React.FC<IconProps>;
  export const AlertTriangle: React.FC<IconProps>;
  export const Info: React.FC<IconProps>;
}
