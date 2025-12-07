/**
 * User Interface
 * Represents a user in the system
 */
export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  username: string;
  avatar?: string;
  createdAt: string;
  updatedAt: string;
}

/**
 * OrderItem Interface
 * Represents a single item within an order
 */
export interface OrderItem {
  id: string;
  productId: string;
  productName: string;
  quantity: number;
  price: number;
  total: number;
  description?: string;
}

/**
 * Order Interface
 * Represents a complete order with items
 */
export interface Order {
  id: string;
  userId: string;
  items: OrderItem[];
  subtotal: number;
  tax: number;
  shippingCost: number;
  total: number;
  status: 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled';
  shippingAddress: string;
  createdAt: string;
  updatedAt: string;
}

/**
 * ApiResponse Interface
 * Standard API response wrapper
 */
export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data?: T;
  error?: {
    code: string;
    details?: string;
  };
  timestamp: string;
}

/**
 * PaginatedResponse Interface
 * Wrapper for paginated API responses
 */
export interface PaginatedResponse<T> {
  success: boolean;
  message: string;
  data: T[];
  pagination: {
    currentPage: number;
    pageSize: number;
    totalItems: number;
    totalPages: number;
    hasNextPage: boolean;
    hasPreviousPage: boolean;
  };
  timestamp: string;
}
