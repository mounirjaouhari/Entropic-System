import React from 'react';

interface HeaderProps {
  title: string;
  subtitle?: string;
  actions?: React.ReactNode;
  className?: string;
}

const Header: React.FC<HeaderProps> = ({ title, subtitle, actions, className = '' }) => {
  return (
    <div className={`bg-white shadow p-6 rounded-lg mb-6 flex items-center justify-between ${className}`}>
      <div className="flex-1">
        <h1 className="text-3xl font-bold text-gray-900">{title}</h1>
        {subtitle && <p className="text-gray-600 mt-1">{subtitle}</p>}
      </div>
      {actions && <div className="flex gap-3">{actions}</div>}
    </div>
  );
};

export default Header;