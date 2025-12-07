import React from 'react';

interface LoaderProps {
  size?: 'sm' | 'md' | 'lg';
  message?: string;
  fullScreen?: boolean;
}

const Loader: React.FC<LoaderProps> = ({ size = 'md', message, fullScreen = false }) => {
  const sizeStyles = {
    sm: 'w-4 h-4',
    md: 'w-8 h-8',
    lg: 'w-12 h-12',
  };

  const spinner = (
    <div className={`inline-block animate-spin rounded-full border-b-2 border-blue-600 ${sizeStyles[size]}`} />
  );

  if (fullScreen) {
    return (
      <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
        <div className="bg-white rounded-lg p-8 shadow-lg">
          {spinner}
          {message && <p className="mt-4 text-gray-700 text-center">{message}</p>}
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col items-center justify-center">
      {spinner}
      {message && <p className="mt-2 text-gray-700 text-center">{message}</p>}
    </div>
  );
};

export default Loader;