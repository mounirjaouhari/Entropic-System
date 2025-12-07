import React from 'react';

interface CardProps {
  children: React.ReactNode;
  className?: string;
  padding?: 'sm' | 'md' | 'lg';
  shadow?: boolean;
  border?: boolean;
}

const Card: React.FC<CardProps> = ({
  children,
  className = '',
  padding = 'md',
  shadow = true,
  border = false,
}) => {
  const paddingStyles = {
    sm: 'p-3',
    md: 'p-6',
    lg: 'p-8',
  };

  const shadowStyles = shadow ? 'shadow-lg' : '';
  const borderStyles = border ? 'border border-gray-200' : '';

  const finalClassName = `bg-white rounded-lg ${paddingStyles[padding]} ${shadowStyles} ${borderStyles} ${className}`;

  return <div className={finalClassName}>{children}</div>;
};

export default Card;